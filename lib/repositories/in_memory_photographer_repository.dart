import '../data/seed_data.dart';
import '../models/page_result.dart';
import '../models/photographer.dart';
import '../models/photographer_query.dart';
import 'photographer_repository.dart';

class InMemoryPhotographerRepository implements PhotographerRepository {
  InMemoryPhotographerRepository() : _items = [...seedPhotographers];
  final List<Photographer> _items;
  @override
  Future<PageResult<Photographer>> find(PhotographerQuery q) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (q.experienceFrom != null &&
        q.experienceTo != null &&
        q.experienceFrom! > q.experienceTo!) {
      throw ArgumentError('Стаж «от» больше стажа «до»');
    }
    var rows = _items.where((x) => q.includeDeleted || !x.isDeleted).toList();
    final n = q.search.trim().toLowerCase();
    if (n.isNotEmpty) {
      rows = rows
          .where((x) =>
              x.lastName.toLowerCase().contains(n) ||
              x.firstName.toLowerCase().contains(n) ||
              x.specialization.toLowerCase().contains(n))
          .toList();
    }
    if (q.specialization != null) {
      rows = rows.where((x) => x.specialization == q.specialization).toList();
    }
    if (q.experienceFrom != null) {
      rows = rows.where((x) => x.experienceYears >= q.experienceFrom!).toList();
    }
    if (q.experienceTo != null) {
      rows = rows.where((x) => x.experienceYears <= q.experienceTo!).toList();
    }
    rows.sort((a, b) {
      final r = switch (q.sortField) {
        'specialization' => a.specialization.compareTo(b.specialization),
        'experienceYears' => a.experienceYears.compareTo(b.experienceYears),
        'hourlyRate' => a.hourlyRate.compareTo(b.hourlyRate),
        _ => a.lastName.compareTo(b.lastName)
      };
      return q.sortAscending ? r : -r;
    });
    final total = rows.length,
        from = (q.page - 1) * q.size,
        to = (from + q.size) > total ? total : from + q.size;
    return PageResult(
        items: from >= total ? <Photographer>[] : rows.sublist(from, to),
        page: q.page,
        size: q.size,
        total: total);
  }

  @override
  Future<Photographer?> findById(int id) async {
    for (final x in _items) {
      if (x.id == id) return x;
    }
    return null;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _items.indexWhere((x) => x.id == id);
    if (i < 0) throw StateError('Фотограф не найден');
    _items[i] = _items[i].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    _items.removeWhere((x) => x.id == id);
  }

  @override
  Future<void> restore(int id) async {
    final i = _items.indexWhere((x) => x.id == id);
    if (i < 0) throw StateError('Фотограф не найден');
    _items[i] = _items[i].copyWith(clearDeletedAt: true);
  }

  @override
  Future<int> softDeleteMany(List<int> ids) async {
    var c = 0;
    for (final id in ids) {
      final i = _items.indexWhere((x) => x.id == id && !x.isDeleted);
      if (i >= 0) {
        _items[i] = _items[i].copyWith(deletedAt: DateTime.now());
        c++;
      }
    }
    return c;
  }

  @override
  Future<int> hardDeleteMany(List<int> ids) async {
    final before = _items.length;
    _items.removeWhere((x) => ids.contains(x.id));
    return before - _items.length;
  }
}
