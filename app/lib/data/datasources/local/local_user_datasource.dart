import 'package:sqflite/sqflite.dart';

abstract class LocalUserDataSource {
  // TODO: Implement local user data caching
}

class LocalUserDataSourceImpl implements LocalUserDataSource {
  final Database _database;

  LocalUserDataSourceImpl(this._database);
  
  // TODO: Implement local user caching methods
}