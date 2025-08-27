import 'package:equatable/equatable.dart';

/// Domain entity representing a user in the app
/// This is the core business object, independent of external APIs or database schemas
class UserEntity extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? fullName;
  final bool isAdmin;
  final bool canInvite;
  final bool canManage;
  final bool canOrganize;
  final String? avatarUrl;
  final UserPreferencesEntity preferences;
  final List<String> favoriteRecipes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLogin;
  final DateTime? cachedAt;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.isAdmin = false,
    this.canInvite = false,
    this.canManage = false,
    this.canOrganize = false,
    this.avatarUrl,
    this.preferences = const UserPreferencesEntity(),
    this.favoriteRecipes = const [],
    this.createdAt,
    this.updatedAt,
    this.lastLogin,
    this.cachedAt,
  });

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        fullName,
        isAdmin,
        canInvite,
        canManage,
        canOrganize,
        avatarUrl,
        preferences,
        favoriteRecipes,
        createdAt,
        updatedAt,
        lastLogin,
        cachedAt,
      ];

  /// Create a copy with modified fields
  UserEntity copyWith({
    String? id,
    String? username,
    String? email,
    String? fullName,
    bool? isAdmin,
    bool? canInvite,
    bool? canManage,
    bool? canOrganize,
    String? avatarUrl,
    UserPreferencesEntity? preferences,
    List<String>? favoriteRecipes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
    DateTime? cachedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      isAdmin: isAdmin ?? this.isAdmin,
      canInvite: canInvite ?? this.canInvite,
      canManage: canManage ?? this.canManage,
      canOrganize: canOrganize ?? this.canOrganize,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      preferences: preferences ?? this.preferences,
      favoriteRecipes: favoriteRecipes ?? this.favoriteRecipes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  /// Get display name (full name or username)
  String get displayName => fullName?.isNotEmpty == true ? fullName! : username;

  /// Check if user has administrative privileges
  bool get hasAdminPrivileges => isAdmin;

  /// Check if user can create invitations
  bool get hasInvitePrivileges => canInvite || isAdmin;

  /// Check if user can manage recipes and data
  bool get hasManagePrivileges => canManage || isAdmin;

  /// Check if user can organize meal plans and shopping lists
  bool get hasOrganizePrivileges => canOrganize || isAdmin;

  /// Get user's permission level
  UserPermissionLevel get permissionLevel {
    if (isAdmin) return UserPermissionLevel.admin;
    if (canManage) return UserPermissionLevel.manager;
    if (canOrganize) return UserPermissionLevel.organizer;
    if (canInvite) return UserPermissionLevel.contributor;
    return UserPermissionLevel.viewer;
  }

  /// Check if user has favorited a specific recipe
  bool hasRecipeInFavorites(String recipeId) {
    return favoriteRecipes.contains(recipeId);
  }

  /// Add recipe to favorites
  UserEntity addToFavorites(String recipeId) {
    if (hasRecipeInFavorites(recipeId)) return this;
    
    return copyWith(
      favoriteRecipes: [...favoriteRecipes, recipeId],
    );
  }

  /// Remove recipe from favorites
  UserEntity removeFromFavorites(String recipeId) {
    if (!hasRecipeInFavorites(recipeId)) return this;
    
    return copyWith(
      favoriteRecipes: favoriteRecipes.where((id) => id != recipeId).toList(),
    );
  }

  /// Check if user account is recently active (within last 30 days)
  bool get isRecentlyActive {
    if (lastLogin == null) return false;
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return lastLogin!.isAfter(thirtyDaysAgo);
  }
}

/// User preferences entity
class UserPreferencesEntity extends Equatable {
  final bool privateRecipes;
  final String defaultRecipePublic;
  final bool showRecipeNutrition;
  final bool showRecipeAssets;
  final bool landscapeViewDefault;
  final bool disableCommentsDefault;
  final bool disableAmountDefault;
  final String localeCode;
  final String firstDayOfWeek;
  final DietaryPreferencesEntity? dietaryPreferences;

  const UserPreferencesEntity({
    this.privateRecipes = false,
    this.defaultRecipePublic = 'true',
    this.showRecipeNutrition = true,
    this.showRecipeAssets = true,
    this.landscapeViewDefault = false,
    this.disableCommentsDefault = false,
    this.disableAmountDefault = false,
    this.localeCode = 'en-US',
    this.firstDayOfWeek = 'monday',
    this.dietaryPreferences,
  });

  @override
  List<Object?> get props => [
        privateRecipes,
        defaultRecipePublic,
        showRecipeNutrition,
        showRecipeAssets,
        landscapeViewDefault,
        disableCommentsDefault,
        disableAmountDefault,
        localeCode,
        firstDayOfWeek,
        dietaryPreferences,
      ];

  /// Create a copy with modified fields
  UserPreferencesEntity copyWith({
    bool? privateRecipes,
    String? defaultRecipePublic,
    bool? showRecipeNutrition,
    bool? showRecipeAssets,
    bool? landscapeViewDefault,
    bool? disableCommentsDefault,
    bool? disableAmountDefault,
    String? localeCode,
    String? firstDayOfWeek,
    DietaryPreferencesEntity? dietaryPreferences,
  }) {
    return UserPreferencesEntity(
      privateRecipes: privateRecipes ?? this.privateRecipes,
      defaultRecipePublic: defaultRecipePublic ?? this.defaultRecipePublic,
      showRecipeNutrition: showRecipeNutrition ?? this.showRecipeNutrition,
      showRecipeAssets: showRecipeAssets ?? this.showRecipeAssets,
      landscapeViewDefault: landscapeViewDefault ?? this.landscapeViewDefault,
      disableCommentsDefault: disableCommentsDefault ?? this.disableCommentsDefault,
      disableAmountDefault: disableAmountDefault ?? this.disableAmountDefault,
      localeCode: localeCode ?? this.localeCode,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
    );
  }

  /// Get first day of week as DateTime weekday (1=Monday, 7=Sunday)
  int get firstDayOfWeekInt => switch (firstDayOfWeek.toLowerCase()) {
    'monday' => DateTime.monday,
    'tuesday' => DateTime.tuesday,
    'wednesday' => DateTime.wednesday,
    'thursday' => DateTime.thursday,
    'friday' => DateTime.friday,
    'saturday' => DateTime.saturday,
    'sunday' => DateTime.sunday,
    _ => DateTime.monday,
  };

  /// Check if recipes should be public by default
  bool get recipesPublicByDefault => defaultRecipePublic == 'true';
}

/// Dietary preferences entity
class DietaryPreferencesEntity extends Equatable {
  final List<String> allergies;
  final List<String> dietaryRestrictions;
  final List<String> dislikedIngredients;
  final List<String> preferredCuisines;
  final bool vegetarian;
  final bool vegan;
  final bool glutenFree;
  final bool dairyFree;
  final bool keto;
  final bool lowCarb;
  final bool lowFat;
  final bool lowSodium;

  const DietaryPreferencesEntity({
    this.allergies = const [],
    this.dietaryRestrictions = const [],
    this.dislikedIngredients = const [],
    this.preferredCuisines = const [],
    this.vegetarian = false,
    this.vegan = false,
    this.glutenFree = false,
    this.dairyFree = false,
    this.keto = false,
    this.lowCarb = false,
    this.lowFat = false,
    this.lowSodium = false,
  });

  @override
  List<Object?> get props => [
        allergies,
        dietaryRestrictions,
        dislikedIngredients,
        preferredCuisines,
        vegetarian,
        vegan,
        glutenFree,
        dairyFree,
        keto,
        lowCarb,
        lowFat,
        lowSodium,
      ];

  /// Create a copy with modified fields
  DietaryPreferencesEntity copyWith({
    List<String>? allergies,
    List<String>? dietaryRestrictions,
    List<String>? dislikedIngredients,
    List<String>? preferredCuisines,
    bool? vegetarian,
    bool? vegan,
    bool? glutenFree,
    bool? dairyFree,
    bool? keto,
    bool? lowCarb,
    bool? lowFat,
    bool? lowSodium,
  }) {
    return DietaryPreferencesEntity(
      allergies: allergies ?? this.allergies,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      dislikedIngredients: dislikedIngredients ?? this.dislikedIngredients,
      preferredCuisines: preferredCuisines ?? this.preferredCuisines,
      vegetarian: vegetarian ?? this.vegetarian,
      vegan: vegan ?? this.vegan,
      glutenFree: glutenFree ?? this.glutenFree,
      dairyFree: dairyFree ?? this.dairyFree,
      keto: keto ?? this.keto,
      lowCarb: lowCarb ?? this.lowCarb,
      lowFat: lowFat ?? this.lowFat,
      lowSodium: lowSodium ?? this.lowSodium,
    );
  }

  /// Check if user has any dietary restrictions
  bool get hasDietaryRestrictions {
    return allergies.isNotEmpty ||
        dietaryRestrictions.isNotEmpty ||
        vegetarian ||
        vegan ||
        glutenFree ||
        dairyFree ||
        keto ||
        lowCarb ||
        lowFat ||
        lowSodium;
  }

  /// Get all active dietary restrictions as a list
  List<String> get activeDietaryRestrictions {
    final restrictions = <String>[];
    
    if (vegetarian) restrictions.add('Vegetarian');
    if (vegan) restrictions.add('Vegan');
    if (glutenFree) restrictions.add('Gluten-Free');
    if (dairyFree) restrictions.add('Dairy-Free');
    if (keto) restrictions.add('Keto');
    if (lowCarb) restrictions.add('Low-Carb');
    if (lowFat) restrictions.add('Low-Fat');
    if (lowSodium) restrictions.add('Low-Sodium');
    
    restrictions.addAll(dietaryRestrictions);
    
    return restrictions;
  }

  /// Check if a recipe matches user's dietary preferences
  bool isRecipeCompatible(List<String> recipeCategories, List<String> recipeTags) {
    final allRecipeInfo = [...recipeCategories, ...recipeTags].map((e) => e.toLowerCase());
    
    // Check for allergies (any match means incompatible)
    for (final allergy in allergies) {
      if (allRecipeInfo.any((info) => info.contains(allergy.toLowerCase()))) {
        return false;
      }
    }
    
    // Check for disliked ingredients (any match means incompatible)
    for (final disliked in dislikedIngredients) {
      if (allRecipeInfo.any((info) => info.contains(disliked.toLowerCase()))) {
        return false;
      }
    }
    
    // Check dietary restrictions
    if (vegetarian && !allRecipeInfo.any((info) => info.contains('vegetarian'))) {
      return false;
    }
    
    if (vegan && !allRecipeInfo.any((info) => info.contains('vegan'))) {
      return false;
    }
    
    if (glutenFree && !allRecipeInfo.any((info) => info.contains('gluten-free'))) {
      return false;
    }
    
    if (dairyFree && !allRecipeInfo.any((info) => info.contains('dairy-free'))) {
      return false;
    }
    
    return true;
  }
}

/// User permission levels enumeration
enum UserPermissionLevel {
  viewer,
  contributor,
  organizer,
  manager,
  admin;

  String get displayName => switch (this) {
    UserPermissionLevel.viewer => 'Viewer',
    UserPermissionLevel.contributor => 'Contributor',
    UserPermissionLevel.organizer => 'Organizer', 
    UserPermissionLevel.manager => 'Manager',
    UserPermissionLevel.admin => 'Admin',
  };

  String get description => switch (this) {
    UserPermissionLevel.viewer => 'Can view recipes and meal plans',
    UserPermissionLevel.contributor => 'Can invite users and create content',
    UserPermissionLevel.organizer => 'Can organize meal plans and shopping lists',
    UserPermissionLevel.manager => 'Can manage recipes and user data',
    UserPermissionLevel.admin => 'Full administrative access',
  };

  /// Check if this permission level has at least the specified level
  bool hasLevel(UserPermissionLevel requiredLevel) {
    return index >= requiredLevel.index;
  }
}