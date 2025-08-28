import 'package:flutter/material.dart';

class RecipeSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget content;
  final Widget? headerWidget;

  const RecipeSection({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
    this.headerWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 20),
          child: Row(
            children: [
              Container(
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
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (headerWidget != null) headerWidget!,
            ],
          ),
        ),
        content,
      ],
    );
  }
}