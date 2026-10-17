import 'package:flutter/foundation.dart';

import '../models/author.dart';
import '../models/book.dart';
import '../repositories/author_repository.dart';
import '../repositories/book_repository.dart';
import 'book_list_notifier.dart';

/// Данные карточки автора. Экран получает их через notifier, а не обращается
/// к репозиториям напрямую.
class AuthorDetails {
  final Author author;
  final List<Book> books;

  const AuthorDetails({required this.author, required this.books});
}

/// Состояние карточки автора.
class AuthorDetailNotifier extends ChangeNotifier {
  AuthorDetailNotifier(this._authors, this._books);

  final AuthorRepository _authors;
  final BookRepository _books;

  LoadStatus _status = LoadStatus.idle;
  AuthorDetails? _details;
  String? _error;
  bool _disposed = false;

  LoadStatus get status => _status;
  AuthorDetails? get details => _details;
  String? get error => _error;

  Future<void> load(int id) async {
    _status = LoadStatus.loading;
    _error = null;
    _safeNotify();
    try {
      final author = await _authors.findById(id);
      if (author == null) {
        _details = null;
      } else {
        _details = AuthorDetails(
          author: author,
          books: await _books.findByAuthor(author.id),
        );
      }
      _status = LoadStatus.success;
    } catch (e) {
      _error = 'Не удалось загрузить карточку: $e';
      _status = LoadStatus.error;
    }
    _safeNotify();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
