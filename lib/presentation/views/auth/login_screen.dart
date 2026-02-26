import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:validation_textformfield/validation_textformfield.dart';
import 'package:water/core/utils/helpers.dart';
import 'package:water/presentation/views/auth/register_screen.dart';
import 'package:water/wigets/loading_widget.dart';
import '../../../FingPrint/controller.dart';
import '../../../main.dart';
import '../../controllers/auth_controller.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FingerprintController controller = Get.put(FingerprintController());
  final first = shared.getBool('firstTime');

  final _formKey = GlobalKey<FormState>();
  final RxBool _isPasswordVisible = false.obs;
  final RxBool _isLoggingIn = false.obs;
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
    _emailController.dispose();
    _passwordController.dispose();
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // شريط حالة الاتصال
                        Obx(() => _buildConnectionStatusBar(theme)),

                        const SizedBox(height: 16),

                        // الهيدر مع الشعار
                        _buildHeader(theme),

                        const SizedBox(height: 40),

                        // بطاقة تسجيل الدخول
                        _buildLoginCard(theme, isDark),

                        const SizedBox(height: 24),

                        // زر تسجيل الدخول بالبصمة
                        if (first != true) _buildBiometricButton(theme),

                        const SizedBox(height: 20),

                        // رابط إنشاء حساب
                        _buildRegisterLink(theme),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // شاشة التحميل
          Obx(() => _isLoggingIn.value || _isCheckingConnection.value
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
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(width: 1 , color: const Color(0x0ff3c56c)),
          ),
          child: const Icon(
            Icons.water_drop_rounded,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'تسجيل الدخول',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'مرحباً بعودتك! يرجى إدخال بياناتك',
          style: TextStyle(
            fontSize: 14,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // حقل البريد الإلكتروني
          EmailValidationTextField(
            whenTextFieldEmpty: "يرجى إدخال البريد الإلكتروني",
            validatorMassage: "البريد الإلكتروني غير صالح",
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              enabled: !_isLoggingIn.value && _authController.isConnected.value,
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

          // حقل كلمة المرور
          Obx(() => _buildPasswordField(theme)),

          const SizedBox(height: 12),

          // رابط نسيت كلمة المرور
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: (_isLoggingIn.value || !_authController.isConnected.value)
                  ? null
                  : () {
                Helpers.customSnackBar(
                  title: 'قريباً',
                  message: 'خدمة استعادة كلمة المرور قريباً',
                  background: CupertinoColors.systemBlue,
                );
              },
              style: TextButton.styleFrom(
                overlayColor: Colors.transparent,
              ),
              child: Text(
                'نسيت كلمة المرور؟',
                style: TextStyle(
                  color: (_isLoggingIn.value || !_authController.isConnected.value)
                      ? Colors.grey
                      : theme.primaryColor,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // زر تسجيل الدخول
          _buildLoginButton(theme),

          // إظهار رسالة عند عدم وجود اتصال
          Obx(() {
            if (!_authController.isConnected.value) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'غير متصل بالإنترنت. لا يمكن تسجيل الدخول حالياً',
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

  Widget _buildPasswordField(ThemeData theme) {
    return TextFormField(
      controller: _passwordController,
      textInputAction: TextInputAction.done,
      obscureText: !_isPasswordVisible.value,
      enabled: !_isLoggingIn.value && _authController.isConnected.value,
      decoration: InputDecoration(
        enabled: !_isLoggingIn.value && _authController.isConnected.value,
        prefixIcon: Icon(Iconsax.lock, color: theme.primaryColor),
        suffixIcon: IconButton(
          style: ButtonStyle(
              overlayColor: WidgetStatePropertyAll(Colors.transparent)
          ),
          icon: Icon(
            _isPasswordVisible.value ? Iconsax.eye : Iconsax.eye_slash,
            color: theme.hintColor,
          ),
          onPressed: (_isLoggingIn.value || !_authController.isConnected.value)
              ? null
              : () => _isPasswordVisible.toggle(),
        ),
        labelText: 'كلمة المرور',
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال كلمة المرور';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton(ThemeData theme) {
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
        border: Border.all(width: 1 , color: const Color(0x0ff3c56c)),
      ),
      child: ElevatedButton(
        onPressed: (_isLoggingIn.value || !_authController.isConnected.value)
            ? null
            : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoggingIn.value
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
                _authController.isConnected.value ? Iconsax.login : Icons.wifi_off,
                color: Colors.white
            ),
            const SizedBox(width: 12),
            Text(
              _authController.isConnected.value ? 'تسجيل الدخول' : 'لا يوجد اتصال',
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

  Widget _buildBiometricButton(ThemeData theme) {
    return controller.isLoading.value
        ? const Center(
      child: CircularProgressIndicator(),
    )
        : Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _authController.isConnected.value
              ? theme.colorScheme.secondary.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: ElevatedButton(
        onPressed: (_isLoggingIn.value || !_authController.isConnected.value)
            ? null
            : _handleBiometricLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.finger_scan,
              color: _authController.isConnected.value
                  ? theme.colorScheme.secondary
                  : Colors.grey,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'الدخول بالبصمة',
              style: TextStyle(
                color: _authController.isConnected.value
                    ? theme.colorScheme.secondary
                    : Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterLink(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ليس لديك حساب؟',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        TextButton(
          onPressed:  () {
            Get.to(() => const RegisterScreen(),
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 500),
            );
          },
          style: TextButton.styleFrom(
            overlayColor: Colors.transparent,
          ),
          child: Text(
            'إنشاء حساب جديد',
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
    _isLoggingIn.value = true;

      final result = await _authController.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (result) {
        _showSuccessSnackBar('تم تسجيل الدخول بنجاح');

        await Future.delayed(const Duration(milliseconds: 500));
        await _authController.saveSessionAfterLogin();

        Get.offAll(
              () => HomeScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
      } else {
        _showErrorSnackBar('البريد الإلكتروني أو كلمة المرور غير صحيحة');
      }

  }

  Future<void> _handleBiometricLogin() async {

      // التحقق من الاتصال قبل المتابعة
      final hasConnection = await _authController.checkInternetConnection();
      if (!hasConnection) {
        _showErrorSnackBar('لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك');
        return;
      }

      final success = await controller.authenticate();

      if (success) {
        final result = await _authController.restoreSession();

        if (result) {
          _showSuccessSnackBar('تم تسجيل الدخول بنجاح');
          Get.offAll(() => HomeScreen());
        } else {
          _showErrorSnackBar('حدث خطأ أو أنك لم تسجل دخولك بعد');
        }
      } else if (controller.errorMessage.value == 'LocalAuthException(code noCredentialsSet, null, null)') {
        _showErrorSnackBar('جهازك غير محمي بقفل');
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