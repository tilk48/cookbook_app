import 'package:flutter/material.dart';
import '../../../providers/recipe_detail_provider.dart';

class RecipeActionsMenu extends StatelessWidget {
  final RecipeDetailProvider provider;

  const RecipeActionsMenu({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: Colors.white),
        color: Theme.of(context).colorScheme.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'share',
            child: Row(
              children: [
                Icon(Icons.share, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                const Text('Share Recipe'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                const Text('Edit Recipe'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'add_to_meal_plan',
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                const Text('Add to Meal Plan'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'add_to_shopping',
            child: Row(
              children: [
                Icon(Icons.shopping_cart,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                const Text('Add to Shopping List'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'duplicate',
            child: Row(
              children: [
                Icon(Icons.copy, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                const Text('Duplicate Recipe'),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 12),
                Text('Delete Recipe',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ),
          ),
        ],
        onSelected: (value) => _handleMenuAction(context, value),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'share':
        _shareRecipe(context);
        break;
      case 'edit':
        _editRecipe(context);
        break;
      case 'add_to_meal_plan':
        _addToMealPlan(context);
        break;
      case 'add_to_shopping':
        _addToShoppingList(context);
        break;
      case 'duplicate':
        _duplicateRecipe(context);
        break;
      case 'delete':
        _deleteRecipe(context);
        break;
    }
  }

  void _shareRecipe(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share feature coming soon!')),
    );
  }

  void _editRecipe(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit feature coming soon!')),
    );
  }

  void _addToMealPlan(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meal plan feature coming soon!')),
    );
  }

  void _addToShoppingList(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Shopping list feature coming soon!')),
    );
  }

  void _duplicateRecipe(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Duplicate feature coming soon!')),
    );
  }

  void _deleteRecipe(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: Text(
            'Are you sure you want to delete "${provider.recipe?.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Delete feature coming soon!')),
        );
      }
    });
  }
}
