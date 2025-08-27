import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static DatabaseHelper get instance => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getDatabasesPath();
    final path = join(documentsDirectory, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create recipes table with comprehensive fields
    await db.execute('''
      CREATE TABLE recipes (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        slug TEXT UNIQUE NOT NULL,
        description TEXT,
        image_url TEXT,
        prep_time TEXT,
        cook_time TEXT,
        total_time TEXT,
        perform_time TEXT,
        recipe_yield TEXT,
        rating INTEGER,
        is_favorite INTEGER DEFAULT 0,
        last_made TEXT,
        times_made INTEGER DEFAULT 0,
        date_added TEXT,
        date_updated TEXT,
        created_at TEXT,
        updated_at TEXT,
        cached_at TEXT,
        json_data TEXT
      )
    ''');

    // Create recipe categories table
    await db.execute('''
      CREATE TABLE recipe_categories (
        id TEXT PRIMARY KEY,
        recipe_id TEXT NOT NULL,
        name TEXT NOT NULL,
        slug TEXT NOT NULL,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');

    // Create recipe tags table
    await db.execute('''
      CREATE TABLE recipe_tags (
        id TEXT PRIMARY KEY,
        recipe_id TEXT NOT NULL,
        name TEXT NOT NULL,
        slug TEXT NOT NULL,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');

    // Create recipe ingredients table
    await db.execute('''
      CREATE TABLE recipe_ingredients (
        id TEXT PRIMARY KEY,
        recipe_id TEXT NOT NULL,
        title TEXT,
        note TEXT,
        unit TEXT,
        food TEXT,
        quantity REAL,
        disable_amount INTEGER DEFAULT 0,
        original_text TEXT,
        reference_id TEXT,
        position INTEGER DEFAULT 0,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');

    // Create recipe instructions table
    await db.execute('''
      CREATE TABLE recipe_instructions (
        id TEXT PRIMARY KEY,
        recipe_id TEXT NOT NULL,
        title TEXT NOT NULL,
        text TEXT NOT NULL,
        position INTEGER DEFAULT 0,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');

    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        full_name TEXT,
        is_admin INTEGER DEFAULT 0,
        can_invite INTEGER DEFAULT 0,
        can_manage INTEGER DEFAULT 0,
        can_organize INTEGER DEFAULT 0,
        avatar_url TEXT,
        created_at TEXT,
        updated_at TEXT,
        last_login TEXT,
        cached_at TEXT,
        json_data TEXT
      )
    ''');

    // Create user preferences table
    await db.execute('''
      CREATE TABLE user_preferences (
        user_id TEXT PRIMARY KEY,
        private_recipes INTEGER DEFAULT 0,
        default_recipe_public TEXT DEFAULT 'true',
        show_recipe_nutrition INTEGER DEFAULT 1,
        show_recipe_assets INTEGER DEFAULT 1,
        landscape_view_default INTEGER DEFAULT 0,
        disable_comments_default INTEGER DEFAULT 0,
        disable_amount_default INTEGER DEFAULT 0,
        locale_code TEXT DEFAULT 'en-US',
        first_day_of_week TEXT DEFAULT 'monday',
        json_data TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Create dietary preferences table
    await db.execute('''
      CREATE TABLE dietary_preferences (
        user_id TEXT PRIMARY KEY,
        allergies TEXT,
        dietary_restrictions TEXT,
        disliked_ingredients TEXT,
        preferred_cuisines TEXT,
        vegetarian INTEGER DEFAULT 0,
        vegan INTEGER DEFAULT 0,
        gluten_free INTEGER DEFAULT 0,
        dairy_free INTEGER DEFAULT 0,
        keto INTEGER DEFAULT 0,
        low_carb INTEGER DEFAULT 0,
        low_fat INTEGER DEFAULT 0,
        low_sodium INTEGER DEFAULT 0,
        json_data TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Create user favorites table
    await db.execute('''
      CREATE TABLE user_favorites (
        user_id TEXT NOT NULL,
        recipe_id TEXT NOT NULL,
        created_at TEXT,
        PRIMARY KEY (user_id, recipe_id),
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');

    // Create meal plans table
    await db.execute('''
      CREATE TABLE meal_plans (
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        user_id TEXT NOT NULL,
        household_id TEXT NOT NULL,
        shopping_list_ids TEXT,
        settings_json TEXT,
        created_at TEXT,
        updated_at TEXT,
        cached_at TEXT,
        json_data TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Create meal plan entries table
    await db.execute('''
      CREATE TABLE meal_plan_entries (
        id TEXT PRIMARY KEY,
        meal_plan_id TEXT NOT NULL,
        date TEXT NOT NULL,
        meal_type TEXT NOT NULL,
        recipe_id TEXT,
        recipe_name TEXT,
        recipe_slug TEXT,
        title TEXT,
        text TEXT,
        servings INTEGER,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (meal_plan_id) REFERENCES meal_plans (id) ON DELETE CASCADE
      )
    ''');

    // Create shopping lists table
    await db.execute('''
      CREATE TABLE shopping_lists (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        user_id TEXT NOT NULL,
        household_id TEXT NOT NULL,
        settings_json TEXT,
        created_at TEXT,
        updated_at TEXT,
        cached_at TEXT,
        json_data TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Create shopping list items table
    await db.execute('''
      CREATE TABLE shopping_list_items (
        id TEXT PRIMARY KEY,
        shopping_list_id TEXT NOT NULL,
        display TEXT NOT NULL,
        quantity REAL,
        unit TEXT,
        food TEXT,
        recipe TEXT,
        recipe_id TEXT,
        note TEXT,
        category TEXT,
        checked INTEGER DEFAULT 0,
        price REAL,
        position INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (shopping_list_id) REFERENCES shopping_lists (id) ON DELETE CASCADE
      )
    ''');

    // Create recipe nutrition table
    await db.execute('''
      CREATE TABLE recipe_nutrition (
        recipe_id TEXT PRIMARY KEY,
        calories TEXT,
        fat_content TEXT,
        protein_content TEXT,
        carbohydrate_content TEXT,
        fiber_content TEXT,
        sugar_content TEXT,
        sodium_content TEXT,
        json_data TEXT,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');

    // Create recipe settings table
    await db.execute('''
      CREATE TABLE recipe_settings (
        recipe_id TEXT PRIMARY KEY,
        is_public INTEGER DEFAULT 1,
        show_nutrition INTEGER DEFAULT 1,
        show_assets INTEGER DEFAULT 1,
        landscape_view INTEGER DEFAULT 0,
        disable_comments INTEGER DEFAULT 0,
        disable_amount INTEGER DEFAULT 0,
        locked INTEGER DEFAULT 0,
        json_data TEXT,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');

    // Create recipe assets table
    await db.execute('''
      CREATE TABLE recipe_assets (
        id TEXT PRIMARY KEY,
        recipe_id TEXT NOT NULL,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        file_name TEXT NOT NULL,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');

    // Create recipe notes table
    await db.execute('''
      CREATE TABLE recipe_notes (
        id TEXT PRIMARY KEY,
        recipe_id TEXT NOT NULL,
        title TEXT NOT NULL,
        text TEXT NOT NULL,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await _createIndexes(db);
  }

  Future<void> _createIndexes(Database db) async {
    // Recipe indexes
    await db.execute('CREATE INDEX idx_recipes_name ON recipes (name)');
    await db.execute('CREATE INDEX idx_recipes_slug ON recipes (slug)');
    await db.execute('CREATE INDEX idx_recipes_cached_at ON recipes (cached_at)');
    await db.execute('CREATE INDEX idx_recipes_is_favorite ON recipes (is_favorite)');
    await db.execute('CREATE INDEX idx_recipes_rating ON recipes (rating)');
    
    // Recipe relationships indexes
    await db.execute('CREATE INDEX idx_recipe_categories_recipe_id ON recipe_categories (recipe_id)');
    await db.execute('CREATE INDEX idx_recipe_tags_recipe_id ON recipe_tags (recipe_id)');
    await db.execute('CREATE INDEX idx_recipe_ingredients_recipe_id ON recipe_ingredients (recipe_id)');
    await db.execute('CREATE INDEX idx_recipe_instructions_recipe_id ON recipe_instructions (recipe_id)');
    await db.execute('CREATE INDEX idx_recipe_nutrition_recipe_id ON recipe_nutrition (recipe_id)');
    await db.execute('CREATE INDEX idx_recipe_settings_recipe_id ON recipe_settings (recipe_id)');
    await db.execute('CREATE INDEX idx_recipe_assets_recipe_id ON recipe_assets (recipe_id)');
    await db.execute('CREATE INDEX idx_recipe_notes_recipe_id ON recipe_notes (recipe_id)');
    
    // User indexes
    await db.execute('CREATE INDEX idx_users_username ON users (username)');
    await db.execute('CREATE INDEX idx_users_email ON users (email)');
    await db.execute('CREATE INDEX idx_user_favorites_user_id ON user_favorites (user_id)');
    await db.execute('CREATE INDEX idx_user_favorites_recipe_id ON user_favorites (recipe_id)');
    
    // Meal plan indexes
    await db.execute('CREATE INDEX idx_meal_plans_start_date ON meal_plans (start_date)');
    await db.execute('CREATE INDEX idx_meal_plans_end_date ON meal_plans (end_date)');
    await db.execute('CREATE INDEX idx_meal_plans_user_id ON meal_plans (user_id)');
    await db.execute('CREATE INDEX idx_meal_plan_entries_meal_plan_id ON meal_plan_entries (meal_plan_id)');
    await db.execute('CREATE INDEX idx_meal_plan_entries_date ON meal_plan_entries (date)');
    await db.execute('CREATE INDEX idx_meal_plan_entries_meal_type ON meal_plan_entries (meal_type)');
    
    // Shopping list indexes
    await db.execute('CREATE INDEX idx_shopping_lists_user_id ON shopping_lists (user_id)');
    await db.execute('CREATE INDEX idx_shopping_list_items_list_id ON shopping_list_items (shopping_list_id)');
    await db.execute('CREATE INDEX idx_shopping_list_items_category ON shopping_list_items (category)');
    await db.execute('CREATE INDEX idx_shopping_list_items_checked ON shopping_list_items (checked)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < newVersion) {
      // Add migration logic based on version differences
      // For now, just recreate all tables (destructive migration)
      await _dropAllTables(db);
      await _onCreate(db, newVersion);
    }
  }

  Future<void> _dropAllTables(Database db) async {
    // Drop tables in reverse dependency order
    await db.execute('DROP TABLE IF EXISTS shopping_list_items');
    await db.execute('DROP TABLE IF EXISTS shopping_lists');
    await db.execute('DROP TABLE IF EXISTS meal_plan_entries');
    await db.execute('DROP TABLE IF EXISTS meal_plans');
    await db.execute('DROP TABLE IF EXISTS user_favorites');
    await db.execute('DROP TABLE IF EXISTS dietary_preferences');
    await db.execute('DROP TABLE IF EXISTS user_preferences');
    await db.execute('DROP TABLE IF EXISTS users');
    await db.execute('DROP TABLE IF EXISTS recipe_notes');
    await db.execute('DROP TABLE IF EXISTS recipe_assets');
    await db.execute('DROP TABLE IF EXISTS recipe_settings');
    await db.execute('DROP TABLE IF EXISTS recipe_nutrition');
    await db.execute('DROP TABLE IF EXISTS recipe_instructions');
    await db.execute('DROP TABLE IF EXISTS recipe_ingredients');
    await db.execute('DROP TABLE IF EXISTS recipe_tags');
    await db.execute('DROP TABLE IF EXISTS recipe_categories');
    await db.execute('DROP TABLE IF EXISTS recipes');
  }

  Future<void> clearCache() async {
    final db = await database;
    await db.transaction((txn) async {
      // Clear all cached data
      await txn.delete('shopping_list_items');
      await txn.delete('shopping_lists');
      await txn.delete('meal_plan_entries');
      await txn.delete('meal_plans');
      await txn.delete('user_favorites');
      await txn.delete('dietary_preferences');
      await txn.delete('user_preferences');
      await txn.delete('users');
      await txn.delete('recipe_notes');
      await txn.delete('recipe_assets');
      await txn.delete('recipe_settings');
      await txn.delete('recipe_nutrition');
      await txn.delete('recipe_instructions');
      await txn.delete('recipe_ingredients');
      await txn.delete('recipe_tags');
      await txn.delete('recipe_categories');
      await txn.delete('recipes');
    });
  }

  /// Clear only expired cache entries (older than specified duration)
  Future<void> clearExpiredCache({Duration maxAge = const Duration(days: 7)}) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(maxAge).toIso8601String();
    
    await db.transaction((txn) async {
      // Only clear entries older than cutoff date
      await txn.delete('recipes', where: 'cached_at < ?', whereArgs: [cutoffDate]);
      await txn.delete('users', where: 'cached_at < ?', whereArgs: [cutoffDate]);
      await txn.delete('meal_plans', where: 'cached_at < ?', whereArgs: [cutoffDate]);
      await txn.delete('shopping_lists', where: 'cached_at < ?', whereArgs: [cutoffDate]);
    });
  }

  /// Get database statistics
  Future<Map<String, int>> getDatabaseStats() async {
    final db = await database;
    final stats = <String, int>{};
    
    // Count records in each table
    final tables = [
      'recipes', 'recipe_categories', 'recipe_tags', 'recipe_ingredients',
      'recipe_instructions', 'recipe_nutrition', 'recipe_settings', 'recipe_assets',
      'recipe_notes', 'users', 'user_preferences', 'dietary_preferences',
      'user_favorites', 'meal_plans', 'meal_plan_entries', 'shopping_lists',
      'shopping_list_items'
    ];
    
    for (final table in tables) {
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table');
      stats[table] = result.first['count'] as int;
    }
    
    return stats;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}