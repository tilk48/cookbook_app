import 'package:flutter/material.dart';
import 'package:mealie_api/mealie_api.dart';
import 'package:provider/provider.dart';
import '../../../providers/recipe_create_provider.dart';

class IngredientItem extends StatefulWidget {
  final RecipeIngredient ingredient;
  final ValueChanged<RecipeIngredient> onChanged;
  final VoidCallback onRemoved;

  const IngredientItem({
    super.key,
    required this.ingredient,
    required this.onChanged,
    required this.onRemoved,
  });

  @override
  State<IngredientItem> createState() => _IngredientItemState();
}

class _IngredientItemState extends State<IngredientItem> {
  late TextEditingController _quantityController;
  IngredientUnit? _selectedUnit;
  IngredientFood? _selectedFood;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: widget.ingredient.quantity?.toString() ?? '');
    _selectedUnit = widget.ingredient.unit;
    _selectedFood = widget.ingredient.food;
    
    _quantityController.addListener(_updateIngredient);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _updateIngredient() {
    final quantity = double.tryParse(_quantityController.text);
    
    final updatedIngredient = RecipeIngredient(
      quantity: quantity,
      unit: _selectedUnit,
      food: _selectedFood,
      originalText: _buildOriginalText(),
    );
    
    widget.onChanged(updatedIngredient);
  }

  String _buildOriginalText() {
    final parts = <String>[];
    if (_quantityController.text.isNotEmpty) parts.add(_quantityController.text);
    if (_selectedUnit != null) parts.add(_selectedUnit!.abbreviation ?? _selectedUnit!.name);
    if (_selectedFood != null) parts.add(_selectedFood!.name);
    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with delete button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ingredient',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: widget.onRemoved,
                  icon: const Icon(Icons.delete_outline),
                  color: Theme.of(context).colorScheme.error,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Quantity row
            Row(
              children: [
                Icon(
                  Icons.scale_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      hintText: 'e.g. 2, 1.5, 1/2',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Unit row
            Row(
              children: [
                Icon(
                  Icons.straighten_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _UnitSelector(
                    selectedUnit: _selectedUnit,
                    onUnitSelected: (unit) {
                      setState(() {
                        _selectedUnit = unit;
                      });
                      _updateIngredient();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Food/Ingredient row
            Row(
              children: [
                Icon(
                  Icons.restaurant_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FoodSelector(
                    selectedFood: _selectedFood,
                    onFoodSelected: (food) {
                      setState(() {
                        _selectedFood = food;
                      });
                      _updateIngredient();
                    },
                  ),
                ),
              ],
            ),
            
            // Preview text if we have values
            if (_quantityController.text.isNotEmpty || _selectedUnit != null || _selectedFood != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Preview: ${_buildOriginalText()}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _UnitSelector extends StatelessWidget {
  final IngredientUnit? selectedUnit;
  final ValueChanged<IngredientUnit?> onUnitSelected;

  const _UnitSelector({
    required this.selectedUnit,
    required this.onUnitSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeCreateProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTap: () => _showUnitSelector(context, provider),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Unit',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selectedUnit?.name ?? 'Select unit',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: selectedUnit != null
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: selectedUnit != null ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                      if (selectedUnit?.abbreviation != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${selectedUnit!.abbreviation}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showUnitSelector(BuildContext context, RecipeCreateProvider provider) async {
    final result = await showDialog<IngredientUnit>(
      context: context,
      builder: (context) => _SearchableSelector<IngredientUnit>(
        title: 'Select Unit',
        selectedItem: selectedUnit,
        searchHint: 'Search units...',
        itemBuilder: (unit) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            title: Text(unit.name),
            subtitle: unit.abbreviation != null ? Text('Abbreviation: ${unit.abbreviation}') : null,
            trailing: selectedUnit?.id == unit.id ? const Icon(Icons.check, color: Colors.green) : null,
            onTap: () => Navigator.of(context).pop(unit),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            tileColor: selectedUnit?.id == unit.id 
                ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                : null,
          ),
        ),
        searchFunction: provider.searchUnits,
        displayText: (unit) => unit.name,
        onClear: () => Navigator.of(context).pop(null),
      ),
    );

    if (result != null) {
      onUnitSelected(result);
    } else if (result == null && selectedUnit != null) {
      // User explicitly cleared selection
      onUnitSelected(null);
    }
  }
}

class _FoodSelector extends StatelessWidget {
  final IngredientFood? selectedFood;
  final ValueChanged<IngredientFood?> onFoodSelected;

  const _FoodSelector({
    required this.selectedFood,
    required this.onFoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeCreateProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTap: () => _showFoodSelector(context, provider),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ingredient',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selectedFood?.name ?? 'Select ingredient',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: selectedFood != null
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: selectedFood != null ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                      if (selectedFood?.description != null && selectedFood!.description!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          selectedFood!.description!,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showFoodSelector(BuildContext context, RecipeCreateProvider provider) async {
    final result = await showDialog<IngredientFood>(
      context: context,
      builder: (context) => _SearchableSelector<IngredientFood>(
        title: 'Select Ingredient',
        selectedItem: selectedFood,
        searchHint: 'Search ingredients...',
        itemBuilder: (food) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            title: Text(food.name),
            subtitle: food.description != null && food.description!.isNotEmpty 
                ? Text(food.description!) 
                : null,
            trailing: selectedFood?.id == food.id ? const Icon(Icons.check, color: Colors.green) : null,
            onTap: () => Navigator.of(context).pop(food),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            tileColor: selectedFood?.id == food.id 
                ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                : null,
          ),
        ),
        searchFunction: provider.searchFoods,
        displayText: (food) => food.name,
        onClear: () => Navigator.of(context).pop(null),
      ),
    );

    if (result != null) {
      onFoodSelected(result);
    } else if (result == null && selectedFood != null) {
      // User explicitly cleared selection
      onFoodSelected(null);
    }
  }
}

class _SearchableSelector<T> extends StatefulWidget {
  final String title;
  final T? selectedItem;
  final String searchHint;
  final Widget Function(T) itemBuilder;
  final Future<List<T>> Function(String query, {int page}) searchFunction;
  final String Function(T) displayText;
  final VoidCallback onClear;

  const _SearchableSelector({
    required this.title,
    required this.selectedItem,
    required this.searchHint,
    required this.itemBuilder,
    required this.searchFunction,
    required this.displayText,
    required this.onClear,
  });

  @override
  State<_SearchableSelector<T>> createState() => _SearchableSelectorState<T>();
}

class _SearchableSelectorState<T> extends State<_SearchableSelector<T>> {
  final _searchController = TextEditingController();
  List<T> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _performSearch('');
    _searchController.addListener(() {
      _performSearch(_searchController.text, reset: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query, {bool reset = true}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
        _hasMore = true;
      });
    }
    
    try {
      final pageToLoad = reset ? 1 : _currentPage + 1;
      final results = await widget.searchFunction(query, page: pageToLoad);
      if (mounted) {
        setState(() {
          if (reset) {
            _items = results;
            _currentPage = 1;
          } else {
            _items.addAll(results);
            _currentPage = pageToLoad;
          }
          _isLoading = false;
          // If we got fewer results than requested, we've reached the end
          _hasMore = results.length >= 50;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        height: 600,
        child: Column(
          children: [
            // Search field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: widget.searchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            
            // Results list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _items.isEmpty
                      ? Center(
                          child: Text(
                            'No ${widget.title.toLowerCase()} found',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      : ListView.builder(
                          itemCount: _items.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < _items.length) {
                              return widget.itemBuilder(_items[index]);
                            } else {
                              // Load More button
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                  child: _isLoading
                                      ? const CircularProgressIndicator()
                                      : OutlinedButton.icon(
                                          onPressed: () => _performSearch(_searchController.text, reset: false),
                                          icon: const Icon(Icons.expand_more),
                                          label: const Text('Load More'),
                                        ),
                                ),
                              );
                            }
                          },
                        ),
            ),
          ],
        ),
      ),
      actions: [
        if (widget.selectedItem != null)
          TextButton(
            onPressed: widget.onClear,
            child: const Text('Clear Selection'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}