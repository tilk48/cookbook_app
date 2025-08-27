import 'package:equatable/equatable.dart';

/// Domain entity representing a shopping list in the app
/// This is the core business object, independent of external APIs or database schemas
class ShoppingListEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String userId;
  final String householdId;
  final List<ShoppingListItemEntity> items;
  final ShoppingListSettingsEntity settings;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? cachedAt;

  const ShoppingListEntity({
    required this.id,
    required this.name,
    this.description,
    required this.userId,
    required this.householdId,
    this.items = const [],
    this.settings = const ShoppingListSettingsEntity(),
    this.createdAt,
    this.updatedAt,
    this.cachedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        userId,
        householdId,
        items,
        settings,
        createdAt,
        updatedAt,
        cachedAt,
      ];

  /// Create a copy with modified fields
  ShoppingListEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? userId,
    String? householdId,
    List<ShoppingListItemEntity>? items,
    ShoppingListSettingsEntity? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? cachedAt,
  }) {
    return ShoppingListEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      householdId: householdId ?? this.householdId,
      items: items ?? this.items,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  /// Get items grouped by category
  Map<String, List<ShoppingListItemEntity>> get itemsByCategory {
    final grouped = <String, List<ShoppingListItemEntity>>{};
    
    for (final item in items) {
      final category = item.category ?? 'Uncategorized';
      grouped.putIfAbsent(category, () => []).add(item);
    }
    
    // Sort items within each category by position and name
    for (final categoryItems in grouped.values) {
      categoryItems.sort((a, b) {
        final positionCompare = a.position.compareTo(b.position);
        if (positionCompare != 0) return positionCompare;
        return a.display.compareTo(b.display);
      });
    }
    
    return grouped;
  }

  /// Get only unchecked (pending) items
  List<ShoppingListItemEntity> get pendingItems {
    return items.where((item) => !item.checked).toList()
      ..sort((a, b) => a.position.compareTo(b.position));
  }

  /// Get only checked (completed) items
  List<ShoppingListItemEntity> get completedItems {
    return items.where((item) => item.checked).toList()
      ..sort((a, b) => a.position.compareTo(b.position));
  }

  /// Get total number of items
  int get totalItems => items.length;

  /// Get number of completed items
  int get completedCount => items.where((item) => item.checked).length;

  /// Get number of pending items
  int get pendingCount => items.where((item) => !item.checked).length;

  /// Get completion percentage
  double get completionPercentage {
    if (totalItems == 0) return 0.0;
    return completedCount / totalItems;
  }

  /// Check if all items are completed
  bool get isCompleted => totalItems > 0 && completedCount == totalItems;

  /// Check if list is empty
  bool get isEmpty => totalItems == 0;

  /// Add an item to the shopping list
  ShoppingListEntity addItem(ShoppingListItemEntity item) {
    // Set position to be last
    final newItem = item.copyWith(position: items.length);
    return copyWith(items: [...items, newItem]);
  }

  /// Remove an item from the shopping list
  ShoppingListEntity removeItem(String itemId) {
    final updatedItems = items.where((item) => item.id != itemId).toList();
    // Reorder positions after removal
    for (int i = 0; i < updatedItems.length; i++) {
      updatedItems[i] = updatedItems[i].copyWith(position: i);
    }
    return copyWith(items: updatedItems);
  }

  /// Update an existing item
  ShoppingListEntity updateItem(ShoppingListItemEntity updatedItem) {
    return copyWith(
      items: items.map((item) => item.id == updatedItem.id ? updatedItem : item).toList(),
    );
  }

  /// Toggle item checked status
  ShoppingListEntity toggleItemChecked(String itemId) {
    return copyWith(
      items: items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(checked: !item.checked);
        }
        return item;
      }).toList(),
    );
  }

  /// Mark all items as checked
  ShoppingListEntity checkAllItems() {
    return copyWith(
      items: items.map((item) => item.copyWith(checked: true)).toList(),
    );
  }

  /// Mark all items as unchecked
  ShoppingListEntity uncheckAllItems() {
    return copyWith(
      items: items.map((item) => item.copyWith(checked: false)).toList(),
    );
  }

  /// Clear all completed items
  ShoppingListEntity clearCompletedItems() {
    return copyWith(
      items: items.where((item) => !item.checked).toList(),
    );
  }

  /// Reorder items by moving an item to a new position
  ShoppingListEntity reorderItem(String itemId, int newPosition) {
    final itemsCopy = List<ShoppingListItemEntity>.from(items);
    final itemIndex = itemsCopy.indexWhere((item) => item.id == itemId);
    
    if (itemIndex == -1 || newPosition < 0 || newPosition >= itemsCopy.length) {
      return this;
    }
    
    final item = itemsCopy.removeAt(itemIndex);
    itemsCopy.insert(newPosition, item);
    
    // Update positions
    for (int i = 0; i < itemsCopy.length; i++) {
      itemsCopy[i] = itemsCopy[i].copyWith(position: i);
    }
    
    return copyWith(items: itemsCopy);
  }

  /// Get estimated total cost (if prices are available)
  double? get estimatedTotal {
    double? total;
    
    for (final item in items) {
      if (item.price != null) {
        total = (total ?? 0.0) + (item.price! * (item.quantity ?? 1));
      }
    }
    
    return total;
  }

  /// Get all categories used in this list
  List<String> get usedCategories {
    return items
        .map((item) => item.category ?? 'Uncategorized')
        .toSet()
        .toList()
      ..sort();
  }

  /// Merge another shopping list into this one
  ShoppingListEntity mergeWith(ShoppingListEntity other) {
    final mergedItems = <String, ShoppingListItemEntity>{};
    
    // Add current items
    for (final item in items) {
      mergedItems[item.display.toLowerCase()] = item;
    }
    
    // Add items from other list, combining quantities if same item
    for (final otherItem in other.items) {
      final key = otherItem.display.toLowerCase();
      if (mergedItems.containsKey(key)) {
        final existing = mergedItems[key]!;
        final combinedQuantity = (existing.quantity ?? 1) + (otherItem.quantity ?? 1);
        mergedItems[key] = existing.copyWith(quantity: combinedQuantity);
      } else {
        mergedItems[key] = otherItem.copyWith(position: mergedItems.length);
      }
    }
    
    return copyWith(items: mergedItems.values.toList());
  }
}

/// Individual shopping list item
class ShoppingListItemEntity extends Equatable {
  final String id;
  final String display;
  final double? quantity;
  final String? unit;
  final String? food;
  final String? recipe;
  final String? recipeId;
  final String? note;
  final String? category;
  final bool checked;
  final double? price;
  final int position;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ShoppingListItemEntity({
    required this.id,
    required this.display,
    this.quantity,
    this.unit,
    this.food,
    this.recipe,
    this.recipeId,
    this.note,
    this.category,
    this.checked = false,
    this.price,
    this.position = 0,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        display,
        quantity,
        unit,
        food,
        recipe,
        recipeId,
        note,
        category,
        checked,
        price,
        position,
        createdAt,
        updatedAt,
      ];

  /// Create a copy with modified fields
  ShoppingListItemEntity copyWith({
    String? id,
    String? display,
    double? quantity,
    String? unit,
    String? food,
    String? recipe,
    String? recipeId,
    String? note,
    String? category,
    bool? checked,
    double? price,
    int? position,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShoppingListItemEntity(
      id: id ?? this.id,
      display: display ?? this.display,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      food: food ?? this.food,
      recipe: recipe ?? this.recipe,
      recipeId: recipeId ?? this.recipeId,
      note: note ?? this.note,
      category: category ?? this.category,
      checked: checked ?? this.checked,
      price: price ?? this.price,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get formatted quantity text
  String get quantityText {
    if (quantity == null) return '';
    
    // Format quantity nicely (avoid .0 for whole numbers)
    final formattedQuantity = quantity! == quantity!.roundToDouble() 
        ? quantity!.round().toString()
        : quantity!.toString();
    
    if (unit?.isNotEmpty == true) {
      return '$formattedQuantity $unit';
    }
    
    return formattedQuantity;
  }

  /// Get full display text with quantity
  String get fullDisplayText {
    final quantityStr = quantityText;
    if (quantityStr.isEmpty) return display;
    return '$quantityStr $display';
  }

  /// Check if this item is from a recipe
  bool get isFromRecipe => recipeId != null && recipe != null;

  /// Get estimated cost for this item
  double? get estimatedCost {
    if (price == null) return null;
    return price! * (quantity ?? 1);
  }

  /// Get formatted price text
  String? get priceText {
    if (price == null) return null;
    return '\$${price!.toStringAsFixed(2)}';
  }

  /// Get formatted total cost text
  String? get totalCostText {
    final cost = estimatedCost;
    if (cost == null) return null;
    return '\$${cost.toStringAsFixed(2)}';
  }

  /// Check if item has any additional details
  bool get hasDetails => note?.isNotEmpty == true || isFromRecipe || price != null;

  /// Get priority for sorting (checked items go to bottom)
  int get sortPriority => checked ? 1 : 0;
}

/// Shopping list settings entity
class ShoppingListSettingsEntity extends Equatable {
  final bool groupByCategory;
  final bool showPrices;
  final bool showRecipeSource;
  final bool hideCompletedItems;
  final ShoppingListSortOrder sortOrder;
  final List<String> customCategories;

  const ShoppingListSettingsEntity({
    this.groupByCategory = true,
    this.showPrices = false,
    this.showRecipeSource = true,
    this.hideCompletedItems = false,
    this.sortOrder = ShoppingListSortOrder.manual,
    this.customCategories = const [],
  });

  @override
  List<Object?> get props => [
        groupByCategory,
        showPrices,
        showRecipeSource,
        hideCompletedItems,
        sortOrder,
        customCategories,
      ];

  /// Create a copy with modified fields
  ShoppingListSettingsEntity copyWith({
    bool? groupByCategory,
    bool? showPrices,
    bool? showRecipeSource,
    bool? hideCompletedItems,
    ShoppingListSortOrder? sortOrder,
    List<String>? customCategories,
  }) {
    return ShoppingListSettingsEntity(
      groupByCategory: groupByCategory ?? this.groupByCategory,
      showPrices: showPrices ?? this.showPrices,
      showRecipeSource: showRecipeSource ?? this.showRecipeSource,
      hideCompletedItems: hideCompletedItems ?? this.hideCompletedItems,
      sortOrder: sortOrder ?? this.sortOrder,
      customCategories: customCategories ?? this.customCategories,
    );
  }

  /// Get all available categories (default + custom)
  List<String> get allCategories {
    final defaultCategories = [
      'Produce',
      'Dairy & Eggs', 
      'Meat & Seafood',
      'Pantry',
      'Frozen',
      'Bakery',
      'Beverages',
      'Snacks',
      'Health & Beauty',
      'Household',
      'Other',
    ];
    
    return [...defaultCategories, ...customCategories]..sort();
  }
}

/// Shopping list sort order enumeration
enum ShoppingListSortOrder {
  manual,
  alphabetical,
  category,
  price,
  dateAdded;

  String get displayName => switch (this) {
    ShoppingListSortOrder.manual => 'Manual',
    ShoppingListSortOrder.alphabetical => 'Alphabetical',
    ShoppingListSortOrder.category => 'By Category',
    ShoppingListSortOrder.price => 'By Price',
    ShoppingListSortOrder.dateAdded => 'Date Added',
  };

  String get description => switch (this) {
    ShoppingListSortOrder.manual => 'Drag to reorder items',
    ShoppingListSortOrder.alphabetical => 'Sort items A-Z',
    ShoppingListSortOrder.category => 'Group by food category',
    ShoppingListSortOrder.price => 'Sort by item price',
    ShoppingListSortOrder.dateAdded => 'Sort by when added',
  };
}

/// Shopping list status enumeration
enum ShoppingListStatus {
  active,
  completed,
  archived;

  String get displayName => switch (this) {
    ShoppingListStatus.active => 'Active',
    ShoppingListStatus.completed => 'Completed',
    ShoppingListStatus.archived => 'Archived',
  };

  String get description => switch (this) {
    ShoppingListStatus.active => 'Currently using this list',
    ShoppingListStatus.completed => 'Finished shopping',
    ShoppingListStatus.archived => 'Saved for reference',
  };
}