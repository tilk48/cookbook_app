import 'package:flutter/material.dart';
import '../../../providers/recipe_detail_provider.dart';

class InstructionsList extends StatelessWidget {
  final RecipeDetailProvider provider;

  const InstructionsList({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: provider.instructions.asMap().entries.map((entry) {
          final index = entry.key;
          final instruction = entry.value;
          final isCompleted = provider.isStepCompleted(index);
          
          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: index < provider.instructions.length - 1 ? 16.0 : 0),
            decoration: BoxDecoration(
              color: isCompleted 
                  ? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Number / Completion Button
                GestureDetector(
                  onTap: () => provider.toggleStepCompletion(index),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: isCompleted 
                          ? null
                          : Border.all(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              width: 1.5,
                            ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 22,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Instruction Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: AnimatedOpacity(
                      opacity: isCompleted ? 0.6 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (instruction.title?.isNotEmpty == true)
                            Text(
                              instruction.title!,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                decorationColor: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          if (instruction.title?.isNotEmpty == true)
                            const SizedBox(height: 6),
                          Text(
                            instruction.text ?? 'No instruction provided',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              decorationColor: Theme.of(context).colorScheme.outline,
                              height: 1.4,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
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