import 'package:equatable/equatable.dart';

/// Domain entity representing a meal plan in the app
/// This is the core business object, independent of external APIs or database schemas
class MealPlanEntity extends Equatable {
  final String id;
  final String? title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String userId;
  final String householdId;
  final List<MealPlanEntryEntity> entries;
  final List<String> shoppingListIds;
  final MealPlanSettingsEntity settings;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? cachedAt;

  const MealPlanEntity({
    required this.id,
    this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.userId,
    required this.householdId,
    this.entries = const [],
    this.shoppingListIds = const [],
    this.settings = const MealPlanSettingsEntity(),
    this.createdAt,
    this.updatedAt,
    this.cachedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        startDate,
        endDate,
        userId,
        householdId,
        entries,
        shoppingListIds,
        settings,
        createdAt,
        updatedAt,
        cachedAt,
      ];

  /// Create a copy with modified fields
  MealPlanEntity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
    String? householdId,
    List<MealPlanEntryEntity>? entries,
    List<String>? shoppingListIds,
    MealPlanSettingsEntity? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? cachedAt,
  }) {
    return MealPlanEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      userId: userId ?? this.userId,
      householdId: householdId ?? this.householdId,
      entries: entries ?? this.entries,
      shoppingListIds: shoppingListIds ?? this.shoppingListIds,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  /// Get display title (title or generated from date range)
  String get displayTitle {
    if (title?.isNotEmpty == true) return title!;
    
    final formatter = settings.dateFormat;
    return 'Meal Plan ${formatter.format(startDate)} - ${formatter.format(endDate)}';
  }

  /// Get duration of the meal plan in days
  int get durationInDays => endDate.difference(startDate).inDays + 1;

  /// Check if meal plan is currently active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate.add(const Duration(days: 1)));
  }

  /// Check if meal plan is in the future
  bool get isFuture => DateTime.now().isBefore(startDate);

  /// Check if meal plan is in the past
  bool get isPast => DateTime.now().isAfter(endDate);

  /// Get entries for a specific date
  List<MealPlanEntryEntity> getEntriesForDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return entries.where((entry) {
      final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
      return entryDate == targetDate;
    }).toList()..sort((a, b) => a.mealType.sortOrder.compareTo(b.mealType.sortOrder));
  }

  /// Get entries for a specific meal type and date
  List<MealPlanEntryEntity> getEntriesForMealType(DateTime date, MealType mealType) {
    return getEntriesForDate(date)
        .where((entry) => entry.mealType == mealType)
        .toList();
  }

  /// Get all unique recipes used in this meal plan
  List<String> get uniqueRecipeIds {
    return entries
        .map((entry) => entry.recipeId)
        .where((id) => id != null)
        .cast<String>()
        .toSet()
        .toList();
  }

  /// Get total number of meals planned
  int get totalMealsPlanned => entries.length;

  /// Get meals planned by type
  Map<MealType, int> get mealsByType {
    final result = <MealType, int>{};
    for (final entry in entries) {
      result[entry.mealType] = (result[entry.mealType] ?? 0) + 1;
    }
    return result;
  }

  /// Add a meal plan entry
  MealPlanEntity addEntry(MealPlanEntryEntity entry) {
    return copyWith(entries: [...entries, entry]);
  }

  /// Remove a meal plan entry
  MealPlanEntity removeEntry(String entryId) {
    return copyWith(
      entries: entries.where((e) => e.id != entryId).toList(),
    );
  }

  /// Update a meal plan entry
  MealPlanEntity updateEntry(MealPlanEntryEntity updatedEntry) {
    return copyWith(
      entries: entries.map((e) => e.id == updatedEntry.id ? updatedEntry : e).toList(),
    );
  }

  /// Check if a specific date falls within this meal plan
  bool containsDate(DateTime date) {
    final checkDate = DateTime(date.year, date.month, date.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    
    return !checkDate.isBefore(start) && !checkDate.isAfter(end);
  }

  /// Get all dates in this meal plan
  List<DateTime> get allDates {
    final dates = <DateTime>[];
    var current = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    
    while (!current.isAfter(end)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    return dates;
  }

  /// Get meal plan completion percentage (days with at least one meal)
  double get completionPercentage {
    if (durationInDays == 0) return 0.0;
    
    final daysWithMeals = allDates
        .where((date) => getEntriesForDate(date).isNotEmpty)
        .length;
        
    return daysWithMeals / durationInDays;
  }
}

/// Individual meal plan entry
class MealPlanEntryEntity extends Equatable {
  final String id;
  final DateTime date;
  final MealType mealType;
  final String? recipeId;
  final String? recipeName;
  final String? recipeSlug;
  final String? title;
  final String? text;
  final int? servings;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MealPlanEntryEntity({
    required this.id,
    required this.date,
    required this.mealType,
    this.recipeId,
    this.recipeName,
    this.recipeSlug,
    this.title,
    this.text,
    this.servings,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        date,
        mealType,
        recipeId,
        recipeName,
        recipeSlug,
        title,
        text,
        servings,
        createdAt,
        updatedAt,
      ];

  /// Create a copy with modified fields
  MealPlanEntryEntity copyWith({
    String? id,
    DateTime? date,
    MealType? mealType,
    String? recipeId,
    String? recipeName,
    String? recipeSlug,
    String? title,
    String? text,
    int? servings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealPlanEntryEntity(
      id: id ?? this.id,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      recipeId: recipeId ?? this.recipeId,
      recipeName: recipeName ?? this.recipeName,
      recipeSlug: recipeSlug ?? this.recipeSlug,
      title: title ?? this.title,
      text: text ?? this.text,
      servings: servings ?? this.servings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get display name for this entry
  String get displayName {
    if (recipeName?.isNotEmpty == true) return recipeName!;
    if (title?.isNotEmpty == true) return title!;
    return 'Meal Plan Entry';
  }

  /// Check if this entry has a linked recipe
  bool get hasRecipe => recipeId != null;

  /// Check if this is a custom text entry (no recipe)
  bool get isCustomEntry => !hasRecipe;

  /// Get formatted servings text
  String? get servingsText {
    if (servings == null) return null;
    return servings == 1 ? '1 serving' : '$servings servings';
  }
}

/// Meal plan settings entity
class MealPlanSettingsEntity extends Equatable {
  final bool showNutrition;
  final bool includeIngredients;
  final bool autoGenerateShoppingList;
  final String dateFormatString;
  final List<MealType> defaultMealTypes;

  const MealPlanSettingsEntity({
    this.showNutrition = true,
    this.includeIngredients = true,
    this.autoGenerateShoppingList = false,
    this.dateFormatString = 'MMM d, y',
    this.defaultMealTypes = const [
      MealType.breakfast,
      MealType.lunch,
      MealType.dinner,
    ],
  });

  @override
  List<Object?> get props => [
        showNutrition,
        includeIngredients,
        autoGenerateShoppingList,
        dateFormatString,
        defaultMealTypes,
      ];

  /// Create a copy with modified fields
  MealPlanSettingsEntity copyWith({
    bool? showNutrition,
    bool? includeIngredients,
    bool? autoGenerateShoppingList,
    String? dateFormatString,
    List<MealType>? defaultMealTypes,
  }) {
    return MealPlanSettingsEntity(
      showNutrition: showNutrition ?? this.showNutrition,
      includeIngredients: includeIngredients ?? this.includeIngredients,
      autoGenerateShoppingList: autoGenerateShoppingList ?? this.autoGenerateShoppingList,
      dateFormatString: dateFormatString ?? this.dateFormatString,
      defaultMealTypes: defaultMealTypes ?? this.defaultMealTypes,
    );
  }

  /// Get date formatter based on settings
  // Note: In real implementation, you'd import intl package and use DateFormat
  // For now, using a simple toString representation
  dynamic get dateFormat => dateFormatString; // DateFormat(dateFormatString);
}

/// Meal type enumeration
enum MealType {
  breakfast('Breakfast', 0),
  lunch('Lunch', 1),
  dinner('Dinner', 2),
  snack('Snack', 3),
  dessert('Dessert', 4),
  other('Other', 5);

  const MealType(this.displayName, this.sortOrder);

  final String displayName;
  final int sortOrder;

  /// Get meal type from string
  static MealType fromString(String value) {
    return values.firstWhere(
      (type) => type.name.toLowerCase() == value.toLowerCase(),
      orElse: () => MealType.other,
    );
  }

  /// Get typical time for this meal type
  String get typicalTime => switch (this) {
    MealType.breakfast => '7:00 AM',
    MealType.lunch => '12:00 PM',
    MealType.dinner => '6:00 PM',
    MealType.snack => '3:00 PM',
    MealType.dessert => '8:00 PM',
    MealType.other => '',
  };

  /// Get emoji representation
  String get emoji => switch (this) {
    MealType.breakfast => '🥐',
    MealType.lunch => '🍽️',
    MealType.dinner => '🍖',
    MealType.snack => '🍎',
    MealType.dessert => '🍰',
    MealType.other => '🍴',
  };

  /// Check if this is a main meal (not snack/dessert/other)
  bool get isMainMeal => [breakfast, lunch, dinner].contains(this);
}

/// Meal plan status enumeration
enum MealPlanStatus {
  draft,
  active,
  completed,
  archived;

  String get displayName => switch (this) {
    MealPlanStatus.draft => 'Draft',
    MealPlanStatus.active => 'Active',
    MealPlanStatus.completed => 'Completed',
    MealPlanStatus.archived => 'Archived',
  };

  String get description => switch (this) {
    MealPlanStatus.draft => 'Plan is being prepared',
    MealPlanStatus.active => 'Currently following this plan',
    MealPlanStatus.completed => 'Plan has been finished',
    MealPlanStatus.archived => 'Plan is archived for reference',
  };
}