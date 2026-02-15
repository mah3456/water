//
// import '../core/database/database_helper.dart';
// import 'models/client_model.dart';
// import 'models/user_model.dart';
//
// class SeedData {
//   static Future<void> seedInitialData() async {
//     try {
//       final dbHelper = DatabaseHelper();
//       final db = await dbHelper.database;
//
//       // التحقق إذا كان جدول المستخدمين موجوداً
//       try {
//         final users = await db.rawQuery('SELECT COUNT(*) as count FROM users');
//         final count = users.first['count'] as int;
//         if (count > 0) {
//           print('✅ البيانات موجودة بالفعل');
//           return;
//         }
//       } catch (e) {
//         // الجدول غير موجود، نستمر في الإنشاء
//         print('📝 الجداول غير موجودة، سيتم إنشاؤها...');
//       }
//
//       print('🚀 بدء تهيئة قاعدة البيانات...');
//
//       // إضافة مستخدم افتراضي
//       final adminUser = UserModel(
//         name: 'مدير النظام',
//         phone: '07701234567',
//         password: 'admin123',
//         createdAt: DateTime.now(),
//       );
//
//       final userId = await db.insert('users', adminUser.toMap());
//       print('✅ تم إضافة المستخدم الافتراضي (ID: $userId)');
//
//       // إضافة عملاء افتراضيين
//       final defaultClients = [
//         ClientModel(
//           name: 'أحمد محمد',
//           phone: '07701234568',
//           address: 'المنطقة الشرقية - شارع النخيل',
//           meterNumber: 'MTR001',
//           totalDebt: 15000,
//           currentBill: 5000,
//           notes: 'عميل منتظم في الدفع',
//           createdAt: DateTime.now(),
//           createdBy: userId,
//         ),
//         ClientModel(
//           name: 'سعاد علي',
//           phone: '07701234569',
//           address: 'المنطقة الغربية - حي الأندلس',
//           meterNumber: 'MTR002',
//           totalDebt: 25000,
//           currentBill: 8000,
//           notes: 'تحتاج متابعة',
//           createdAt: DateTime.now(),
//           createdBy: userId,
//         ),
//         ClientModel(
//           name: 'خالد حسن',
//           phone: '07701234570',
//           address: 'المنطقة الشمالية - شارع الصناعة',
//           meterNumber: 'MTR003',
//           totalDebt: 5000,
//           currentBill: 2000,
//           notes: null,
//           createdAt: DateTime.now(),
//           createdBy: userId,
//         ),
//       ];
//
//       for (final client in defaultClients) {
//         final clientId = await db.insert('clients', client.toMap());
//         print('✅ تم إضافة العميل: ${client.name} (ID: $clientId)');
//       }
//
//       print('🎉 تم إضافة البيانات الأولية بنجاح');
//     } catch (e) {
//       print('❌ خطأ في إضافة البيانات الأولية: $e');
//       rethrow;
//     }
//   }
// }