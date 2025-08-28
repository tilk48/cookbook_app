import 'package:flutter/material.dart';
import '../../../providers/recipe_detail_provider.dart';

class IngredientsList extends StatelessWidget {
  final RecipeDetailProvider provider;

  const IngredientsList({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: provider.ingredients.asMap().entries.map((entry) {
          final index = entry.key;
          final ingredient = entry.value;
          final hasQuantity = provider.ingredientHasQuantity(ingredient);
          final formattedText =
              provider.getFormattedIngredient(ingredient, scaled: true);

          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(
                bottom: index < provider.ingredients.length - 1 ? 12.0 : 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Quantity indicator
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: hasQuantity
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),

                // Ingredient text
                Expanded(
                  child: Text(
                    formattedText,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: hasQuantity &&
                                  provider.currentServings !=
                                      provider.originalServings
                              ? FontWeight.w600
                              : FontWeight.w500,
                          height: 1.3,
                        ),
                  ),
                ),

                // Scaling indicator (only show if servings changed)
                if (hasQuantity &&
                    provider.currentServings != provider.originalServings)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${provider.currentServings} / ${provider.originalServings}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
