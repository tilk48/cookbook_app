import 'package:sqflite/sqflite.dart';

abstract class LocalRecipeDataSource {
  // TODO: Implement local recipe data caching
}

class LocalRecipeDataSourceImpl implements LocalRecipeDataSource {
  final Database _database;

  LocalRecipeDataSourceImpl(this._database);
  
  // TODO: Implement local recipe caching methods
}