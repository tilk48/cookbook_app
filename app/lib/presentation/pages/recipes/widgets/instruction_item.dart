import 'package:flutter/material.dart';
import 'package:mealie_api/mealie_api.dart';

class InstructionItem extends StatefulWidget {
  final int index;
  final RecipeInstruction instruction;
  final ValueChanged<RecipeInstruction> onChanged;
  final VoidCallback onRemoved;

  const InstructionItem({
    super.key,
    required this.index,
    required this.instruction,
    required this.onChanged,
    required this.onRemoved,
  });

  @override
  State<InstructionItem> createState() => _InstructionItemState();
}

class _InstructionItemState extends State<InstructionItem> {
  late TextEditingController _titleController;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.instruction.title ?? '');
    _textController = TextEditingController(text: widget.instruction.text ?? '');

    _titleController.addListener(_updateInstruction);
    _textController.addListener(_updateInstruction);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _updateInstruction() {
    final updatedInstruction = RecipeInstruction(
      id: widget.instruction.id,
      title: _titleController.text.isEmpty ? null : _titleController.text,
      text: _textController.text.isEmpty ? null : _textController.text,
    );
    
    widget.onChanged(updatedInstruction);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    '${widget.index + 1}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Step Title (Optional)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: widget.onRemoved,
                  icon: const Icon(Icons.delete_outline),
                  color: Theme.of(context).colorScheme.error,
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Instructions',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}