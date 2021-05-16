import 'package:medicine/database/pills_database.dart';
import 'package:sqflite/sqflite.dart';

class Repository {
  PillsDatabase _pillsDatabase = PillsDatabase();
  static Database _database;

  //init database
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _pillsDatabase.setDatabase();
    return _database;
  }

  //insert something to database
  Future<int> insertData(String table, Map<String, dynamic> data) async {
    Database db = await database;
    try {
      return await db.insert(table, data);
    } catch (e) {
      return null;
    }
  }

  //get all data from database
  Future<List<Map<String, dynamic>>> getAllData(table) async {
    Database db = await database;
    try {
      return db.query(table);
    } catch (e) {
      return null;
    }
  }

  //delete data
  Future<int> deleteData(String table, int id) async {
    Database db = await database;
    try {
      return await db.delete(table, where: "id = ?", whereArgs: [id]);
    } catch (e) {
      return null;
    }
  }

  //delete data
  Future<List<Object>> deleteAllPills(String table, int uniqueId) async {
    Database db = await database;
    Batch batch = db.batch();
    try {
      batch.delete(table, where: "uniqueId = ?", whereArgs: [uniqueId]);
      return await batch.commit(noResult: true);
    } catch (e) {
      return null;
    }
  }

  // update data
  Future<int> updateData(
      String table, int id, Map<String, dynamic> data) async {
    Database db = await database;
    try {
      return await db.update(table, data, where: "id = ?", whereArgs: [id]);
    } catch (e) {
      return null;
    }
  }

  // get all data about a pill
  Future<List<Map<String, dynamic>>> getPillDataFromDB(table, int id) async {
    Database db = await database;
    try {
      return db.query(table, where: "id = ?", whereArgs: [id]);
    } catch (e) {
      return null;
    }
  }

  // get all data about a pill
  Future<List<Map<String, dynamic>>> getAllDATAFromDB(table) async {
    Database db = await database;
    try {
      // Get the records
      return db.rawQuery('SELECT * FROM $table');
    } catch (e) {
      return null;
    }
  }

  // get all data about a pill
  Future<List<Map<String, dynamic>>> getAllPillsForEdit(
      table, int uniqueId) async {
    Database db = await database;
    try {
      // Get the records
      return db.rawQuery('SELECT * FROM $table where uniqueId = ?', [uniqueId]);
    } catch (e) {
      return null;
    }
  }
}
