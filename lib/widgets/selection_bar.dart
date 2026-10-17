import 'package:flutter/material.dart';

/// Панель над списком: счётчик выбранных и действия над ними.
class SelectionBar extends StatelessWidget {
  final int count;
  final VoidCallback onSoftDelete;
  final VoidCallback onHardDelete;
  final VoidCallback onClear;

  const SelectionBar({
    super.key,
    required this.count,
    required this.onSoftDelete,
    required this.onHardDelete,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Выбрано записей: $count',
              style: theme.textTheme.titleSmall,
            ),
            FilledButton.tonalIcon(
              onPressed: onSoftDelete,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Удалить выбранные'),
            ),
            OutlinedButton.icon(
              onPressed: onHardDelete,
              icon: const Icon(Icons.delete_forever),
              label: const Text('Стереть навсегда'),
            ),
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.clear),
              label: const Text('Снять выделение'),
            ),
          ],
        ),
      ),
    );
  }
}
