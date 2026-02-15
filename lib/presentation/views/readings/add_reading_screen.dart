import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water/core/utils/helpers.dart';
import '../../../data/models/client_model.dart';
import '../../../wigets/loading_widget.dart';
import '../../controllers/ClientsController.dart';
import '../../controllers/ReadingController.dart';
import '../../controllers/profilecontroller.dart';

class AddReadingScreen extends StatefulWidget {
  const AddReadingScreen({super.key, this.client});

  final ClientModel? client;

  @override
  State<AddReadingScreen> createState() => _AddReadingScreenState();
}

class _AddReadingScreenState extends State<AddReadingScreen> {
  final ProfileController user = Get.put(ProfileController());
  final ReadingsController readings = Get.put(ReadingsController());
  final ClientsController clients = Get.put(ClientsController());

  final _formKey = GlobalKey<FormState>();
  ClientModel? selectedClient;
  final TextEditingController _currentReadingController = TextEditingController();
  final TextEditingController _previousReadingController = TextEditingController();
  final TextEditingController _rateController = TextEditingController(text: '1200.0');
  DateTime _readingDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    // تحميل قائمة العملاء
    await clients.getAllClients();

    if (widget.client != null) {
      // إذا تم تمرير عميل، استخدمه مباشرة
      setState(() {
        selectedClient = widget.client;
      });
      _loadLastReading(widget.client!.id!);
    }
  }

  void _loadLastReading(int clientId) async {
    final lastReading = await readings.getLastReading(clientId);

    if (lastReading != null) {
      _previousReadingController.text = lastReading.currentReading.toString();
    } else {
      _previousReadingController.text = '0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة قراءة جديدة'),
        centerTitle: true,
      ),

      body: Obx(() => Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // عرض معلومات العميل أو اختياره
                  if (widget.client != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text('العميل | '),
                        Text(
                          widget.client!.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    _buildClientSelector(),
                  ],

                  const SizedBox(height: 30),

                  // عرض الحقول فقط إذا تم اختيار عميل
                  if (selectedClient != null) ...[
                    TextFormField(
                      controller: _previousReadingController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'القراءة السابقة',
                        labelStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.history),
                        border: OutlineInputBorder(),
                        suffixText: 'وحده',
                        suffixStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال القراءة السابقة';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _currentReadingController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'القراءة الحالية',
                        labelStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.speed),
                        border: OutlineInputBorder(),
                        suffixText: 'وحده',
                        suffixStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال القراءة الحالية';
                        }
                        if (int.tryParse(value) == null) {
                          return 'يرجى إدخال رقم صحيح';
                        }
                        if (int.parse(value) <= int.parse(_previousReadingController.text)) {
                          return 'القراءة الحالية يجب أن تكون أكبر من القراءة السابقة';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _rateController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelStyle: TextStyle(color: Colors.grey),
                              labelText: 'سعر الوحده',
                              prefixIcon: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('ر.ي', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال السعر';
                              }
                              if (double.tryParse(value) == null) {
                                return 'يرجى إدخال رقم صحيح';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'تاريخ القراءة',
                                prefixIcon: Icon(Icons.calendar_today),
                                border: OutlineInputBorder(),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_formatDate(_readingDate)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    _buildCalculationPreview(),

                    const SizedBox(height: 30),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submitReading,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CupertinoColors.systemBlue,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: const Text(
                              'حفظ القراءة',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (widget.client == null) ...[
                    // رسالة توجيه إذا لم يتم اختيار عميل
                    const Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Center(
                        child: Text(
                          'الرجاء اختيار عميل لإضافة قراءة جديدة',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (readings.isLoading.value)
            LoadingWidget()
        ],
      )),
    );
  }

  Widget _buildClientSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ClientModel>(
              value: selectedClient,
              isExpanded: true,
              hint: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('اختر من القائمة'),
              ),
              items: clients.clients.map((client) {
                return DropdownMenuItem<ClientModel>(
                  value: client,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '${client.name} - ${client.meterNumber}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (client) {
                setState(() {
                  selectedClient = client;
                  if (client != null) {
                    _loadLastReading(client.id!);
                  }
                });
              },
            ),
          ),
        ),
        if (clients.clients.isEmpty && !clients.isLoading.value)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'لا يوجد عملاء متاحون',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCalculationPreview() {
    if (selectedClient == null) return const SizedBox.shrink();

    final current = int.tryParse(_currentReadingController.text) ?? 0;
    final previous = int.tryParse(_previousReadingController.text) ?? 0;
    final rate = double.tryParse(_rateController.text) ?? 1200.0;

    final consumption = current - previous;
    final total = consumption * rate;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'ملخص الحساب',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الاستهلاك:'),
                Text('$consumption وحدة'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('سعر الوحدة:'),
                Text('${rate.toStringAsFixed(2)} ر.ي'),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'الإجمالي:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${total.toStringAsFixed(2)} ر.ي',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      cancelText: 'إالغاء',
      confirmText: 'حفظ',
      context: context,
      initialDate: _readingDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _readingDate) {
      setState(() {
        _readingDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _submitReading() async {
    if (_formKey.currentState!.validate() && selectedClient != null) {

      final current = int.parse(_currentReadingController.text);
      final previous = int.parse(_previousReadingController.text);
      final rate = double.parse(_rateController.text);
      final consumption = current - previous;
      final total = consumption * rate;

      var success = await readings.addReading(
        clientId: selectedClient!.id!,
        currentReading: current,
        previousReading: previous,
        readingDate: _readingDate,
        totalAmount: total,
        reader: user.fullName,
      );

      clients.loadClient(clientId: selectedClient!.id!);
      clients.getAllClients();
      clients.update();


      if (success) {
        Helpers.customSnackBar(
          title: 'نجاح',
          message: 'تم إضافة القراءة بنجاح',
          background: CupertinoColors.systemGreen,
        );
      } else {
        Get.snackbar(
          'فشل',
          'فشل إضافة القراءة',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      }
    }
  }

  @override
  void dispose() {
    _currentReadingController.dispose();
    _previousReadingController.dispose();
    _rateController.dispose();
    super.dispose();
  }
}