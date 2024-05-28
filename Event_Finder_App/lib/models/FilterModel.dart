import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'Filter.dart';

class DBUtils {
  static Future<Database> init() async {
    var database = openDatabase(
      path.join(await getDatabasesPath(), 'filterDatabase.db'),
      onCreate: (db, version) {
        return db.execute(
            "CREATE TABLE filters(filterType TEXT PRIMARY KEY, value TEXT)");
      },
      version: 1,
    );
    return database;
  }
}

class FilterModel {
  Future<int> insertFilter(Filter filter) async {
    final Database db = await DBUtils.init();
    int insertResult = await db.insert(
      'filters',
      filter.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return insertResult;
  }

  Future<int> editFilter(Filter filter) async {
    final Database db = await DBUtils.init();
    int editResult = await db.update(
      'filters',
      filter.toMap(),
      where: "filterType = ?",
      whereArgs: [filter.filterType],
    );
    return editResult;
  }

  Future<int> deleteFilterByFilterType(String filterType) async {
    final Database db = await DBUtils.init();
    int deleteResult = await db.delete(
      'filters',
      where: "filterType = ?",
      whereArgs: [filterType],
    );
    return deleteResult;
  }

  Future<List<Filter>> getAllFilter() async {
    print("Getting all filters!");
    final Database db = await DBUtils.init();
    final List<Map<String, dynamic>> maps = await db.query('filters');
    List<Filter> result = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        result.add(Filter.fromMap(maps[i]));
      }
    }
    return result;
  }
}
