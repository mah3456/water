import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:validation_textformfield/validation_textformfield.dart';
import 'package:water/core/utils/helpers.dart';
import 'package:water/presentation/views/auth/register_screen.dart';
import 'package:water/wigets/loading_widget.dart';
import '../../controllers/auth_controller.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final RxBool _isPasswordVisible = false.obs;
  final RxBool _isLoggingIn = false.obs; // حالة خاصة بتسجيل الدخول

  @override
  void dispose() {
    Future.delayed(Duration(seconds: 1)).then((value) {
      _emailController.dispose();
      _passwordController.dispose();
      _emailController.clear();
      _passwordController.clear();
    },);
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    const Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 70),
                    const Icon(
                      Icons.water_drop,
                      size: 80,
                      color: CupertinoColors.systemBlue,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'نظام إدارة العملاء',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.systemBlue,
                      ),
                    ),
                    const SizedBox(height: 60),
                    EmailValidationTextField(
                      whenTextFieldEmpty: "يرجى إدخال البريد الإلكتروني",
                      validatorMassage: "البريد غير صالح",
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email),
                        label: const Text('البريد الإلكتروني', style: TextStyle(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.shade700,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        border: const OutlineInputBorder(),
                        counterText: '',
                        hintStyle: const TextStyle(
                          color: Colors.black54,
                          fontSize: 16.0,
                        ),
                      ),
                      textEditingController: _emailController,
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => _textFormField(
                        controller: _passwordController,
                        label: 'كلمة المرور',
                        icon: const Icon(Icons.lock),
                        inputType: TextInputType.visiblePassword,
                        lines: 1,
                        enabled: !_isLoggingIn.value,
                        obscureText: !_isPasswordVisible.value,
                        suffixIcon: IconButton(
                          style: const ButtonStyle(
                            overlayColor: WidgetStatePropertyAll(
                              Colors.transparent,
                            ),
                          ),
                          icon: Icon(
                            _isPasswordVisible.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: _isLoggingIn.value
                              ? null
                              : () {
                                  _isPasswordVisible.toggle();
                                },
                        ),
                        validiting: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال كلمة مرور';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: _isLoggingIn.value
                            ? null
                            : () {
                                // إضافة وظيفة استعادة كلمة المرور هنا
                                Helpers.customSnackBar(
                                  title: 'قريباً',
                                  message: 'خدمة استعادة كلمة المرور قريباً',
                                  background: CupertinoColors.systemBlue,
                                );
                              },
                        child: Text(
                          'نسيت كلمة المرور؟',
                          style: TextStyle(
                            color: _isLoggingIn.value
                                ? Colors.grey
                                : CupertinoColors.systemBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Obx(
                      () => ElevatedButton(
                        onPressed: _isLoggingIn.value
                            ? null
                            : () {
                                _submit();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CupertinoColors.systemBlue,
                          disabledBackgroundColor: CupertinoColors.systemBlue
                              .withOpacity(0.5),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoggingIn.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'تسجيل الدخول',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'ليس لديك حساب؟',
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: _isLoggingIn.value
                              ? null
                              : () {
                                  Get.to(
                                    () => const RegisterScreen(),
                                    transition: Transition.fadeIn,
                                    duration: const Duration(milliseconds: 500),
                                  );
                                },
                          child: Text(
                            'إنشاء حساب جديد',
                            style: TextStyle(
                              color: _isLoggingIn.value
                                  ? Colors.grey
                                  : Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // شاشة التحميل الشفافة
          Obx(
            () => _isLoggingIn.value
                ? LoadingWidget()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _textFormField({
    required TextEditingController controller,
    required String label,
    required Widget icon,
    FormFieldValidator<String>? validiting,
    required TextInputType inputType,
    required int lines,
    bool obscureText = false,
    Widget? suffixIcon,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      enabled: enabled,
      decoration: InputDecoration(
        labelStyle:TextStyle(color: Colors.grey),
        labelText: label,
        prefixIcon: icon,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade700, width: 1.0),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      maxLines: lines,
      keyboardType: inputType,
      obscureText: obscureText,
      validator: validiting,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus(); // إخفاء لوحة المفاتيح

    _isLoggingIn.value = true;

    try {
      final result = await _authController.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (result) {
        // عرض رسالة النجاح
        Helpers.customSnackBar(
          title: 'تم',
          message: 'تم تسجيل الدخول بنجاح',
          background: CupertinoColors.systemGreen,
          duration: const Duration(seconds: 1),
        );

        // مسح الحقول


        // الانتقال بعد تأخير قصير
        await Future.delayed(const Duration(milliseconds: 500));

        // الانتقال للشاشة الرئيسية
        Get.offAll(
          () => HomeScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
      } else {
        Helpers.customSnackBar(
          title: 'خطأ',
          message: 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
          background: CupertinoColors.systemRed,
        );
      }
    } finally {
      _isLoggingIn.value = false;
    }
  }
}
