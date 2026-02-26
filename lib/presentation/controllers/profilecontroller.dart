import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:water/core/utils/helpers.dart';
import '../../core/supabase/supabase_user_helper.dart';
import '../../data/models/user_model.dart';

class ProfileController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  final SupabaseUserRepository userHelper = SupabaseUserRepository();

  Rx<User?> currentUser = Rx<User?>(null);
  Rx<Map<String, dynamic>> userProfile = Rx<Map<String, dynamic>>({});
  RxBool isLoading = RxBool(false);
  RxBool isUpdatingImage = RxBool(false);
  RxString selectedImagePath = RxString('');

  @override
  void onInit() {
    super.onInit();
    getCurrentUser();
    setupAuthListener();
    getUserProfile(userId: currentUser.value?.id ?? 0);
  }

  // الحصول على المستخدم الحالي
  void getCurrentUser() async {
    try {
      isLoading.value = true;
      final Session? session = supabase.auth.currentSession;
      currentUser.value = session?.user;

      if (currentUser.value != null) {
        await getUserProfile(userId: currentUser.value!.id);
      }
    } catch (e) {
      Helpers.customSnackBar(
        title: 'خطأ',
        message: 'خطأ في الحصول على المستخدم',
        background: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // الاستماع لتغييرات المصادقة
  void setupAuthListener() {
    supabase.auth.onAuthStateChange.listen((AuthState data) {
      final User? user = data.session?.user;
      currentUser.value = user;

      if (user != null) {
        getUserProfile(userId: user.id);
      } else {
        userProfile.value = {};
      }
    });
  }

  // الحصول على بيانات الملف الشخصي
  Future<void> getUserProfile({required userId}) async {
    try {
      isLoading.value = true;

      final data = await supabase
          .from('users')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (data != null) {
        userProfile.value = Map<String, dynamic>.from(data);
      } else {}
    } on PostgrestException catch (e) {
      if (e.code == '406' || e.code == 'PGRST116') {
      } else {
        rethrow;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
  }) async {
    try {
      isLoading.value = true;

      final updatedUser = UserModel(
        name: name,
        phone: phone,
        password: '',
        createdAt: DateTime.now(),
      );

      final updatedData = await userHelper.editeProfile(
        userId: currentUser.value!.id.toString(),
        user: updatedUser,
      );

      getCurrentUser();

      print(updatedData);

      // عرض رسالة نجاح
      if (updatedData.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on PostgrestException catch (e) {
      if (e.message.contains(
        'duplicate key value violates unique constraint "users_phone_key"',
      )) {
        Helpers.customSnackBar(
          title: 'فشل',
          message: 'رقم الهاتف هذا مستخدم بالفعل',
          background: Colors.red,
        );
      }

      rethrow;
    } catch (e) {
      if (e.toString().contains(
        'ClientException with SocketException: Failed host lookup',
      )) {
        Helpers.customSnackBar(
          title: 'خطا!',
          message: 'لا يوجد اتصال بالانترنت',
          background: Colors.red,
        );
      }

      Helpers.customSnackBar(
          title: 'خطا!',
          message: 'فشل  التحديث',
          background: Colors.red
      );

      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    try {
      var response = await supabase.auth.signOut();
      currentUser.value = null;
      userProfile.value = {};

      return response;
    } catch (e) {
      print('خطأ في تسجيل الخروج: $e');
    }
  }

  // التحقق من حالة تسجيل الدخول
  bool get isLoggedIn => currentUser.value != null;

  // جلب بيانات محددة
  String get fullName => userProfile.value['name'] ?? 'غير محدد';
  String get email =>
      userProfile.value['email'] ?? currentUser.value?.email ?? 'غير محدد';
  String get phone => userProfile.value['phone'] ?? 'غير محدد';
  String get createdAt {
    if (currentUser.value?.createdAt != null) {
      final date = currentUser.value!.createdAt;
      return date;
    }
    return 'غير معروف';
  }
}
