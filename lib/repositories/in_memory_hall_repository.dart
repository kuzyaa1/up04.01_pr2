import '../data/seed_data.dart';
import '../models/hall_query.dart';
import '../models/page_result.dart';
import '../models/studio_hall.dart';
import 'hall_repository.dart';

class InMemoryHallRepository implements HallRepository {
  InMemoryHallRepository() : _items = [...seedHalls];
  final List<StudioHall> _items;
  @override
  Future<PageResult<StudioHall>> find(HallQuery q) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (q.capacityFrom != null &&
        q.capacityTo != null &&
        q.capacityFrom! > q.capacityTo!) {
      throw ArgumentError('Вместимость «от» больше вместимости «до»');
    }
    if (q.priceFrom != null && q.priceTo != null && q.priceFrom! > q.priceTo!) {
      throw ArgumentError('Цена «от» больше цены «до»');
    }
    var rows = _items.where((x) => q.includeDeleted || !x.isDeleted).toList();
    final n = q.search.trim().toLowerCase();
    if (n.isNotEmpty) {
      rows = rows
          .where((x) =>
              x.name.toLowerCase().contains(n) ||
              x.code.toLowerCase().contains(n))
          .toList();
    }
    if (q.style != null) rows = rows.where((x) => x.style == q.style).toList();
    if (q.capacityFrom != null) {
      rows = rows.where((x) => x.capacity >= q.capacityFrom!).toList();
    }
    if (q.capacityTo != null) {
      rows = rows.where((x) => x.capacity <= q.capacityTo!).toList();
    }
    if (q.priceFrom != null) {
      rows = rows.where((x) => x.hourlyRate >= q.priceFrom!).toList();
    }
    if (q.priceTo != null) {
      rows = rows.where((x) => x.hourlyRate <= q.priceTo!).toList();
    }
    rows.sort((a, b) {
      final r = switch (q.sortField) {
        'capacity' => a.capacity.compareTo(b.capacity),
        'hourlyRate' => a.hourlyRate.compareTo(b.hourlyRate),
        'style' => a.style.compareTo(b.style),
        _ => a.name.toLowerCase().compareTo(b.name.toLowerCase())
      };
      return q.sortAscending ? r : -r;
    });
    final total = rows.length,
        from = (q.page - 1) * q.size,
        to = (from + q.size) > total ? total : from + q.size;
    return PageResult(
        items: from >= total ? <StudioHall>[] : rows.sublist(from, to),
        page: q.page,
        size: q.size,
        total: total);
  }

  @override
  Future<StudioHall?> findById(int id) async =>
      _items.where((x) => x.id == id).cast<StudioHall?>().firstOrNull;
  @override
  Future<void> softDelete(int id) async {
    final i = _items.indexWhere((x) => x.id == id);
    if (i < 0) throw StateError('Зал не найден');
    _items[i] = _items[i].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    _items.removeWhere((x) => x.id == id);
  }

  @override
  Future<void> restore(int id) async {
    final i = _items.indexWhere((x) => x.id == id);
    if (i < 0) throw StateError('Зал не найден');
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

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
