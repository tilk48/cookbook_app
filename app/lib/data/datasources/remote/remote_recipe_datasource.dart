import 'package:mealie_api/mealie_api.dart';

abstract class RemoteRecipeDataSource {}

class RemoteRecipeDataSourceImpl implements RemoteRecipeDataSource {
  final MealieClient _client;
  RemoteRecipeDataSourceImpl(this._client);
}