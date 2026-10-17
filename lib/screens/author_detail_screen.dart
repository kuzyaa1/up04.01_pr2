import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/author_detail_notifier.dart';
import '../state/book_list_notifier.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/list_state_views.dart';

/// Карточка автора. Данные запрашиваются только через [AuthorDetailNotifier].
class AuthorDetailScreen extends StatelessWidget {
  final int id;

  const AuthorDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<AuthorDetailNotifier>();
    return AppScaffold(
      title: 'Карточка автора',
      selectedIndex: 1,
      child: switch (notifier.status) {
        LoadStatus.idle || LoadStatus.loading => const LoadingView(),
        LoadStatus.error => ErrorView(
            message: notifier.error,
            onRetry: () => notifier.load(id),
          ),
        LoadStatus.success when notifier.details == null => EmptyView(
            message: 'Автор с номером $id не найден.',
            actions: [
              FilledButton(
                onPressed: () => context.go('/authors'),
                child: const Text('К списку авторов'),
              ),
            ],
          ),
        LoadStatus.success => _AuthorDetailsView(details: notifier.details!),
      },
    );
  }
}

class _AuthorDetailsView extends StatelessWidget {
  final AuthorDetails details;

  const _AuthorDetailsView({required this.details});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final author = details.author;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(author.fullName, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              _row(context, 'Имя', author.firstName),
              _row(context, 'Фамилия', author.lastName),
              _row(context, 'Страна', author.country),
              _row(context, 'Год рождения', '${author.birthYear}'),
              _row(context, 'Статус', author.isDeleted ? 'удалён' : 'в справочнике'),
              const SizedBox(height: 24),
              Text('Книги автора', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              if (details.books.isEmpty)
                Text('В каталоге нет книг этого автора.', style: theme.textTheme.bodyMedium)
              else
                for (final book in details.books)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(book.title),
                      subtitle: Text('${book.year} • ISBN ${book.isbn}'),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () => context.push('/books/${book.id}'),
                    ),
                  ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/authors');
                  }
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('К списку авторов'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
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
