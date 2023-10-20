import 'package:sqflite/sqflite.dart' as sql;
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

class DBHelper {
  static Future<List<Map<String, Object>>>? data;

  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'LocationDemo.db'),
        onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE ${'userlocations'}(lat TEXT ,lng TEXT ,time TEXT )');
    }, version: 1);
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    db.transaction((txn) => txn.insert(
          table,
          data,
          conflictAlgorithm: ConflictAlgorithm.replace,
        ));
    print('inserted....');
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DBHelper.database();
    print('call get data....');
    return await db.transaction((txn) => txn.query(table));
  }

  static void clearTable(String tableName) async {
    final db = await DBHelper.database();

    db.delete(tableName);
  }
}
