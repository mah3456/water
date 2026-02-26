import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:water/presentation/views/clients/client_details_screen.dart';
import 'package:water/presentation/views/readings/add_reading_screen.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/client_model.dart';
import '../../../wigets/client_card.dart';
import '../../controllers/ClientsController.dart';
import '../../controllers/auth_controller.dart';
import 'add_client_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final ClientsController client = Get.put(ClientsController());
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final AuthController _authController = Get.find<AuthController>(); // إضافة AuthController

  List<ClientModel> _filteredClients = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      client.loadClients();
      _checkInitialConnection();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkInitialConnection() async {
    final hasConnection = await _authController.checkInternetConnection();
    if (!hasConnection) {
      Helpers.showErrorSnackBar('لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك');
      return;
    }
  }
  
  Future<void> _refresh() async {
    try {
      _checkInitialConnection();
      client.isLoading.value = true;
      await client.loadClients();
    } finally {
      client.isLoading.value = false;
    }
  }

  Future<void> _refreshData() async {
    _checkInitialConnection();
    print(_authController.isConnected.value);
    await client.loadClients();
    setState(() {
      _filteredClients = _searchController.text.isEmpty
          ? client.clients
          : client.searchClients(_searchController.text);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filteredClients = client.clients;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(

        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right),
          onPressed: () => Get.back(),
        ),

        title: const Text(
          'قائمة العملاء',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Iconsax.refresh, color: Colors.white),
            tooltip: 'تحديث',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _buildSearchBar(theme),
          ),
        ),
      ),

      floatingActionButton:  FloatingActionButton.extended(
        backgroundColor: theme.primaryColor,
        onPressed: () => _authController.isConnected.value? Get.toNamed('/add-client') : _checkInitialConnection(),
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: const Text(
          'إضافة عميل',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 4,
      ),

      body: Obx(() {
        return RefreshIndicator(
          onRefresh: _refresh,
          color: theme.primaryColor,
          child: Stack(
            children: [
              _buildContent(theme),
              if (client.isLoading.value)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                    minHeight: 2,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'ابحث بالاسم، رقم الهاتف، أو رقم العداد',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: const Icon(Iconsax.search_normal, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            onPressed: _clearSearch,
            icon: const Icon(Iconsax.close_circle, color: Colors.grey),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onChanged: (value) {
          setState(() {
            _filteredClients = client.searchClients(value);
            _isSearching = value.isNotEmpty;
          });
        },
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 8),

        // إحصائيات سريعة
        _buildStatsSection(theme),

        const SizedBox(height: 16),

        // عنوان القائمة
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'قائمة العملاء',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_getDisplayClients().length}',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const Spacer(),
              if (_isSearching)
                TextButton(
                  onPressed: _clearSearch,
                  child: const Text('إلغاء البحث'),
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // عرض العملاء
        Expanded(
          child: Obx(() {
            final allClients = client.clients;
            final isLoading = client.isLoading.value;

            if (_searchController.text.isEmpty && _filteredClients.isEmpty) {
              _filteredClients = allClients;
            }

            if (isLoading && allClients.isEmpty) {
              return _buildLoadingState(theme);
            }

            final displayClients = _getDisplayClients();

            if (displayClients.isEmpty) {
              return _buildEmptyState(theme);
            }

            return _buildClientsList(displayClients);
          }),
        ),
      ],
    );
  }

  Widget _buildStatsSection(ThemeData theme) {
    final totalClients = client.clients.length;
    final activeClients = client.clients.where((c) => (c.totalDebt ?? 0) > 0).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Iconsax.people,
            value: '$totalClients',
            label: 'إجمالي العملاء',
            color: Colors.white,
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.white.withOpacity(0.3),
          ),
          _buildStatItem(
            icon: Iconsax.wallet,
            value: '$activeClients',
            label: 'نشط',
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color.withOpacity(0.9), size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.primaryColor,
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            'جاري تحميل بيانات العملاء...',
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),

              child: Icon(
                _searchController.text.isEmpty ? Iconsax.people : Iconsax.search_normal,
                size: 80,
                color: theme.primaryColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _searchController.text.isEmpty
                  ? 'لا يوجد عملاء حالياً'
                  : 'لا توجد نتائج للبحث',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isEmpty
                  ? 'قم بإضافة عميل جديد للبدء'
                  : 'حاول استخدام كلمات بحث مختلفة',
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            if (_searchController.text.isEmpty)
              ElevatedButton.icon(
                onPressed: () => Get.toNamed('/add-client'),
                icon: const Icon(Iconsax.add),
                label: const Text('إضافة عميل جديد'),
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
      ),
    );
  }

  Widget _buildClientsList(List<ClientModel> clients) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      itemCount: clients.length,
      itemBuilder: (context, index) {
        final client = clients[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClientCard(
            client: client,
            onTap: () {
              _authController.isConnected.value ? Get.to(() => ClientDetailsScreen(client: client.id ?? 0)): _checkInitialConnection();
            },
            onLongPress: () {
              _checkInitialConnection();
             _authController.isConnected.value? _showClientOptions(context, client) : null;
            },
          ),
        );
      },
    );
  }

  List<ClientModel> _getDisplayClients() {
    return _searchController.text.isNotEmpty ? _filteredClients : client.clients;
  }

  void _showClientOptions(BuildContext context, ClientModel client) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Iconsax.edit, color: theme.primaryColor),
                ),
                title: const Text(
                  'تعديل البيانات',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Get.to(
                    AddClientScreen(
                      client: ClientModel(
                        id: client.id,
                        name: client.name,
                        createdBy: client.createdBy,
                        totalDebt: client.totalDebt,
                        currentBill: client.currentBill,
                        phone: client.phone,
                        address: client.address,
                        meterNumber: client.meterNumber,
                        createdAt: client.createdAt,
                        notes: client.notes,
                      ),
                    ),
                    transition: Transition.fadeIn,
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Iconsax.receipt, color: Colors.green),
                ),
                title: const Text(
                  'إضافة قراءة جديدة',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Get.to(AddReadingScreen(
                    client: ClientModel(
                      id: client.id,
                      name: client.name,
                      createdBy: client.createdBy,
                      totalDebt: client.totalDebt,
                      currentBill: client.currentBill,
                      phone: client.phone,
                      address: client.address,
                      meterNumber: client.meterNumber,
                      createdAt: client.createdAt,
                      notes: client.notes,
                    ),
                  ));
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Iconsax.money, color: Colors.blue),
                ),
                title: const Text(
                  'تسديد فاتورة',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/pay-bill', arguments: client.id);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Iconsax.trash, color: Colors.red),
                ),
                title: const Text(
                  'حذف العميل',
                  style: TextStyle(fontWeight: FontWeight.w500, color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteDialog(client);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeleteDialog(ClientModel client) async {
    final theme = Theme.of(context);

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('حذف العميل'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل أنت متأكد من حذف العميل "${client.name}"؟'),
            const SizedBox(height: 8),
            Text(
              'سيتم حذف جميع الفواتير والقراءات المرتبطة بهذا العميل.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade700,
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.transparent,
              overlayColor: Colors.transparent,
            ),
            child: const Text('إلغاء' ,style: TextStyle(color: Colors.grey),),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.transparent,
              overlayColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('حذف' , style: TextStyle(color: Colors.red),),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await this.client.deleteClient(id: client.id!);
        if (success > 0) {
          Get.snackbar(
            'تم الحذف',
            'تم حذف العميل بنجاح',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            borderRadius: 8,
            margin: const EdgeInsets.all(16),
            icon: const Icon(Iconsax.tick_circle, color: Colors.white),
          );
          await _refreshData();
        }
      } catch (e) {
        Get.snackbar(
          'خطأ',
          'فشل في حذف العميل',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          borderRadius: 8,
          margin: const EdgeInsets.all(16),
          icon: const Icon(Iconsax.close_circle, color: Colors.white),
        );
      }
    }
  }
}