import '../data/seed_data.dart';
import '../models/book.dart';
import '../models/book_query.dart';
import '../models/page_result.dart';
import 'book_repository.dart';

/// Реализация каталога книг на данных в памяти.
///
/// Данные живут только до перезагрузки страницы — сервер подключается в ПР4.
class InMemoryBookRepository implements BookRepository {
  InMemoryBookRepository({List<Book>? seeded})
      : _books = [...(seeded ?? seedBooks)];

  final List<Book> _books;

  @override
  Future<PageResult<Book>> find(BookQuery q) async {
    // Небольшая задержка имитирует сеть: без неё индикатор загрузки
    // невозможно увидеть, а в ПР4 он понадобится по-настоящему.
    await Future<void>.delayed(const Duration(milliseconds: 250));

    // Диапазон года задан неверно — сообщаем об этом состоянием ошибки,
    // чтобы экран показал его, а не пустой список.
    if (q.yearFrom != null && q.yearTo != null && q.yearFrom! > q.yearTo!) {
      throw ArgumentError('Год «от» больше года «до»');
    }

    var rows = _books.where((b) => q.includeDeleted || !b.isDeleted).toList();

    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where((b) =>
              b.title.toLowerCase().contains(needle) ||
              b.isbn.toLowerCase().contains(needle))
          .toList();
    }

    if (q.genreId != null) {
      rows = rows.where((b) => b.genreIds.contains(q.genreId)).toList();
    }
    if (q.publisherId != null) {
      rows = rows.where((b) => b.publisherId == q.publisherId).toList();
    }
    if (q.yearFrom != null) {
      rows = rows.where((b) => b.year >= q.yearFrom!).toList();
    }
    if (q.yearTo != null) {
      rows = rows.where((b) => b.year <= q.yearTo!).toList();
    }

    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'year' => a.year.compareTo(b.year),
        'pages' => a.pages.compareTo(b.pages),
        'isbn' => a.isbn.compareTo(b.isbn),
        _ => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      };
      return q.sortAscending ? result : -result;
    });

    return _paginate(rows, q.page, q.size);
  }

  @override
  Future<Book?> findById(int id) async {
    for (final book in _books) {
      if (book.id == id) return book;
    }
    return null;
  }

  @override
  Future<List<Book>> findByIds(List<int> ids) async {
    return _books.where((b) => ids.contains(b.id)).toList();
  }

  @override
  Future<List<Book>> findByAuthor(int authorId) async {
    return _books
        .where((b) => !b.isDeleted && b.authorIds.contains(authorId))
        .toList();
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _books.indexWhere((b) => b.id == id);
    if (i == -1) throw StateError('Книга $id не найдена');
    _books[i] = _books[i].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    _books.removeWhere((b) => b.id == id);
  }

  @override
  Future<void> restore(int id) async {
    final i = _books.indexWhere((b) => b.id == id);
    if (i == -1) throw StateError('Книга $id не найдена');
    _books[i] = _books[i].copyWith(clearDeletedAt: true);
  }

  @override
  Future<int> softDeleteMany(List<int> ids) async {
    var count = 0;
    for (final id in ids) {
      final i = _books.indexWhere((b) => b.id == id && !b.isDeleted);
      if (i != -1) {
        _books[i] = _books[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    return count;
  }

  @override
  Future<int> hardDeleteMany(List<int> ids) async {
    final before = _books.length;
    _books.removeWhere((b) => ids.contains(b.id));
    return before - _books.length;
  }

  PageResult<Book> _paginate(List<Book> rows, int page, int size) {
    final total = rows.length;
    final from = (page - 1) * size;
    // Осторожно: num.clamp возвращает num, а не int, и в sublist его
    // передать нельзя, поэтому границу считаем явно.
    final to = (from + size) > total ? total : (from + size);
    final items = from >= total ? <Book>[] : rows.sublist(from, to);
    return PageResult<Book>(items: items, page: page, size: size, total: total);
  }
}
