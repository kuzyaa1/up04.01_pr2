import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/author_query.dart';
import '../models/book_query.dart';
import '../repositories/author_repository.dart';
import '../repositories/book_repository.dart';
import '../screens/author_detail_screen.dart';
import '../screens/author_list_screen.dart';
import '../screens/book_detail_screen.dart';
import '../screens/book_list_screen.dart';
import '../screens/home_screen.dart';
import '../screens/not_found_screen.dart';
import '../state/author_detail_notifier.dart';
import '../state/book_detail_notifier.dart';

/// Схема маршрутов приложения.
///
/// /                     — главная с переходом в разделы
/// /books                — каталог книг; условия отбора в query-параметрах
/// /books/:id            — карточка книги
/// /authors              — справочник авторов
/// /authors/:id          — карточка автора
/// всё остальное         — экран 404 через errorBuilder
///
/// Экраны списка получают условия отбора прямо из адреса, поэтому
/// ссылку на отфильтрованный список можно открыть в новой вкладке.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/books',
      builder: (context, state) => BookListScreen(
        query: BookQuery.fromUri(state.uri),
      ),
    ),
    GoRoute(
      path: '/books/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? -1;
        return ChangeNotifierProvider<BookDetailNotifier>(
          create: (context) => BookDetailNotifier(
            context.read<BookRepository>(),
            context.read<AuthorRepository>(),
          )..load(id),
          child: BookDetailScreen(id: id),
        );
      },
    ),
    GoRoute(
      path: '/authors',
      builder: (context, state) => AuthorListScreen(
        query: AuthorQuery.fromUri(state.uri),
      ),
    ),
    GoRoute(
      path: '/authors/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? -1;
        return ChangeNotifierProvider<AuthorDetailNotifier>(
          create: (context) => AuthorDetailNotifier(
            context.read<AuthorRepository>(),
            context.read<BookRepository>(),
          )..load(id),
          child: AuthorDetailScreen(id: id),
        );
      },
    ),
  ],
  errorBuilder: (context, state) =>
      NotFoundScreen(location: state.uri.toString()),
);
