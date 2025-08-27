import 'package:flutter/material.dart';
import 'package:mealie_api/mealie_api.dart';

/// API Test Harness for testing Mealie API calls
class ApiTestHarness {
  static const String defaultServerUrl = 'https://mealie.ek3r7jer1e.xyz';
  static const String defaultUsername =
      'tilman.kieselbach@icloud.com'; // Set your credentials here
  static const String defaultPassword =
      'XUA9zxu4myf2pug_bgb'; // Set your credentials here

  late MealieClient _client;
  String? _accessToken;

  ApiTestHarness({
    String serverUrl = defaultServerUrl,
  }) {
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

  /// Test recipe fetching with different parameters
  Future<void> testRecipeQuery({
    int page = 1,
    int perPage = 20,
    String? orderBy,
    String? orderDirection,
    String? search,
    List<String>? tags,
    List<String>? categories,
    Map<String, String>? customParams,
  }) async {
    try {
      print('\n🧪 Testing Recipe Query:');
      print('📊 Parameters:');
      print('  - page: $page');
      print('  - perPage: $perPage');
      print('  - orderBy: $orderBy');
      print('  - orderDirection: $orderDirection');
      print('  - search: $search');
      print('  - tags: $tags');
      print('  - categories: $categories');
      if (customParams != null) {
        print('  - custom: $customParams');
      }

      // Build query parameters manually to test different casings
      final params = <String, String>{
        'page': page.toString(),
        'perPage': perPage.toString(), // Test camelCase
      };

      if (orderBy != null) params['orderBy'] = orderBy;
      if (orderDirection != null) params['orderDirection'] = orderDirection;
      if (search != null && search.isNotEmpty) params['search'] = search;
      
      // Add tag filtering - multiple tags can be comma-separated or repeated
      if (tags != null && tags.isNotEmpty) {
        // Test different formats based on Mealie API
        if (tags.length == 1) {
          params['tags'] = tags.first;
        } else {
          // For multiple tags, let's test comma-separated
          params['tags'] = tags.join(',');
        }
        params['requireAllTags'] = 'false'; // OR logic, not AND
      }
      
      // Add category filtering similar to tags
      if (categories != null && categories.isNotEmpty) {
        if (categories.length == 1) {
          params['recipeCategory'] = categories.first;
        } else {
          params['recipeCategory'] = categories.join(',');
        }
        params['requireAllCategories'] = 'false';
      }

      // Add custom parameters for testing
      if (customParams != null) {
        params.addAll(customParams);
      }

      print('🌐 Making API call to: ${_client.baseUrl}/api/recipes');
      print(
          '🔗 Full URL with params: ${_client.baseUrl}/api/recipes?${_buildQueryString(params)}');

      // Use the proper recipes API with QueryParameters
      final queryParameters = QueryParameters(
        page: page,
        perPage: perPage,
        orderBy: orderBy,
        orderDirection: orderDirection != null ? 
          (orderDirection == 'desc' ? OrderDirection.desc : OrderDirection.asc) : null,
        search: search,
        tags: tags,
        categories: categories,
        requireAllTags: tags != null && tags.isNotEmpty ? false : null,
        requireAllCategories: categories != null && categories.isNotEmpty ? false : null,
      );

      final response = await _client.recipes.getRecipes(queryParams: queryParameters);

      final itemCount = response.items.length;
      final total = response.total;
      final totalPages = response.totalPages;

      print('✅ Success!');
      print('📈 Results:');
      print('  - Items returned: $itemCount');
      print('  - Total recipes: $total');
      print('  - Total pages: $totalPages');

      if (itemCount > 0) {
        final firstRecipe = response.items.first;
        print('  - First recipe: ${firstRecipe.name}');
        if (orderBy == 'rating') {
          print('  - First recipe rating: ${firstRecipe.rating}');
        }
        if (orderBy == 'name') {
          print('  - First recipe name: ${firstRecipe.name}');
        }
        
        // Show tags and categories for filtering tests
        if (tags != null || categories != null) {
          final recipeTags = firstRecipe.tags ?? [];
          final recipeCategories = firstRecipe.recipeCategory ?? [];
          
          print('  - First recipe tags: ${recipeTags.map((t) => t.name).join(', ')}');
          print('  - First recipe categories: ${recipeCategories.map((c) => c.name).join(', ')}');
        }
      }
    } catch (e) {
      print('💥 Error: $e');
    }
  }

  /// Test different sorting options
  Future<void> testAllSortOptions() async {
    final sortOptions = {
      'name': 'asc',
      'rating': 'desc',
      'date_added': 'desc',
      'date_updated': 'desc',
      'cook_time': 'asc',
    };

    print('\n🔄 Testing all sort options...\n');

    for (final entry in sortOptions.entries) {
      await testRecipeQuery(
        orderBy: entry.key,
        orderDirection: entry.value,
        perPage: 5, // Small result set for testing
      );
      await Future.delayed(const Duration(seconds: 1)); // Rate limiting
    }
  }

  /// Test parameter casing variations
  Future<void> testParameterCasing() async {
    print('\n🔤 Testing parameter casing...\n');

    // Test camelCase (expected by Mealie)
    await testRecipeQuery(customParams: {
      'orderBy': 'rating',
      'orderDirection': 'desc',
      'perPage': '10',
    });

    await Future.delayed(const Duration(seconds: 1));

    // Test snake_case (what we were sending)
    await testRecipeQuery(customParams: {
      'order_by': 'rating',
      'order_direction': 'desc',
      'per_page': '10',
    });
  }

  /// Get user info to verify authentication
  Future<void> testUserInfo() async {
    try {
      print('\n👤 Testing user info...');
      final user = await _client.users.getCurrentUser();
      print('✅ Current user: ${user.username} (${user.email})');
    } catch (e) {
      print('❌ Failed to get user info: $e');
    }
  }

  /// Get all available tags from the API
  Future<List<Map<String, dynamic>>> getAllTags() async {
    try {
      print('\n🏷️ Fetching all tags...');
      final tags = await _client.recipes.getTags();
      
      print('✅ Found ${tags.length} tags');
      
      // Show first few tags
      for (final tag in tags.take(5)) {
        print('  - ${tag.name} (ID: ${tag.id})');
      }
      
      // Convert to Map<String, dynamic> format for backward compatibility
      return tags.map((tag) => {
        'id': tag.id,
        'name': tag.name,
        'slug': tag.slug,
      }).toList();
    } catch (e) {
      print('💥 Error getting tags: $e');
      return [];
    }
  }
  
  /// Test tag filtering with actual tag IDs
  Future<void> testTagFiltering() async {
    print('\n🧪 Testing Tag Filtering...');
    
    // Get available tags first
    final tags = await getAllTags();
    
    if (tags.isEmpty) {
      print('❌ No tags available for testing');
      return;
    }
    
    // Test with first tag
    final firstTag = tags.first;
    final tagId = firstTag['id'] as String;
    final tagName = firstTag['name'] as String;
    
    print('\n🏷️ Testing filter by tag: "$tagName" (ID: $tagId)');
    
    // Test with tag ID (like in the curl example)
    await testRecipeQuery(
      tags: [tagId],
      perPage: 10,
      customParams: {
        'requireAllTags': 'false',
      }
    );
    
    // Test with multiple tags if available
    if (tags.length > 1) {
      final secondTag = tags[1];
      final secondTagId = secondTag['id'] as String;
      final secondTagName = secondTag['name'] as String;
      
      print('\n🏷️🏷️ Testing filter by multiple tags: "$tagName" and "$secondTagName"');
      
      await testRecipeQuery(
        tags: [tagId, secondTagId],
        perPage: 10,
        customParams: {
          'requireAllTags': 'false', // OR logic
        }
      );
    }
  }

  String _buildQueryString(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}

/// Test page widget for manual testing
class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  final ApiTestHarness _harness = ApiTestHarness();
  bool _isAuthenticated = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Test Harness')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isAuthenticated) ...[
              ElevatedButton(
                onPressed: _isLoading ? null : _authenticate,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Authenticate'),
              ),
            ] else ...[
              const Text('✅ Authenticated',
                  style: TextStyle(color: Colors.green)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _testUserInfo,
                child: const Text('Test User Info'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _testBasicQuery,
                child: const Text('Test Basic Query'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _testParameterCasing,
                child: const Text('Test Parameter Casing'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _testAllSortOptions,
                child: const Text('Test All Sort Options'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _testRatingSort,
                child: const Text('Test Rating Sort'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _testTagFiltering,
                child: const Text('Test Tag Filtering'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _authenticate() async {
    setState(() => _isLoading = true);
    final success = await _harness.authenticate();
    setState(() {
      _isAuthenticated = success;
      _isLoading = false;
    });
  }

  Future<void> _testUserInfo() async {
    await _harness.testUserInfo();
  }

  Future<void> _testBasicQuery() async {
    await _harness.testRecipeQuery();
  }

  Future<void> _testParameterCasing() async {
    await _harness.testParameterCasing();
  }

  Future<void> _testAllSortOptions() async {
    await _harness.testAllSortOptions();
  }

  Future<void> _testRatingSort() async {
    await _harness.testRecipeQuery(
      orderBy: 'rating',
      orderDirection: 'desc',
      perPage: 10,
    );
  }
  
  Future<void> _testTagFiltering() async {
    await _harness.testTagFiltering();
  }
}
