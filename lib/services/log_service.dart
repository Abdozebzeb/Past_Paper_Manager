import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../logic/log_model.dart';

class LogService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final directory = await getApplicationSupportDirectory();
    String path = join(directory.path, 'cie_user_data.db');
    
    return await openDatabase(
      path,
      version: 3, // Increased version
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE logs(id TEXT PRIMARY KEY, dateCompleted TEXT, duration TEXT, code TEXT, codeName TEXT, year TEXT, season TEXT, scoredMarks INTEGER, rawMarks INTEGER, grade TEXT)",
        );
        await db.execute("CREATE TABLE user_prefs(key TEXT PRIMARY KEY, value TEXT)");
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("CREATE TABLE IF NOT EXISTS user_prefs(key TEXT PRIMARY KEY, value TEXT)");
        }
        if (oldVersion < 3) {
          // Migration to add scoredMarks and rawMarks if they don't exist
          try {
             await db.execute("ALTER TABLE logs ADD COLUMN scoredMarks INTEGER DEFAULT 0");
             // Note: in previous versions 'rawMarks' might have held scored marks. 
             // We are resetting to be safe or you can rename columns.
          } catch(e) {}
        }
      },
    );
  }

  // --- Preference Methods (Replacing SharedPreferences) ---
  static Future<void> setPref(String key, String value) async {
    final db = await database;
    await db.insert('user_prefs', {'key': key, 'value': value}, 
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<String?> getPref(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user_prefs', where: 'key = ?', whereArgs: [key]);
    if (maps.isEmpty) return null;
    return maps.first['value'] as String;
  }

  // --- Log Methods ---
  static Future<void> saveLog(PaperLog log) async {
    final db = await database;
    await db.insert('logs', log.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String cleanId = (user.email ?? "unknown").replaceAll('.', '_');
      await FirebaseFirestore.instance.collection('users').doc(cleanId).set({
        'PaperLogs': FieldValue.arrayUnion([log.toMap()])
      }, SetOptions(merge: true));
    }
  }

  static Future<List<PaperLog>> getAllLogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('logs');
    return List.generate(maps.length, (i) => PaperLog.fromMap(maps[i]));
  }

  static Future<void> deleteLogs(List<String> ids) async {
    final db = await database;
    await db.delete('logs', where: "id IN (${ids.map((id) => "'$id'").join(',')})");
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String cleanId = (user.email ?? "unknown").replaceAll('.', '_');
      final currentLogs = await getAllLogs();
      await FirebaseFirestore.instance.collection('users').doc(cleanId).update({
        'PaperLogs': currentLogs.map((l) => l.toMap()).toList()
      });
    }
  }
}