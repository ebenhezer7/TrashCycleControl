import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/note_model.dart';

/// Service untuk mengelola penyimpanan data lokal SQLite menggunakan sqflite.
class LocalDbService {
  static final LocalDbService instance = LocalDbService._internal();
  static Database? _database;

  LocalDbService._internal();

  factory LocalDbService() => instance;

  /// Singleton database getter
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDb();
    return _database!;
  }

  /// 1. Inisialisasi Database SQLite dan membuat tabel `notes`
  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'trashcycle_control.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL DEFAULT '1',
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE notes ADD COLUMN user_id TEXT NOT NULL DEFAULT '1'");
        }
      },
    );
  }

  /// 2. CREATE: Menyisipkan catatan shift baru
  Future<int> createNote(NoteModel note) async {
    final db = await database;
    return await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 3a. READ ALL: Mengambil semua data catatan shift (untuk role superadmin & supervisor)
  Future<List<NoteModel>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      orderBy: 'id DESC',
    );

    return List.generate(maps.length, (i) => NoteModel.fromMap(maps[i]));
  }

  /// 3b. READ BY USER: Mengambil catatan shift khusus milik user_id tertentu (untuk role operator)
  Future<List<NoteModel>> getNotesByUser(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );

    return List.generate(maps.length, (i) => NoteModel.fromMap(maps[i]));
  }

  /// 4. UPDATE: Memperbarui data catatan shift berdasarkan ID
  Future<int> updateNote(NoteModel note) async {
    if (note.id == null) return 0;
    final db = await database;

    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  /// 5. DELETE: Menghapus catatan shift berdasarkan ID
  Future<int> deleteNote(int id) async {
    final db = await database;

    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
