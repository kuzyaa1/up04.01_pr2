import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/seed_data.dart';
import '../state/book_detail_notifier.dart';
import '../state/book_list_notifier.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/list_state_views.dart';

/// Карточка книги — просмотр всех полей записи.
/// Данные запрашиваются только через [BookDetailNotifier].
class BookDetailScreen extends StatelessWidget {
  final int id;

  const BookDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<BookDetailNotifier>();
    return AppScaffold(
      title: 'Карточка книги',
      selectedIndex: 0,
      child: switch (notifier.status) {
        LoadStatus.idle || LoadStatus.loading => const LoadingView(),
        LoadStatus.error => ErrorView(
            message: notifier.error,
            onRetry: () => notifier.load(id),
          ),
        LoadStatus.success when notifier.details == null => EmptyView(
            message: 'Книга с номером $id не найдена.',
            actions: [
              FilledButton(
                onPressed: () => context.go('/books'),
                child: const Text('К списку книг'),
              ),
            ],
          ),
        LoadStatus.success => _BookDetailsView(details: notifier.details!),
      },
    );
  }
}

class _BookDetailsView extends StatelessWidget {
  final BookDetails details;

  const _BookDetailsView({required this.details});

  @override
  Widget build(BuildContext context) {
    final book = details.book;
    final authors = details.authors.isEmpty
        ? '—'
        : details.authors.map((a) => a.fullName).join(', ');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(book.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              _DetailRow(label: 'ISBN', value: book.isbn),
              _DetailRow(label: 'Год издания', value: '${book.year}'),
              _DetailRow(label: 'Страниц', value: '${book.pages}'),
              _DetailRow(label: 'Издательство', value: publisherName(book.publisherId)),
              _DetailRow(label: 'Жанры', value: book.genreIds.map(genreName).join(', ')),
              _DetailRow(label: 'Авторы', value: authors),
              _DetailRow(label: 'Всего экземпляров', value: '${book.copiesTotal}'),
              _DetailRow(label: 'Доступно', value: '${book.copiesAvailable}'),
              _DetailRow(label: 'Статус', value: book.isDeleted ? 'удалена' : 'в каталоге'),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/books');
                  }
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('К списку книг'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
