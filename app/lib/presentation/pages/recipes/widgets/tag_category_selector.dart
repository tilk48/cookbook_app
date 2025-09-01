import 'package:flutter/material.dart';
import 'package:mealie_api/mealie_api.dart';

class TagCategorySelector<T extends dynamic> extends StatelessWidget {
  final String title;
  final List<T> items;
  final List<T> selectedItems;
  final Function(T item, bool isSelected) onItemToggled;

  const TagCategorySelector({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItems,
    required this.onItemToggled,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final name = _getItemName(item);
            final id = _getItemId(item);
            final isSelected = selectedItems.any((selected) => _getItemId(selected) == id);
            
            return CheckboxListTile(
              title: Text(name),
              value: isSelected,
              onChanged: (value) {
                onItemToggled(item, value ?? false);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }

  String _getItemName(dynamic item) {
    if (item is RecipeTag) return item.name;
    if (item is RecipeCategory) return item.name;
    return item.toString();
  }

  String _getItemId(dynamic item) {
    if (item is RecipeTag) return item.id;
    if (item is RecipeCategory) return item.id;
    return item.toString();
  }
}