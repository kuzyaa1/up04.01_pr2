import 'package:flutter/foundation.dart';

import '../models/author.dart';
import '../models/book.dart';
import '../repositories/author_repository.dart';
import '../repositories/book_repository.dart';
import 'book_list_notifier.dart';

/// Данные карточки книги. Экран получает их через notifier, а не обращается
/// к репозиториям напрямую.
class BookDetails {
  final Book book;
  final List<Author> authors;

  const BookDetails({required this.book, required this.authors});
}

/// Состояние карточки книги.
class BookDetailNotifier extends ChangeNotifier {
  BookDetailNotifier(this._books, this._authors);

  final BookRepository _books;
  final AuthorRepository _authors;

  LoadStatus _status = LoadStatus.idle;
  BookDetails? _details;
  String? _error;
  bool _disposed = false;

  LoadStatus get status => _status;
  BookDetails? get details => _details;
  String? get error => _error;

  Future<void> load(int id) async {
    _status = LoadStatus.loading;
    _error = null;
    _safeNotify();
    try {
      final book = await _books.findById(id);
      if (book == null) {
        _details = null;
      } else {
        _details = BookDetails(
          book: book,
          authors: await _authors.findByIds(book.authorIds),
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
