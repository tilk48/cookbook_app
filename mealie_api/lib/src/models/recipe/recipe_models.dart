import 'package:json_annotation/json_annotation.dart';

part 'recipe_models.g.dart';

@JsonSerializable()
class RecipeSummary {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? image;
  @JsonKey(name: 'recipe_category')
  final List<RecipeCategory>? recipeCategory;
  final List<RecipeTag>? tags;
  final int? rating;
  @JsonKey(name: 'date_added')
  final DateTime? dateAdded;
  @JsonKey(name: 'date_updated')
  final DateTime? dateUpdated;

  const RecipeSummary({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.image,
    this.recipeCategory,
    this.tags,
    this.rating,
    this.dateAdded,
    this.dateUpdated,
  });

  factory RecipeSummary.fromJson(Map<String, dynamic> json) =>
      _$RecipeSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeSummaryToJson(this);
}

@JsonSerializable()
class Recipe {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? image;
  @JsonKey(name: 'recipe_category')
  final List<RecipeCategory>? recipeCategory;
  final List<RecipeTag>? tags;
  @JsonKey(name: 'recipe_ingredient')
  final List<RecipeIngredient>? recipeIngredient;
  @JsonKey(name: 'recipe_instructions')
  final List<RecipeInstruction>? recipeInstructions;
  final RecipeNutrition? nutrition;
  final RecipeSettings? settings;
  final List<RecipeAsset>? assets;
  final List<RecipeNote>? notes;
  @JsonKey(name: 'recipe_yield')
  final String? recipeYield;
  @JsonKey(name: 'recipe_servings')
  final double? recipeServings;
  final String? totalTime;
  final String? prepTime;
  final String? cookTime;
  final String? performTime;
  final int? rating;
  @JsonKey(name: 'date_added')
  final DateTime? dateAdded;
  @JsonKey(name: 'date_updated')
  final DateTime? dateUpdated;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'update_at')
  final DateTime? updateAt;

  const Recipe({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.image,
    this.recipeCategory,
    this.tags,
    this.recipeIngredient,
    this.recipeInstructions,
    this.nutrition,
    this.settings,
    this.assets,
    this.notes,
    this.recipeYield,
    this.recipeServings,
    this.totalTime,
    this.prepTime,
    this.cookTime,
    this.performTime,
    this.rating,
    this.dateAdded,
    this.dateUpdated,
    this.createdAt,
    this.updateAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // Handle both camelCase and snake_case field names
    final normalizedJson = Map<String, dynamic>.from(json);
    
    // Handle timing fields that might come as camelCase instead of snake_case
    if (json.containsKey('totalTime') && !json.containsKey('total_time')) {
      normalizedJson['total_time'] = json['totalTime'];
    }
    if (json.containsKey('prepTime') && !json.containsKey('prep_time')) {
      normalizedJson['prep_time'] = json['prepTime'];
    }
    if (json.containsKey('cookTime') && !json.containsKey('cook_time')) {
      normalizedJson['cook_time'] = json['cookTime'];
    }
    if (json.containsKey('performTime') && !json.containsKey('perform_time')) {
      normalizedJson['perform_time'] = json['performTime'];
    }
    
    // Handle ingredient and instruction fields that come as camelCase
    if (json.containsKey('recipeIngredient') && !json.containsKey('recipe_ingredient')) {
      normalizedJson['recipe_ingredient'] = json['recipeIngredient'];
    }
    if (json.containsKey('recipeInstructions') && !json.containsKey('recipe_instructions')) {
      normalizedJson['recipe_instructions'] = json['recipeInstructions'];
    }
    if (json.containsKey('recipeCategory') && !json.containsKey('recipe_category')) {
      normalizedJson['recipe_category'] = json['recipeCategory'];
    }
    if (json.containsKey('recipeYield') && !json.containsKey('recipe_yield')) {
      normalizedJson['recipe_yield'] = json['recipeYield'];
    }
    if (json.containsKey('recipeServings') && !json.containsKey('recipe_servings')) {
      normalizedJson['recipe_servings'] = json['recipeServings'];
    }
    
    try {
      return _$RecipeFromJson(normalizedJson);
    } catch (e) {
      // More detailed error logging
      print('DEBUG: Error parsing Recipe JSON: $e');
      print('DEBUG: JSON keys: ${json.keys.toList()}');
      print('DEBUG: Problematic values - totalTime: ${json['totalTime']}, prepTime: ${json['prepTime']}, cookTime: ${json['cookTime']}');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$RecipeToJson(this);
}

@JsonSerializable()
class RecipeCategory {
  final String id;
  final String name;
  final String slug;

  const RecipeCategory({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory RecipeCategory.fromJson(Map<String, dynamic> json) =>
      _$RecipeCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeCategoryToJson(this);
}

@JsonSerializable()
class RecipeTag {
  final String id;
  final String name;
  final String slug;

  const RecipeTag({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory RecipeTag.fromJson(Map<String, dynamic> json) =>
      _$RecipeTagFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeTagToJson(this);
}

@JsonSerializable()
class IngredientFood {
  final String id;
  final String name;
  @JsonKey(name: 'plural_name')
  final String? pluralName;
  final String? description;

  const IngredientFood({
    required this.id,
    required this.name,
    this.pluralName,
    this.description,
  });

  factory IngredientFood.fromJson(Map<String, dynamic> json) =>
      _$IngredientFoodFromJson(json);

  Map<String, dynamic> toJson() => _$IngredientFoodToJson(this);
}

@JsonSerializable()
class IngredientUnit {
  final String id;
  final String name;
  @JsonKey(name: 'plural_name')
  final String? pluralName;
  final String? description;
  final String? abbreviation;
  @JsonKey(name: 'plural_abbreviation')
  final String? pluralAbbreviation;
  @JsonKey(name: 'use_abbreviation')
  final bool? useAbbreviation;

  const IngredientUnit({
    required this.id,
    required this.name,
    this.pluralName,
    this.description,
    this.abbreviation,
    this.pluralAbbreviation,
    this.useAbbreviation,
  });

  factory IngredientUnit.fromJson(Map<String, dynamic> json) =>
      _$IngredientUnitFromJson(json);

  Map<String, dynamic> toJson() => _$IngredientUnitToJson(this);
}

@JsonSerializable()
class RecipeIngredient {
  final String? title;
  final String? note;
  final IngredientUnit? unit;
  final IngredientFood? food;
  final bool? disable_amount;
  final double? quantity;
  @JsonKey(name: 'original_text')
  final String? originalText;
  @JsonKey(name: 'reference_id')
  final String? referenceId;
  final String? display;

  const RecipeIngredient({
    this.title,
    this.note,
    this.unit,
    this.food,
    this.disable_amount,
    this.quantity,
    this.originalText,
    this.referenceId,
    this.display,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) =>
      _$RecipeIngredientFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeIngredientToJson(this);
}

@JsonSerializable()
class RecipeInstruction {
  final String? id;
  final String? title;
  final String? text;
  @JsonKey(name: 'ingredient_references')
  final List<IngredientReference>? ingredientReferences;

  const RecipeInstruction({
    this.id,
    this.title,
    this.text,
    this.ingredientReferences,
  });

  factory RecipeInstruction.fromJson(Map<String, dynamic> json) =>
      _$RecipeInstructionFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeInstructionToJson(this);
}

@JsonSerializable()
class IngredientReference {
  @JsonKey(name: 'reference_id')
  final String referenceId;

  const IngredientReference({required this.referenceId});

  factory IngredientReference.fromJson(Map<String, dynamic> json) =>
      _$IngredientReferenceFromJson(json);

  Map<String, dynamic> toJson() => _$IngredientReferenceToJson(this);
}

@JsonSerializable()
class RecipeNutrition {
  final String? calories;
  @JsonKey(name: 'fat_content')
  final String? fatContent;
  @JsonKey(name: 'protein_content')
  final String? proteinContent;
  @JsonKey(name: 'carbohydrate_content')
  final String? carbohydrateContent;
  @JsonKey(name: 'fiber_content')
  final String? fiberContent;
  @JsonKey(name: 'sugar_content')
  final String? sugarContent;
  @JsonKey(name: 'sodium_content')
  final String? sodiumContent;

  const RecipeNutrition({
    this.calories,
    this.fatContent,
    this.proteinContent,
    this.carbohydrateContent,
    this.fiberContent,
    this.sugarContent,
    this.sodiumContent,
  });

  factory RecipeNutrition.fromJson(Map<String, dynamic> json) =>
      _$RecipeNutritionFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeNutritionToJson(this);
}

@JsonSerializable()
class RecipeSettings {
  @JsonKey(name: 'public')
  final bool? isPublic;
  @JsonKey(name: 'show_nutrition')
  final bool? showNutrition;
  @JsonKey(name: 'show_assets')
  final bool? showAssets;
  @JsonKey(name: 'landscape_view')
  final bool? landscapeView;
  @JsonKey(name: 'disable_comments')
  final bool? disableComments;
  @JsonKey(name: 'disable_amount')
  final bool? disableAmount;
  @JsonKey(name: 'locked')
  final bool? locked;

  const RecipeSettings({
    this.isPublic,
    this.showNutrition,
    this.showAssets,
    this.landscapeView,
    this.disableComments,
    this.disableAmount,
    this.locked,
  });

  factory RecipeSettings.fromJson(Map<String, dynamic> json) =>
      _$RecipeSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeSettingsToJson(this);
}

@JsonSerializable()
class RecipeAsset {
  final String name;
  final String icon;
  @JsonKey(name: 'file_name')
  final String fileName;

  const RecipeAsset({
    required this.name,
    required this.icon,
    required this.fileName,
  });

  factory RecipeAsset.fromJson(Map<String, dynamic> json) =>
      _$RecipeAssetFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeAssetToJson(this);
}

@JsonSerializable()
class RecipeNote {
  final String? id;
  final String? title;
  final String? text;

  const RecipeNote({
    this.id,
    this.title,
    this.text,
  });

  factory RecipeNote.fromJson(Map<String, dynamic> json) =>
      _$RecipeNoteFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeNoteToJson(this);
}

@JsonSerializable()
class CreateRecipeRequest {
  final String name;
  final String? description;
  @JsonKey(name: 'recipe_category')
  final List<String>? recipeCategory;
  final List<String>? tags;
  @JsonKey(name: 'recipe_ingredient')
  final List<RecipeIngredient>? recipeIngredient;
  @JsonKey(name: 'recipe_instructions')
  final List<CreateRecipeInstruction>? recipeInstructions;
  @JsonKey(name: 'recipe_yield')
  final String? recipeYield;
  @JsonKey(name: 'total_time')
  final String? totalTime;
  @JsonKey(name: 'prep_time')
  final String? prepTime;
  @JsonKey(name: 'cook_time')
  final String? cookTime;

  const CreateRecipeRequest({
    required this.name,
    this.description,
    this.recipeCategory,
    this.tags,
    this.recipeIngredient,
    this.recipeInstructions,
    this.recipeYield,
    this.totalTime,
    this.prepTime,
    this.cookTime,
  });

  factory CreateRecipeRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateRecipeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateRecipeRequestToJson(this);
}

@JsonSerializable()
class CreateRecipeInstruction {
  final String title;
  final String text;

  const CreateRecipeInstruction({
    required this.title,
    required this.text,
  });

  factory CreateRecipeInstruction.fromJson(Map<String, dynamic> json) =>
      _$CreateRecipeInstructionFromJson(json);

  Map<String, dynamic> toJson() => _$CreateRecipeInstructionToJson(this);
}