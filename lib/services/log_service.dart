import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../logic/log_model.dart';
import 'analytics_service.dart';

class LogService {
  static Database? _db;

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

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'user_logs.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE logs(id TEXT PRIMARY KEY, dateCompleted TEXT, duration TEXT, code TEXT, codeName TEXT, year TEXT, season TEXT, rawMarks INTEGER, grade TEXT)",
      );
    });
  }

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
}