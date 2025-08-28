import 'package:flutter/material.dart';
import '../../../providers/recipe_detail_provider.dart';

class RecipeStats extends StatelessWidget {
  final RecipeDetailProvider provider;

  const RecipeStats({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final statTiles = <Widget>[];

      if (provider.totalTime?.isNotEmpty == true) {
        statTiles.add(_buildStatTile(
          context,
          Icons.access_time,
          'Total Time',
          provider.totalTime!,
        ));
      }

      if (provider.prepTime?.isNotEmpty == true) {
        statTiles.add(_buildStatTile(
          context,
          Icons.schedule,
          'Prep Time',
          provider.prepTime!,
        ));
      }

      if (provider.cookTime?.isNotEmpty == true) {
        statTiles.add(_buildStatTile(
          context,
          Icons.local_fire_department,
          'Cook Time',
          provider.cookTime!,
        ));
      }

      if (provider.recipeYield?.isNotEmpty == true) {
        statTiles.add(_buildStatTile(
          context,
          Icons.people,
          'Servings',
          provider.recipeYield!,
        ));
      }

      if (statTiles.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: statTiles.asMap().entries.map((entry) {
            final index = entry.key;
            final tile = entry.value;
            return Column(
              children: [
                tile,
                if (index < statTiles.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.1),
                  ),
              ],
            );
          }).toList(),
        ),
      );
    } catch (e) {
      print('DEBUG: Error building recipe stats: $e');
      return const SizedBox.shrink();
    }
  }

  Widget _buildStatTile(
      BuildContext context, IconData icon, String label, String value) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
