
import '../../core/database/database_constants.dart';

class UserModel {
  int? id;
  String name;
  String phone;
  String password;
  String? email;
  DateTime createdAt;

  UserModel({
    this.id,
    this.email,
    required this.name,
    required this.phone,
    required this.password,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      DatabaseConstants.userName: name,
      DatabaseConstants.userPhone: phone,
      DatabaseConstants.userEmail: email,
      DatabaseConstants.userPassword: password,
      DatabaseConstants.createdAt: createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map[DatabaseConstants.userId],
      name: map[DatabaseConstants.userName],
      phone: map[DatabaseConstants.userPhone],
      email: map[DatabaseConstants.userEmail],
      password: map[DatabaseConstants.userPassword],
      createdAt: DateTime.parse(map[DatabaseConstants.createdAt]),
    );
  }
}