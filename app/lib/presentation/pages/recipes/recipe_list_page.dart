import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/navigation/app_router.dart';
import '../../providers/recipe_provider.dart';
import '../../widgets/recipes/recipe_card.dart';
import '../../widgets/recipes/recipe_search_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RecipeProvider>();
      // Initialize search controller with current provider state
      _searchController.text = provider.currentQuery;
      
      // Load recipes if they haven't been loaded, or refresh with current filters
      if (provider.recipes.isEmpty) {
        provider.refreshRecipes();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // Load more recipes when reaching the bottom
      context.read<RecipeProvider>().loadMoreRecipes();
    }
  }

  void _onSearchChanged(String query) {
    final provider = context.read<RecipeProvider>();
    provider.searchRecipes(
      query: query,
      categories: provider.currentCategories,
      tags: provider.currentTags,
      sortBy: provider.currentSortOption,
    );
  }

  Future<void> _onRefresh() async {
    await context.read<RecipeProvider>().refreshRecipes();
  }

  void _showFilterDialog() async {
    final recipeProvider = context.read<RecipeProvider>();
    
    // Load categories and tags if not already loaded
    await Future.wait([
      recipeProvider.loadCategories(),
      recipeProvider.loadTags(),
    ]);
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => RecipeFilterDialog(
        selectedCategories: recipeProvider.currentCategories,
        selectedTags: recipeProvider.currentTags,
        sortOption: recipeProvider.currentSortOption,
        availableCategories: recipeProvider.availableCategoryNames,
        availableTags: recipeProvider.availableTagNames,
        onFiltersChanged: (categories, tags, sortOption) {
          recipeProvider.searchRecipes(
            query: recipeProvider.currentQuery,
            categories: categories,
            tags: tags,
            sortBy: sortOption,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filters',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              context.push(AppRouter.profile);
            },
            tooltip: 'Profile',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          RecipeSearchBar(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onClear: () {
              _searchController.clear();
              _onSearchChanged('');
            },
          ),
          
          // Active Filters Chips
          Consumer<RecipeProvider>(
            builder: (context, provider, child) {
              final hasActiveFilters = provider.currentCategories.isNotEmpty || 
                                     provider.currentTags.isNotEmpty || 
                                     provider.currentSortOption != RecipeSortOption.dateUpdated;
              
              if (!hasActiveFilters) return const SizedBox.shrink();
              
              return Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Sort chip
                    if (provider.currentSortOption != RecipeSortOption.dateUpdated)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text('Sort: ${provider.currentSortOption.displayName}'),
                          selected: false,
                          onSelected: (_) {},
                          onDeleted: () {
                            provider.searchRecipes(
                              query: provider.currentQuery,
                              categories: provider.currentCategories,
                              tags: provider.currentTags,
                              sortBy: RecipeSortOption.dateUpdated,
                            );
                          },
                        ),
                      ),
                    
                    // Category chips
                    ...provider.currentCategories.map((category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: false,
                        onSelected: (_) {},
                        onDeleted: () {
                          final newCategories = List<String>.from(provider.currentCategories);
                          newCategories.remove(category);
                          provider.searchRecipes(
                            query: provider.currentQuery,
                            categories: newCategories,
                            tags: provider.currentTags,
                            sortBy: provider.currentSortOption,
                          );
                        },
                      ),
                    )),
                    
                    // Tag chips
                    ...provider.currentTags.map((tag) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(tag),
                        selected: false,
                        onSelected: (_) {},
                        onDeleted: () {
                          final newTags = List<String>.from(provider.currentTags);
                          newTags.remove(tag);
                          provider.searchRecipes(
                            query: provider.currentQuery,
                            categories: provider.currentCategories,
                            tags: newTags,
                            sortBy: provider.currentSortOption,
                          );
                        },
                      ),
                    )),
                  ],
                ),
              );
            },
          ),
          
          // Recipe List
          Expanded(
            child: Consumer<RecipeProvider>(
              builder: (context, recipeProvider, child) {
                if (recipeProvider.isLoading && recipeProvider.recipes.isEmpty) {
                  return const LoadingWidget(message: 'Loading recipes...');
                }
                
                if (recipeProvider.error != null && recipeProvider.recipes.isEmpty) {
                  return CustomErrorWidget(
                    message: recipeProvider.error!,
                    onRetry: () => recipeProvider.loadRecipes(),
                  );
                }
                
                if (recipeProvider.recipes.isEmpty) {
                  return _buildEmptyState(recipeProvider);
                }
                
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: _buildGridView(recipeProvider),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create recipe page
          context.go('/recipes/create');
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Recipe',
      ),
    );
  }

  Widget _buildGridView(RecipeProvider recipeProvider) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: recipeProvider.recipes.length + (recipeProvider.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= recipeProvider.recipes.length) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        return RecipeCard(
          recipe: recipeProvider.recipes[index],
          onTap: () {
            context.goToRecipeDetail(recipeProvider.recipes[index].slug);
          },
        );
      },
    );
  }


  Widget _buildEmptyState(RecipeProvider provider) {
    final hasActiveFilters = provider.currentQuery.isNotEmpty || 
                            provider.currentCategories.isNotEmpty || 
                            provider.currentTags.isNotEmpty ||
                            provider.currentSortOption != RecipeSortOption.dateUpdated;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              hasActiveFilters ? 'No recipes found' : 'No recipes yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasActiveFilters 
                  ? 'Try adjusting your search or filters'
                  : 'Add your first recipe to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (!hasActiveFilters)
              FilledButton.icon(
                onPressed: () {
                  context.go('/recipes/create');
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Recipe'),
              ),
          ],
        ),
      ),
    );
  }
}

// Enum for sorting
enum RecipeSortOption {
  name,
  dateAdded,
  dateUpdated,
  rating,
  cookTime;
  
  String get displayName => switch (this) {
    RecipeSortOption.name => 'Name',
    RecipeSortOption.dateAdded => 'Date Added',
    RecipeSortOption.dateUpdated => 'Recently Updated',
    RecipeSortOption.rating => 'Rating',
    RecipeSortOption.cookTime => 'Cook Time',
  };
}

// Improved Filter Dialog with Tabs
class RecipeFilterDialog extends StatefulWidget {
  final List<String> selectedCategories;
  final List<String> selectedTags;
  final RecipeSortOption sortOption;
  final List<String> availableCategories;
  final List<String> availableTags;
  final Function(List<String>, List<String>, RecipeSortOption) onFiltersChanged;

  const RecipeFilterDialog({
    super.key,
    required this.selectedCategories,
    required this.selectedTags,
    required this.sortOption,
    required this.availableCategories,
    required this.availableTags,
    required this.onFiltersChanged,
  });

  @override
  State<RecipeFilterDialog> createState() => _RecipeFilterDialogState();
}

class _RecipeFilterDialogState extends State<RecipeFilterDialog> with TickerProviderStateMixin {
  late List<String> _selectedCategories;
  late List<String> _selectedTags;
  late RecipeSortOption _sortOption;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _selectedCategories = List.from(widget.selectedCategories);
    _selectedTags = List.from(widget.selectedTags);
    _sortOption = widget.sortOption;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int get _totalSelectedCount => _selectedCategories.length + _selectedTags.length;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with title and selected count
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Filters & Sorting',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  if (_totalSelectedCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_totalSelectedCount selected',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Tab Bar
            Container(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                indicatorColor: Theme.of(context).colorScheme.primary,
                tabs: [
                  Tab(
                    text: 'Sort',
                    icon: Icon(Icons.sort, size: 20),
                  ),
                  Tab(
                    text: 'Categories (${widget.availableCategories.length})',
                    icon: Icon(Icons.category, size: 20),
                  ),
                  Tab(
                    text: 'Tags (${widget.availableTags.length})',
                    icon: Icon(Icons.local_offer, size: 20),
                  ),
                ],
              ),
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Sort Tab
                  _buildSortTab(),
                  
                  // Categories Tab
                  _buildCategoriesTab(),
                  
                  // Tags Tab
                  _buildTagsTab(),
                ],
              ),
            ),
            
            // Action Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: _totalSelectedCount > 0 ? _clearAll : null,
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Clear All'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _applyFilters,
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Apply'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose how to sort your recipes',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: RecipeSortOption.values.length,
              itemBuilder: (context, index) {
                final option = RecipeSortOption.values[index];
                return RadioListTile<RecipeSortOption>(
                  title: Text(option.displayName),
                  subtitle: Text(_getSortDescription(option)),
                  value: option,
                  groupValue: _sortOption,
                  onChanged: (value) {
                    setState(() {
                      _sortOption = value!;
                    });
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Select recipe categories',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (_selectedCategories.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedCategories.clear();
                    });
                  },
                  icon: const Icon(Icons.clear, size: 16),
                  label: Text('Clear (${_selectedCategories.length})'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: widget.availableCategories.isEmpty
                ? _buildEmptyState('No categories available', Icons.category)
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: widget.availableCategories.length,
                    itemBuilder: (context, index) {
                      final category = widget.availableCategories[index];
                      final isSelected = _selectedCategories.contains(category);
                      
                      return FilterChip(
                        label: Text(
                          category,
                          overflow: TextOverflow.ellipsis,
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedCategories.add(category);
                            } else {
                              _selectedCategories.remove(category);
                            }
                          });
                        },
                        showCheckmark: false,
                        selectedColor: Theme.of(context).colorScheme.primaryContainer,
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Select recipe tags',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (_selectedTags.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedTags.clear();
                    });
                  },
                  icon: const Icon(Icons.clear, size: 16),
                  label: Text('Clear (${_selectedTags.length})'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: widget.availableTags.isEmpty
                ? _buildEmptyState('No tags available', Icons.local_offer)
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.availableTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      
                      return FilterChip(
                        label: Text(tag),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTags.add(tag);
                            } else {
                              _selectedTags.remove(tag);
                            }
                          });
                        },
                        showCheckmark: false,
                        selectedColor: Theme.of(context).colorScheme.secondaryContainer,
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _getSortDescription(RecipeSortOption option) {
    return switch (option) {
      RecipeSortOption.name => 'Alphabetical order',
      RecipeSortOption.dateAdded => 'Newest recipes first',
      RecipeSortOption.dateUpdated => 'Recently updated first',
      RecipeSortOption.rating => 'Highest rated first',
      RecipeSortOption.cookTime => 'Quickest recipes first',
    };
  }

  void _clearAll() {
    setState(() {
      _selectedCategories.clear();
      _selectedTags.clear();
      _sortOption = RecipeSortOption.dateUpdated;
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged(_selectedCategories, _selectedTags, _sortOption);
    Navigator.of(context).pop();
  }
}
