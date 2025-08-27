import 'package:dio/dio.dart';
import '../models/shopping_list/shopping_list_models.dart';
import '../exceptions/mealie_exception.dart';

class ShoppingListsApi {
  final Dio _dio;

  ShoppingListsApi(this._dio);

  /// Get all shopping lists
  Future<List<ShoppingList>> getShoppingLists() async {
    try {
      final response = await _dio.get('/api/households/shopping/lists');
      return (response.data as List)
          .map((json) => ShoppingList.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Get a specific shopping list
  Future<ShoppingList> getShoppingList(String listId) async {
    try {
      final response = await _dio.get('/api/households/shopping/lists/$listId');
      return ShoppingList.fromJson(response.data);
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Create a new shopping list
  Future<ShoppingList> createShoppingList(CreateShoppingListRequest request) async {
    try {
      final response = await _dio.post('/api/households/shopping/lists', data: request.toJson());
      return ShoppingList.fromJson(response.data);
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Update a shopping list
  Future<ShoppingList> updateShoppingList(String listId, CreateShoppingListRequest request) async {
    try {
      final response = await _dio.put('/api/households/shopping/lists/$listId', data: request.toJson());
      return ShoppingList.fromJson(response.data);
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Delete a shopping list
  Future<void> deleteShoppingList(String listId) async {
    try {
      await _dio.delete('/api/households/shopping/lists/$listId');
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Add item to shopping list
  Future<ShoppingListItem> addItemToList(String listId, CreateShoppingListItemRequest request) async {
    try {
      final response = await _dio.post('/api/households/shopping/lists/$listId/items', data: request.toJson());
      return ShoppingListItem.fromJson(response.data);
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Update shopping list item
  Future<ShoppingListItem> updateListItem(String listId, String itemId, CreateShoppingListItemRequest request) async {
    try {
      final response = await _dio.put('/api/households/shopping/lists/$listId/items/$itemId', data: request.toJson());
      return ShoppingListItem.fromJson(response.data);
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Delete shopping list item
  Future<void> deleteListItem(String listId, String itemId) async {
    try {
      await _dio.delete('/api/households/shopping/lists/$listId/items/$itemId');
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Toggle item checked status
  Future<ShoppingListItem> toggleItemChecked(String listId, String itemId) async {
    try {
      final response = await _dio.patch('/api/households/shopping/lists/$listId/items/$itemId/check');
      return ShoppingListItem.fromJson(response.data);
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }
}