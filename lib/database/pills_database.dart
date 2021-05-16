import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class PillsDatabase {
  setDatabase() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, "pills_db");
    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE Pills (id INTEGER PRIMARY KEY, uniqueId INTEGER, name TEXT, amount TEXT, type TEXT, notes TEXT, maxPills INTEGER, howManyWeeks INTEGER, howManyDays INTEGER, medicineForm TEXT, time INTEGER, notifyId INTEGER, time1 INTEGER, time2 INTEGER, withLiquid INTEGER, afterMeal INTEGER, dailyFreq INTEGER, dayOrWeek INTEGER)");
    });
    return database;
  }
}
