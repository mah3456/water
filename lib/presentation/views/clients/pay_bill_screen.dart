import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/supabase/supabase_client_helper.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/client_model.dart';
import '../../../data/models/reading_model.dart';
import '../../../wigets/loading_widget.dart';
import '../../controllers/ClientsController.dart';
import '../../controllers/InvoiceController.dart';
import '../../controllers/ReadingController.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/client_controller.dart';
import '../../controllers/profilecontroller.dart';
import '../../controllers/reading_controller.dart';

class PayBillScreen extends StatefulWidget {
  const PayBillScreen({super.key});

  @override
  State<PayBillScreen> createState() => _PayBillScreenState();
}

class _PayBillScreenState extends State<PayBillScreen> with TickerProviderStateMixin {
  final ClientsController _clientController = Get.put(ClientsController());
  final ReadingsController _readingController = Get.put(ReadingsController());
  final ProfileController user = Get.put(ProfileController());
  final InvoiceController invoice = Get.put(InvoiceController());
  final AuthController _authController = Get.find<AuthController>();

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  ClientModel? selectedClient;
  List<ReadingModel> unpaidInvoices = [];
  ReadingModel? selectedInvoice;
  RxBool isLoading = true.obs;
  RxBool isProcessing = false.obs;
  String paymentMethod = 'نقداً';
  bool paySpecificInvoice = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClient();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadClient() async {
    final clientId = Get.arguments;
    if (clientId != null && clientId is int) {
      final client = await _clientController.getClientById(clientId: clientId);
      if (client != null) {
        setState(() {
          selectedClient = client;
        });
        await _loadUnpaidInvoices(client.id!);
      }
    }
    isLoading.value = false;
  }

  Future<void> _loadUnpaidInvoices(int clientId) async {
    final readings = await _readingController.getReadingsByClientId(clientId: clientId);
    setState(() {
      unpaidInvoices = readings.where((reading) => !reading.isPaid).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'تسديد فاتورة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (isLoading.value) {
          return _buildLoadingState(theme);
        }

        if (selectedClient == null) {
          return _buildErrorState(theme);
        }

        return Stack(
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // معلومات العميل
                      _buildClientInfoCard(theme),
                      const SizedBox(height: 20),

                      // اختيار طريقة الدفع
                      // _buildPaymentMethodSelector(theme),
                      const SizedBox(height: 20),

                      // اختيار الفاتورة
                      if (unpaidInvoices.isNotEmpty) ...[
                        _buildInvoiceSelector(theme),
                        const SizedBox(height: 20),
                      ],

                      // حقل إدخال المبلغ
                      _buildAmountField(theme),
                      const SizedBox(height: 20),

                      // ملاحظات
                      _buildNotesField(theme),
                      const SizedBox(height: 30),

                      // أزرار الإجراء
                      _buildActionButtons(theme),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            if (isProcessing.value)
              LoadingWidget()
          ],
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
            'جاري تحميل البيانات...',
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.warning_2,
              size: 60,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'العميل غير موجود',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لم نتمكن من العثور على بيانات العميل',
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Iconsax.arrow_left),
            label: const Text('العودة'),
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

  Widget _buildClientInfoCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(width: 1 , color: Color(0x0ff3c56c)),

      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Iconsax.profile_circle, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedClient!.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'رقم العداد: ${selectedClient!.meterNumber}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white30, height: 1),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildClientStat(
                  icon: Iconsax.money,
                  value: Helpers.formatCurrency(selectedClient!.totalDebt),
                  label: 'إجمالي الدين',
                  color: Colors.red,
                ),
                _buildClientStat(
                  icon: Iconsax.receipt,
                  value: '${unpaidInvoices.length}',
                  label: 'فواتير غير مدفوعة',
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }


  Widget _buildInvoiceSelector(ThemeData theme) {
    if (unpaidInvoices.isEmpty) {
      return _buildNoInvoicesCard(theme);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 1 , color: Color(0x0ff3c56c)),

      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Iconsax.receipt, color: theme.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'اختر الفاتورة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${unpaidInvoices.length} فواتير',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...unpaidInvoices.map((invoice) {
              return _buildInvoiceItem(invoice, theme);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildNoInvoicesCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.tick_circle,
              size: 40,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد فواتير غير مدفوعة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جميع فواتير هذا العميل تم دفعها',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceItem(ReadingModel invoice, ThemeData theme) {
    final isSelected = selectedInvoice?.id == invoice.id;
    final consumption = invoice.consumption ?? 0;
    final amount = (invoice.totalAmount ?? 0) - (invoice.subscription == 1 ? 300 : 0);

    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.transparent),
      onTap: () {
        setState(() {
          selectedInvoice = isSelected ? null : invoice;
          _updateAmountField();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.05) : Colors.grey.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.secondary : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.secondary : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isSelected ? Iconsax.tick_circle : Iconsax.receipt,
                    color: isSelected ? Colors.white : Colors.grey,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'فاتورة ${Helpers.formatDate(invoice.readingDate)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildInvoiceDetailChip(
                            label: 'الاستهلاك',
                            value: '$consumption',
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 5),
                          _buildInvoiceDetailChip(
                            label: 'المبلغ',
                            value: Helpers.formatCurrency(amount + (invoice.subscription == 1 ? 300 : 0)),
                            color: Colors.green,
                          ),


                        ],
                      ),

                      const SizedBox(height: 10),
                      _buildInvoiceDetailChip(
                        label: 'اشتراك',
                        value: Helpers.formatCurrency((invoice.subscription == 1 ? 300 : 0)),
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInvoiceStat(
                    label: 'السابقة',
                    value: '${invoice.previousReading ?? 0}',
                    icon: Iconsax.arrow_down,
                  ),
                  _buildInvoiceStat(
                    label: 'الحالية',
                    value: '${invoice.currentReading ?? 0}',
                    icon: Iconsax.arrow_up,
                  ),
                  _buildInvoiceStat(
                    label: 'الاستهلاك',
                    value: '$consumption',
                    icon: Iconsax.flash,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceDetailChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 10,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInvoiceStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildAmountField(ThemeData theme) {
    String hintText = 'أدخل المبلغ المراد دفعه';
    double maxAmount = selectedClient!.totalDebt;

    if (selectedInvoice != null) {
      maxAmount = (selectedInvoice!.totalAmount ?? 0) + 300;
      hintText = 'مبلغ الفاتورة: ${Helpers.formatCurrency(maxAmount)}';
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 1 , color: Color(0x0ff3c56c)),

      ),
      child: TextFormField(
        controller: _amountController,
        decoration: InputDecoration(
          labelStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(Iconsax.money, color: theme.colorScheme.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          suffixText: 'ر.ي',
          suffixStyle: const TextStyle(fontWeight: FontWeight.bold),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          contentPadding: const EdgeInsets.all(16),
        ),
        keyboardType: TextInputType.number,
        readOnly: paySpecificInvoice && selectedInvoice != null,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'يرجى إدخال المبلغ';
          }
          final amount = double.tryParse(value);
          if (amount == null || amount <= 0) {
            return 'يرجى إدخال مبلغ صحيح';
          }
          if (amount > maxAmount) {
            return 'المبلغ أكبر من الحد الأقصى';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildNotesField(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 1 , color: Color(0x0ff3c56c)),

      ),
      child: TextFormField(
        controller: _notesController,
        decoration: InputDecoration(
          labelText: 'ملاحظات الدفع (اختياري)',
          labelStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(Iconsax.note, color: theme.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.all(16),
        ),
        maxLines: 3,
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: isProcessing.value ? null : _submitPayment,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isProcessing.value ? Iconsax.timer : Iconsax.tick_circle),
              const SizedBox(width: 12),
              Text(
                isProcessing.value ? 'جاري المعالجة...' : 'تأكيد الدفع',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        if (selectedInvoice != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.info_circle, color: Colors.green, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'سيتم تسديد فاتورة بقيمة ${Helpers.formatCurrency((selectedInvoice!.totalAmount ?? 0) + 300)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _updateAmountField() {
    if (selectedInvoice != null) {
      _amountController.text = ((selectedInvoice!.totalAmount ?? 0) + 300).toStringAsFixed(2);
    } else {
      _amountController.clear();
    }
  }

  void _submitPayment() async {
    if (_formKey.currentState!.validate()) {

      final hasConnection = await _authController.checkInternetConnection();
      if (!hasConnection) {
        Helpers.showErrorSnackBar('لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك');
        return;
      }

      final amount = double.tryParse(_amountController.text);

      if (amount == null) {
        _showErrorSnackBar('المبلغ غير صالح');
        return;
      }

      isProcessing.value = true;

        if (selectedInvoice != null) {
          final success = await _clientController.paySpecificInvoice(
            clientId: selectedClient!.id!,
            invoiceId: selectedInvoice!.id!,
            paidAmount: amount,
            price: selectedInvoice!.remainingAmount ?? 0,
            notes: _notesController.text,
            paybay: user.fullName,
          );

          if (success) {
            await _refreshData();
            _showSuccessSnackBar('تم تسديد الفاتورة بنجاح');
            Get.back();
          } else {
            _showErrorSnackBar('فشلت عملية الدفع');
          }
        } else {
          _showErrorSnackBar('الرجاء اختيار فاتورة');
        }

    }
  }

  Future<void> _refreshData() async {
    await _clientController.loadClients();
    await _clientController.loadClient(clientId: selectedClient!.id!);
    await _loadClient();
    await _loadUnpaidInvoices(selectedClient!.id!);
    await _readingController.loadClientReadings(clientId: selectedClient!.id!);
    invoice.update();
    invoice.fetchAllInvoices();
  }

  void _showSuccessSnackBar(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        'تم',
        message,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Iconsax.tick_circle, color: Colors.white),
      );
    });
  }

  void _showErrorSnackBar(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        'خطأ',
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Iconsax.close_circle, color: Colors.white),
      );
    });
  }
}