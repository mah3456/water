import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/InvoiceModel.dart';
import '../../controllers/InvoiceController.dart';
import '../../controllers/ReadingController.dart';
import '../../controllers/auth_controller.dart';

class InvoicesScreen extends StatelessWidget {
  InvoicesScreen({super.key});

  final InvoiceController controller = Get.put(InvoiceController());
  final TextEditingController searchController = TextEditingController();
  final ReadingsController _readingsController = Get.find<ReadingsController>();
  final AuthController _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'الفواتير',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // فلتر الفواتير
          Obx(() => PopupMenuButton<String>(
            icon: const Icon(Iconsax.filter),
            onSelected: controller.setFilter,
            initialValue: controller.filterType.value,
            color: theme.cardColor,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Iconsax.element_4, size: 20, color: theme.iconTheme.color),
                    const SizedBox(width: 8),
                    Text('جميع الفواتير', style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'paid',
                child: Row(
                  children: [
                    Icon(Iconsax.tick_circle, size: 20, color: Colors.green),
                    const SizedBox(width: 8),
                    Text('الفواتير المدفوعة', style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'unpaid',
                child: Row(
                  children: [
                    Icon(Iconsax.close_circle, size: 20, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('الفواتير غير المدفوعة', style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                  ],
                ),
              ),
            ],
          )),

          // تحديث
          IconButton(
            icon: const Icon(Iconsax.refresh),
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
                return _buildLoadingState(theme);
              }

              if (controller.filteredInvoices.isEmpty) {
                return _buildEmptyState(theme);
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredInvoices.length,
                itemBuilder: (context, index) {
                  final invoice = controller.filteredInvoices[index];
                  return _buildInvoiceCard(invoice, theme);
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
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat('#,##0.0', 'ar');

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'إجمالي',
              value: '${currencyFormat.format(controller.totalAmount)} ر.ي',
              icon: Iconsax.receipt,
              color: Colors.blue,
              gradient: const [Color(0xFF2196F3), Color(0xFF1976D2)],
              theme: theme,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: _buildStatCard(
              title: 'مدفوعة',
              value: '${controller.paidCount} فاتورة',
              icon: Iconsax.tick_circle,
              color: Colors.green,
              gradient: const [Color(0xFF4CAF50), Color(0xFF388E3C)],
              theme: theme,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: _buildStatCard(
              title: 'غير مدفوعة',
              value: '${controller.unpaidCount} فاتورة',
              icon: Iconsax.clock,
              color: Colors.orange,
              gradient: const [Color(0xFFFF9800), Color(0xFFF57C00)],
              theme: theme,
            ),
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
    required List<Color> gradient,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 20 , bottom: 20 , right: 20 , left: 10),
      alignment: Alignment.center,
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 10, color: Colors.white),
              ),
             SizedBox(width: 2,),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                  hintStyle: TextStyle(color: theme.hintColor),
                  prefixIcon: Icon(Iconsax.search_normal, color: theme.iconTheme.color),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                style: theme.textTheme.bodyLarge,
                onChanged: (value) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    controller.searchInvoice(value);
                  });
                },
              ),
            ),
            if (searchController.text.isNotEmpty)
              IconButton(
                icon: Icon(Iconsax.close_circle, color: theme.iconTheme.color),
                onPressed: () {
                  searchController.clear();
                  controller.searchInvoice('');
                },
              ),
          ],
        ),
      ),
    );
  }

  // بطاقة الفاتورة
  Widget _buildInvoiceCard(InvoiceModel invoice, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final consumption = invoice.reading.currentReading - invoice.reading.previousReading;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => '',
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // رأس البطاقة - معلومات العميل
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: invoice.reading.isPaid
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor,
                          theme.primaryColor.withOpacity(0.7),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        invoice.client.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Iconsax.speedometer, size: 14, color: theme.iconTheme.color?.withOpacity(0.6)),
                            const SizedBox(width: 4),
                            Text(
                              'عداد: ${invoice.client.meterNumber}',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: invoice.reading.isPaid
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      invoice.reading.isPaid ? 'مدفوع' : 'غير مدفوع',
                      style: TextStyle(
                        color: invoice.reading.isPaid ? Colors.green : Colors.orange,
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
                  // تاريخ ورقم الفاتورة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoChip(
                        icon: Iconsax.calendar,
                        label: invoice.formattedDate,
                        color: Colors.blue,
                      ),
                      _buildInfoChip(
                        icon: Iconsax.receipt,
                        label: '#${invoice.reading.id}',
                        color: Colors.purple,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // قراءة العداد
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildReadingStat(
                          label: 'السابقة',
                          value: '${invoice.reading.previousReading}',
                          icon: Iconsax.arrow_down,
                          color: Colors.blue,
                        ),
                        Container(
                          height: 30,
                          width: 1,
                          color: theme.dividerColor,
                        ),
                        _buildReadingStat(
                          label: 'الحالية',
                          value: '${invoice.reading.currentReading}',
                          icon: Iconsax.arrow_up,
                          color: Colors.green,
                        ),
                        Container(
                          height: 30,
                          width: 1,
                          color: theme.dividerColor,
                        ),
                        _buildReadingStat(
                          label: 'الاستهلاك',
                          value: '$consumption',
                          icon: Iconsax.flash,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // تفاصيل المبالغ
                  Row(
                    children: [
                      Expanded(
                        child: _buildAmountChip(
                          label: 'المبلغ',
                          value: invoice.formattedAmount,
                          icon: Iconsax.money,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAmountChip(
                          label: 'المتبقي',
                          value: invoice.formattedRemaining,
                          icon: Iconsax.money_recive,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAmountChip(
                          label: 'المدفوع',
                          value: invoice.formattedPaid,
                          icon: Iconsax.tick_circle,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // المسدد
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.user, size: 16, color: theme.iconTheme.color),
                        const SizedBox(width: 8),
                        Text(
                          'المسدد: ',
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            invoice.reading.payby ?? 'غير محدد',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // أزرار الإجراءات
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: Iconsax.printer,
                        label: 'طباعة',
                        color: Colors.blue,
                        onTap: () => _printInvoice(invoice),
                      ),
                      if (!invoice.reading.isPaid)
                        _buildActionButton(
                          icon: Iconsax.money,
                          label: 'تسديد',
                          color: Colors.green,
                          onTap: ()  async {
                            final hasConnection = await _authController.checkInternetConnection();
                            if (!hasConnection) {
                              Helpers.showErrorSnackBar('لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك');
                              return;
                            }

                           _authController.isConnected.value? Get.toNamed('/pay-bill', arguments: invoice.client.id):null;

                            },
                        ),
                      _buildActionButton(
                        icon: Iconsax.trash,
                        label: 'حذف',
                        color: Colors.red,
                        onTap: () async {
                          final hasConnection = await _authController.checkInternetConnection();
                          if (!hasConnection) {
                            Helpers.showErrorSnackBar('لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك');
                            return;
                          }
                          _authController.isConnected.value? _showDeleteDialog(invoice, theme): null;

                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
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
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountChip({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // حالة التحميل
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
            'جاري تحميل الفواتير...',
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // حالة عدم وجود فواتير
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
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
              'لا توجد فواتير',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.filterType.value != 'all'
                  ? 'لا توجد فواتير ${controller.filterType.value == 'paid' ? 'مدفوعة' : 'غير مدفوعة'}'
                  : 'لم يتم إضافة أي فواتير بعد',
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // نافذة تفاصيل الفاتورة
  void _showInvoiceDetails(InvoiceModel invoice, ThemeData theme) {
    final consumption = invoice.reading.currentReading - invoice.reading.previousReading;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
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
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'تفاصيل الفاتورة',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),

                    // معلومات العميل
                    _buildDetailRow('اسم العميل', invoice.client.name),
                    _buildDetailRow('رقم العداد', invoice.client.meterNumber),
                    const Divider(height: 24),

                    // قراءة العداد
                    _buildDetailRow('القراءة السابقة', '${invoice.reading.previousReading} وحدة'),
                    _buildDetailRow('القراءة الحالية', '${invoice.reading.currentReading} وحدة'),
                    _buildDetailRow('الاستهلاك', '$consumption وحدة'),
                    const Divider(height: 24),

                    // المبالغ
                    _buildDetailRow('قيمة الاستهلاك', Helpers.formatCurrency(consumption * 1200)),
                    _buildDetailRow('رسوم الاشتراك', Helpers.formatCurrency(invoice.reading.subscription == 1 ? 300 : 0)),
                    _buildDetailRow('الإجمالي', invoice.formattedAmount),
                    _buildDetailRow('المدفوع', invoice.formattedPaid),
                    _buildDetailRow('المتبقي', invoice.formattedRemaining, isHighlighted: true),
                    const Divider(height: 24),

                    // تاريخ الفاتورة
                    _buildDetailRow('تاريخ الفاتورة', invoice.formattedDate),
                    _buildDetailRow('حالة الفاتورة', invoice.reading.isPaid ? 'مدفوع' : 'غير مدفوع'),
                    _buildDetailRow('المسدد', invoice.reading.payby ?? 'غير محدد'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  // نافذة تأكيد الحذف
  void _showDeleteDialog(InvoiceModel invoice, ThemeData theme) {
    Get.dialog(
      AlertDialog(
        title: const Text('حذف الفاتورة'),
        content: Text('هل أنت متأكد من حذف فاتورة ${invoice.client.name}؟'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
            ),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final res = await _readingsController.delete(readingId: invoice.reading.id!);
              controller.update();
              controller.fetchAllInvoices();

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (res) {
                  Get.snackbar(
                    'تم',
                    'تم حذف الفاتورة بنجاح',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                    icon: const Icon(Iconsax.tick_circle, color: Colors.white),
                  );
                } else {
                  Get.snackbar(
                    'فشل',
                    'فشل حذف الفاتورة',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                    icon: const Icon(Iconsax.close_circle, color: Colors.white),
                  );
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }


  // طباعة الفاتورة
  void _printInvoice(InvoiceModel invoice) {
    Get.snackbar(
      'طباعة',
      'جاري تجهيز الفاتورة للطباعة...',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}