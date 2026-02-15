import 'package:sqflite/sqflite.dart';

import '../../core/database/database_constants.dart';
import '../../core/database/database_helper.dart';
import '../models/reading_model.dart';

class ReadingRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertReading(ReadingModel reading) async {
    final db = await _databaseHelper.database;
    var response =  await db.insert(
      DatabaseConstants.readingsTable,
      reading.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return response;
  }

  Future<List<ReadingModel>> getReadingsByClientId(int clientId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.readingsTable,
      where: '${DatabaseConstants.clientId} = ?',
      whereArgs: [clientId],
      orderBy: '${DatabaseConstants.readingDate} DESC',
    );
    return List.generate(maps.length, (i) {
      return ReadingModel.fromMap(maps[i]);
    });
  }

  Future<ReadingModel?> getLastReading(int clientId) async {
    final db = await _databaseHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.readingsTable,
      where: '${DatabaseConstants.clientId} = ?',
      whereArgs: [clientId],
      orderBy: DatabaseConstants.consumption,
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return ReadingModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<ReadingModel>> getAllReadings() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps =
    await db.query(DatabaseConstants.readingsTable);
    return List.generate(maps.length, (i) {
      return ReadingModel.fromMap(maps[i]);
    });
  }


  Future<int> markAsPaid({required int readingId}) async {
    final db = await _databaseHelper.database;
    var response =  await db.update(DatabaseConstants.readingsTable,
      {
        DatabaseConstants.isPaid: 1,
        DatabaseConstants.createdAt: DateTime.now().toIso8601String(),
      },
      where: '${DatabaseConstants.readingId} = ?',
      whereArgs: [readingId],
    );

    return response;
  }

  // دالة جديدة للحصول على الفواتير غير المدفوعة
  Future<List<ReadingModel>> getUnpaidInvoices(int clientId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.readingsTable,
      where: '${DatabaseConstants.clientIdForeignKey} = ? AND ${DatabaseConstants.isPaid} = 0',
      whereArgs: [clientId],
      orderBy: '${DatabaseConstants.readingDate} DESC',
    );
    return List.generate(maps.length, (i) {
      return ReadingModel.fromMap(maps[i]);
    });
  }


  Future<int> deleteReading({required int id}) async {
    final db = await _databaseHelper.database;

    var response = db.delete(
      DatabaseConstants.readingsTable,
      where: '${DatabaseConstants.readingId} =?',
      whereArgs: [id]
    );

    return response;
  }


  Future<int> payAmount({required int readingId , required double amount}) async {
    final db = await _databaseHelper.database;
    var response =  await db.update(DatabaseConstants.readingsTable,
      {
        DatabaseConstants.totalAmount: amount,
        DatabaseConstants.createdAt: DateTime.now().toIso8601String(),
      },
      where: '${DatabaseConstants.readingId} = ?',
      whereArgs: [readingId],
    );

    return response;
  }







}