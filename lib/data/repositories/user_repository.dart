import 'package:sqflite/sqflite.dart';
import '../../core/database/database_constants.dart';
import '../../core/database/database_helper.dart';
import '../models/user_model.dart';

class UserRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertUser(UserModel user) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      DatabaseConstants.usersTable,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUserByPhone(String phone) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.usersTable,
      where: '${DatabaseConstants.userPhone} = ?',
      whereArgs: [phone],
    );
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<UserModel?> login(String phone, String password) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.usersTable,
      where: '${DatabaseConstants.userPhone} = ? AND ${DatabaseConstants.userPassword} = ?',
      whereArgs: [phone, password],
    );
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps =
    await db.query(DatabaseConstants.usersTable);
    return List.generate(maps.length, (i) {
      return UserModel.fromMap(maps[i]);
    });
  }

  // دالة جديدة لتحديث بيانات المستخدم
  Future<int> updateUser(UserModel user) async {
    final db = await _databaseHelper.database;
    var response = await db.update(
      DatabaseConstants.usersTable,
      user.toMap(),
      where: '${DatabaseConstants.userId} = ?',
      whereArgs: [user.id],
    );

    return response;
  }

  // دالة لتغيير كلمة المرور
  Future<int> changePassword(int userId, String newPassword) async {
    final db = await _databaseHelper.database;
    var response =  await db.update(
      DatabaseConstants.usersTable,
      {DatabaseConstants.userPassword: newPassword},
      where: '${DatabaseConstants.userId} = ?',
      whereArgs: [userId],
    );

    return response;
  }
}