import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class DBUtils{
  static Future<Database> init() async{
    var database=openDatabase(path.join(await getDatabasesPath(),'eventFinder.db' ),
    onCreate: (db, version){
      db.execute('CREATE TABLE preferences(preference TEXT PRIMARY KEY, value TEXT)');
    },
    version: 1,
    );
    return database;
  }
  Future saveUserToken(Map<String,dynamic> userTokenMap) async {
    Database db=await init();
    return await db.insert('preferences', userTokenMap,conflictAlgorithm: ConflictAlgorithm.replace);
  }
}