// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../data/models/response.dart';
// import '../../data/models/user_model.dart';
//
// class UserRepository {
//   final supabase = Supabase.instance.client;
//
//   // تسجيل مستخدم جديد باستخدام الاسم، البريد، الهاتف، وكلمة المرور
//   Future<BaseResponse<dynamic>> signUpWithEmailAndPhone({
//     required String fullName,
//     required String email,
//     required String phone,
//     required String password,
//     String? username,
//   }) async {
//     try {
//       print('جاري تسجيل مستخدم جديد:');
//       print('الاسم: $fullName');
//       print('البريد: $email');
//       print('الهاتف: $phone');
//
//       // 1. التحقق من عدم وجود البريد مسبقاً في جدول profiles
//       final existingEmail = await supabase
//           .from('profiles')
//           .select('email')
//           .eq('email', email)
//           .maybeSingle();
//
//       if (existingEmail != null) {
//         return BaseResponse(
//           success: false,
//           message: 'البريد الإلكتروني مسجل بالفعل',
//           error: 'EMAIL_EXISTS',
//           statusCode: 400,
//         );
//       }
//
//       // 2. التحقق من عدم وجود الهاتف مسبقاً
//       final existingPhone = await supabase
//           .from('profiles')
//           .select('phone')
//           .eq('phone', phone)
//           .maybeSingle();
//
//       if (existingPhone != null) {
//         return BaseResponse(
//           success: false,
//           message: 'رقم الهاتف مسجل بالفعل',
//           error: 'PHONE_EXISTS',
//           statusCode: 400,
//         );
//       }
//
//       // 3. إنشاء حساب في Authentication
//       final authResponse = await supabase.auth.signUp(
//         email: email,
//         password: password,
//         data: {
//           'full_name': fullName,
//           'phone': phone,
//           'email': email,
//           'username': username ?? email.split('@')[0],
//         },
//       );
//
//       if (authResponse.user == null) {
//         return BaseResponse(
//           success: false,
//           message: 'فشل إنشاء حساب المستخدم',
//           error: 'USER_CREATION_FAILED',
//           statusCode: 500,
//         );
//       }
//
//       // 4. إنشاء الملف الشخصي في جدول profiles
//       final profileData = {
//         'id': authResponse.user!.id,
//         'full_name': fullName,
//         'email': email,
//         'phone': phone,
//         'username': username ?? email.split('@')[0],
//         'created_at': DateTime.now().toIso8601String(),
//         'updated_at': DateTime.now().toIso8601String(),
//       };
//
//       final profileResponse = await supabase
//           .from('profiles')
//           .insert(profileData)
//           .select()
//           .single();
//
//       // 5. إنشاء سجل في جدول users (إذا كان لديك جدول منفصل)
//       try {
//         final userModel = UserModel(
//           id: authResponse.user!.id,
//           fullName: fullName,
//           email: email,
//           phone: phone,
//           password: password, // Note: لا تخزن كلمة المرور كنص واضح!
//           username: username,
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         );
//
//         await supabase
//             .from('users')
//             .insert(userModel.toMap())
//             .select()
//             .single();
//       } catch (e) {
//         print('ملاحظة: فشل إنشاء سجل في جدول users: $e');
//         // يمكن تجاهل هذا الخطأ إذا كان جدول profiles هو الرئيسي
//       }
//
//       return BaseResponse(
//         success: true,
//         message: authResponse.session == null
//             ? 'تم التسجيل بنجاح. يرجى التحقق من بريدك الإلكتروني'
//             : 'تم التسجيل وتسجيل الدخول بنجاح',
//         statusCode: 200,
//       );
//
//     } on AuthException catch (e) {
//       print('خطأ في المصادقة: ${e.message}');
//       return BaseResponse(
//         success: false,
//         message: _translateAuthError(e.message),
//         error: e.code,
//         statusCode: 0,
//       );
//     } on PostgrestException catch (e) {
//       print('خطأ في قاعدة البيانات: ${e.message}');
//       return BaseResponse(
//         success: false,
//         message: _translateDatabaseError(e.message),
//         error: e.code ?? 'DATABASE_ERROR',
//         statusCode: 500,
//       );
//     } catch (e) {
//       print('خطأ غير متوقع: $e');
//       return BaseResponse(
//         success: false,
//         message: 'حدث خطأ غير متوقع',
//         error: 'UNKNOWN_ERROR',
//         statusCode: 500,
//       );
//     }
//   }
//
//   // تسجيل الدخول باستخدام البريد وكلمة المرور
//   Future<BaseResponse<dynamic>> loginWithEmail({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final response = await supabase.auth.signInWithPassword(
//         email: email,
//         password: password,
//       );
//
//       // جلب بيانات الملف الشخصي
//       final profile = await supabase
//           .from('profiles')
//           .select()
//           .eq('id', response.user!.id)
//           .single();
//
//       return BaseResponse(
//         success: true,
//         message: 'تم تسجيل الدخول بنجاح',
//         statusCode: 200,
//       );
//     } on AuthException catch (e) {
//       return BaseResponse(
//         success: false,
//         message: _translateAuthError(e.message),
//         error: e.code,
//         statusCode: 0,
//       );
//     } catch (e) {
//       return BaseResponse(
//         success: false,
//         message: 'حدث خطأ غير متوقع',
//         error: 'UNKNOWN_ERROR',
//         statusCode: 500,
//       );
//     }
//   }
//
//   // تسجيل الدخول باستخدام الهاتف وكلمة المرور
//   Future<BaseResponse<dynamic>> loginWithPhone({
//     required String phone,
//     required String password,
//   }) async {
//     try {
//       // البحث عن البريد المرتبط بالهاتف
//       final profile = await supabase
//           .from('profiles')
//           .select('email')
//           .eq('phone', phone)
//           .maybeSingle();
//
//       if (profile == null) {
//         return BaseResponse(
//           success: false,
//           message: 'رقم الهاتف غير مسجل',
//           error: 'PHONE_NOT_FOUND',
//           statusCode: 404,
//         );
//       }
//
//       final email = profile['email'] as String;
//
//       // استخدام البريد لتسجيل الدخول
//       final response = await supabase.auth.signInWithPassword(
//         email: email,
//         password: password,
//       );
//
//       return BaseResponse(
//         success: true,
//         message: 'تم تسجيل الدخول بنجاح',
//         statusCode: 200,
//       );
//     } on AuthException catch (e) {
//       return BaseResponse(
//         success: false,
//         message: _translateAuthError(e.message),
//         error: e.code,
//         statusCode: 0,
//       );
//     } catch (e) {
//       return BaseResponse(
//         success: false,
//         message: 'حدث خطأ غير متوقع',
//         error: 'UNKNOWN_ERROR',
//         statusCode: 500,
//       );
//     }
//   }
//
//   // تحديث بيانات المستخدم
//   Future<BaseResponse<dynamic>> updateUserProfile({
//     required String userId,
//     String? fullName,
//     String? email,
//     String? phone,
//     String? username,
//   }) async {
//     try {
//       final updateData = <String, dynamic>{};
//
//       if (fullName != null) updateData['full_name'] = fullName;
//       if (email != null) updateData['email'] = email;
//       if (phone != null) updateData['phone'] = phone;
//       if (username != null) updateData['username'] = username;
//       updateData['updated_at'] = DateTime.now().toIso8601String();
//
//       // التحقق من عدم تكرار البريد إذا تم تحديثه
//       if (email != null) {
//         final existingEmail = await supabase
//             .from('profiles')
//             .select('id')
//             .eq('email', email)
//             .neq('id', userId)
//             .maybeSingle();
//
//         if (existingEmail != null) {
//           return BaseResponse(
//             success: false,
//             message: 'البريد الإلكتروني مسجل بالفعل',
//             error: 'EMAIL_EXISTS',
//             statusCode: 400,
//           );
//         }
//       }
//
//       // التحقق من عدم تكرار الهاتف إذا تم تحديثه
//       if (phone != null) {
//         final existingPhone = await supabase
//             .from('profiles')
//             .select('id')
//             .eq('phone', phone)
//             .neq('id', userId)
//             .maybeSingle();
//
//         if (existingPhone != null) {
//           return BaseResponse(
//             success: false,
//             message: 'رقم الهاتف مسجل بالفعل',
//             error: 'PHONE_EXISTS',
//             statusCode: 400,
//           );
//         }
//       }
//
//       final response = await supabase
//           .from('profiles')
//           .update(updateData)
//           .eq('id', userId)
//           .select()
//           .single();
//
//       return BaseResponse(
//         success: true,
//         message: 'تم تحديث البيانات بنجاح',
//         statusCode: 200,
//       );
//     } on PostgrestException catch (e) {
//       return BaseResponse(
//         success: false,
//         message: _translateDatabaseError(e.message),
//         error: e.code ?? 'DATABASE_ERROR',
//         statusCode: 500,
//       );
//     } catch (e) {
//       return BaseResponse(
//         success: false,
//         message: 'حدث خطأ غير متوقع',
//         error: 'UNKNOWN_ERROR',
//         statusCode: 500,
//       );
//     }
//   }
//
//   // تغيير كلمة المرور
//   Future<BaseResponse<dynamic>> changePassword({
//     required String currentPassword,
//     required String newPassword,
//   }) async {
//     try {
//       final user = supabase.auth.currentUser;
//       if (user == null) {
//         return BaseResponse(
//           success: false,
//           message: 'يجب تسجيل الدخول أولاً',
//           error: 'NOT_AUTHENTICATED',
//           statusCode: 401,
//         );
//       }
//
//       // تحديث كلمة المرور
//       await supabase.auth.updateUser(
//         UserAttributes(password: newPassword),
//       );
//
//       return BaseResponse(
//         success: true,
//         message: 'تم تغيير كلمة المرور بنجاح',
//         statusCode: 200,
//       );
//     } on AuthException catch (e) {
//       return BaseResponse(
//         success: false,
//         message: _translateAuthError(e.message),
//         error: e.code,
//         statusCode: 0,
//       );
//     } catch (e) {
//       return BaseResponse(
//         success: false,
//         message: 'حدث خطأ غير متوقع',
//         error: 'UNKNOWN_ERROR',
//         statusCode: 500,
//       );
//     }
//   }
//
//   // التحقق من وجود بريد
//   Future<bool> checkEmailExists(String email, {String? excludeUserId}) async {
//     try {
//       var query = supabase
//           .from('profiles')
//           .select('id')
//           .eq('email', email);
//
//       if (excludeUserId != null) {
//         query = query.neq('id', excludeUserId);
//       }
//
//       final response = await query.maybeSingle();
//       return response != null;
//     } catch (e) {
//       print('خطأ في التحقق من البريد: $e');
//       return false;
//     }
//   }
//
//   // التحقق من وجود هاتف
//   Future<bool> checkPhoneExists(String phone, {String? excludeUserId}) async {
//     try {
//       var query = supabase
//           .from('profiles')
//           .select('id')
//           .eq('phone', phone);
//
//       if (excludeUserId != null) {
//         query = query.neq('id', excludeUserId);
//       }
//
//       final response = await query.maybeSingle();
//       return response != null;
//     } catch (e) {
//       print('خطأ في التحقق من الهاتف: $e');
//       return false;
//     }
//   }
//
//   // الحصول على بيانات الملف الشخصي
//   Future<Map<String, dynamic>?> getUserProfile(String userId) async {
//     try {
//       return await supabase
//           .from('profiles')
//           .select()
//           .eq('id', userId)
//           .maybeSingle();
//     } catch (e) {
//       print('خطأ في جلب الملف الشخصي: $e');
//       return null;
//     }
//   }
//
//   // الحصول على بيانات الملف الشخصي (دالة خاصة)
//   Future<Map<String, dynamic>?> _getUserProfile(String userId) async {
//     try {
//       return await supabase
//           .from('profiles')
//           .select()
//           .eq('id', userId)
//           .maybeSingle();
//     } catch (e) {
//       return null;
//     }
//   }
//
//   // ترجمة أخطاء المصادقة
//   String _translateAuthError(String message) {
//     if (message.contains('Invalid login credentials')) {
//       return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
//     } else if (message.contains('Email not confirmed')) {
//       return 'يرجى تأكيد بريدك الإلكتروني أولاً';
//     } else if (message.contains('User already registered')) {
//       return 'البريد الإلكتروني مسجل بالفعل';
//     } else if (message.contains('Password should be at least')) {
//       return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
//     } else if (message.contains('Invalid email')) {
//       return 'البريد الإلكتروني غير صالح';
//     } else if (message.contains('Phone number already exists')) {
//       return 'رقم الهاتف مسجل بالفعل';
//     } else if (message.contains('rate limit')) {
//       return 'لقد حاولت كثيراً، انتظر قليلاً ثم حاول مرة أخرى';
//     }
//     return message;
//   }
//
//   // ترجمة أخطاء قاعدة البيانات
//   String _translateDatabaseError(String message) {
//     if (message.contains('duplicate key')) {
//       if (message.contains('email')) {
//         return 'البريد الإلكتروني مسجل بالفعل';
//       } else if (message.contains('phone')) {
//         return 'رقم الهاتف مسجل بالفعل';
//       } else if (message.contains('username')) {
//         return 'اسم المستخدم مسجل بالفعل';
//       }
//     } else if (message.contains('violates foreign key constraint')) {
//       return 'البيانات المرتبطة غير صحيحة';
//     } else if (message.contains('null value')) {
//       return 'يجب ملء جميع الحقول المطلوبة';
//     }
//     return 'حدث خطأ في قاعدة البيانات';
//   }
//
//   // إعادة تعيين كلمة المرور
//   Future<BaseResponse<dynamic>> resetPassword(String email) async {
//     try {
//       await supabase.auth.resetPasswordForEmail(
//         email,
//         redirectTo: 'YOUR_APP://reset-password',
//       );
//
//       return BaseResponse(
//         success: true,
//         message: 'تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني',
//         statusCode: 200,
//       );
//     } on AuthException catch (e) {
//       return BaseResponse(
//         success: false,
//         message: _translateAuthError(e.message),
//         error: e.code,
//         statusCode: 0,
//       );
//     } catch (e) {
//       return BaseResponse(
//         success: false,
//         message: 'حدث خطأ غير متوقع',
//         error: 'UNKNOWN_ERROR',
//         statusCode: 500,
//       );
//     }
//   }
//
//   // تسجيل الخروج
//   Future<BaseResponse<dynamic>> logout() async {
//     try {
//       await supabase.auth.signOut();
//       return BaseResponse(
//         success: true,
//         message: 'تم تسجيل الخروج بنجاح',
//         statusCode: 200,
//       );
//     } catch (e) {
//       return BaseResponse(
//         success: false,
//         message: 'حدث خطأ أثناء تسجيل الخروج',
//         error: 'LOGOUT_ERROR',
//         statusCode: 500,
//       );
//     }
//   }
//
//   // الحصول على المستخدم الحالي
//   Future<BaseResponse<dynamic>> getCurrentUser() async {
//     try {
//       final user = supabase.auth.currentUser;
//       if (user == null) {
//         return BaseResponse(
//           success: false,
//           message: 'لم يتم تسجيل الدخول',
//           error: 'NOT_AUTHENTICATED',
//           statusCode: 401,
//         );
//       }
//
//       final profile = await _getUserProfile(user.id);
//
//       return BaseResponse(
//         success: true,
//         message: 'تم جلب بيانات المستخدم',
//         statusCode: 200,
//       );
//     } catch (e) {
//       return BaseResponse(
//         success: false,
//         message: 'حدث خطأ في جلب بيانات المستخدم',
//         error: 'FETCH_ERROR',
//         statusCode: 500,
//       );
//     }
//   }
//
//   // حذف الحساب
//   Future<BaseResponse<dynamic>> deleteAccount() async {
//     try {
//       final user = supabase.auth.currentUser;
//       if (user == null) {
//         return BaseResponse(
//           success: false,
//           message: 'لم يتم تسجيل الدخول',
//           error: 'NOT_AUTHENTICATED',
//           statusCode: 401,
//         );
//       }
//
//       // حذف الملف الشخصي
//       await supabase.from('profiles').delete().eq('id', user.id);
//
//       // حذف المستخدم من Authentication
//       await supabase.auth.admin.deleteUser(user.id);
//
//       return BaseResponse(
//         success: true,
//         message: 'تم حذف الحساب بنجاح',
//         statusCode: 200,
//       );
//     } catch (e) {
//       return BaseResponse(
//         success: false,
//         message: 'حدث خطأ أثناء حذف الحساب',
//         error: 'DELETE_ERROR',
//         statusCode: 500,
//       );
//     }
//   }
// }