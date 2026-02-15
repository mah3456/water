// import 'package:sqflite/sqflite.dart';
// import '../../core/database/database_constants.dart';
// import '../../core/database/database_helper.dart';
// import '../models/client_model.dart';
//
// class ClientRepository {
//   final DatabaseHelper _databaseHelper = DatabaseHelper();
//
//   Future<int> insertClient({required ClientModel client}) async {
//     final db = await _databaseHelper.database;
//
//     var response =  await db.insert(
//       DatabaseConstants.clientsTable,
//       client.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//
//     return response;
//   }
//
//   Future<List<ClientModel>> getAllClients() async {
//     final db = await _databaseHelper.database;
//     final List<Map<String, dynamic>> maps =
//     await db.query(DatabaseConstants.clientsTable);
//     return List.generate(maps.length, (i) {
//       return ClientModel.fromMap(maps[i]);
//     });
//   }
//
//   Future<List<Map<String, dynamic>>> queryAllClients() async {
//     final db = await _databaseHelper.database;
//     return await db.query(DatabaseConstants.clientsTable);
//   }
//
//
//
//
//   Future<ClientModel?> getClientById({required int id}) async {
//     final db = await _databaseHelper.database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       DatabaseConstants.clientsTable,
//       where: '${DatabaseConstants.clientId} = ?',
//       whereArgs: [id],
//     );
//     if (maps.isNotEmpty) {
//       return ClientModel.fromMap(maps.first);
//     }
//     return null;
//   }
//
//   Future<dynamic> updateClient({required ClientModel client}) async {
//     final db = await _databaseHelper.database;
//     var response = await db.update(
//       DatabaseConstants.clientsTable,
//       client.toMap(),
//       where: '${DatabaseConstants.clientId} = ?',
//       whereArgs: [client.id],
//     );
//
//     return response;
//   }
//
//   Future<int> deleteClient(int id) async {
//     final db = await _databaseHelper.database;
//     var response =  await db.delete(
//       DatabaseConstants.clientsTable,
//       where: '${DatabaseConstants.clientId} = ?',
//       whereArgs: [id],
//     );
//
//     return response;
//   }
//
//   Future<int> updateClientDebt(int clientId, double amount) async {
//     final client = await getClientById(id: clientId);
//     if (client != null) {
//       client.totalDebt += amount;
//       return await updateClient(client: client);
//     }
//     return await updateClient(client: client!);
//   }
//
//   Future<int> updateClientCurrent({required int clientId,required double amount}) async {
//     final client = await getClientById(id: clientId);
//     if (client != null) {
//       client.currentBill = amount;
//       return await updateClient(client: client);
//     }
//     return await updateClient(client: client!);
//   }
//
//
//
//   Future<int> payBill({required int clientId, required double amount}) async {
//     final client = await getClientById(id: clientId);
//     if (client != null && client.totalDebt >= amount) {
//       client.totalDebt -= amount;
//      return  await updateClient(client: client);
//     }
//     return 1;
//   }
//
//
//
//
//
//
//
//   // دالة جديدة للحصول على عملاء مستخدم محدد
//   Future<List<ClientModel>> getClientsByUser(int userId) async {
//     final db = await _databaseHelper.database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       DatabaseConstants.clientsTable,
//       where: '${DatabaseConstants.createdBy} = ?',
//       whereArgs: [userId],
//     );
//     return List.generate(maps.length, (i) {
//       return ClientModel.fromMap(maps[i]);
//     });
//   }
//
//   // دالة جديدة لحساب إجمالي ديون مستخدم محدد
//   Future<double> getTotalDebtByUser(int userId) async {
//     final db = await _databaseHelper.database;
//     final List<Map<String, dynamic>> maps = await db.rawQuery('''
//       SELECT SUM(${DatabaseConstants.totalDebt}) as total_debt
//       FROM ${DatabaseConstants.clientsTable}
//       WHERE ${DatabaseConstants.createdBy} = ?
//     ''', [userId]);
//
//     if (maps.isNotEmpty && maps.first['total_debt'] != null) {
//       return maps.first['total_debt'].toDouble();
//     }
//     return 0.0;
//   }
//
//   // دالة جديدة للحصول على إحصائيات المديونيات للمستخدم
//   Future<Map<String, dynamic>> getUserDebtStatistics(int userId) async {
//     final db = await _databaseHelper.database;
//
//     // إجمالي الديون
//     final totalDebtResult = await db.rawQuery('''
//       SELECT SUM(${DatabaseConstants.totalDebt}) as total_debt
//       FROM ${DatabaseConstants.clientsTable}
//       WHERE ${DatabaseConstants.createdBy} = ?
//     ''', [userId]);
//
//     // عدد العملاء
//     final clientsCountResult = await db.rawQuery('''
//       SELECT COUNT(*) as clients_count
//       FROM ${DatabaseConstants.clientsTable}
//       WHERE ${DatabaseConstants.createdBy} = ?
//     ''', [userId]);
//
//     // العملاء الذين لديهم ديون
//     final debtClientsResult = await db.rawQuery('''
//       SELECT COUNT(*) as debt_clients_count
//       FROM ${DatabaseConstants.clientsTable}
//       WHERE ${DatabaseConstants.createdBy} = ?
//       AND ${DatabaseConstants.totalDebt} > 0
//     ''', [userId]);
//
//     // متوسط الدين
//     final averageDebtResult = await db.rawQuery('''
//       SELECT AVG(${DatabaseConstants.totalDebt}) as average_debt
//       FROM ${DatabaseConstants.clientsTable}
//       WHERE ${DatabaseConstants.createdBy} = ?
//       AND ${DatabaseConstants.totalDebt} > 0
//     ''', [userId]);
//
//     return {
//       'total_debt': totalDebtResult.isNotEmpty && totalDebtResult.first['total_debt'] != null
//           ? totalDebtResult.first['total_debt']
//           : 0.0,
//       'clients_count': clientsCountResult.isNotEmpty
//           ? clientsCountResult.first['clients_count'] as int
//           : 0,
//       'debt_clients_count': debtClientsResult.isNotEmpty
//           ? debtClientsResult.first['debt_clients_count'] as int
//           : 0,
//       'average_debt': averageDebtResult.isNotEmpty && averageDebtResult.first['average_debt'] != null
//           ? averageDebtResult.first['average_debt']
//           : 0.0,
//     };
//   }
//
//
//
// }