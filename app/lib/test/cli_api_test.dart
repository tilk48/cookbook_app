import 'dart:io';
import 'package:mealie_api/mealie_api.dart';

/// CLI-based API test tool for testing Mealie API calls directly from command line
class CliApiTest {
  static const String defaultServerUrl = 'https://mealie.ek3r7jer1e.xyz';
  static const String defaultUsername = 'tilman.kieselbach@icloud.com';
  static const String defaultPassword = 'XUA9zxu4myf2pug_bgb';

  late MealieClient _client;
  String? _accessToken;

  CliApiTest({String serverUrl = defaultServerUrl}) {
    _client = MealieClient(baseUrl: serverUrl);
  }

  /// Authenticate with the API
  Future<bool> authenticate({
    String username = defaultUsername,
    String password = defaultPassword,
  }) async {
    try {
      print('🔐 Authenticating with $username...');
      final response = await _client.auth
          .login(LoginRequest(username: username, password: password));

      _accessToken = response.accessToken;
      _client.setAccessToken(_accessToken!);

      print('✅ Authentication successful!');
      print('📝 Access token: ${_accessToken?.substring(0, 20)}...');
      return true;
    } catch (e) {
      print('❌ Authentication failed: $e');
      return false;
    }
  }

  /// Test basic recipe fetching
  Future<void> testBasicRecipes() async {
    try {
      print('\n📚 Testing basic recipe fetch...');
      
      final response = await _client.recipes.getRecipes(
        queryParams: const QueryParameters(page: 1, perPage: 5),
      );

      print('✅ Success! Found ${response.items.length} recipes (total: ${response.total})');
      
      if (response.items.isNotEmpty) {
        print('📄 First few recipes:');
        for (int i = 0; i < response.items.length; i++) {
          final recipe = response.items[i];
          print('  ${i + 1}. ${recipe.name} (Rating: ${recipe.rating ?? 'N/A'})');
          
          if (recipe.tags?.isNotEmpty == true) {
            print('     Tags: ${recipe.tags!.map((t) => '${t.name} (${t.id})').join(', ')}');
          }
          if (recipe.recipeCategory?.isNotEmpty == true) {
            print('     Categories: ${recipe.recipeCategory!.map((c) => '${c.name} (${c.id})').join(', ')}');
          }
        }
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  /// Get all available categories and show them
  Future<List<RecipeCategory>> getAllCategories() async {
    try {
      print('\n📂 Fetching all available categories...');
      final categories = await _client.recipes.getCategories();
      
      print('✅ Found ${categories.length} categories:');
      for (final category in categories.take(10)) {
        print('  - ${category.name} (ID: ${category.id})');
      }
      
      if (categories.length > 10) {
        print('  ... and ${categories.length - 10} more');
      }
      
      return categories;
    } catch (e) {
      print('❌ Error getting categories: $e');
      return [];
    }
  }

  /// Get all available tags and show them
  Future<List<RecipeTag>> getAllTags() async {
    try {
      print('\n🏷️ Fetching all available tags...');
      
      // Since we have tags in the recipe results, let's extract them from there
      print('🔍 Extracting tags from recipe data...');
      final response = await _client.recipes.getRecipes(
        queryParams: const QueryParameters(page: 1, perPage: 50),
      );
      
      final tagMap = <String, RecipeTag>{};
      for (final recipe in response.items) {
        if (recipe.tags != null) {
          for (final tag in recipe.tags!) {
            tagMap[tag.id] = tag;
          }
        }
      }
      
      final tags = tagMap.values.toList();
      
      print('✅ Found ${tags.length} unique tags from recipes:');
      for (final tag in tags.take(10)) {
        print('  - ${tag.name} (ID: ${tag.id})');
      }
      
      if (tags.length > 10) {
        print('  ... and ${tags.length - 10} more');
      }
      
      return tags;
    } catch (e) {
      print('❌ Error getting tags: $e');
      return [];
    }
  }

  /// Test server-side tag filtering
  Future<void> testTagFiltering() async {
    print('\n🧪 Testing Server-Side Tag Filtering...');
    
    // Get available tags first
    final tags = await getAllTags();
    
    if (tags.isEmpty) {
      print('❌ No tags available for testing');
      return;
    }

    // Test with the first tag
    final testTag = tags.first;
    print('\n🎯 Testing filter with tag: "${testTag.name}" (ID: ${testTag.id})');
    
    try {
      // Test server-side tag filtering
      final queryParams = QueryParameters(
        page: 1,
        perPage: 20,
        tags: [testTag.id], // Use UUID for server-side filtering
        requireAllTags: false, // OR logic
      );
      
      print('🌐 API Parameters: ${queryParams.toQueryMap()}');
      
      final response = await _client.recipes.getRecipes(queryParams: queryParams);
      
      print('✅ Server-side filtering results:');
      print('  - Found ${response.items.length} recipes with tag "${testTag.name}"');
      print('  - Total matching recipes in database: ${response.total}');
      print('  - Total pages: ${response.totalPages}');
      
      if (response.items.isNotEmpty) {
        print('\n📄 Matching recipes:');
        for (int i = 0; i < response.items.length && i < 5; i++) {
          final recipe = response.items[i];
          final recipeTags = recipe.tags?.map((t) => t.name).join(', ') ?? 'No tags';
          print('  ${i + 1}. ${recipe.name}');
          print('     Tags: $recipeTags');
          
          // Verify the recipe actually contains the filtered tag
          final hasTag = recipe.tags?.any((t) => t.id == testTag.id) ?? false;
          print('     ✓ Contains "${testTag.name}": $hasTag');
        }
      }
      
      // Test with multiple tags if available
      if (tags.length > 1) {
        final secondTag = tags[1];
        print('\n🎯🎯 Testing multiple tag filter: "${testTag.name}" OR "${secondTag.name}"');
        
        final multiTagParams = QueryParameters(
          page: 1,
          perPage: 10,
          tags: [testTag.id, secondTag.id],
          requireAllTags: false, // OR logic
        );
        
        print('🌐 Multi-tag API Parameters: ${multiTagParams.toQueryMap()}');
        
        final multiTagResponse = await _client.recipes.getRecipes(queryParams: multiTagParams);
        
        print('✅ Multi-tag filtering results:');
        print('  - Found ${multiTagResponse.items.length} recipes with either tag');
        print('  - Total matching recipes: ${multiTagResponse.total}');
      }
      
    } catch (e) {
      print('❌ Tag filtering error: $e');
    }
  }

  /// Test server-side category filtering
  Future<void> testCategoryFiltering() async {
    print('\n🧪 Testing Server-Side Category Filtering...');
    
    // Get available categories first
    final categories = await getAllCategories();
    
    if (categories.isEmpty) {
      print('❌ No categories available for testing');
      return;
    }

    // Test with the first category
    final testCategory = categories.first;
    print('\n🎯 Testing filter with category: "${testCategory.name}" (ID: ${testCategory.id})');
    
    try {
      // Test server-side category filtering
      final queryParams = QueryParameters(
        page: 1,
        perPage: 20,
        categories: [testCategory.id], // Use UUID for server-side filtering
        requireAllCategories: false, // OR logic
      );
      
      print('🌐 API Parameters: ${queryParams.toQueryMap()}');
      
      final response = await _client.recipes.getRecipes(queryParams: queryParams);
      
      print('✅ Server-side category filtering results:');
      print('  - Found ${response.items.length} recipes with category "${testCategory.name}"');
      print('  - Total matching recipes in database: ${response.total}');
      print('  - Total pages: ${response.totalPages}');
      
      if (response.items.isNotEmpty) {
        print('\n📄 Matching recipes:');
        for (int i = 0; i < response.items.length && i < 5; i++) {
          final recipe = response.items[i];
          final recipeCategories = recipe.recipeCategory?.map((c) => c.name).join(', ') ?? 'No categories';
          print('  ${i + 1}. ${recipe.name}');
          print('     Categories: $recipeCategories');
          
          // Verify the recipe actually contains the filtered category
          final hasCategory = recipe.recipeCategory?.any((c) => c.id == testCategory.id) ?? false;
          print('     ✓ Contains "${testCategory.name}": $hasCategory');
        }
      }
      
      // Test with multiple categories if available
      if (categories.length > 1) {
        final secondCategory = categories[1];
        print('\n🎯🎯 Testing multiple category filter: "${testCategory.name}" OR "${secondCategory.name}"');
        
        final multiCategoryParams = QueryParameters(
          page: 1,
          perPage: 10,
          categories: [testCategory.id, secondCategory.id],
          requireAllCategories: false, // OR logic
        );
        
        print('🌐 Multi-category API Parameters: ${multiCategoryParams.toQueryMap()}');
        
        final multiCategoryResponse = await _client.recipes.getRecipes(queryParams: multiCategoryParams);
        
        print('✅ Multi-category filtering results:');
        print('  - Found ${multiCategoryResponse.items.length} recipes with either category');
        print('  - Total matching recipes: ${multiCategoryResponse.total}');
      }
      
      // Test combined tag and category filtering if both are available
      if (categories.isNotEmpty) {
        print('\n🎯🏷️ Testing combined tag + category filtering...');
        final tags = await getAllTags();
        
        if (tags.isNotEmpty) {
          final combinedParams = QueryParameters(
            page: 1,
            perPage: 10,
            tags: [tags.first.id],
            categories: [testCategory.id],
            requireAllTags: false,
            requireAllCategories: false,
          );
          
          print('🌐 Combined API Parameters: ${combinedParams.toQueryMap()}');
          
          final combinedResponse = await _client.recipes.getRecipes(queryParams: combinedParams);
          
          print('✅ Combined filtering results:');
          print('  - Found ${combinedResponse.items.length} recipes with both filters');
          print('  - Total matching recipes: ${combinedResponse.total}');
        }
      }
      
    } catch (e) {
      print('❌ Category filtering error: $e');
    }
  }

  /// Test sorting functionality
  Future<void> testSorting() async {
    print('\n📊 Testing Sorting...');
    
    try {
      // Test rating sort (descending)
      print('\n🌟 Testing rating sort (highest first)...');
      final ratingSortParams = QueryParameters(
        page: 1,
        perPage: 5,
        orderBy: 'rating',
        orderDirection: OrderDirection.desc,
      );
      
      final ratingResponse = await _client.recipes.getRecipes(queryParams: ratingSortParams);
      
      print('✅ Rating sort results (showing top 5):');
      for (int i = 0; i < ratingResponse.items.length; i++) {
        final recipe = ratingResponse.items[i];
        print('  ${i + 1}. ${recipe.name} - Rating: ${recipe.rating ?? 'N/A'}');
      }
      
      // Test name sort
      print('\n🔤 Testing name sort (alphabetical)...');
      final nameSortParams = QueryParameters(
        page: 1,
        perPage: 5,
        orderBy: 'name',
        orderDirection: OrderDirection.asc,
      );
      
      final nameResponse = await _client.recipes.getRecipes(queryParams: nameSortParams);
      
      print('✅ Name sort results (first 5 alphabetically):');
      for (int i = 0; i < nameResponse.items.length; i++) {
        final recipe = nameResponse.items[i];
        print('  ${i + 1}. ${recipe.name}');
      }
      
    } catch (e) {
      print('❌ Sorting error: $e');
    }
  }

  /// Test search functionality
  Future<void> testSearch() async {
    print('\n🔍 Testing Search...');
    
    try {
      const searchQuery = 'chicken';
      print('🔍 Searching for: "$searchQuery"');
      
      final searchParams = QueryParameters(
        page: 1,
        perPage: 5,
        search: searchQuery,
      );
      
      final searchResponse = await _client.recipes.searchRecipes(
        query: searchQuery,
        queryParams: searchParams,
      );
      
      print('✅ Search results for "$searchQuery":');
      print('  - Found ${searchResponse.items.length} recipes (total: ${searchResponse.total})');
      
      for (int i = 0; i < searchResponse.items.length; i++) {
        final recipe = searchResponse.items[i];
        print('  ${i + 1}. ${recipe.name}');
      }
      
    } catch (e) {
      print('❌ Search error: $e');
    }
  }

  /// Test recipe detail endpoint
  Future<void> testRecipeDetail() async {
    print('\n🔍 Testing Recipe Detail Endpoint...');
    
    try {
      // Test the specific recipe mentioned by user
      const testSlug = 'herzhafte-franzbrotchen-mit-barlauch';
      print('🎯 Testing recipe: $testSlug');
      
      // First, let's check the raw API response
      print('\n🔍 Checking raw API response...');
      final response = await _client.dio.get('/api/recipes/$testSlug');
      final jsonData = response.data;
      
      print('📄 Raw response keys: ${jsonData.keys.toList()}');
      
      // Check for ingredient-related fields
      final ingredientKeys = jsonData.keys.where((key) => 
        key.toString().toLowerCase().contains('ingredient')).toList();
      print('🥕 Ingredient-related keys: $ingredientKeys');
      
      // Check for instruction-related fields
      final instructionKeys = jsonData.keys.where((key) => 
        key.toString().toLowerCase().contains('instruction')).toList();
      print('👨‍🍳 Instruction-related keys: $instructionKeys');
      
      // Check if ingredients exist with different key names
      if (jsonData.containsKey('recipeIngredient')) {
        print('✅ Found recipeIngredient: ${jsonData['recipeIngredient']?.length ?? 'null'}');
        if (jsonData['recipeIngredient'] != null && (jsonData['recipeIngredient'] as List).isNotEmpty) {
          print('🔍 First ingredient structure: ${jsonData['recipeIngredient'][0]}');
        }
      }
      if (jsonData.containsKey('recipe_ingredient')) {
        print('✅ Found recipe_ingredient: ${jsonData['recipe_ingredient']?.length ?? 'null'}');
      }
      if (jsonData.containsKey('ingredients')) {
        print('✅ Found ingredients: ${jsonData['ingredients']?.length ?? 'null'}');
      }
      
      // Check if instructions exist with different key names
      if (jsonData.containsKey('recipeInstructions')) {
        print('✅ Found recipeInstructions: ${jsonData['recipeInstructions']?.length ?? 'null'}');
      }
      if (jsonData.containsKey('recipe_instructions')) {
        print('✅ Found recipe_instructions: ${jsonData['recipe_instructions']?.length ?? 'null'}');
      }
      if (jsonData.containsKey('instructions')) {
        print('✅ Found instructions: ${jsonData['instructions']?.length ?? 'null'}');
      }
      
      print('\n📋 Now testing parsed Recipe object...');
      final recipe = await _client.recipes.getRecipe(testSlug);
      
      print('✅ Recipe detail loaded successfully!');
      print('📄 Recipe: ${recipe.name}');
      final desc = recipe.description ?? 'None';
      print('📝 Description: ${desc.length > 100 ? desc.substring(0, 100) + '...' : desc}');
      print('🆔 ID: ${recipe.id}');
      print('🏷️ Slug: ${recipe.slug}');
      
      // Check ingredients
      final ingredients = recipe.recipeIngredient;
      print('\n🥕 Ingredients: ${ingredients?.length ?? 0}');
      if (ingredients?.isNotEmpty == true) {
        print('First few ingredients:');
        for (int i = 0; i < (ingredients!.length > 5 ? 5 : ingredients.length); i++) {
          final ingredient = ingredients[i];
          print('  ${i + 1}. ${ingredient.originalText ?? '${ingredient.quantity} ${ingredient.unit} ${ingredient.food}'}');
          print('      - quantity: ${ingredient.quantity}');
          print('      - unit: ${ingredient.unit}');
          print('      - food: ${ingredient.food}');
          print('      - disable_amount: ${ingredient.disable_amount}');
        }
      }
      
      // Check instructions
      final instructions = recipe.recipeInstructions;
      print('\n👨‍🍳 Instructions: ${instructions?.length ?? 0}');
      if (instructions?.isNotEmpty == true) {
        print('First few instructions:');
        for (int i = 0; i < (instructions!.length > 3 ? 3 : instructions.length); i++) {
          final instruction = instructions[i];
          print('  ${i + 1}. ID: ${instruction.id}');
          print('     Title: ${instruction.title}');
          final text = instruction.text ?? 'None';
          print('     Text: ${text.length > 100 ? text.substring(0, 100) + '...' : text}');
        }
      }
      
      // Check other fields
      print('\n⏱️ Timing:');
      print('  - Total: ${recipe.totalTime}');
      print('  - Prep: ${recipe.prepTime}');
      print('  - Cook: ${recipe.cookTime}');
      print('  - Yield: ${recipe.recipeYield}');
      
      // Check raw API response for serving fields
      print('\n🍽️ Raw serving fields:');
      print('  - recipeServings: ${jsonData['recipeServings']}');
      print('  - recipeYieldQuantity: ${jsonData['recipeYieldQuantity']}');
      print('  - recipeYield: ${jsonData['recipeYield']}');
      
      print('\n🏷️ Categories: ${recipe.recipeCategory?.map((c) => c.name).join(', ') ?? 'None'}');
      print('🏷️ Tags: ${recipe.tags?.map((t) => t.name).join(', ') ?? 'None'}');
      
      // Check settings and nutrition
      print('\n⚙️ Settings: ${recipe.settings != null ? 'Present' : 'None'}');
      print('🥗 Nutrition: ${recipe.nutrition != null ? 'Present' : 'None'}');
      print('📝 Notes: ${recipe.notes?.length ?? 0}');
      print('📎 Assets: ${recipe.assets?.length ?? 0}');
      
    } catch (e, stackTrace) {
      print('❌ Recipe detail test failed: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Run comprehensive API tests
  Future<void> runAllTests() async {
    print('🚀 Starting Comprehensive API Tests\n');
    print('=' * 50);
    
    // Authenticate first
    final authenticated = await authenticate();
    if (!authenticated) {
      print('❌ Cannot proceed without authentication');
      return;
    }
    
    // Run tests
    await testBasicRecipes();
    await testRecipeDetail(); // Add recipe detail test
    await testSorting();
    await testSearch();
    await testTagFiltering();
    await testCategoryFiltering();
    
    print('\n' + '=' * 50);
    print('🏁 All tests completed!');
  }
}

/// Main function to run CLI tests
void main(List<String> args) async {
  final tester = CliApiTest();
  
  if (args.isNotEmpty) {
    switch (args.first) {
      case 'auth':
        await tester.authenticate();
        break;
      case 'basic':
        await tester.authenticate();
        await tester.testBasicRecipes();
        break;
      case 'tags':
        await tester.authenticate();
        await tester.getAllTags();
        break;
      case 'categories':
        await tester.authenticate();
        await tester.getAllCategories();
        break;
      case 'filter':
        await tester.authenticate();
        await tester.testTagFiltering();
        break;
      case 'categories-filter':
        await tester.authenticate();
        await tester.testCategoryFiltering();
        break;
      case 'sort':
        await tester.authenticate();
        await tester.testSorting();
        break;
      case 'search':
        await tester.authenticate();
        await tester.testSearch();
        break;
      case 'recipe-detail':
        await tester.authenticate();
        await tester.testRecipeDetail();
        break;
      case 'all':
      default:
        await tester.runAllTests();
    }
  } else {
    await tester.runAllTests();
  }
  
  exit(0);
}