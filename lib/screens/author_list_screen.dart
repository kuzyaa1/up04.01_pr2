import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/breakpoints.dart';
import '../models/author.dart';
import '../models/author_query.dart';
import '../state/author_list_notifier.dart';
import '../state/book_list_notifier.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/author_filter_bar.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/entity_cards.dart';
import '../widgets/entity_table.dart';
import '../widgets/list_state_views.dart';
import '../widgets/selection_bar.dart';

/// Экран справочника авторов.
///
/// Устроен так же, как каталог книг: та же таблица [EntityTable],
/// та же пагинация, тот же принцип «адрес — источник истины».
class AuthorListScreen extends StatefulWidget {
  final AuthorQuery query;

  const AuthorListScreen({super.key, required this.query});

  @override
  State<AuthorListScreen> createState() => _AuthorListScreenState();
}

class _AuthorListScreenState extends State<AuthorListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void didUpdateWidget(covariant AuthorListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
    }
  }

  void _sync() {
    if (!mounted) return;
    context.read<AuthorListNotifier>().applyQuery(widget.query);
  }

  void _updateQuery(AuthorQuery next) {
    final params = next.toQueryParameters();
    final location = params.isEmpty
        ? '/authors'
        : Uri(path: '/authors', queryParameters: params).toString();
    context.go(location);
  }

  Future<void> _softDelete(AuthorListNotifier notifier, Author author) async {
    final ok = await confirmAction(
      context,
      title: 'Логическое удаление',
      message: 'Убрать автора «${author.fullName}» из справочника? '
          'Запись можно будет восстановить.',
    );
    if (!ok) return;
    await notifier.softDelete(author.id);
  }

  Future<void> _hardDelete(AuthorListNotifier notifier, Author author) async {
    final ok = await confirmAction(
      context,
      title: 'Физическое удаление',
      message: 'Стереть автора «${author.fullName}» навсегда?',
      confirmLabel: 'Стереть',
      destructive: true,
    );
    if (!ok) return;
    await notifier.hardDelete(author.id);
  }

  Future<void> _deleteSelected(
    AuthorListNotifier notifier, {
    required bool hard,
  }) async {
    final count = notifier.selected.length;
    final ok = await confirmAction(
      context,
      title: hard ? 'Физическое удаление' : 'Логическое удаление',
      message: hard
          ? 'Стереть выбранные записи ($count шт.) навсегда?'
          : 'Убрать выбранные записи ($count шт.) из справочника?',
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
    final notifier = context.watch<AuthorListNotifier>();

    return AppScaffold(
      title: 'Авторы',
      selectedIndex: 1,
      actions: [
        IconButton(
          tooltip: 'Обновить',
          icon: const Icon(Icons.refresh),
          onPressed: notifier.load,
        ),
      ],
      child: Column(
        children: [
          AuthorFilterBar(query: widget.query, onChanged: _updateQuery),
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

  Widget _buildState(AuthorListNotifier notifier) {
    return switch (notifier.status) {
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

  Widget _buildEmpty(AuthorListNotifier notifier) {
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
      message: 'По заданным условиям авторов не найдено.',
      actions: [
        if (notifier.query.hasActiveFilters)
          FilledButton.icon(
            onPressed: () =>
                _updateQuery(AuthorQuery(size: notifier.query.size)),
            icon: const Icon(Icons.filter_alt_off),
            label: const Text('Сбросить фильтры'),
          ),
      ],
    );
  }

  Widget _buildList(AuthorListNotifier notifier) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < kCompactWidth) {
          return EntityCards<Author>(
            items: notifier.result.items,
            idOf: (author) => author.id,
            selected: notifier.selected,
            onToggleSelect: notifier.toggleSelection,
            titleOf: (author) => author.fullName,
            linesOf: (author) => [
              'Страна: ${author.country}',
              'Год рождения: ${author.birthYear}',
              if (author.isDeleted) 'Статус: удалён',
            ],
            actions: (author) => _rowActions(notifier, author),
          );
        }

        return EntityTable<Author>(
          items: notifier.result.items,
          idOf: (author) => author.id,
          selected: notifier.selected,
          onToggleSelect: notifier.toggleSelection,
          onSelectAll: () =>
              notifier.selectAll(notifier.result.items.map((a) => a.id)),
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
              label: 'Фамилия',
              sortField: 'lastName',
              build: (author) => Text(
                author.isDeleted
                    ? '${author.lastName} (удалён)'
                    : author.lastName,
              ),
            ),
            TableColumnSpec(
              label: 'Имя',
              sortField: 'firstName',
              build: (author) => Text(author.firstName),
            ),
            TableColumnSpec(
              label: 'Страна',
              sortField: 'country',
              build: (author) => Text(author.country),
            ),
            TableColumnSpec(
              label: 'Год рождения',
              sortField: 'birthYear',
              numeric: true,
              build: (author) => Text('${author.birthYear}'),
            ),
          ],
          actions: (author) => _rowActions(notifier, author),
        );
      },
    );
  }

  List<Widget> _rowActions(AuthorListNotifier notifier, Author author) {
    return [
      IconButton(
        tooltip: 'Открыть карточку',
        icon: const Icon(Icons.open_in_new),
        onPressed: () => context.push('/authors/${author.id}'),
      ),
      if (author.isDeleted)
        IconButton(
          tooltip: 'Восстановить',
          icon: const Icon(Icons.restore),
          onPressed: () => notifier.restore(author.id),
        )
      else
        IconButton(
          tooltip: 'Логически удалить',
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _softDelete(notifier, author),
        ),
      IconButton(
        tooltip: 'Стереть навсегда',
        icon: const Icon(Icons.delete_forever),
        onPressed: () => _hardDelete(notifier, author),
      ),
    ];
  }
}
