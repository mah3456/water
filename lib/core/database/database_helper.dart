import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'water_management.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // جدول المستخدمين
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.usersTable} (
        ${DatabaseConstants.userId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.userName} TEXT NOT NULL,
        ${DatabaseConstants.userPhone} TEXT NOT NULL UNIQUE,
        ${DatabaseConstants.userPassword} TEXT NOT NULL,
        ${DatabaseConstants.createdAt} TEXT NOT NULL
      )
    ''');

    // جدول العملاء
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.clientsTable} (
        ${DatabaseConstants.clientId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.clientName} TEXT NOT NULL,
        ${DatabaseConstants.clientPhone} TEXT NOT NULL,
        ${DatabaseConstants.clientAddress} TEXT,
        ${DatabaseConstants.meterNumber} TEXT UNIQUE,
        ${DatabaseConstants.totalDebt} REAL DEFAULT 0,
        ${DatabaseConstants.currentBill} REAL DEFAULT 0,
        ${DatabaseConstants.notes} TEXT,
        ${DatabaseConstants.createdAt} TEXT NOT NULL,
        ${DatabaseConstants.createdBy} INTEGER,
        FOREIGN KEY (${DatabaseConstants.createdBy}) 
        REFERENCES ${DatabaseConstants.usersTable}(${DatabaseConstants.userId})
      )
    ''');

    // جدول القراءات - تم التصحيح هنا
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.readingsTable} (
        ${DatabaseConstants.readingId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.clientIdForeignKey} INTEGER NOT NULL,
        ${DatabaseConstants.currentReading} INTEGER NOT NULL,
        ${DatabaseConstants.previousReading} INTEGER NOT NULL,
        ${DatabaseConstants.consumption} INTEGER NOT NULL,
        ${DatabaseConstants.readingDate} TEXT NOT NULL,
        ${DatabaseConstants.ratePerUnit} REAL DEFAULT 2.0,
        ${DatabaseConstants.totalAmount} REAL NOT NULL,
        ${DatabaseConstants.isPaid} INTEGER DEFAULT 0,
        ${DatabaseConstants.createdAt} TEXT NOT NULL,
        ${DatabaseConstants.reader} TEXT NOT NULL,
        ${DatabaseConstants.payby} TEXT,

        FOREIGN KEY (${DatabaseConstants.clientIdForeignKey}) 
        REFERENCES ${DatabaseConstants.clientsTable}(${DatabaseConstants.clientId})
      )
    ''');
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}