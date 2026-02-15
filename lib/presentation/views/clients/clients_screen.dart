import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water/presentation/views/clients/client_details_screen.dart';
import 'package:water/presentation/views/readings/add_reading_screen.dart';
import '../../../data/models/client_model.dart';
import '../../../wigets/client_card.dart';
import '../../controllers/ClientsController.dart';
import 'add_client_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final ClientsController client = Get.put(ClientsController());

  final TextEditingController _searchController = TextEditingController();
  List<ClientModel> _filteredClients = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      client.loadClients();
    });
    // يمكنك تفعيل الاشتراك في التحديثات الحية هنا إذا أردت
    // _clientController.subscribeToRealtimeUpdates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      client.isLoading.value = true;
      await client.loadClients();
    } finally {
      client.isLoading.value = false;
    }
  }

  Future<void> _refreshData() async {
    await client.loadClients();
    setState(() {
      _filteredClients = _searchController.text.isEmpty ? client.clients : client.searchClients(_searchController.text);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة العملاء'),
        centerTitle: true,
        actions: [
          // زر تحديث البيانات
          IconButton(onPressed: _refreshData, icon: const Icon(Icons.refresh)),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CupertinoColors.systemBlue,
        onPressed: () {
          Get.toNamed('/add-client');
        },
        label: const Row(
          children: [
            Text('إضافة عميل', style: TextStyle(color: Colors.white)),
            SizedBox(width: 8),
            Icon(Icons.add, color: Colors.white),
          ],
        ),
      ),

      body: Obx(() {

        // if (client.isLoading.value) {
        //   return Center(
        //     child: Column(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary ),
        //         const SizedBox(height: 16),
        //         const Text('جاري تحميل بيانات العميل...'),
        //       ],
        //     ),
        //   );
        // }


        return RefreshIndicator(
          onRefresh: _refresh,
          child: Stack(
            children: [
              _buildContent(),
              // مؤشر التحميل أثناء التحديث
              if (client.isLoading.value)
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
    return Column(
      children: [
        // شريط البحث
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'بحث عن عميل',
              hintText: 'ابحث بالاسم، رقم الهاتف، أو رقم العداد',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _filteredClients = client.clients;
                  });
                },
                icon: const Icon(Icons.clear),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _filteredClients = client.searchClients(value);
              });
            },
          ),
        ),

        // عرض العملاء
        Expanded(
          child: Obx(() {
            // تحميل البيانات التلقائية من الـ controller
            final allClients = client.clients;
            final isLoading = client.isLoading.value;

            // تحديث القائمة المصفاة عند تغيير البيانات
            if (_searchController.text.isEmpty &&
                _filteredClients.isEmpty) {
              _filteredClients = allClients;
            }

            if (isLoading && allClients.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // إذا كان هناك بحث، استخدم _filteredClients، وإلا استخدم كل العملاء
            final displayClients = _searchController.text.isNotEmpty
                ? _filteredClients
                : allClients;

            if (displayClients.isEmpty) {
              return _buildEmptyState();
            }

            return _buildClientsList(displayClients);
          }),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.group_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'لا يوجد عملاء'
                : 'لا توجد نتائج للبحث',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? 'انقر على زر + لإضافة عميل جديد'
                : 'جرب مصطلحات بحث أخرى',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          if (_searchController.text.isEmpty)
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/add-client'),
              icon: const Icon(Icons.add),
              label: const Text('إضافة عميل جديد'),
            ),
        ],
      ),
    );
  }

  Widget _buildClientsList(List<ClientModel> clients) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: clients.length,
      itemBuilder: (context, index) {
        final client = clients[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClientCard(
            client: client,
            onTap: () {
              Get.to(() => ClientDetailsScreen(client: client.id!));
            },
            onLongPress: () {
              _showClientOptions(context, client);
            },
          ),
        );
      },
    );
  }

  void _showClientOptions(BuildContext context, ClientModel client) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('تعديل البيانات'),
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
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'حذف العميل',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteDialog(client);
                },
              ),
              ListTile(
                leading: const Icon(Icons.receipt),
                title: const Text('إضافة فاتورة'),
                onTap: () {
                  Navigator.pop(context);
                  Get.to(AddReadingScreen(
                    client:  ClientModel(
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
                  )
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.payment),
                title: const Text('تسديد فاتوره'),
                onTap: () {
                  Navigator.pop(context);

                  Get.toNamed('/pay-bill', arguments: client.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeleteDialog(ClientModel client) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('حذف العميل'),
        content: Text(
          'هل أنت متأكد من حذف العميل ${client.name}؟\nسيتم حذف جميع الفواتير المرتبطة به.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await this.client.deleteClient(id: client.id!);
        if (success > 0) {
          Get.snackbar(
            'نجاح',
            'تم حذف العميل بنجاح',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          await _refreshData();
        }
      } catch (e) {
        Get.snackbar(
          'خطأ',
          'فشل في حذف العميل: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}
