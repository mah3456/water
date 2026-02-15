import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/supabase/supabase_client_helper.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/client_model.dart';
import '../../../data/models/reading_model.dart';
import '../../../wigets/loading_widget.dart';
import '../../controllers/ClientsController.dart';
import '../../controllers/ReadingController.dart';
import '../../controllers/client_controller.dart';
import '../../controllers/profilecontroller.dart';
import '../../controllers/reading_controller.dart';

class PayBillScreen extends StatefulWidget {
  const PayBillScreen({super.key});

  @override
  State<PayBillScreen> createState() => _PayBillScreenState();
}

class _PayBillScreenState extends State<PayBillScreen> {
  final ClientsController _clientController = Get.put(ClientsController());
  final ReadingsController _readingController = Get.put(ReadingsController());
  final ProfileController user = Get.put(ProfileController());

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  ClientModel? selectedClient;
  List<ReadingModel> unpaidInvoices = [];
  ReadingModel? selectedInvoice;
  var isLoading = true.obs;
  var paymentMethod = 'نقداً';
  bool paySpecificInvoice = false;

  @override
  void initState() {
    super.initState();
    _loadClient();
  }



  Future<void> _loadClient() async {
    final clientId = Get.arguments;
    if (clientId != null && clientId is int) {
      final client = await _clientController.getClientById(clientId: clientId,);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسديد فاتورة'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (isLoading.value) {
          return  Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary,)),
              const SizedBox(height: 20),

              Text('جاري التحميل ...')
            ],
          );
        }

        if (selectedClient == null) {
          return const Center(child: Text('العميل غير موجود'));
        }

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // معلومات العميل
                    _buildClientInfoCard(),
                    const SizedBox(height: 20),

                    // اختيار نوع الدفع
                    // _buildPaymentTypeSelector(),
                    const SizedBox(height: 20),

                    // إذا كان الدفع لفاتورة محددة
                      _buildInvoiceSelector(),
                      const SizedBox(height: 20),


                    // حقل إدخال المبلغ
                    _buildAmountField(),
                    const SizedBox(height: 20),

                    // ملاحظات
                    _buildNotesField(),
                    const SizedBox(height: 30),

                    const SizedBox(height: 30),

                    // أزرار الإجراء
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),

            if (_clientController.isLoading.value)
              LoadingWidget()
          ],
        );
      }),
    );
  }

  Widget _buildClientInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, size: 24, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectedClient!.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.confirmation_number, size: 20, color: Colors.grey),
                const SizedBox(width: 10),
                Text(
                  'رقم العداد: ${selectedClient!.meterNumber}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.money_off, size: 20, color: Colors.red),
                    const SizedBox(width: 10),
                    Text(
                      'الدين الحالي:',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Text(
                  Helpers.formatCurrency(selectedClient!.totalDebt),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('عدد الفواتير غير المدفوعة:'),
                Chip(
                  label: Text(
                    '${unpaidInvoices.length} فاتورة',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildInvoiceSelector() {
    if (unpaidInvoices.isEmpty) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, size: 48, color: Colors.green),
                  const SizedBox(height: 10),
                  const Text(
                    'لا توجد فواتير غير مدفوعة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'جميع فواتير هذا العميل تم دفعها',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                ],
              ),
            ),
          ),
        ],
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'اختر الفاتورة المراد تسديدها',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

              ],
            ),

            const SizedBox(height: 10),
            ...unpaidInvoices.map((invoice) {
              return _buildInvoiceItem(invoice);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceItem(ReadingModel invoice) {
    final isSelected = selectedInvoice?.id == invoice.id;
    final invoiceDate = Helpers.formatDate(invoice.readingDate);
    final invoiceAmount = Helpers.formatCurrency(invoice.remainingAmount!);

    return InkWell(
      onTap: () {
        setState(() {
          selectedInvoice = isSelected ? null : invoice;
          _updateAmountField();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white70 : null,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : null,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? Icons.check : Icons.receipt,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'فاتورة ${invoice.id}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.blue : null,
                        ),
                      ),
                      Text(
                        invoiceDate,
                        style: TextStyle(
                          color: isSelected ? Colors.blue : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'السابقه: ${invoice.previousReading} وحده',
                            style: TextStyle(
                                fontSize: 12,
                              color: isSelected ? Colors.blue : null,

                            ),
                          ),
                          Text(
                            'الحالبه: ${invoice.currentReading} وحده',
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.blue : null,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 9,),
                      Text(
                        'الاستهلاك: ${invoice.consumption} وحده',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.blue : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'المبلغ: $invoiceAmount',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'محددة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
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

  Widget _buildAmountField() {
    String hintText = 'أدخل المبلغ المراد دفعه';
    double maxAmount = selectedClient!.totalDebt;

    if (selectedInvoice != null) {
      maxAmount = selectedInvoice!.totalAmount!;
      hintText = 'مبلغ الفاتورة: ${Helpers.formatCurrency(maxAmount)}';
    }

    return TextFormField(
      controller: _amountController,
      decoration: InputDecoration(
        labelText: 'المبلغ المدفوع',
        prefixIcon: const Icon(Icons.attach_money),
        border: const OutlineInputBorder(),
        suffixText: 'ر.ي',
        suffixStyle: const TextStyle(fontWeight: FontWeight.bold),
        hintText: hintText,
        filled: true,
        fillColor: Colors.transparent,
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
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'ملاحظات الدفع (اختياري)',
        prefixIcon: Icon(Icons.note),
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.transparent,
      ),
      maxLines: 3,
    );
  }


  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(

              child: ElevatedButton(
                onPressed: () => _submitPayment(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: CupertinoColors.systemGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'تأكيد الدفع',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),

        const SizedBox(height: 10),
        if (selectedInvoice != null)
          Text(
            'سيتم تسديد فاتورة رقم ${selectedInvoice!.id} بقيمة ${Helpers.formatCurrency(selectedInvoice!.totalAmount!)}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  void _updateAmountField() {
    if ( selectedInvoice != null) {
      _amountController.text = selectedInvoice!.remainingAmount!.toStringAsFixed(2);
    } else {
      _amountController.clear();
    }
  }

  void _submitPayment() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text);

      if (amount == null) {
        Helpers.customSnackBar(
          title: 'خطأ',
          message: 'المبلغ غير صالح',
          background: Colors.red,
        );
        return;
      }

      if (selectedInvoice != null) {

        var success = await _clientController.paySpecificInvoice(
          clientId: selectedClient!.id!,
          invoiceId: selectedInvoice!.id!,
          paidAmount: amount,
          price: selectedInvoice!.totalAmount!,
          notes: _notesController.text,
          paybay: user.fullName
        );


        if (success) {
          await _clientController.loadClients();
          await _clientController.loadClient(clientId: selectedClient!.id!);
          await _loadClient();
          _clientController.update();
          _readingController.update();
          await _loadUnpaidInvoices(selectedClient!.id!);
          await _readingController.loadClientReadings(clientId: selectedClient!.id!);

          Helpers.customSnackBar(
            title: 'تم',
            message:'تم تسديد الفاتورة بنجاح',
            background: CupertinoColors.systemGreen,
          );


        } else {
          Helpers.customSnackBar(
            title: 'فشل',
            message: 'فشلت العملية',
            background: Colors.red,
          );
        }

      }



    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}