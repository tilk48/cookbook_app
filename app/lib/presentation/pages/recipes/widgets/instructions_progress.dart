import 'package:flutter/material.dart';
import '../../../providers/recipe_detail_provider.dart';

class InstructionsProgress extends StatelessWidget {
  final RecipeDetailProvider provider;

  const InstructionsProgress({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.instructions.isEmpty) return const SizedBox.shrink();
    
    final completedCount = provider.completedStepsCount;
    final totalCount = provider.instructions.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: progress == 1.0 
            ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
            : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: progress == 1.0 
            ? Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress indicator
          Container(
            width: 80,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: progress == 1.0 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Progress text
          Text(
            '$completedCount/$totalCount',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: progress == 1.0 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          // Reset button (only show if there are completed steps)
          if (completedCount > 0) ...[
            const SizedBox(width: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: provider.resetStepCompletions,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.refresh,
                    size: 18,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}