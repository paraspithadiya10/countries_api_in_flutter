import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  DBHelper._();

  static final DBHelper getInstance = DBHelper._();
  final String countryTable = 'country';
  final String code = 'code';
  final String name = 'name';
  final String flagUrl = 'flagUrl';
  final String currency = 'currency';

  Database? myDb;

  Future<Database> getDB() async {
    myDb ??= await openDB();
    return myDb!;
  }

  Future<Database> openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String path = join(appDir.path, 'countries.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE $countryTable ($code TEXT PRIMARY KEY, $name TEXT, $flagUrl TEXT, $currency VARCHAR(20))',
        );
      },
    );
  }

  Future<void> insertCountries(List<Map<String, dynamic>> countries) async {
    var db = await getDB();
    var batch = db.batch();
    for (var country in countries) {
      batch.insert(
        countryTable,
        country,
      );
    }
    await batch.commit();
  }

  Future<List<Map<String, dynamic>>> getAllCountries() async {
    var db = await getDB();
    return await db.query(countryTable);
  }

  Future<bool> deleteCountry(String countryCode) async {
    var db = await getDB();
    int rowsAffected = await db.delete(
      countryTable,
      where: '$code = ?',
      whereArgs: [countryCode],
    );
    return rowsAffected > 0;
  }
}
