import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:get_storage/get_storage.dart';

class FingerprintController extends GetxController {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final GetStorage _storage = GetStorage();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final isAuthenticated = false.obs;
  final isFingerprintEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkFingerprintStatus();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      // تهيئة البصمة بشكل آمن
      final bool canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) {
        errorMessage.value = 'الجهاز لا يدعم المصادقة الحيوية';
      }
    } catch (e) {
      print('خطأ في التهيئة: $e');
    }
  }

  void checkFingerprintStatus() {
    isFingerprintEnabled.value = _storage.read('isFingerprintEnabled') ?? false;
  }

  Future<bool> _checkBiometrics() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        errorMessage.value = 'الجهاز لا يدعم البصمة';
        return false;
      }

      final List<BiometricType> availableBiometrics =
      await _localAuth.getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        errorMessage.value = 'لا توجد بصمة مسجلة في الجهاز';
        return false;
      }

      return true;
    } catch (e) {
      errorMessage.value = 'خطأ في التحقق من البصمة';
      return false;
    }
  }

  // **الطريقة المعدلة لتجنب FragmentActivity error**
  Future<bool> authenticate() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // طريقة متوافقة مع الإصدار القديم
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'المصادقة مطلوبة لفتح التطبيق',
        biometricOnly: false, // اسمح باستخدام PIN/Password كبديل
      );

      if (didAuthenticate) {
        isAuthenticated.value = true;

      } else {
        errorMessage.value = 'تم إلغاء المصادقة';
      }

      isLoading.value = false;
      return didAuthenticate;
    } catch (e) {
      isLoading.value = false;

      // معالجة الأخطاء الخاصة
     errorMessage.value = e.toString();
     print('error : ${errorMessage.value}');


      return false;
    }
  }

  Future<void> toggleFingerprint(bool value) async {
    if (value) {
      final bool canAuthenticate = await _checkBiometrics();
      if (canAuthenticate) {
        // طلب المصادقة مباشرة
        final bool authenticated = await authenticate();
        if (authenticated) {
          isFingerprintEnabled.value = true;
          await _storage.write('isFingerprintEnabled', true);
          Get.snackbar('نجاح', 'تم تفعيل فتح التطبيق بالبصمة');
        }
      } else {
        // إذا لم يكن هناك بصمة، عطل الميزة
        isFingerprintEnabled.value = false;
        Get.snackbar('تحذير', 'لا يمكن تفعيل البصمة');
      }
    } else {
      isFingerprintEnabled.value = false;
      await _storage.write('isFingerprintEnabled', false);
      Get.snackbar('نجاح', 'تم تعطيل فتح التطبيق بالبصمة');
    }
  }

  // طريقة بديلة للمصادقة (أكثر أماناً)
  Future<bool> authenticateWithFallback() async {
    try {
      return await authenticate();
    } catch (e) {
      // إذا فشلت البصمة، استخدم بديل
      Get.defaultDialog(
        title: 'المصادقة البديلة',
        middleText: 'فشلت البصمة. هل تريد استخدام كلمة المرور؟',
        textConfirm: 'نعم',
        textCancel: 'لا',
        onConfirm: () {
          Get.back();
          // هنا يمكنك إضافة كود المصادقة البديلة
          isAuthenticated.value = true;
        },
        onCancel: () => Get.back(),
      );
      return false;
    }
  }

  Future<bool> checkOnAppStart() async {
    if (!isFingerprintEnabled.value) {
      return true; // السماح بالدخول إذا كانت البصمة غير مفعلة
    }

    return await authenticate();
  }
}


