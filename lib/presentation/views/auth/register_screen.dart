import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final RxBool _isPasswordVisible = false.obs;
  final RxBool _isPasswordVisible1 = false.obs;
  final RxBool _isSubmitting = false.obs; // حالة خاصة بالتسجيل

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    'إنشاء حساب جديد',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 100),
                  _textFormField(
                    controller: _nameController,
                    label: 'الاسم الكامل',
                    icon: const Icon(Icons.person),
                    inputType: TextInputType.text,
                    lines: 1,
                    validiting: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال الاسم';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  EmailValidationTextField(
                    whenTextFieldEmpty: "يرجى إدخال البريد الالكتروني",
                    validatorMassage: "البريد غير صالح",
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email),
                      label: const Text('البريد الالكتروني' , style: TextStyle(color: Colors.grey),),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade700,
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1.0,
                        ),
                      ),
                      border: const OutlineInputBorder(),
                      counterText: '',
                      hintStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                      ),
                    ),
                    textEditingController: _emailController,
                  ),
                  const SizedBox(height: 20),
                  _textFormField(
                    controller: _phoneController,
                    label: 'رقم الهاتف',
                    icon: const Icon(Icons.phone),
                    inputType: TextInputType.phone,
                    lines: 1,
                    validiting: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال رقم الهاتف';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Obx(() => PassWordValidationTextFiled(
                    lineIndicator: false,
                    passwordMinError: "كلمة المرور اقل من 6 أحرف",
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
                      suffixIcon: IconButton(
                        style: const ButtonStyle(
                          overlayColor: WidgetStatePropertyAll(
                            Colors.transparent,
                          ),
                        ),
                        icon: Icon(
                          _isPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          _isPasswordVisible.toggle();
                        },
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      label: const Text('كلمة المرور' ,style: TextStyle(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade700,
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1.0,
                        ),
                      ),
                      border: const OutlineInputBorder(),
                      counterText: '',
                      hintStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                      ),
                    ),
                  )),
                  const SizedBox(height: 20),
                  Obx(() => ConfirmPassWordValidationTextFromField(
                    obscureText: !_isPasswordVisible1.value,
                    scrollPadding: const EdgeInsets.only(left: 60),
                    whenTextFieldEmpty: "يرجى تأكيد كلمة المرور",
                    validatorMassage: "كلمتا المرور غير متطابقتين",
                    confirmtextEditingController: _confirmPasswordController,
                    passtextEditingController: _passwordController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      label: const Text('تأكيد كلمة المرور' ,style: TextStyle(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade700,
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1.0,
                        ),
                      ),
                      border: const OutlineInputBorder(),
                      counterText: '',
                      hintStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                      ),
                      suffixIcon: IconButton(
                        style: const ButtonStyle(
                          overlayColor: WidgetStatePropertyAll(
                            Colors.transparent,
                          ),
                        ),
                        icon: Icon(
                          _isPasswordVisible1.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          _isPasswordVisible1.toggle();
                        },
                      ),
                    ),
                  )),
                  const SizedBox(height: 30),
                  Obx(() => ElevatedButton(
                    onPressed: _isSubmitting.value ? null : () => _submit(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CupertinoColors.systemBlue,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: _isSubmitting.value
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'إنشاء حساب',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'لديك حساب بالفعل؟',
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                        style: const ButtonStyle(
                          overlayColor:
                          WidgetStatePropertyAll(Colors.transparent),
                        ),
                        onPressed: _isSubmitting.value
                            ? null
                            : () {
                          Get.to(
                                () =>  LoginScreen(),
                            transition: Transition.fadeIn,
                            duration: const Duration(milliseconds: 500),
                          );
                        },
                        child: Text(
                          'سجل الدخول',
                          style: TextStyle(
                            color: _isSubmitting.value
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
          // شاشة التحميل الشفافة
          Obx(() => _isSubmitting.value
              ? LoadingWidget()
              : const SizedBox.shrink()),
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
  }) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        prefixIcon: icon,
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey.shade700,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey.shade400,
            width: 1.0,
          ),
        ),
      ),
      maxLines: lines,
      keyboardType: inputType,
      validator: validiting,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus(); // إخفاء لوحة المفاتيح

    _isSubmitting.value = true;

    try {
      final newUser = UserModel(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        createdAt: DateTime.now(),
      );

      final result = await _authController.register(user: newUser);

      if (result) {
        // عرض رسالة النجاح
        Helpers.customSnackBar(
          title: 'تم',
          message: 'تم إنشاء حسابك بنجاح',
          background: CupertinoColors.systemGreen,
        );

        // الانتقال بعد تأخير قصير
        await Future.delayed(const Duration(milliseconds: 800));

        // الانتقال لشاشة الدخول
        Get.offAll(
              () =>  LoginScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
      } else {
        Helpers.customSnackBar(
          title: 'فشل',
          message: 'حدث خطأ أثناء إنشاء الحساب',
          background: Colors.red,
        );
      }
    } finally {
      _isSubmitting.value = false;
    }
  }
}