import 'package:test/test.dart';
import 'package:mealie_api/mealie_api.dart';

void main() {
  group('Model Serialization Tests', () {
    test('LoginRequest serialization', () {
      final request = LoginRequest(
        username: 'test_user',
        password: 'test_password',
        rememberMe: true,
      );

      final json = request.toJson();
      expect(json['username'], equals('test_user'));
      expect(json['password'], equals('test_password'));
      expect(json['remember_me'], equals(true));

      final reconstructed = LoginRequest.fromJson(json);
      expect(reconstructed.username, equals(request.username));
      expect(reconstructed.password, equals(request.password));
      expect(reconstructed.rememberMe, equals(request.rememberMe));
    });

    test('TokenResponse serialization', () {
      final json = {
        'access_token': 'test_token_123',
        'token_type': 'Bearer',
      };

      final response = TokenResponse.fromJson(json);
      expect(response.accessToken, equals('test_token_123'));
      expect(response.tokenType, equals('Bearer'));

      final serialized = response.toJson();
      expect(serialized['access_token'], equals('test_token_123'));
      expect(serialized['token_type'], equals('Bearer'));
    });

    test('RecipeSummary serialization', () {
      final json = {
        'id': 'recipe_123',
        'name': 'Test Recipe',
        'slug': 'test-recipe',
        'description': 'A test recipe',
        'rating': 5,
        'date_added': '2024-01-01T10:00:00Z',
      };

      final recipe = RecipeSummary.fromJson(json);
      expect(recipe.id, equals('recipe_123'));
      expect(recipe.name, equals('Test Recipe'));
      expect(recipe.slug, equals('test-recipe'));
      expect(recipe.description, equals('A test recipe'));
      expect(recipe.rating, equals(5));
      expect(recipe.dateAdded, equals(DateTime.parse('2024-01-01T10:00:00Z')));

      final serialized = recipe.toJson();
      expect(serialized['id'], equals('recipe_123'));
      expect(serialized['name'], equals('Test Recipe'));
    });

    test('CreateRecipeRequest basic serialization', () {
      final request = CreateRecipeRequest(
        name: 'New Recipe',
        description: 'Description',
        prepTime: '15 minutes',
        cookTime: '30 minutes',
      );

      final json = request.toJson();
      expect(json['name'], equals('New Recipe'));
      expect(json['description'], equals('Description'));
      expect(json['prep_time'], equals('15 minutes'));
      expect(json['cook_time'], equals('30 minutes'));

      // Test basic reconstruction
      final reconstructed = CreateRecipeRequest.fromJson(json);
      expect(reconstructed.name, equals(request.name));
      expect(reconstructed.description, equals(request.description));
      expect(reconstructed.prepTime, equals(request.prepTime));
      expect(reconstructed.cookTime, equals(request.cookTime));
    });

    test('RecipeIngredient serialization', () {
      final ingredient = RecipeIngredient(
        food: 'Flour',
        quantity: 2.0,
        unit: 'cups',
        originalText: '2 cups flour',
      );

      final json = ingredient.toJson();
      expect(json['food'], equals('Flour'));
      expect(json['quantity'], equals(2.0));
      expect(json['unit'], equals('cups'));
      expect(json['original_text'], equals('2 cups flour'));

      final reconstructed = RecipeIngredient.fromJson(json);
      expect(reconstructed.food, equals(ingredient.food));
      expect(reconstructed.quantity, equals(ingredient.quantity));
      expect(reconstructed.unit, equals(ingredient.unit));
      expect(reconstructed.originalText, equals(ingredient.originalText));
    });

    test('PaginatedResponse serialization', () {
      final json = {
        'page': 1,
        'per_page': 10,
        'total': 100,
        'total_pages': 10,
        'items': [
          {
            'id': 'recipe_1',
            'name': 'Recipe 1',
            'slug': 'recipe-1',
          }
        ],
        'next': 'next_page_url',
        'previous': null,
      };

      final response = PaginatedResponse<RecipeSummary>.fromJson(
        json,
        (json) => RecipeSummary.fromJson(json as Map<String, dynamic>),
      );

      expect(response.page, equals(1));
      expect(response.perPage, equals(10));
      expect(response.total, equals(100));
      expect(response.totalPages, equals(10));
      expect(response.items.length, equals(1));
      expect(response.items.first.name, equals('Recipe 1'));
      expect(response.next, equals('next_page_url'));
      expect(response.previous, isNull);
    });
  });

  group('Enum Serialization Tests', () {
    test('OrderDirection serialization', () {
      expect(OrderDirection.asc.name, equals('asc'));
      expect(OrderDirection.desc.name, equals('desc'));
    });

    test('PlanEntryType serialization', () {
      expect(PlanEntryType.breakfast.name, equals('breakfast'));
      expect(PlanEntryType.lunch.name, equals('lunch'));
      expect(PlanEntryType.dinner.name, equals('dinner'));
      expect(PlanEntryType.side.name, equals('side'));
    });
  });

  group('QueryParameters Tests', () {
    test('QueryParameters toQueryMap', () {
      final params = QueryParameters(
        page: 2,
        perPage: 20,
        orderBy: 'name',
        orderDirection: OrderDirection.desc,
        search: 'chicken',
      );

      final queryMap = params.toQueryMap();
      expect(queryMap['page'], equals('2'));
      expect(queryMap['per_page'], equals('20'));
      expect(queryMap['order_by'], equals('name'));
      expect(queryMap['order_direction'], equals('desc'));
      expect(queryMap['search'], equals('chicken'));
    });

    test('QueryParameters empty values', () {
      final params = QueryParameters();
      final queryMap = params.toQueryMap();
      expect(queryMap, isEmpty);
    });
  });
}