
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water/main.dart';
import '../../core/supabase/supabase_user_helper.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/user_model.dart';


class AuthController extends GetxController {
  final SupabaseUserRepository _userRepository = SupabaseUserRepository();

  var isLoggedIn = false.obs;
  var isLoading = false.obs;

  var isConnected = true.obs; // متغير لتتبع حالة الاتصال

  // دالة للتحقق من الاتصال بالإنترنت عبر Supabase
  Future<bool> checkInternetConnection() async {
    try {
      // محاولة الاتصال بـ Supabase للتحقق من وجود إنترنت فعلي
      // نستخدم استعلام بسيط جداً مع مهلة قصيرة
      final response = await _userRepository.supabase
          .from('clients') // قد تحتاج إلى تعديل هذا
          .select('*')
          .limit(1)
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Connection timeout');
        },
      );

      // إذا وصلنا إلى هنا، فهذا يعني أن هناك اتصال فعلي بالإنترنت
      isConnected.value = true;
      print('✅ اتصال بالإنترنت موجود');
      return true;
    } on TimeoutException catch (_) {
      // انتهت المهلة - لا يوجد استجابة من الخادم
      isConnected.value = false;
      print('❌ انتهت مهلة الاتصال - لا يوجد إنترنت');
      return false;
    } on SocketException catch (_) {
      // خطأ في المقبس - لا يوجد اتصال بالشبكة
      isConnected.value = false;
      print('❌ خطأ في المقبس - لا يوجد اتصال بالشبكة');
      return false;
    } catch (e) {
      // إذا كان الخطأ بسبب عدم وجود جدول health_check،
      // فهذا يعني أن الخادم استجاب ولكن الجدول غير موجود
      // بالتالي هناك اتصال بالإنترنت!
      if (e.toString().contains('relation') && e.toString().contains('does not exist')) {
        isConnected.value = true;
        print('✅ الخادم استجاب (الجدول غير موجود) - يوجد إنترنت');
        return true;
      }

      // إذا كان الخطأ من نوع ClientException (مشكلة في الشبكة)
      if (e.toString().contains('ClientException') ||
          e.toString().contains('Network is unreachable') ||
          e.toString().contains('Failed host lookup')) {
        isConnected.value = false;
        print('❌ ClientException - لا يوجد إنترنت');
        return false;
      }

      // أي خطأ آخر قد يعني أن الخادم استجاب ولكن هناك مشكلة أخرى
      // لذلك نعتبر أن هناك اتصال
      print('⚠️ خطأ غير معروف ولكن قد يكون هناك اتصال: $e');
      isConnected.value = true;
      return true;
    }
  }


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

      if(e.toString().contains('ClientException with SocketException: Failed host lookup')){
        Helpers.customSnackBar(
            title: 'خطا!',
            message: 'لا يوجد اتصال بالانترنت',
            background: Colors.red
        );
      }

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



// بعد نجاح تسجيل الدخول
  Future<void> saveSessionAfterLogin() async {
    final session = _userRepository.supabase.auth.currentSession;
    if (session != null) {

      final sessionJson = session.toJson();

      await shared.setString('supabase_session', jsonEncode(sessionJson));

      await shared.setString('access_token', session.accessToken);

    }
  }

// في مكان آخر من الكود
  Future<bool> restoreSession() async {
    try {

      final String? sessionString = await shared.getString('supabase_session');

      if (sessionString != null){

        final response = await SupabaseUserRepository().supabase.auth.recoverSession(sessionString);

        print(response.user != null);

        if(response.user != null){
          return true;
        } else{
          return false;
        }

      } else{
        return false;
      }

    }  catch (e) {

      if(e.toString().contains('ClientException with SocketException: Failed host lookup')){
        Helpers.customSnackBar(
            title: 'خطا!',
            message: 'لا يوجد اتصال بالانترنت',
            background: Colors.red
        );
      }

      isLoading.value = false;

      if(e.toString().contains('AuthApiException') & e.toString().contains('Invalid Refresh Token: Refresh Token Not Found')){
        Get.snackbar(
          ' خطا!',
          'يجب عليك تسجيل الدخول',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }else if(e.toString().contains('AuthApiException') & e.toString().contains('Invalid Refresh Token: Already Used')){
        Get.snackbar(
          ' خطا!',
          'يجب عليك تسجيل الدخول',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

      rethrow;
    } finally{
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

      if(e.toString().contains('ClientException with SocketException: Failed host lookup')){
        Helpers.customSnackBar(
            title: 'خطا!',
            message: 'لا يوجد اتصال بالانترنت',
            background: Colors.red
        );
      }

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

}