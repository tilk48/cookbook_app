import 'package:flutter/material.dart';
import '../../../providers/recipe_detail_provider.dart';

class ServingAdjustment extends StatelessWidget {
  final RecipeDetailProvider provider;

  const ServingAdjustment({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Decrease button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: provider.currentServings > 1
                ? provider.decreaseServings
                : null,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: provider.currentServings > 1
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                    : Theme.of(context).colorScheme.outline.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: provider.currentServings > 1
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                      : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.remove,
                size: 18,
                color: provider.currentServings > 1
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 8),

        // Serving count display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${provider.currentServings}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                TextSpan(
                  text: '/${provider.originalServings}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(width: 8),

        // Increase button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: provider.currentServings < 50
                ? provider.increaseServings
                : null,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: provider.currentServings < 50
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                    : Theme.of(context).colorScheme.outline.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: provider.currentServings < 50
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                      : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.add,
                size: 18,
                color: provider.currentServings < 50
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}