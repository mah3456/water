import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:water/data/models/client_model.dart';
import 'package:water/presentation/views/clients/add_client_screen.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/reading_model.dart';
import '../../controllers/ClientsController.dart';
import '../../controllers/ReadingController.dart';
import '../../controllers/auth_controller.dart';
import '../readings/add_reading_screen.dart';

class ClientDetailsScreen extends StatefulWidget {
  const ClientDetailsScreen({super.key, required this.client});

  final int client;

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen>
    with SingleTickerProviderStateMixin {
  final ClientsController _clientController = Get.find<ClientsController>();
  final ReadingsController _readingsController = Get.find<ReadingsController>();
  final AuthController _authController = Get.find<AuthController>();

  late TabController _tabController;
  final RxBool _isInitialized = false.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // تأخير تحميل البيانات حتى بعد اكتمال البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClientDetails();
      _checkInitialConnection();

    });


  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadClientDetails() async {
    try {

      final hasConnection = await _authController.checkInternetConnection();
      if (!hasConnection) {
        Helpers.showErrorSnackBar('لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك');
        return;
      }
      await Future.wait([
        _readingsController.loadClientReadings(clientId: widget.client),
        _clientController.loadClient(clientId: widget.client),
      ]);
    } finally {
      _isInitialized.value = true;
    }
  }

  Future<void> _refreshData() async {
    try {
      await _loadClientDetails();
    } catch (e) {
      print('Error refreshing: $e');
    }
  }

  Future<void> _checkInitialConnection() async {
    final hasConnection = await _authController.checkInternetConnection();
    if (!hasConnection) {
      Helpers.showErrorSnackBar('لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,

        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          final client = _clientController.selectedClient.value;
          return Text(
            client?.name ?? 'تفاصيل العميل',
            style: const TextStyle(fontWeight: FontWeight.bold),
          );
        }),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'المعلومات', icon: Icon(Iconsax.profile_circle)),
            Tab(text: 'القراءات', icon: Icon(Iconsax.receipt)),
          ],
        ),
      ),


      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Obx(() {
        if (!_isInitialized.value || _clientController.selectedClient.value == null) {
          return Container();
        }

        return SpeedDial(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          icon: Iconsax.more,
          activeIcon: Iconsax.close_circle5,
          spacing: 10,
          spaceBetweenChildren: 8,
          overlayOpacity: 0.0,
          children: [
            SpeedDialChild(
              child: const Icon(Iconsax.receipt),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              label: 'إضافة قراءة',
              onTap: () {
                _checkInitialConnection();
              _authController.isConnected.value? Get.to(
                   AddReadingScreen(client: _clientController.selectedClient.value,)
               ):null;
              },
            ),

            SpeedDialChild(
              child: const Icon(Iconsax.money),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              label: 'تسديد فاتورة',
              onTap: () {
                _checkInitialConnection();
                Get.toNamed(
                '/pay-bill',
                arguments: _clientController.selectedClient.value?.id ?? 0,
              );
              },
            ),


            SpeedDialChild(
              child: const Icon(Iconsax.edit),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              label: 'تعديل البيانات',
              onTap: () {
                _checkInitialConnection();
               _authController.isConnected.value? Get.to(
                AddClientScreen(
                  client: _clientController.selectedClient.value ?? ClientModel(name: 'name', phone: 'phone', address: 'address', meterNumber: 'meterNumber', createdAt: DateTime.now()),
                ),
              ):null;


                },
            ),
          ],
        );
      }),

      body: Obx(() {
        if (!_isInitialized.value) {
          return _buildLoadingState(theme);
        }

        return RefreshIndicator(
          onRefresh: _refreshData,
          color: theme.primaryColor,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildInfoTab(theme),
              _buildReadingsTab(theme),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: CircularProgressIndicator(
              color: theme.primaryColor,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'جاري تحميل بيانات العميل...',
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab(ThemeData theme) {
    final client = _clientController.selectedClient.value;

    if (client == null) {
      return const Center(child: Text('لا توجد بيانات'));
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // بطاقة المعلومات الشخصية
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.profile_circle,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  client.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'رقم العداد: ${client.meterNumber}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // بطاقات المبالغ
          Row(
            children: [
              Expanded(
                child: _buildAmountCard(
                  title: 'إجمالي الدين',
                  amount: client.totalDebt ?? 0,
                  icon: Iconsax.money,
                  color: Colors.red,
                  gradient: const [Color(0xFFFF6B6B), Color(0xFFEE5253)],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAmountCard(
                  title: 'الفاتورة الحالية',
                  amount: client.currentBill ?? 0,
                  icon: Iconsax.receipt,
                  color: Colors.blue,
                  gradient: const [Color(0xFF4A90E2), Color(0xFF357ABD)],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // معلومات الاتصال
          _buildInfoCard(
            icon: Iconsax.call,
            title: 'معلومات الاتصال',
            children: [
              _buildInfoRow('الهاتف', client.phone ?? 'غير محدد', Iconsax.call),
              _buildInfoRow('العنوان', client.address ?? 'غير محدد', Iconsax.location),
            ],
          ),

          const SizedBox(height: 12),

          // ملاحظات
          if (client.notes != null && client.notes!.isNotEmpty)
            _buildInfoCard(
              icon: Iconsax.note,
              title: 'ملاحظات',
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    client.notes!,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            Helpers.formatCurrency(amount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingsTab(ThemeData theme) {
    return Obx(() {
      if (_readingsController.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: theme.primaryColor),
              const SizedBox(height: 16),
              Text('جاري تحميل القراءات...'),
            ],
          ),
        );
      }

      if (_readingsController.readings.isEmpty) {
        return _buildEmptyReadings(theme);
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _readingsController.readings.length,
        itemBuilder: (context, index) {
          final reading = _readingsController.readings[index];
          return _buildReadingCard(reading, theme);
        },
      );
    });
  }

  Widget _buildEmptyReadings(ThemeData theme) {
    final client = _clientController.selectedClient.value;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.receipt,
              size: 60,
              color: theme.primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد قراءات سابقة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'قم بإضافة أول قراءة لهذا العميل',
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.to(AddReadingScreen(
              client: client,
            )),
            icon: const Icon(Iconsax.add),
            label: const Text('إضافة قراءة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingCard(ReadingModel reading, ThemeData theme) {
    final consumption = (reading.currentReading ?? 0) - (reading.previousReading ?? 0);
    final amount = consumption * 1200;
    final subscription = reading.subscription == 1 ? 300.0 : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 1 , color: Color(0x0ff3c56c)),

      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: reading.isPaid ? Colors.green : Colors.orange,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    reading.isPaid ? Iconsax.tick_circle : Iconsax.clock,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    Helpers.formatDate(reading.readingDate),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    reading.isPaid ? 'مدفوع' : 'غير مدفوع',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildReadingStat(
                      label: 'القراءة السابقة',
                      value: '${reading.previousReading ?? 0}',
                      icon: Iconsax.arrow_down,
                      color: Colors.blue,
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.grey.shade200,
                    ),
                    _buildReadingStat(
                      label: 'القراءة الحالية',
                      value: '${reading.currentReading ?? 0}',
                      icon: Iconsax.arrow_up,
                      color: Colors.green,
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.grey.shade200,
                    ),
                    _buildReadingStat(
                      label: 'الاستهلاك',
                      value: '$consumption',
                      icon: Iconsax.flash,
                      color: Colors.orange,
                    ),
                  ],
                ),

                const Divider(height: 24),

                // Details
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailChip(
                        label: 'قيمة الاستهلاك',
                        value: Helpers.formatCurrency(double.parse(amount.toString())),
                        icon: Iconsax.money,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDetailChip(
                        label: 'رسوم الاشتراك',
                        value: Helpers.formatCurrency(subscription),
                        icon: Iconsax.element_plus,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildDetailChip(
                        label: 'المتبقي',
                        value: Helpers.formatCurrency(reading.remainingAmount ?? 0),
                        icon: Iconsax.money_recive,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDetailChip(
                        label: 'الإجمالي',
                        value: Helpers.formatCurrency(amount + subscription),
                        icon: Iconsax.money_recive,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),

                const Divider(height: 24),

                // Footer with reader info and delete button
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPersonInfo(
                            icon: Iconsax.user,
                            label: 'قراءة',
                            value: reading.reader ?? 'غير محدد',
                          ),
                          const SizedBox(height: 8),
                          _buildPersonInfo(
                            icon: Iconsax.profile_2user,
                            label: 'تسديد',
                            value: reading.payby ?? 'غير محدد',
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => _showDeleteDialog(reading),
                        icon: const Icon(Iconsax.trash, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailChip({
    required String label,
    required String value,
    required IconData icon,
    Color color = Colors.blue,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(ReadingModel reading) {
    final theme = Theme.of(context);

    Get.dialog(
      AlertDialog(
        title: const Text('حذف الفاتورة'),
        content: Text('هل أنت متأكد من حذف فاتورة تاريخ ${Helpers.formatDate(reading.readingDate)}؟'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.transparent,
              overlayColor: Colors.transparent,
            ),
            child: const Text('إلغاء' ,style: TextStyle(color: Colors.grey),),
          ),
          TextButton(
            onPressed: () async {
                final hasConnection = await _authController.checkInternetConnection();
                if (!hasConnection) {
                  Helpers.showErrorSnackBar('لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك');
                  return;
                }


              Get.back();
              final res = await _readingsController.delete(readingId: reading.id!);
              if (res) {
                await _refreshData();

                // استخدام addPostFrameCallback لتأخير الـ Snackbar
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Get.snackbar(
                    'تم',
                    'تم حذف الفاتورة بنجاح',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                });
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Get.snackbar(
                    'فشل',
                    'فشل حذف الفاتورة',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.transparent,
              overlayColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('حذف' , style: TextStyle(color: Colors.red),),
          ),
        ],
      ),
    );
  }
}