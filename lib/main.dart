import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'core/router.dart';
import 'repositories/author_repository.dart';
import 'repositories/book_repository.dart';
import 'repositories/in_memory_author_repository.dart';
import 'repositories/in_memory_book_repository.dart';
import 'state/author_list_notifier.dart';
import 'state/book_list_notifier.dart';

void main() {
  // Убирает решётку из адреса: /books вместо /#/books
  usePathUrlStrategy();
  runApp(
    MultiProvider(
      providers: [
        // Provider — для объектов без собственного состояния.
        Provider<BookRepository>(create: (_) => InMemoryBookRepository()),
        Provider<AuthorRepository>(create: (_) => InMemoryAuthorRepository()),

        // ChangeNotifierProvider — для ChangeNotifier; сам вызовет dispose().
        // Загрузку запускает экран: условия отбора приходят из адреса.
        ChangeNotifierProvider<BookListNotifier>(
          create: (context) => BookListNotifier(context.read<BookRepository>()),
        ),
        ChangeNotifierProvider<AuthorListNotifier>(
          create: (context) =>
              AuthorListNotifier(context.read<AuthorRepository>()),
        ),
      ],
      child: const LibraryApp(),
    ),
  );
}

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Библиотечная система',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
