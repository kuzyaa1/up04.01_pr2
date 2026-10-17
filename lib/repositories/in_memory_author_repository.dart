import '../data/seed_data.dart';
import '../models/author.dart';
import '../models/author_query.dart';
import '../models/page_result.dart';
import 'author_repository.dart';

/// Реализация справочника авторов на данных в памяти.
class InMemoryAuthorRepository implements AuthorRepository {
  InMemoryAuthorRepository({List<Author>? seeded})
      : _authors = [...(seeded ?? seedAuthors)];

  final List<Author> _authors;

  @override
  Future<PageResult<Author>> find(AuthorQuery q) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (q.yearFrom != null && q.yearTo != null && q.yearFrom! > q.yearTo!) {
      throw ArgumentError('Год рождения «от» больше года «до»');
    }

    var rows = _authors.where((a) => q.includeDeleted || !a.isDeleted).toList();

    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where((a) =>
              a.lastName.toLowerCase().contains(needle) ||
              a.firstName.toLowerCase().contains(needle) ||
              a.country.toLowerCase().contains(needle))
          .toList();
    }

    if (q.country != null) {
      rows = rows.where((a) => a.country == q.country).toList();
    }
    if (q.yearFrom != null) {
      rows = rows.where((a) => a.birthYear >= q.yearFrom!).toList();
    }
    if (q.yearTo != null) {
      rows = rows.where((a) => a.birthYear <= q.yearTo!).toList();
    }

    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'firstName' => a.firstName.toLowerCase().compareTo(b.firstName.toLowerCase()),
        'country' => a.country.toLowerCase().compareTo(b.country.toLowerCase()),
        'birthYear' => a.birthYear.compareTo(b.birthYear),
        _ => a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase()),
      };
      return q.sortAscending ? result : -result;
    });

    final total = rows.length;
    final from = (q.page - 1) * q.size;
    final to = (from + q.size) > total ? total : (from + q.size);
    final items = from >= total ? <Author>[] : rows.sublist(from, to);

    return PageResult<Author>(items: items, page: q.page, size: q.size, total: total);
  }

  @override
  Future<List<Author>> findByIds(List<int> ids) async {
    return _authors.where((a) => ids.contains(a.id)).toList();
  }

  @override
  Future<Author?> findById(int id) async {
    for (final author in _authors) {
      if (author.id == id) return author;
    }
    return null;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _authors.indexWhere((a) => a.id == id);
    if (i == -1) throw StateError('Автор $id не найден');
    _authors[i] = _authors[i].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    _authors.removeWhere((a) => a.id == id);
  }

  @override
  Future<void> restore(int id) async {
    final i = _authors.indexWhere((a) => a.id == id);
    if (i == -1) throw StateError('Автор $id не найден');
    _authors[i] = _authors[i].copyWith(clearDeletedAt: true);
  }

  @override
  Future<int> softDeleteMany(List<int> ids) async {
    var count = 0;
    for (final id in ids) {
      final i = _authors.indexWhere((a) => a.id == id && !a.isDeleted);
      if (i != -1) {
        _authors[i] = _authors[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    return count;
  }

  @override
  Future<int> hardDeleteMany(List<int> ids) async {
    final before = _authors.length;
    _authors.removeWhere((a) => ids.contains(a.id));
    return before - _authors.length;
  }
}
