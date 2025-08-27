import 'package:equatable/equatable.dart';

/// Domain entity representing a recipe in the app
/// This is the core business object, independent of external APIs or database schemas
class RecipeEntity extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? imageUrl;
  final List<RecipeCategoryEntity> categories;
  final List<RecipeTagEntity> tags;
  final List<RecipeIngredientEntity> ingredients;
  final List<RecipeInstructionEntity> instructions;
  final RecipeNutritionEntity? nutrition;
  final RecipeSettingsEntity settings;
  final List<RecipeAssetEntity> assets;
  final List<RecipeNoteEntity> notes;
  
  // Time and yield information
  final String? recipeYield;
  final String? totalTime;
  final String? prepTime;
  final String? cookTime;
  final String? performTime;
  
  // User interaction data
  final int? rating;
  final bool isFavorite;
  final DateTime? lastMade;
  final int timesMade;
  
  // Metadata
  final DateTime? dateAdded;
  final DateTime? dateUpdated;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? cachedAt;

  const RecipeEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.imageUrl,
    this.categories = const [],
    this.tags = const [],
    this.ingredients = const [],
    this.instructions = const [],
    this.nutrition,
    this.settings = const RecipeSettingsEntity(),
    this.assets = const [],
    this.notes = const [],
    this.recipeYield,
    this.totalTime,
    this.prepTime,
    this.cookTime,
    this.performTime,
    this.rating,
    this.isFavorite = false,
    this.lastMade,
    this.timesMade = 0,
    this.dateAdded,
    this.dateUpdated,
    this.createdAt,
    this.updatedAt,
    this.cachedAt,
  });

  @override
  List<Object?> get props => [
    id, name, slug, description, imageUrl,
    categories, tags, ingredients, instructions,
    nutrition, settings, assets, notes,
    recipeYield, totalTime, prepTime, cookTime, performTime,
    rating, isFavorite, lastMade, timesMade,
    dateAdded, dateUpdated, createdAt, updatedAt, cachedAt,
  ];

  /// Create a copy with modified fields
  RecipeEntity copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    String? imageUrl,
    List<RecipeCategoryEntity>? categories,
    List<RecipeTagEntity>? tags,
    List<RecipeIngredientEntity>? ingredients,
    List<RecipeInstructionEntity>? instructions,
    RecipeNutritionEntity? nutrition,
    RecipeSettingsEntity? settings,
    List<RecipeAssetEntity>? assets,
    List<RecipeNoteEntity>? notes,
    String? recipeYield,
    String? totalTime,
    String? prepTime,
    String? cookTime,
    String? performTime,
    int? rating,
    bool? isFavorite,
    DateTime? lastMade,
    int? timesMade,
    DateTime? dateAdded,
    DateTime? dateUpdated,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? cachedAt,
  }) {
    return RecipeEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      nutrition: nutrition ?? this.nutrition,
      settings: settings ?? this.settings,
      assets: assets ?? this.assets,
      notes: notes ?? this.notes,
      recipeYield: recipeYield ?? this.recipeYield,
      totalTime: totalTime ?? this.totalTime,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      performTime: performTime ?? this.performTime,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
      lastMade: lastMade ?? this.lastMade,
      timesMade: timesMade ?? this.timesMade,
      dateAdded: dateAdded ?? this.dateAdded,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  /// Get the primary image URL for the recipe
  String? get primaryImageUrl => imageUrl;

  /// Check if the recipe has any dietary restrictions
  bool get hasDietaryInfo => nutrition != null;

  /// Get total cooking time in minutes (if available)
  int? get totalTimeMinutes => _parseTimeToMinutes(totalTime);

  /// Get prep time in minutes (if available) 
  int? get prepTimeMinutes => _parseTimeToMinutes(prepTime);

  /// Get cook time in minutes (if available)
  int? get cookTimeMinutes => _parseTimeToMinutes(cookTime);

  /// Parse time string to minutes (handles formats like "30 minutes", "1 hour", "1h 30m")
  int? _parseTimeToMinutes(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    
    final timeRegex = RegExp(r'(\d+)\s*(hour|hr|h|minute|min|m)', caseSensitive: false);
    final matches = timeRegex.allMatches(timeStr);
    
    int totalMinutes = 0;
    for (final match in matches) {
      final value = int.tryParse(match.group(1) ?? '') ?? 0;
      final unit = match.group(2)?.toLowerCase() ?? '';
      
      if (unit.startsWith('h')) {
        totalMinutes += value * 60;
      } else if (unit.startsWith('m')) {
        totalMinutes += value;
      }
    }
    
    return totalMinutes > 0 ? totalMinutes : null;
  }

  /// Get estimated difficulty based on ingredients and instructions
  RecipeDifficulty get estimatedDifficulty {
    final ingredientCount = ingredients.length;
    final instructionCount = instructions.length;
    final totalTime = totalTimeMinutes ?? 0;
    
    if (ingredientCount <= 5 && instructionCount <= 5 && totalTime <= 30) {
      return RecipeDifficulty.easy;
    } else if (ingredientCount <= 10 && instructionCount <= 10 && totalTime <= 60) {
      return RecipeDifficulty.medium;
    } else {
      return RecipeDifficulty.hard;
    }
  }
}

/// Recipe category entity
class RecipeCategoryEntity extends Equatable {
  final String id;
  final String name;
  final String slug;

  const RecipeCategoryEntity({
    required this.id,
    required this.name,
    required this.slug,
  });

  @override
  List<Object?> get props => [id, name, slug];
}

/// Recipe tag entity
class RecipeTagEntity extends Equatable {
  final String id;
  final String name;
  final String slug;

  const RecipeTagEntity({
    required this.id,
    required this.name,
    required this.slug,
  });

  @override
  List<Object?> get props => [id, name, slug];
}

/// Recipe ingredient entity
class RecipeIngredientEntity extends Equatable {
  final String? title;
  final String? note;
  final String? unit;
  final String? food;
  final bool disableAmount;
  final double? quantity;
  final String? originalText;
  final String? referenceId;
  final int position;

  const RecipeIngredientEntity({
    this.title,
    this.note,
    this.unit,
    this.food,
    this.disableAmount = false,
    this.quantity,
    this.originalText,
    this.referenceId,
    this.position = 0,
  });

  @override
  List<Object?> get props => [
    title, note, unit, food, disableAmount,
    quantity, originalText, referenceId, position,
  ];

  /// Get formatted ingredient string for display
  String get displayText {
    final buffer = StringBuffer();
    
    if (quantity != null && !disableAmount) {
      buffer.write('${quantity!} ');
    }
    
    if (unit != null && unit!.isNotEmpty) {
      buffer.write('$unit ');
    }
    
    if (food != null && food!.isNotEmpty) {
      buffer.write(food);
    } else if (originalText != null) {
      buffer.write(originalText);
    }
    
    if (note != null && note!.isNotEmpty) {
      buffer.write(' ($note)');
    }
    
    return buffer.toString().trim();
  }
}

/// Recipe instruction entity
class RecipeInstructionEntity extends Equatable {
  final String id;
  final String title;
  final String text;
  final int position;
  final List<String> ingredientReferences;

  const RecipeInstructionEntity({
    required this.id,
    required this.title,
    required this.text,
    this.position = 0,
    this.ingredientReferences = const [],
  });

  @override
  List<Object?> get props => [id, title, text, position, ingredientReferences];
}

/// Recipe nutrition entity
class RecipeNutritionEntity extends Equatable {
  final String? calories;
  final String? fatContent;
  final String? proteinContent;
  final String? carbohydrateContent;
  final String? fiberContent;
  final String? sugarContent;
  final String? sodiumContent;

  const RecipeNutritionEntity({
    this.calories,
    this.fatContent,
    this.proteinContent,
    this.carbohydrateContent,
    this.fiberContent,
    this.sugarContent,
    this.sodiumContent,
  });

  @override
  List<Object?> get props => [
    calories, fatContent, proteinContent, carbohydrateContent,
    fiberContent, sugarContent, sodiumContent,
  ];

  /// Check if any nutrition info is available
  bool get hasNutritionInfo => [
    calories, fatContent, proteinContent, carbohydrateContent,
    fiberContent, sugarContent, sodiumContent,
  ].any((element) => element != null && element.isNotEmpty);
}

/// Recipe settings entity
class RecipeSettingsEntity extends Equatable {
  final bool isPublic;
  final bool showNutrition;
  final bool showAssets;
  final bool landscapeView;
  final bool disableComments;
  final bool disableAmount;
  final bool locked;

  const RecipeSettingsEntity({
    this.isPublic = true,
    this.showNutrition = true,
    this.showAssets = true,
    this.landscapeView = false,
    this.disableComments = false,
    this.disableAmount = false,
    this.locked = false,
  });

  @override
  List<Object?> get props => [
    isPublic, showNutrition, showAssets, landscapeView,
    disableComments, disableAmount, locked,
  ];
}

/// Recipe asset entity
class RecipeAssetEntity extends Equatable {
  final String name;
  final String icon;
  final String fileName;

  const RecipeAssetEntity({
    required this.name,
    required this.icon,
    required this.fileName,
  });

  @override
  List<Object?> get props => [name, icon, fileName];
}

/// Recipe note entity
class RecipeNoteEntity extends Equatable {
  final String id;
  final String title;
  final String text;

  const RecipeNoteEntity({
    required this.id,
    required this.title,
    required this.text,
  });

  @override
  List<Object?> get props => [id, title, text];
}

/// Recipe difficulty enumeration
enum RecipeDifficulty {
  easy,
  medium,
  hard;

  String get displayName => switch (this) {
    RecipeDifficulty.easy => 'Easy',
    RecipeDifficulty.medium => 'Medium',
    RecipeDifficulty.hard => 'Hard',
  };

  String get description => switch (this) {
    RecipeDifficulty.easy => 'Quick and simple',
    RecipeDifficulty.medium => 'Moderate complexity',
    RecipeDifficulty.hard => 'Advanced cooking',
  };
}