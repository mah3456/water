
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:water/core/database/database_constants.dart';
import 'package:water/data/models/user_model.dart';


class SupabaseUserRepository {
  final supabase = Supabase.instance.client;



  void profile({required String userId}){
    try{

      var response = supabase
          .from('users')
          .stream(primaryKey: ['id'])
          .eq('id', userId)
          .single;


      response;
    } on PostgrestException catch(e){
      rethrow;
    }

  }



  Future<AuthResponse> register({required UserModel user}) async {

    final response = await supabase.auth.signUp(
        email: user.email,
        password: user.password,
        data: {
          'name':user.name,
          'phone':user.phone
        },
        emailRedirectTo: 'ss'
    );

    if (response.user != null) {
      // انتظر ثانية قبل محاولة إعادة الإرسال
      await Future.delayed(const Duration(seconds: 2));
      //
      // await supabase.auth.resend(
      //   type: OtpType.email, // أو EmailOtpType.signup للإصدارات الحديثة
      //   email: user.email,
      //   emailRedirectTo: 'YOUR_APP_SCHEME://verify-email',
      // );
    }

    return response;

  }




  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {

    final AuthResponse response = await supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    return response;

  }


  Future<PostgrestList> editeProfile({required UserModel user , required String userId}) async {

    print(userId);


    var response = await supabase.from('users').update({
      'name':  user.name,
      'phone': user.phone,
    }).eq(DatabaseConstants.userId, userId)
      .select();

    return response;

  }





  Future<Map<String, dynamic>> checkUserExists({
    required String email,
    String? phone,
  }) async {
    try {
      final query = supabase
          .from('users')
          .select('user_id, email, phone');

      // التحقق من email
      if (email.isNotEmpty) {
        query.eq('email', email);
      }

      // التحقق من phone إذا كان موجوداً
      if (phone != null && phone.isNotEmpty) {
        query.or('phone.eq.$phone');
      }

      final result = await query;

      return {
        'exists': result.isNotEmpty,
        'users': result,
        'emailExists': result.any((user) => user['email'] == email),
        'phoneExists': phone != null ? result.any((user) => user['phone'] == phone) : false,
      };

    } catch (e) {
      print('Error checking user: $e');
      return {
        'exists': false,
        'users': [],
        'emailExists': false,
        'phoneExists': false,
      };
    }
  }




}