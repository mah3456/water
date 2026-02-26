import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:water/core/utils/helpers.dart';
import 'package:water/wigets/loading_widget.dart';
import '../../../data/models/client_model.dart';
import '../../controllers/ClientsController.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profilecontroller.dart';

class AddClientScreen extends StatefulWidget {
  AddClientScreen({super.key, this.client});

  final ClientModel? client;

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> with TickerProviderStateMixin {
  final ClientsController clientController = Get.put(ClientsController());
  final ProfileController user = Get.put(ProfileController());
  final AuthController _authController = Get.find<AuthController>();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _meterController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _debtController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final RxBool _isCheckingConnection = false.obs;

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
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    if (widget.client != null) {
      _nameController.text = widget.client!.name;
      _phoneController.text = widget.client!.phone;
      _addressController.text = widget.client!.address;
      _meterController.text = widget.client!.meterNumber;
      _notesController.text = widget.client!.notes ?? '';
      _debtController.text = widget.client!.totalDebt.toString();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });

    // _checkInitialConnection();
  }


  Future<void> _checkInitialConnection() async {
    _isCheckingConnection.value = _authController.isConnected.value;
     _authController.checkInternetConnection();
    _isCheckingConnection.value = _authController.isConnected.value;
    _authController.update();
    setState(() {});

    print(_authController.isConnected.value);

    if(!_authController.isConnected.value){
      Helpers.customSnackBar(title: 'فشل', message: 'لا يوجد اتصال بالانترنت', background: Colors.red);

    };
  }


  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _meterController.dispose();
    _notesController.dispose();
    _debtController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.client != null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          isEditing ? 'تحديث بيانات عميل' : 'إضافة عميل جديد',
          style: const TextStyle(fontWeight: FontWeight.bold),
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
      body: Stack(
        children: [
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
                      // أيقونة رأسية
                      _buildHeader(theme, isEditing),

                      const SizedBox(height: 24),

                      // حقول الإدخال
                      _buildInputField(
                        controller: _nameController,
                        label: 'اسم العميل',
                        icon: Iconsax.user,
                        inputType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال اسم العميل';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildInputField(
                        controller: _phoneController,
                        label: 'رقم الهاتف',
                        icon: Iconsax.call,
                        inputType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال رقم الهاتف';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildInputField(
                        controller: _addressController,
                        label: 'العنوان',
                        icon: Iconsax.location,
                        inputType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال العنوان';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildInputField(
                        controller: _meterController,
                        label: 'رقم العداد',
                        icon: Iconsax.speedometer,
                        inputType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال رقم العداد';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      if (isEditing)
                        _buildInputField(
                          controller: _debtController,
                          label: 'الدين الحالي',
                          icon: Iconsax.money,
                          inputType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال الدين';
                            }
                            if (double.tryParse(value) == null) {
                              return 'يرجى إدخال رقم صحيح';
                            }
                            return null;
                          },
                        ),

                      if (isEditing) const SizedBox(height: 16),

                      _buildInputField(
                        controller: _notesController,
                        label: 'ملاحظات (اختياري)',
                        icon: Iconsax.note,
                        inputType: TextInputType.text,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 32),

                      // زر الحفظ
                      _buildSubmitButton(theme, isEditing),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (clientController.isLoading.value)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const LoadingWidget(),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isEditing) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(width: 1 , color: Color(0x0ff3c56c)),
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.7)],
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
            child: Icon(
              isEditing ? Iconsax.edit : Iconsax.profile_add,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isEditing ? 'تحديث بيانات العميل' : 'إضافة عميل جديد',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isEditing
                ? 'قم بتعديل بيانات العميل حسب الحاجة'
                : 'أدخل بيانات العميل الجديد لإضافته إلى النظام',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType inputType,
    FormFieldValidator<String>? validator,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 18),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Theme.of(context).scaffoldBackgroundColor),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        maxLines: maxLines,
        keyboardType: inputType,
        validator: validator,
        enabled: !clientController.isLoading.value,
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme, bool isEditing) {
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
        onPressed:( clientController.isLoading.value || !_authController.isConnected.value ) ? null
            : () => _submitForm(),
        style: ElevatedButton.styleFrom(
          elevation: 1,
          backgroundColor: !_authController.isConnected.value ? Colors.grey : Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).scaffoldBackgroundColor),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: clientController.isLoading.value
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              isEditing ? 'جاري التحديث...' : 'جاري الإضافة...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isEditing ? Iconsax.refresh : Iconsax.save_2, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              isEditing ? 'تحديث البيانات' : 'إضافة العميل',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.client == null) {

      final hasConnection = await _authController.checkInternetConnection();
      if (!hasConnection) {
        _showErrorSnackBar('لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك');
        return;
      }



      // إضافة عميل جديد
      final client = ClientModel(
        name: _nameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        meterNumber: _meterController.text,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        createdAt: DateTime.now(),
        createdBy: user.supabase.auth.currentUser!.id,
      );

      final success = await clientController.addClient(client: client);

      _checkInitialConnection();

      if (success) {
        await clientController.loadClients();
        await clientController.getAllClients();

        _clearFields();
        _showSuccessSnackBar('تم إضافة العميل بنجاح');

        // العودة بعد نجاح الإضافة
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.back();
        });
      } else {
        _showErrorSnackBar('فشل إضافة العميل');
      }
    } else {

      // تحديث بيانات العميل
      final client = ClientModel(
        id: widget.client!.id,
        name: _nameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        currentBill: widget.client!.currentBill,
        totalDebt: double.parse(_debtController.text),
        meterNumber: _meterController.text,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        createdAt: widget.client!.createdAt,
        createdBy: user.supabase.auth.currentUser!.id,
      );

      final success = await clientController.updateClient(client: client);

      if (success) {
        await clientController.loadClients();
        await clientController.getAllClients();
        await clientController.loadClient(clientId: client.id!);
        clientController.update();

        _showSuccessSnackBar('تم تحديث بيانات العميل');

      } else {
        _showErrorSnackBar('فشل تحديث بيانات العميل');
      }
    }
  }

  void _clearFields() {
    _nameController.clear();
    _phoneController.clear();
    _addressController.clear();
    _meterController.clear();
    _notesController.clear();
    _debtController.clear();
  }

  void _showSuccessSnackBar(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Helpers.customSnackBar(
        title: 'نجاح',
        message: message,
        background: Colors.green,
      );
    });
  }

  void _showErrorSnackBar(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Helpers.customSnackBar(
        title: 'خطأ',
        message: message,
        background: Colors.red,
      );
    });
  }

}