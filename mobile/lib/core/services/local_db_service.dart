import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../features/shift_notes/data/models/note_model.dart';

/// Service Database Lokal SQLite untuk Catatan Shift Petugas (Mode Offline).
class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();
  factory LocalDbService() => _instance;
  LocalDbService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'trashcycle_control.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            user_name TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE notes ADD COLUMN user_id TEXT DEFAULT "1"');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE notes ADD COLUMN user_name TEXT DEFAULT "Petugas SCADA"');
        }
      },
    );
  }

  /// CREATE: Menambah catatan shift baru
  Future<int> createNote(NoteModel note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  /// READ: Mengambil seluruh catatan shift (Akses Superadmin & Supervisor)
  Future<List<NoteModel>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notes', orderBy: 'id DESC');
    return maps.map((map) => NoteModel.fromMap(map)).toList();
  }

  /// READ: Mengambil catatan shift milik user_id tertentu (Akses Operator)
  Future<List<NoteModel>> getNotesByUser(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    return maps.map((map) => NoteModel.fromMap(map)).toList();
  }

  /// UPDATE: Memperbarui catatan shift
  Future<int> updateNote(NoteModel note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  /// DELETE: Menghapus catatan shift
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
