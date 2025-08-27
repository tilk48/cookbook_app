import 'package:mealie_api/mealie_api.dart';

void main() async {
  // Initialize the Mealie client
  final client = MealieClient(
    baseUrl: 'https://demo.mealie.io', // Replace with your Mealie server URL
  );

  try {
    // Example: Login
    print('Logging in...');
    final loginRequest = LoginRequest(
      username: 'demo@mealie.io',
      password: 'demo',
    );

    final tokenResponse = await client.auth.login(loginRequest);
    client.setAccessToken(tokenResponse.accessToken);
    print('✅ Login successful');

    // Example: Get current user
    print('\nFetching user profile...');
    final user = await client.users.getCurrentUser();
    print('👤 Logged in as: ${user.fullName} (${user.email})');

    // Example: Get recipes with search
    print('\nFetching recipes...');
    final recipesResponse = await client.recipes.getRecipes(
      queryParams: QueryParameters(
        page: 1,
        perPage: 5,
        search: 'chicken',
        orderBy: 'name',
        orderDirection: OrderDirection.asc,
      ),
    );

    print('📚 Found ${recipesResponse.total} recipes (showing ${recipesResponse.items.length}):');
    for (final recipe in recipesResponse.items) {
      print('   • ${recipe.name} (${recipe.slug})');
    }

    // Example: Get a specific recipe (if any exist)
    if (recipesResponse.items.isNotEmpty) {
      final firstRecipe = recipesResponse.items.first;
      print('\nFetching detailed recipe: ${firstRecipe.name}');
      
      final detailedRecipe = await client.recipes.getRecipe(firstRecipe.slug);
      print('🍽️  Recipe details:');
      print('   Name: ${detailedRecipe.name}');
      print('   Description: ${detailedRecipe.description ?? 'No description'}');
      print('   Prep Time: ${detailedRecipe.prepTime ?? 'Not specified'}');
      print('   Cook Time: ${detailedRecipe.cookTime ?? 'Not specified'}');
      print('   Servings: ${detailedRecipe.recipeYield ?? 'Not specified'}');
      
      if (detailedRecipe.recipeIngredient != null && detailedRecipe.recipeIngredient!.isNotEmpty) {
        print('   Ingredients:');
        for (final ingredient in detailedRecipe.recipeIngredient!) {
          final quantity = ingredient.quantity != null ? '${ingredient.quantity} ' : '';
          final unit = ingredient.unit != null ? '${ingredient.unit} ' : '';
          final food = ingredient.food ?? ingredient.originalText ?? 'Unknown ingredient';
          print('     - $quantity$unit$food');
        }
      }
    }

    // Example: Get meal plans
    print('\nFetching today\'s meal plan...');
    final todaysMeals = await client.mealPlans.getTodaysMealPlan();
    if (todaysMeals.isNotEmpty) {
      print('🗓️  Today\'s meals:');
      for (final meal in todaysMeals) {
        print('   ${meal.entryType.name.toUpperCase()}: ${meal.title}');
      }
    } else {
      print('📅 No meals planned for today');
    }

    // Example: Get shopping lists
    print('\nFetching shopping lists...');
    final shoppingLists = await client.shoppingLists.getShoppingLists();
    if (shoppingLists.isNotEmpty) {
      print('🛒 Shopping lists (${shoppingLists.length}):');
      for (final list in shoppingLists) {
        print('   • ${list.name} (${list.listItems.length} items)');
      }
    } else {
      print('📝 No shopping lists found');
    }

    // Example: Create a simple recipe
    print('\nCreating a new recipe...');
    final newRecipe = await client.recipes.createRecipe(
      CreateRecipeRequest(
        name: 'SDK Test Recipe',
        description: 'A test recipe created using the Dart SDK',
        recipeIngredient: [
          RecipeIngredient(
            food: 'Test Ingredient',
            quantity: 1.0,
            unit: 'cup',
            originalText: '1 cup test ingredient',
          ),
        ],
        recipeInstructions: [
          CreateRecipeInstruction(
            title: 'Step 1',
            text: 'This is a test step created by the Dart SDK',
          ),
        ],
        prepTime: '5 minutes',
        cookTime: '10 minutes',
        recipeYield: '2 servings',
      ),
    );
    print('✅ Created recipe: ${newRecipe.name} (${newRecipe.slug})');

    // Clean up - delete the test recipe
    print('\nCleaning up test recipe...');
    await client.recipes.deleteRecipe(newRecipe.slug);
    print('🗑️  Test recipe deleted');

    // Example: Logout
    print('\nLogging out...');
    await client.auth.logout();
    client.setAccessToken(null);
    print('👋 Logged out successfully');

  } on MealieException catch (e) {
    print('❌ Mealie API Error: ${e.message}');
    if (e.detail != null) {
      print('   Detail: ${e.detail}');
    }
    if (e.statusCode != null) {
      print('   Status Code: ${e.statusCode}');
    }
  } catch (e) {
    print('❌ Unexpected error: $e');
  } finally {
    // Always close the client to free up resources
    client.close();
  }
}

// Helper extension to format enum names
extension StringExtension on String {
  String get capitalize => '${this[0].toUpperCase()}${substring(1)}';
}