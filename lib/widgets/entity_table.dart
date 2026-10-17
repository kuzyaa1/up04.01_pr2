import 'package:flutter/material.dart';

/// Описание одной колонки таблицы.
///
/// Один и тот же виджет [EntityTable] настраивается списком таких описаний,
/// поэтому для книг и авторов не нужно писать два почти одинаковых экрана.
class TableColumnSpec<T> {
  final String label;

  /// Имя поля, по которому сортируется колонка. `null` — колонка не сортируется.
  final String? sortField;
  final bool numeric;
  final Widget Function(T item) build;

  const TableColumnSpec({
    required this.label,
    required this.build,
    this.sortField,
    this.numeric = false,
  });
}

class EntityTable<T> extends StatelessWidget {
  final List<TableColumnSpec<T>> columns;
  final List<T> items;
  final int Function(T item) idOf;
  final Set<int> selected;
  final ValueChanged<int>? onToggleSelect;
  final VoidCallback? onSelectAll;
  final String? sortField;
  final bool sortAscending;
  final void Function(String field)? onSort;
  final List<Widget> Function(T item)? actions;

  const EntityTable({
    super.key,
    required this.columns,
    required this.items,
    required this.idOf,
    this.selected = const <int>{},
    this.onToggleSelect,
    this.onSelectAll,
    this.sortField,
    this.sortAscending = true,
    this.onSort,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final selectable = onToggleSelect != null;
    final allSelected =
        items.isNotEmpty && items.every((item) => selected.contains(idOf(item)));

    int? sortIndex;
    for (var i = 0; i < columns.length; i++) {
      if (columns[i].sortField != null && columns[i].sortField == sortField) {
        sortIndex = i + (selectable ? 1 : 0);
        break;
      }
    }

    final dataTable = DataTable(
      sortColumnIndex: sortIndex,
      sortAscending: sortAscending,
      showCheckboxColumn: false,
      columns: [
        if (selectable)
          DataColumn(
            label: Checkbox(
              value: allSelected,
              onChanged: (_) => onSelectAll?.call(),
            ),
          ),
        for (final column in columns)
          DataColumn(
            label: Text(column.label),
            numeric: column.numeric,
            onSort: (column.sortField != null && onSort != null)
                ? (_, __) => onSort!(column.sortField!)
                : null,
          ),
        if (actions != null) const DataColumn(label: Text('Действия')),
      ],
      rows: [
        for (final item in items)
          DataRow(
            selected: selected.contains(idOf(item)),
            cells: [
              if (selectable)
                DataCell(
                  Checkbox(
                    value: selected.contains(idOf(item)),
                    onChanged: (_) => onToggleSelect!(idOf(item)),
                  ),
                ),
              for (final column in columns) DataCell(column.build(item)),
              if (actions != null)
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions!(item),
                  ),
                ),
            ],
          ),
      ],
    );

    // DataTable не прокручивается сам. Оборачиваем в двумерную прокрутку,
    // а ConstrainedBox с minWidth не даёт таблице жаться к левому краю.
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: dataTable,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Постраничная навигация под списком.
class PaginationBar extends StatelessWidget {
  final int page;
  final int totalPages;
  final int total;
  final int size;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onSizeChanged;

  const PaginationBar({
    super.key,
    required this.page,
    required this.totalPages,
    required this.total,
    required this.size,
    required this.onPageChanged,
    required this.onSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Всего записей: $total'),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('На странице: '),
              DropdownButton<int>(
                value: size,
                items: [
                  for (final value in const [10, 25, 50])
                    DropdownMenuItem<int>(value: value, child: Text('$value')),
                ],
                onChanged: (value) {
                  if (value != null) onSizeChanged(value);
                },
              ),
            ],
          ),
          IconButton(
            tooltip: 'Первая страница',
            icon: const Icon(Icons.first_page),
            onPressed: page > 1 ? () => onPageChanged(1) : null,
          ),
          IconButton(
            tooltip: 'Предыдущая страница',
            icon: const Icon(Icons.chevron_left),
            onPressed: page > 1 ? () => onPageChanged(page - 1) : null,
          ),
          Text('Страница $page из $totalPages'),
          IconButton(
            tooltip: 'Следующая страница',
            icon: const Icon(Icons.chevron_right),
            onPressed: page < totalPages ? () => onPageChanged(page + 1) : null,
          ),
          IconButton(
            tooltip: 'Последняя страница',
            icon: const Icon(Icons.last_page),
            onPressed: page < totalPages ? () => onPageChanged(totalPages) : null,
          ),
        ],
      ),
    );
  }
}
