import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:validation_textformfield/validation_textformfield.dart';
import 'package:water/core/utils/helpers.dart';
import 'package:water/data/models/user_model.dart';
import 'package:water/wigets/loading_widget.dart';
import '../../controllers/auth_controller.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final AuthController _authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final RxBool _isPasswordVisible = false.obs;
  final RxBool _isPasswordVisible1 = false.obs;
  final RxBool _isSubmitting = false.obs;
  final RxBool _isCheckingConnection = false.obs;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
      _checkInitialConnection();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // دالة للتحقق من الاتصال عند بدء التشغيل
  Future<void> _checkInitialConnection() async {
    _isCheckingConnection.value = true;
    await _authController.checkInternetConnection();
    _isCheckingConnection.value = false;
    _authController.update();
    setState(() {});

  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // الخلفية مع تدرج لوني
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.primaryColor.withOpacity(0.1),
                  Colors.transparent,
                  theme.primaryColor.withOpacity(0.05),
                ],
              ),
            ),
          ),

          // المحتوى الرئيسي
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // شريط حالة الاتصال
                        Obx(() => _buildConnectionStatusBar(theme)),

                        const SizedBox(height: 16),

                        // الهيدر مع الأيقونة
                        _buildHeader(theme),

                        const SizedBox(height: 40),

                        // حقول الإدخال
                        _buildInputFields(theme, isDark),

                        const SizedBox(height: 32),

                        // زر التسجيل
                        _buildSubmitButton(theme),

                        const SizedBox(height: 24),

                        // رابط تسجيل الدخول
                        _buildLoginLink(theme),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // شاشة التحميل
          Obx(() => _isSubmitting.value || _isCheckingConnection.value
              ? Container(
            color: Colors.black.withOpacity(0.3),
            child: const LoadingWidget(),
          )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  // ويدجت لعرض حالة الاتصال
  Widget _buildConnectionStatusBar(ThemeData theme) {
    if (!_authController.isConnected.value) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.orange.shade800, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك',
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: _checkInitialConnection,
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'إعادة محاولة',
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Iconsax.user_add,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          'إنشاء حساب جديد',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'أدخل بياناتك لإنشاء حساب جديد',
          style: TextStyle(
            fontSize: 14,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildInputFields(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // الاسم الكامل
          _buildTextField(
            controller: _nameController,
            label: 'الاسم الكامل',
            icon: Iconsax.user,
            inputType: TextInputType.text,
            enabled: !_isSubmitting.value && _authController.isConnected.value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال الاسم';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // البريد الإلكتروني
          EmailValidationTextField(
            whenTextFieldEmpty: "يرجى إدخال البريد الإلكتروني",
            validatorMassage: "البريد الإلكتروني غير صالح",
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              enabled: !_isSubmitting.value && _authController.isConnected.value,
              prefixIcon: Icon(Iconsax.sms, color: theme.primaryColor),
              label: const Text('البريد الإلكتروني'),
              labelStyle: TextStyle(color: theme.hintColor),
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            textEditingController: _emailController,
          ),

          const SizedBox(height: 16),

          // رقم الهاتف
          _buildTextField(
            controller: _phoneController,
            label: 'رقم الهاتف',
            icon: Iconsax.call,
            inputType: TextInputType.phone,
            enabled: !_isSubmitting.value && _authController.isConnected.value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال رقم الهاتف';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // كلمة المرور
          Obx(() => PassWordValidationTextFiled(
            lineIndicator: false,
            passwordMinError: "كلمة المرور أقل من 6 أحرف",
            hasPasswordEmpty: "كلمة المرور فارغة",
            passwordMaxError: "كلمة المرور طويلة",
            passWordUpperCaseError: "حرف كبير واحد على الأقل",
            passWordDigitsCaseError: "رقم واحد على الأقل",
            passwordLowercaseError: "حرف صغير واحد على الأقل",
            passWordSpecialCharacters: "رمز خاص واحد على الأقل",
            obscureText: !_isPasswordVisible.value,
            scrollPadding: const EdgeInsets.only(left: 60),
            passTextEditingController: _passwordController,
            passwordMaxLength: 15,
            passwordMinLength: 6,
            decoration: InputDecoration(
              enabled: !_isSubmitting.value && _authController.isConnected.value,
              prefixIcon: Icon(Iconsax.lock, color: theme.primaryColor),
              suffixIcon: IconButton(
                style: ButtonStyle(
                    overlayColor: WidgetStatePropertyAll(Colors.transparent)
                ),
                icon: Icon(
                  _isPasswordVisible.value
                      ? Iconsax.eye
                      : Iconsax.eye_slash,
                  color: theme.hintColor,
                ),
                onPressed: (_isSubmitting.value || !_authController.isConnected.value)
                    ? null
                    : () => _isPasswordVisible.toggle(),
              ),
              label: const Text('كلمة المرور'),
              labelStyle: TextStyle(color: theme.hintColor),
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: theme.primaryColor, width: 1),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          )),

          const SizedBox(height: 16),

          // تأكيد كلمة المرور
          Obx(() => ConfirmPassWordValidationTextFromField(
            obscureText: !_isPasswordVisible1.value,
            scrollPadding: const EdgeInsets.only(left: 60),
            whenTextFieldEmpty: "يرجى تأكيد كلمة المرور",
            validatorMassage: "كلمتا المرور غير متطابقتين",
            confirmtextEditingController: _confirmPasswordController,
            passtextEditingController: _passwordController,
            decoration: InputDecoration(
              enabled: !_isSubmitting.value && _authController.isConnected.value,
              prefixIcon: Icon(Iconsax.lock_1, color: theme.primaryColor),
              suffixIcon: IconButton(
                style: ButtonStyle(
                    overlayColor: WidgetStatePropertyAll(Colors.transparent)
                ),
                icon: Icon(
                  _isPasswordVisible1.value
                      ? Iconsax.eye
                      : Iconsax.eye_slash,
                  color: theme.hintColor,
                ),
                onPressed: (_isSubmitting.value || !_authController.isConnected.value)
                    ? null
                    : () => _isPasswordVisible1.toggle(),
              ),
              label: const Text('تأكيد كلمة المرور'),
              labelStyle: TextStyle(color: theme.hintColor),
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          )),

          // إظهار رسالة عند عدم وجود اتصال
          Obx(() {
            if (!_authController.isConnected.value) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'غير متصل بالإنترنت. لا يمكن إنشاء حساب حالياً',
                  style: TextStyle(
                    color: Colors.red.shade400,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType inputType,
    bool enabled = true,
    FormFieldValidator<String>? validator,
  }) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.hintColor),
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        filled: true,
        fillColor: theme.scaffoldBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      keyboardType: inputType,
      validator: validator,
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            _authController.isConnected.value ? theme.primaryColor : Colors.grey,
            _authController.isConnected.value
                ? theme.primaryColor.withOpacity(0.7)
                : Colors.grey.withOpacity(0.7)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ElevatedButton(
        onPressed: (_isSubmitting.value || !_authController.isConnected.value) ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: const Color(0x0ff3c56c))
          ),
        ),
        child: _isSubmitting.value
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                _authController.isConnected.value ? Iconsax.user_add : Icons.wifi_off,
                color: Colors.white
            ),
            const SizedBox(width: 12),
            Text(
              _authController.isConnected.value ? 'إنشاء حساب' : 'لا يوجد اتصال',
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

  Widget _buildLoginLink(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'لديك حساب بالفعل؟',
          style: TextStyle(
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
        TextButton(
          onPressed: () {
            Get.offAll(() => LoginScreen(),
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 500),
            );
          },
          style: TextButton.styleFrom(
            overlayColor: Colors.transparent,
          ),
          child: Text(
            'سجل الدخول',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // التحقق من الاتصال قبل المتابعة
    final hasConnection = await _authController.checkInternetConnection();
    if (!hasConnection) {
      _showErrorSnackBar('لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك');
      return;
    }

    FocusScope.of(context).unfocus();
    _isSubmitting.value = true;

      final newUser = UserModel(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        createdAt: DateTime.now(),
      );

      final result = await _authController.register(user: newUser);

      _checkInitialConnection();

      if (result) {
        _showSuccessSnackBar('تم إنشاء حسابك بنجاح');

        await Future.delayed(const Duration(milliseconds: 800));

        Get.offAll(
              () => LoginScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
      } else {
        _showErrorSnackBar('حدث خطأ أثناء إنشاء الحساب');
      }

  }

  void _showSuccessSnackBar(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Helpers.customSnackBar(
        title: 'تم',
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