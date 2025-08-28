import 'package:flutter/material.dart';
import 'package:mealie_api/mealie_api.dart';
import '../../../providers/recipe_detail_provider.dart';

class RecipeHeader extends StatelessWidget {
  final RecipeDetailProvider provider;

  const RecipeHeader({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final recipe = provider.recipe!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories and Tags
          if (recipe.recipeCategory?.isNotEmpty == true ||
              recipe.tags?.isNotEmpty == true)
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                // Categories
                if (recipe.recipeCategory?.isNotEmpty == true)
                  ...recipe.recipeCategory!.map((category) => Chip(
                        label: Text(category.name),
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        labelStyle: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 0.8,
                          ),
                        ),
                      )),

                // Tags
                if (recipe.tags?.isNotEmpty == true)
                  ...recipe.tags!.map((tag) => Chip(
                        label: Text(tag.name),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        labelStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 0.8,
                          ),
                        ),
                      )),
              ],
            ),

          // Description (without headline)
          if (recipe.description?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            Text(
              recipe.description!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.8),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
