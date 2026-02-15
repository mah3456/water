
import '../../core/database/database_constants.dart';

class ClientModel {
  int? id;
  String name;
  String phone;
  String address;
  String meterNumber;
  double totalDebt;
  double currentBill;
  String? notes;
  DateTime createdAt;
  String? createdBy;

  ClientModel({
    this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.meterNumber,
    this.totalDebt = 0,
    this.currentBill = 0,
    this.notes,
    required this.createdAt,
    this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      DatabaseConstants.clientName: name,
      DatabaseConstants.clientPhone: phone,
      DatabaseConstants.clientAddress: address,
      DatabaseConstants.meterNumber: meterNumber,
      DatabaseConstants.totalDebt: totalDebt,
      DatabaseConstants.currentBill: currentBill,
      DatabaseConstants.notes: notes,
      DatabaseConstants.createdAt: createdAt.toIso8601String(),
      DatabaseConstants.createdBy: createdBy,
    };
  }

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map[DatabaseConstants.clientId],
      name: map[DatabaseConstants.clientName],
      phone: map[DatabaseConstants.clientPhone],
      address: map[DatabaseConstants.clientAddress],
      meterNumber: map[DatabaseConstants.meterNumber],
      totalDebt: map[DatabaseConstants.totalDebt]?.toDouble() ?? 0.0,
      currentBill: map[DatabaseConstants.currentBill]?.toDouble() ?? 0.0,
      notes: map[DatabaseConstants.notes],
      createdAt: DateTime.parse(map[DatabaseConstants.createdAt]),
      createdBy: map[DatabaseConstants.createdBy],
    );
  }
}