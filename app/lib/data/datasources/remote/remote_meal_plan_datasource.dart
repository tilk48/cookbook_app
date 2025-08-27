import 'package:mealie_api/mealie_api.dart';

abstract class RemoteMealPlanDataSource {}

class RemoteMealPlanDataSourceImpl implements RemoteMealPlanDataSource {
  final MealieClient _client;
  RemoteMealPlanDataSourceImpl(this._client);
}