
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/supabase/supabase_user_helper.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/user_model.dart';


class AuthController extends GetxController {
  final SupabaseUserRepository _userRepository = SupabaseUserRepository();

  var isLoggedIn = false.obs;
  var currentUser = Rxn<UserModel>();
  var isLoading = false.obs;



  Future<bool> register({required UserModel user}) async {
    try {
      isLoading.value = true;

      var response = await _userRepository.register(user: user);


      print(response.user);

      if(response.user != null){
        return true;
      } else {
        return false;
      }

    } catch (e) {
      isLoading.value = false;

      if(e.toString().contains('AuthWeakPasswordException') && e.toString().contains('Password should be at least 6 characters')){
        Helpers.customSnackBar(
            title: 'فشل',
            message:' كلمة المرور اقل من 6 احرف',
            background: Colors.red
        );

      } else if(e.toString().contains('AuthApiException') && e.toString().contains('email rate limit exceeded')){
        Helpers.customSnackBar(
            title: 'فشل',
            message:' الرجاء محاولة التسجيل بعد ساعه',
            background: Colors.red
        );
      } else if(e.toString().contains('AuthRetryableFetchException') && e.toString().contains('Error sending confirmation email')){
        Helpers.customSnackBar(
            title: 'فشل',
            message:' فشل ارسال التحقق من البريد',
            background: Colors.red
        );
      }
      rethrow;
    } finally {
      isLoading.value = false;
    }


  }




  Future<bool> login({required String email, required String password}) async {
    try {
      isLoading.value = true;

      final response = await _userRepository.signIn(email: email , password: password);


      print(response.user);

      if (response.user  != null) {
        return true;
      } else {
        return false;
      }

    } catch (e) {
      isLoading.value = false;

      if(e.toString().contains('AuthApiException') && e.toString().contains('Invalid login credentials')){
        Helpers.customSnackBar(
            title: 'فشل',
            message:'خطا البريد او كلمة المرور',
            background: Colors.red
        );
      }

      rethrow;
    } finally {
      isLoading.value = false;
    }
  }


  // دالة لتحديث بيانات المستخدم
  // Future<bool> updateProfile({required String name, required String phone}) async {
  //   try {
  //
  //     if (currentUser.value == null) return false;
  //
  //     isLoading.value = true;
  //
  //
  //     final updatedUser = UserModel(
  //       id: currentUser.value!.id,
  //       name: name,
  //       phone: phone,
  //       password: currentUser.value!.password,
  //       createdAt: currentUser.value!.createdAt,
  //     );
  //
  //     var response = await _userRepository.editeProfile(user: updatedUser);
  //
  //     currentUser.value = updatedUser;
  //
  //     isLoading.value = false;
  //
  //     print(response);
  //
  //     if(response.isNotEmpty){
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } catch (e) {
  //     isLoading.value = false;
  //     Get.snackbar('خطأ', e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
  //     return false;
  //   }
  // }


  //
  // // دالة لتغيير كلمة المرور
  // Future<bool> changePassword(String oldPassword, String newPassword) async {
  //   try {
  //     if (currentUser.value == null) return false;
  //
  //     isLoading.value = true;
  //
  //     // التحقق من كلمة المرور القديمة
  //     final user = await _userRepository.login(currentUser.value!.phone, oldPassword);
  //
  //     if (user == null) {
  //       Helpers.customSnackBar(
  //           title: 'خطأ',
  //           message: 'كلمة المرور الحالية غير صحيحة',
  //           background: Colors.red
  //       );
  //       isLoading.value = false;
  //       return false;
  //     }
  //
  //     var res = await _userRepository.changePassword(currentUser.value!.id!, newPassword);
  //
  //     // تحديث كائن المستخدم الحالي
  //     if(res > 0){
  //       currentUser.value = UserModel(
  //         id: currentUser.value!.id,
  //         name: currentUser.value!.name,
  //         phone: currentUser.value!.phone,
  //         password: newPassword,
  //         createdAt: currentUser.value!.createdAt,
  //       );
  //
  //       isLoading.value = false;
  //
  //       return true;
  //     } else{
  //       return false;
  //     }
  //
  //
  //   } on DatabaseException catch (e) {
  //     isLoading.value = false;
  //     Get.snackbar('خطأ', e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
  //     rethrow;
  //   }
  // }
  //
  //
  // void logout() {
  //   isLoggedIn.value = false;
  //   currentUser.value = null;
  //   Get.offAllNamed('/login');
  //   Get.snackbar('تم', 'تم تسجيل الخروج بنجاح',
  //       backgroundColor: Colors.blue, colorText: Colors.white);
  // }





}