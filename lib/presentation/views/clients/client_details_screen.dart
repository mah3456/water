import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:water/data/models/client_model.dart';
import 'package:water/presentation/views/clients/add_client_screen.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/reading_model.dart';
import '../../controllers/ClientsController.dart';
import '../../controllers/ReadingController.dart';
import '../readings/add_reading_screen.dart';

class ClientDetailsScreen extends StatefulWidget {
  const ClientDetailsScreen({super.key, required this.client});

  final int client;

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  final ClientsController _clientController = Get.find<ClientsController>();
  final ReadingsController _readingsController = Get.find<ReadingsController>();

  // متغير محلي للتحكم في تحميل هذه الشاشة
  final RxBool _screenLoading = true.obs;
  final RxBool _refreshLoading = false.obs;


  @override
  void initState() {
    super.initState();
    _loadClientDetails();
  }

  Future<void> _loadClientDetails() async {
    await _readingsController.loadClientReadings(clientId: widget.client);
    await _clientController.loadClient(clientId: widget.client);
    _clientController.isLoading.value = false;
    _screenLoading.value = false;
  }




  //
  // @override
  // void initState() {
  //   super.initState();
  //   _loadInitialData();
  // }
  //
  // Future<void> _loadInitialData() async {
  //   try {
  //     _screenLoading.value = true;
  //     await _loadClientDetails();
  //   } finally {
  //     _screenLoading.value = false;
  //   }
  // }
  //
  // Future<void> _loadClientDetails() async {
  //   // تحميل البيانات بالتوازي لتقليل وقت الانتظار
  //   await Future.wait([
  //     _readingsController.loadClientReadings(clientId: widget.client),
  //     _clientController.loadClient(clientId: widget.client),
  //   ]);
  // }

  Future<void> _refreshData() async {
    try {
      _refreshLoading.value = true;
      await _loadClientDetails();
    } finally {
      _refreshLoading.value = false;
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(


      appBar: AppBar(),



      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Obx(() {
        // إخفاء FAB أثناء التحميل
        if (_screenLoading.value || _refreshLoading.value) {
          return Container();
        }
        return SpeedDial(
          iconTheme: const IconThemeData(color: Colors.white),
          animationDuration: const Duration(milliseconds: 100),
          renderOverlay: false,
          useRotationAnimation: true,
          icon: Icons.menu,
          activeIcon: Icons.close,
          spacing: 10,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.receipt),
              onTap: () {
                Get.to(AddReadingScreen(
                  client:  ClientModel(
                    id: _clientController.client.id,
                    name: _clientController.client.name,
                    createdBy: _clientController.client.createdBy,
                    totalDebt: _clientController.client.totalDebt,
                    currentBill: _clientController.client.currentBill,
                    phone: _clientController.client.phone,
                    address: _clientController.client.address,
                    meterNumber: _clientController.client.meterNumber,
                    createdAt: _clientController.client.createdAt,
                    notes: _clientController.client.notes,
                  ),
                )
                );
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.payments_outlined),
              onTap: () => Get.toNamed(
                '/pay-bill',
                arguments: _clientController.client.id,
              ),
            ),
            SpeedDialChild(
              child: const Icon(Icons.edit),
              onTap: () => Get.to(
                AddClientScreen(
                  client: ClientModel(
                    id: _clientController.client.id,
                    name: _clientController.client.name,
                    createdBy: _clientController.client.createdBy,
                    totalDebt: _clientController.client.totalDebt,
                    currentBill: _clientController.client.currentBill,
                    phone: _clientController.client.phone,
                    address: _clientController.client.address,
                    meterNumber: _clientController.client.meterNumber,
                    createdAt: _clientController.client.createdAt,
                    notes: _clientController.client.notes,
                  ),
                ),
              ),
            ),
          ],
        );
      }),

      body: Obx(() {
        // تحميل الشاشة الأولى
        if (_screenLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary ),
                const SizedBox(height: 16),
                const Text('جاري تحميل بيانات العميل...'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: Stack(
            children: [
              _buildContent(),
              // مؤشر التحميل أثناء التحديث
              if (_refreshLoading.value)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    minHeight: 3,
                  ),
                ),
            ],
          ),
        );

      }),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // تفاصيل العميل
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    'الاسم:',
                    _clientController.client.name,
                  ),
                  _buildDetailRow(
                    'الهاتف:',
                    _clientController.client.phone,
                  ),
                  _buildDetailRow(
                    'العنوان:',
                    _clientController.client.address,
                  ),
                  _buildDetailRow(
                    'رقم العداد:',
                    _clientController.client.meterNumber,
                  ),
                  if (_clientController.client.notes != null)
                    _buildDetailRow(
                      'ملاحظات:',
                      _clientController.client.notes!,
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildAmountCard(
                        title: 'إجمالي الدين',
                        amount: _clientController.client.totalDebt,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 16),
                      _buildAmountCard(
                        title: 'الفاتورة الحالية',
                        amount: _clientController.client.currentBill,
                        color: Colors.blueGrey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            'سجل القراءات',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),
          Obx(() {
            if (_readingsController.isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (_readingsController.readings.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('لا توجد قراءات سابقة'),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _readingsController.readings.length,
              itemBuilder: (context, index) {
                final reading = _readingsController.readings[index];
                return _buildReadingCard(reading);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildAmountCard({
    required String title,
    required double amount,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                Helpers.formatCurrency(amount),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadingCard(ReadingModel reading) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      Helpers.formatDate(reading.readingDate),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),

                Chip(
                  shape: const BeveledRectangleBorder(
                    side: BorderSide(color: Colors.transparent),
                  ),
                  label: Text(
                    reading.isPaid ? 'مدفوع' : 'غير مدفوع',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: reading.isPaid ? Colors.green : Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildReadingInfo('السابق', reading.previousReading.toString()),
                _buildReadingInfo('الحالي', reading.currentReading.toString()),
                _buildReadingInfo('الاستهلاك', '${reading.consumption} وحده'),
              ],
            ),

            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      ' السعر |  ${Helpers.formatCurrency(double.parse(reading.consumption.toString()) * 1200.0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'الباقي | ${Helpers.formatCurrency(reading.remainingAmount ?? 0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Text(
                          'قراءة | ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: 'cairo',
                            letterSpacing: 1,

                          ),
                        ),
                        Text(
                          reading.reader.toString(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontFamily: 'cairo',
                          ),
                        ),
                      ],

                    ),
                    const SizedBox(height: 10),
                    Row(
                        children: [
                          const Text(
                            'تسديد | ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              fontFamily: 'cairo',
                              letterSpacing: 1,

                            ),
                          ),
                          Text(
                            reading.payby.toString(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontFamily: 'cairo',
                            ),
                          ),
                        ],

                    ),
                  ],
                ),

                IconButton(
                  onPressed: () => Helpers.showDeleteDialog(
                    context: context,
                    content: const Text('هل أنت متأكد من حذف هذه الفاتورة؟'),
                    delete: () async {
                      final res = await _readingsController.delete(
                        readingId: reading.id!,
                      );

                      if (res) {
                        await _refreshData();
                        Helpers.customSnackBar(
                          title: 'تم',
                          message: 'تم حذف الفاتورة',
                          background: CupertinoColors.systemGreen,
                        );
                      } else {
                        Helpers.customSnackBar(
                          title: 'فشل',
                          message: 'فشل حذف الفاتورة',
                          background: Colors.red,
                        );
                      }
                    },
                  ),
                  color: Colors.transparent,
                  icon: const Icon(Icons.delete , color: Colors.red,),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}