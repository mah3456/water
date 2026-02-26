import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:water/core/utils/helpers.dart';
import '../../../data/models/client_model.dart';
import '../../../wigets/loading_widget.dart';
import '../../controllers/ClientsController.dart';
import '../../controllers/ReadingController.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profilecontroller.dart';

class AddReadingScreen extends StatefulWidget {
  const AddReadingScreen({super.key, this.client});

  final ClientModel? client;

  @override
  State<AddReadingScreen> createState() => _AddReadingScreenState();
}

class _AddReadingScreenState extends State<AddReadingScreen> with TickerProviderStateMixin {
  final ProfileController user = Get.put(ProfileController());
  final ReadingsController readings = Get.put(ReadingsController());
  final ClientsController clients = Get.put(ClientsController());
  final AuthController _authController = Get.find<AuthController>();

  final _formKey = GlobalKey<FormState>();
  ClientModel? selectedClient;
  final TextEditingController _currentReadingController = TextEditingController();
  final TextEditingController _previousReadingController = TextEditingController();
  final TextEditingController _rateController = TextEditingController(text: '1200.0');
  DateTime _readingDate = DateTime.now();
  final double subscription = 300.0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _currentReadingController.dispose();
    _previousReadingController.dispose();
    _rateController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    await clients.getAllClients();
    await clients.loadClients();

    if (widget.client != null) {
      setState(() {
        selectedClient = widget.client;
      });
      await _loadLastReading(widget.client!.id!);
    }
  }

  Future<void> _loadLastReading(int clientId) async {
    final lastReading = await readings.getLastReading(clientId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (lastReading != null) {
        _previousReadingController.text = lastReading.currentReading.toString();
      } else {
        _previousReadingController.text = '0';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'إضافة قراءة جديدة',
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


      body: Obx(() => Stack(
        children: [
          if (readings.isLoading.value)
            LoadingWidget()
          else
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // عرض معلومات العميل أو اختياره
                        if (widget.client != null) ...[
                          _buildClientInfoCard(theme),
                        ] else ...[
                          _buildClientSelector(theme),
                        ],

                        const SizedBox(height: 30),

                        // عرض الحقول فقط إذا تم اختيار عميل
                        if (selectedClient != null) ...[
                          _buildReadingFields(theme),

                          const SizedBox(height: 30),

                          _buildCalculationPreview(theme),

                          const SizedBox(height: 30),

                          _buildSubmitButton(theme),
                        ] else if (widget.client == null) ...[
                          _buildEmptyState(theme),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      )),
    );
  }

  Widget _buildClientInfoCard(ThemeData theme) {
    return Container(
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
      child: Row(
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
                  'العميل',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                Text(
                  widget.client!.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Iconsax.speedometer, color: Colors.white.withOpacity(0.8), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'رقم العداد: ${widget.client!.meterNumber}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
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

  Widget _buildClientSelector(ThemeData theme) {
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
                  child: Icon(Iconsax.people, color: theme.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'اختر العميل',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedClient?.id,
                  isExpanded: true,
                  hint: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Iconsax.search_normal, color: Colors.grey.shade400, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'ابحث عن عميل...',
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  ),
                  items: clients.clients.map((client) {
                    return DropdownMenuItem<int>(
                      value: client.id,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  client.name[0].toUpperCase(),
                                  style: TextStyle(
                                    // color: theme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 5,
                                children: [
                                  Text(
                                    client.name,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // const SizedBox(height: 2),
                                  Text(
                                    'عداد: ${client.meterNumber}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (clientId) {
                    if (clientId != null) {
                      final client = clients.clients.firstWhere(
                            (c) => c.id == clientId,
                      );
                      setState(() {
                        selectedClient = client;
                        _loadLastReading(client.id!);
                      });
                    } else {
                      setState(() {
                        selectedClient = null;
                      });
                    }
                  },
                ),
              ),
            ),
            if (clients.clients.isEmpty && !clients.isLoading.value)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Iconsax.info_circle, color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'لا يوجد عملاء متاحون',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingFields(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(width: 1 , color: Color(0x0ff3c56c)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // حقل القراءة السابقة
            field(
               textController: _previousReadingController,
                labelText: 'القراءة السابقة',
                icon: Icon(Iconsax.archive , color: theme.colorScheme.primary,),
                suffixText: 'وحدة',
                theme: theme,
              type: TextInputType.number,
              validation: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال القراءة السابقة';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // حقل القراءة الحالية
            field(
              theme: theme,
              textController: _currentReadingController,
                labelText: 'القراءة الحالية',
                icon: Icon(Iconsax.speedometer, color: theme.colorScheme.primary),
                suffixText: 'وحدة',
              type: TextInputType.number,
              validation: (value) {
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

            const SizedBox(height: 16),

            // صف السعر والتاريخ
            Row(
              children: [
                Expanded(
                  child: field(
                    theme: theme,
                    textController: _rateController,
                      labelText: 'سعر الوحدة',
                      icon: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('ر.ي', style: TextStyle(fontSize: 15 , color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                     suffixText: '',
                    type: TextInputType.number,
                    validation: (value) {
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(width:1 , color: theme.colorScheme.primary),
                      ),
                      child: Row(
                        children: [
                          Icon(Iconsax.calendar, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'تاريخ القراءة',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  _formatDate(_readingDate),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationPreview(ThemeData theme) {
    final current = int.tryParse(_currentReadingController.text) ?? 0;
    final previous = int.tryParse(_previousReadingController.text) ?? 0;
    final rate = double.tryParse(_rateController.text) ?? 1200.0;

    final consumption = current - previous;
    final total = consumption * rate + (readings.subscription ? subscription : 0);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(width: 1 , color: Color(0x0ff3c56c)),

      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // رسوم الاشتراك
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Iconsax.element_plus, color: theme.colorScheme.primary, size: 16),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'رسوم الاشتراك',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '300.0 ر.ي',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    activeThumbColor: Colors.green,
                    inactiveThumbColor: Colors.grey,
                    value: readings.subscription,
                    onChanged: (value) {
                      setState(() {
                        readings.subscription = value;
                      });
                    },
                    activeColor: theme.primaryColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ملخص الحساب
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Iconsax.calculator, color: theme.colorScheme.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'ملخص الحساب',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _buildSummaryRow('الاستهلاك:', '$consumption وحدة', Iconsax.flash),
                  const SizedBox(height: 8),
                  _buildSummaryRow('سعر الوحدة:', '${rate.toStringAsFixed(2)} ر.ي', Iconsax.money),
                  const SizedBox(height: 8),
                  if (readings.subscription)
                    _buildSummaryRow('رسوم الاشتراك:', '$subscription ر.ي', Iconsax.element_plus),

                  const Divider(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Iconsax.money_recive, color: Colors.green, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'الإجمالي:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${total.toStringAsFixed(2)} ر.ي',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
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


  Widget field({
    required ThemeData theme,
    required TextEditingController textController,
    required String labelText,
    required Widget icon,
    required String suffixText,
    required FormFieldValidator<String>? validation,
    required TextInputType type

  }){
    return TextFormField(
      controller: textController,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: icon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary,
          ),),
        filled: true,
        fillColor: Colors.transparent,
        suffixText: suffixText,
        suffixStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
      keyboardType: type,
      validator: validation
    );

  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(width: 1 , color: Color(0x0ff3c56c)),

        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _submitReading,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.save_2, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'حفظ القراءة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.profile_2user,
              size: 60,
              color: theme.primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'الرجاء اختيار عميل',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'قم باختيار عميل من القائمة لإضافة قراءة جديدة',
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      cancelText: 'إلغاء',
      confirmText: 'حفظ',
      context: context,
      initialDate: _readingDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
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

      final hasConnection = await _authController.checkInternetConnection();
      if (!hasConnection) {
        Helpers.showErrorSnackBar('لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك');
        return;
      }

        final current = int.parse(_currentReadingController.text);
        final previous = int.parse(_previousReadingController.text);
        final rate = double.parse(_rateController.text);
        final consumption = current - previous;
        final total = consumption * rate + (readings.subscription ? subscription : 0);

        print(total);
        print(readings.subscription);

        final success = await readings.addReading(
          subscription: readings.subscription ? 1 : 0,
          clientId: selectedClient!.id!,
          currentReading: current,
          previousReading: previous,
          readingDate: _readingDate,
          totalAmount: total,
          reader: user.fullName,
        );

        await clients.loadClient(clientId: selectedClient!.id!);
        await clients.getAllClients();
        clients.update();

        if (success) {
          _showSuccessSnackBar('تم إضافة القراءة بنجاح');
        } else {
          _showErrorSnackBar('فشل إضافة القراءة');
        }
    }
  }

  void _showSuccessSnackBar(String message) {
      Helpers.customSnackBar(
        title: 'نجاح',
       message: message,
       background: Colors.green,
      );

  }

  void _showErrorSnackBar(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Helpers.customSnackBar(
        title: 'فشل',
        message: message,
        background: Colors.red,
      );
    });
  }
}