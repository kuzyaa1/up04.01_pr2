import 'package:flutter/material.dart';

/// Список карточек для узкого окна.
///
/// Таблица на ширине меньше 600 пикселей бесполезна, поэтому тот же набор
/// данных показывается карточками.
class EntityCards<T> extends StatelessWidget {
  final List<T> items;
  final int Function(T item) idOf;
  final Set<int> selected;
  final ValueChanged<int>? onToggleSelect;
  final String Function(T item) titleOf;
  final List<String> Function(T item) linesOf;
  final List<Widget> Function(T item)? actions;

  const EntityCards({
    super.key,
    required this.items,
    required this.idOf,
    required this.titleOf,
    required this.linesOf,
    this.selected = const <int>{},
    this.onToggleSelect,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectable = onToggleSelect != null;

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final id = idOf(item);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (selectable)
                      Checkbox(
                        value: selected.contains(id),
                        onChanged: (_) => onToggleSelect!(id),
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          titleOf(item),
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                for (final line in linesOf(item))
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(line, style: theme.textTheme.bodyMedium),
                  ),
                if (actions != null) ...[
                  const Divider(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 4,
                      children: actions!(item),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
