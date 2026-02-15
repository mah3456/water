import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/InvoiceModel.dart';
import '../../controllers/InvoiceController.dart';
import '../../controllers/ReadingController.dart';



class InvoicesScreen extends StatelessWidget {
  InvoicesScreen({super.key});

  final InvoiceController controller = Get.put(InvoiceController());
  final TextEditingController searchController = TextEditingController();
  final ReadingsController _readingsController = Get.find<ReadingsController>();


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: const Text('الفواتير'),
        centerTitle: true,
        elevation: 0,
        actions: [

          // فلتر الفواتير
          Obx(() => PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: controller.setFilter,
            initialValue: controller.filterType.value,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.list, size: 20),
                    SizedBox(width: 8),
                    Text('جميع الفواتير'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'paid',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 20, color: Colors.green),
                    SizedBox(width: 8),
                    Text('الفواتير المدفوعة'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'unpaid',
                child: Row(
                  children: [
                    Icon(Icons.cancel, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('الفواتير غير المدفوعة'),
                  ],
                ),
              ),
            ],
          )),
          const SizedBox(width: 8),
          
          // تحديث
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchAllInvoices,
          ),
        ],
      ),
      
      body: Column(
        children: [

          // بطاقات الإحصائيات
          Obx(() => _buildStatsCards(context)),


          // شريط البحث
          _buildSearchBar(context),

          // النتائج
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
               return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary,)),
                    const SizedBox(height: 20),

                    Text('جاري التحميل ...')
                  ],
                );
              }

              if (controller.filteredInvoices.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredInvoices.length,
                itemBuilder: (context, index) {
                  final invoice = controller.filteredInvoices[index];
                  return _buildInvoiceCard(invoice , context);
                },
              );
            }),
          ),
        ],
      ),

    );
  }


  // بطاقات الإحصائيات
  Widget _buildStatsCards(BuildContext context) {
    final currencyFormat = NumberFormat('#,##0.0', 'ar');


    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          _buildStatCard(
            title: 'إجمالي الفواتير',
            value: '${currencyFormat.format(controller.totalAmount)} ر.ي',
            icon: Icons.receipt,
            color: Colors.blue,
          ),
          const SizedBox(width: 10),
          _buildStatCard(
            title: 'مدفوعة',
            value: '${controller.paidCount} فاتورة',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
          const SizedBox(width: 10),
          _buildStatCard(
            title: 'غير مدفوعة',
            value: '${controller.unpaidCount} فاتورة',
            icon: Icons.pending,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      // width: 200,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // شريط البحث
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'ابحث باسم العميل أو رقم العداد...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) async{
                print( controller.filteredInvoices.first.client.name);
                // تأخير البحث لتجنب كثرة الطلبات
                Future.delayed(const Duration(milliseconds: 500), () {
                 controller.searchInvoice(value);
                });
              },
            ),
          ),
          if (searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                searchController.clear();
                controller.searchInvoice('');
              },
            ),
        ],
      ),
    );
  }

  // بطاقة الفاتورة
  Widget _buildInvoiceCard(InvoiceModel invoice , BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showInvoiceDetails(invoice , context),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // رأس البطاقة - معلومات العميل
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      invoice.client.name[0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.client.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.speed, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              'عداد: ${invoice.client.meterNumber}',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // حالة الفاتورة
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: invoice.statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      invoice.status,
                      style: TextStyle(
                        color: invoice.statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // محتوى الفاتورة
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'تاريخ الفاتورة: ${invoice.formattedDate}',

                      ),
                      Text(
                        'رقم الفاتورة: #${invoice.reading.id}',

                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // قراءة العداد
                  Row(
                    children: [
                      Expanded(
                        child: _buildInvoiceInfoItem(
                          label: 'القراءة السابقة',
                          value: '${invoice.reading.previousReading}',
                        ),
                      ),
                      Expanded(
                        child: _buildInvoiceInfoItem(
                          label: 'القراءة الحالية',
                          value: '${invoice.reading.currentReading}',
                        ),
                      ),
                      Expanded(
                        child: _buildInvoiceInfoItem(
                          label: 'الاستهلاك',
                          value: '${invoice.reading.currentReading - invoice.reading.previousReading}',
                          isHighlighted: true,
                        ),
                      ),
                    ],
                  ),


                  SizedBox(height: 30),

                  Divider(color: Colors.grey , height: 5),


                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'المبلغ ',
                      ),
                      Text(
                        invoice.formattedAmount,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),
                   Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'المبلغ المتبقي',
                        ),
                        Text(
                          invoice.formattedRemaining,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),


                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'المبلغ الدفوع',
                      ),
                      Text(
                        invoice.formattedPaid,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),


                  const SizedBox(height: 30),
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'المسدد | ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        invoice.reading.payby.toString(),
                      ),
                    ],
                  ),

                ],
              ),
            ),
            
            // أزرار الإجراءات
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!invoice.reading.isPaid)
                    TextButton.icon(
                      onPressed: () => Get.toNamed(
                      '/pay-bill',
                      arguments: invoice.client.id,
                      ),

                      icon: const Icon(Icons.payment, size: 18),
                      label: const Text('تسديد'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                    ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _printInvoice(invoice),
                    icon: const Icon(Icons.print, size: 18),
                    label: const Text('طباعة'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showDeleteDialog(invoice , context),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('حذف'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceInfoItem({
    required String label,
    required String value,
    bool isHighlighted = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            color: isHighlighted ? Colors.blue : null,
          ),
        ),
      ],
    );
  }

  // حالة عدم وجود فواتير
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد فواتير',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لم يتم العثور على أي فواتير',
              style: TextStyle(
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.fetchAllInvoices,
              icon: const Icon(Icons.refresh),
              label: const Text('تحديث'),
            ),
          ],
        ),
      ),
    );
  }

  // نافذة تفاصيل الفاتورة
  void _showInvoiceDetails(InvoiceModel invoice , BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'تفاصيل الفاتورة',
                      style: Theme.of(Get.context!).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    // إضافة المزيد من التفاصيل هنا
                    ...invoice.reading.toMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key),
                            Text(entry.value.toString()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // نافذة تأكيد الحذف
  void _showDeleteDialog(InvoiceModel invoice , BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('حذف الفاتورة'),
        content: Text('هل أنت متأكد من حذف فاتورة ${invoice.client.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء' , style: TextStyle(color: Colors.grey),),
          ),
          ElevatedButton(
            onPressed: () async {

              final res = await _readingsController.delete(
                readingId: invoice.reading.id!,
              );

              controller.fetchAllInvoices;
              controller.update();


              if (res) {
                Helpers.customSnackBar(
                  title: 'تم',
                  message: 'تم حذف الفاتورة',
                  background: CupertinoColors.systemGreen,
                );

                Future.delayed(Duration(milliseconds: 500)).then((value) => Get.back(),);
              } else {
                Helpers.customSnackBar(
                  title: 'فشل',
                  message: 'فشل حذف الفاتورة',
                  background: Colors.red,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Colors.transparent,
              overlayColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
            ),
            child: const Text('حذف' , style: TextStyle(color: Colors.red),),
          ),
        ],
      ),
    );
  }

  // خيارات تصدير التقرير
  void _showExportOptions() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'تصدير التقرير',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('PDF'),
                subtitle: const Text('تصدير كملف PDF'),
                onTap: () {
                  Get.back();
                  Get.snackbar('قريباً', 'قريباً سيتم إضافة هذه الميزة');
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.green),
                title: const Text('Excel'),
                subtitle: const Text('تصدير كملف Excel'),
                onTap: () {
                  Get.back();
                  Get.snackbar('قريباً', 'قريباً سيتم إضافة هذه الميزة');
                },
              ),
              ListTile(
                leading: const Icon(Icons.print, color: Colors.blue),
                title: const Text('طباعة'),
                subtitle: const Text('طباعة التقرير مباشرة'),
                onTap: () {
                  Get.back();
                  Get.snackbar('قريباً', 'قريباً سيتم إضافة هذه الميزة');
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // طباعة الفاتورة
  void _printInvoice(InvoiceModel invoice) {
    Get.snackbar('طباعة', 'جاري تجهيز الفاتورة للطباعة...');
    // سيتم إضافة منطق الطباعة لاحقاً
  }
}