import 'package:mealie_api/mealie_api.dart';

abstract class RemoteShoppingListDataSource {}

class RemoteShoppingListDataSourceImpl implements RemoteShoppingListDataSource {
  final MealieClient _client;
  RemoteShoppingListDataSourceImpl(this._client);
}