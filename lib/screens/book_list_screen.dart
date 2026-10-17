import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/breakpoints.dart';
import '../data/seed_data.dart';
import '../models/book.dart';
import '../models/book_query.dart';
import '../state/book_list_notifier.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/book_filter_bar.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/entity_cards.dart';
import '../widgets/entity_table.dart';
import '../widgets/list_state_views.dart';
import '../widgets/selection_bar.dart';

/// Экран каталога книг.
///
/// Условия отбора живут в адресе страницы: экран читает их из [query],
/// а любое изменение отправляет обратно в адрес. Благодаря этому ссылку
/// на отфильтрованный список можно передать коллеге, а кнопка «назад»
/// браузера возвращает предыдущий набор условий.
class BookListScreen extends StatefulWidget {
  final BookQuery query;

  const BookListScreen({super.key, required this.query});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void didUpdateWidget(covariant BookListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
    }
  }

  void _sync() {
    if (!mounted) return;
    context.read<BookListNotifier>().applyQuery(widget.query);
  }

  /// Кладёт новые условия отбора в адрес — состояние списка следует за ним.
  void _updateQuery(BookQuery next) {
    final params = next.toQueryParameters();
    final location = params.isEmpty
        ? '/books'
        : Uri(path: '/books', queryParameters: params).toString();
    context.go(location);
  }

  Future<void> _softDelete(BookListNotifier notifier, Book book) async {
    final ok = await confirmAction(
      context,
      title: 'Логическое удаление',
      message: 'Убрать книгу «${book.title}» из каталога? '
          'Запись сохранится и её можно будет восстановить.',
    );
    if (!ok) return;
    await notifier.softDelete(book.id);
  }

  Future<void> _hardDelete(BookListNotifier notifier, Book book) async {
    final ok = await confirmAction(
      context,
      title: 'Физическое удаление',
      message: 'Стереть книгу «${book.title}» навсегда? '
          'Восстановить её будет невозможно.',
      confirmLabel: 'Стереть',
      destructive: true,
    );
    if (!ok) return;
    await notifier.hardDelete(book.id);
  }

  Future<void> _deleteSelected(
    BookListNotifier notifier, {
    required bool hard,
  }) async {
    final count = notifier.selected.length;
    final ok = await confirmAction(
      context,
      title: hard ? 'Физическое удаление' : 'Логическое удаление',
      message: hard
          ? 'Стереть выбранные записи ($count шт.) навсегда?'
          : 'Убрать выбранные записи ($count шт.) из каталога? '
              'Их можно будет восстановить.',
      confirmLabel: hard ? 'Стереть' : 'Удалить',
      destructive: hard,
    );
    if (!ok) return;
    if (hard) {
      await notifier.hardDeleteSelected();
    } else {
      await notifier.softDeleteSelected();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<BookListNotifier>();

    return AppScaffold(
      title: 'Каталог книг',
      selectedIndex: 0,
      actions: [
        IconButton(
          tooltip: 'Обновить',
          icon: const Icon(Icons.refresh),
          onPressed: notifier.load,
        ),
      ],
      child: Column(
        children: [
          BookFilterBar(query: widget.query, onChanged: _updateQuery),
          if (notifier.hasSelection)
            SelectionBar(
              count: notifier.selected.length,
              onSoftDelete: () => _deleteSelected(notifier, hard: false),
              onHardDelete: () => _deleteSelected(notifier, hard: true),
              onClear: notifier.clearSelection,
            ),
          Expanded(child: _buildState(notifier)),
          if (notifier.status == LoadStatus.success && notifier.result.total > 0)
            PaginationBar(
              page: notifier.result.page,
              totalPages: notifier.result.totalPages,
              total: notifier.result.total,
              size: notifier.result.size,
              onPageChanged: (page) =>
                  _updateQuery(notifier.query.copyWith(page: page)),
              onSizeChanged: (size) =>
                  _updateQuery(notifier.query.copyWith(size: size)),
            ),
        ],
      ),
    );
  }

  Widget _buildState(BookListNotifier notifier) {
    return switch (notifier.status) {
      // Пустое состояние — это не загрузка: индикатор показывается только
      // для idle и loading.
      LoadStatus.idle || LoadStatus.loading => const LoadingView(),
      LoadStatus.error => ErrorView(
          message: notifier.error,
          onRetry: notifier.load,
        ),
      LoadStatus.success when notifier.result.items.isEmpty =>
        _buildEmpty(notifier),
      LoadStatus.success => _buildList(notifier),
    };
  }

  Widget _buildEmpty(BookListNotifier notifier) {
    if (notifier.query.page > 1 && notifier.result.total > 0) {
      return EmptyView(
        message: 'На этой странице записей нет.',
        actions: [
          FilledButton(
            onPressed: () => _updateQuery(
              notifier.query.copyWith(page: notifier.result.totalPages),
            ),
            child: const Text('На последнюю страницу'),
          ),
        ],
      );
    }
    return EmptyView(
      message: 'По заданным условиям книг не найдено.',
      actions: [
        if (notifier.query.hasActiveFilters)
          FilledButton.icon(
            onPressed: () =>
                _updateQuery(BookQuery(size: notifier.query.size)),
            icon: const Icon(Icons.filter_alt_off),
            label: const Text('Сбросить фильтры'),
          ),
      ],
    );
  }

  Widget _buildList(BookListNotifier notifier) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Узкое окно — карточки, широкое — таблица.
        if (constraints.maxWidth < kCompactWidth) {
          return EntityCards<Book>(
            items: notifier.result.items,
            idOf: (book) => book.id,
            selected: notifier.selected,
            onToggleSelect: notifier.toggleSelection,
            titleOf: (book) => book.title,
            linesOf: (book) => [
              'ISBN: ${book.isbn}',
              'Год: ${book.year} • страниц: ${book.pages}',
              'Издательство: ${publisherName(book.publisherId)}',
              'Жанры: ${book.genreIds.map(genreName).join(', ')}',
              'Доступно: ${book.copiesAvailable} из ${book.copiesTotal}',
              if (book.isDeleted) 'Статус: удалена',
            ],
            actions: (book) => _rowActions(notifier, book),
          );
        }

        return EntityTable<Book>(
          items: notifier.result.items,
          idOf: (book) => book.id,
          selected: notifier.selected,
          onToggleSelect: notifier.toggleSelection,
          onSelectAll: () =>
              notifier.selectAll(notifier.result.items.map((b) => b.id)),
          sortField: notifier.query.sortField,
          sortAscending: notifier.query.sortAscending,
          onSort: (field) => _updateQuery(
            notifier.query.copyWith(
              sortField: field,
              sortAscending: field == notifier.query.sortField
                  ? !notifier.query.sortAscending
                  : true,
            ),
          ),
          columns: [
            TableColumnSpec(
              label: 'Название',
              sortField: 'title',
              build: (book) => Text(
                book.isDeleted ? '${book.title} (удалена)' : book.title,
              ),
            ),
            TableColumnSpec(
              label: 'ISBN',
              sortField: 'isbn',
              build: (book) => Text(book.isbn),
            ),
            TableColumnSpec(
              label: 'Год',
              sortField: 'year',
              numeric: true,
              build: (book) => Text('${book.year}'),
            ),
            TableColumnSpec(
              label: 'Страниц',
              sortField: 'pages',
              numeric: true,
              build: (book) => Text('${book.pages}'),
            ),
            TableColumnSpec(
              label: 'Издательство',
              build: (book) => Text(publisherName(book.publisherId)),
            ),
            TableColumnSpec(
              label: 'Жанры',
              build: (book) =>
                  Text(book.genreIds.map(genreName).join(', ')),
            ),
            TableColumnSpec(
              label: 'Доступно',
              numeric: true,
              build: (book) =>
                  Text('${book.copiesAvailable}/${book.copiesTotal}'),
            ),
          ],
          actions: (book) => _rowActions(notifier, book),
        );
      },
    );
  }

  List<Widget> _rowActions(BookListNotifier notifier, Book book) {
    return [
      IconButton(
        tooltip: 'Открыть карточку',
        icon: const Icon(Icons.open_in_new),
        onPressed: () => context.push('/books/${book.id}'),
      ),
      if (book.isDeleted)
        IconButton(
          tooltip: 'Восстановить',
          icon: const Icon(Icons.restore),
          onPressed: () => notifier.restore(book.id),
        )
      else
        IconButton(
          tooltip: 'Логически удалить',
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _softDelete(notifier, book),
        ),
      IconButton(
        tooltip: 'Стереть навсегда',
        icon: const Icon(Icons.delete_forever),
        onPressed: () => _hardDelete(notifier, book),
      ),
    ];
  }
}
