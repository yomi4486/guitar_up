import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/practice_record.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'guitar_up.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE practice_records (
        id TEXT PRIMARY KEY,
        title TEXT,
        dateTime TEXT NOT NULL,
        guitarType TEXT,
        guitarModel TEXT,
        ampEquipmentMemo TEXT,
        impressionMemo TEXT,
        referenceUrl TEXT,
        videoPaths TEXT
      )
    ''');
  }

  Future<String> insertRecord(PracticeRecord record) async {
    final db = await database;
    await db.insert(
      'practice_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return record.id;
  }

  Future<List<PracticeRecord>> getAllRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'practice_records',
      orderBy: 'dateTime DESC',
    );
    return List.generate(maps.length, (i) => PracticeRecord.fromMap(maps[i]));
  }

  Future<PracticeRecord?> getRecord(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'practice_records',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return PracticeRecord.fromMap(maps.first);
  }

  Future<int> updateRecord(PracticeRecord record) async {
    final db = await database;
    return await db.update(
      'practice_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteRecord(String id) async {
    final db = await database;
    return await db.delete(
      'practice_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<String>> getUsedGuitarModels() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'practice_records',
      columns: ['guitarType', 'guitarModel'],
      distinct: true,
      where: 'guitarModel IS NOT NULL AND guitarModel != ""',
      orderBy: 'dateTime DESC',
    );
    
    final Set<String> models = {};
    for (var map in maps) {
      final guitarType = map['guitarType'] as String?;
      final guitarModel = map['guitarModel'] as String?;
      if (guitarModel != null && guitarModel.isNotEmpty) {
        if (guitarType != null && guitarType.isNotEmpty) {
          models.add('$guitarType - $guitarModel');
        } else {
          models.add(guitarModel);
        }
      }
    }
    return models.toList();
  }
}
