import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/attendance_record.dart';

class DatabaseService {
  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  Database? _database;

  Future<void> initDatabase() async {
    if (_database != null) return;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'smart_class_app.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE attendance (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            qrCode TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            timestamp TEXT NOT NULL,
            previousTopic TEXT,
            expectedTopic TEXT,
            moodScore INTEGER,
            learnedToday TEXT,
            feedback TEXT
          )
        ''');
      },
    );
  }

  Future<Database> get database async {
    if (_database == null) {
      await initDatabase();
    }
    return _database!;
  }

  Future<int> insertRecord(AttendanceRecord record) async {
    final db = await database;
    return db.insert('attendance', record.toMap());
  }

  Future<List<AttendanceRecord>> getAllRecords() async {
    final db = await database;
    final result = await db.query('attendance', orderBy: 'id DESC');
    return result.map((e) => AttendanceRecord.fromMap(e)).toList();
  }
}