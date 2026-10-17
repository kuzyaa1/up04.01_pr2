import 'package:flutter/foundation.dart';

import '../models/book.dart';
import '../models/book_query.dart';
import '../models/page_result.dart';
import '../repositories/book_repository.dart';

/// Состояния экрана со списком.
enum LoadStatus { idle, loading, success, error }

/// Состояние экрана каталога книг.
///
/// Класс ничего не знает ни про виджеты, ни про `BuildContext`:
/// он умеет только загружать данные и сообщать об изменениях.
class BookListNotifier extends ChangeNotifier {
  BookListNotifier(this._repository);

  final BookRepository _repository;

  BookQuery _query = const BookQuery();
  PageResult<Book> _result = PageResult<Book>.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;
  final Set<int> _selected = <int>{};
  bool _disposed = false;

  BookQuery get query => _query;
  PageResult<Book> get result => _result;
  LoadStatus get status => _status;
  String? get error => _error;

  /// Наружу отдаётся неизменяемое представление, чтобы набор нельзя было
  /// изменить в обход [notifyListeners].
  Set<int> get selected => Set.unmodifiable(_selected);
  bool get hasSelection => _selected.isNotEmpty;

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    _safeNotify();

    try {
      _result = await _repository.find(_query);
      _status = LoadStatus.success;
    } catch (e) {
      _error = 'Не удалось загрузить список: $e';
      _status = LoadStatus.error;
    }
    _safeNotify();
  }

  /// Применяет новые условия отбора. Набор выбранных сбрасывается:
  /// при смене условий он теряет смысл.
  Future<void> applyQuery(BookQuery next) async {
    _query = next;
    _selected.clear();
    await load();
  }

  void toggleSelection(int id) {
    if (!_selected.remove(id)) _selected.add(id);
    _safeNotify();
  }

  void selectAll(Iterable<int> ids) {
    _selected
      ..clear()
      ..addAll(ids);
    _safeNotify();
  }

  void clearSelection() {
    if (_selected.isEmpty) return;
    _selected.clear();
    _safeNotify();
  }

  Future<void> softDelete(int id) async {
    await _repository.softDelete(id);
    _selected.remove(id);
    await load();
  }

  Future<void> hardDelete(int id) async {
    await _repository.hardDelete(id);
    _selected.remove(id);
    await load();
  }

  Future<void> restore(int id) async {
    await _repository.restore(id);
    await load();
  }

  Future<void> softDeleteSelected() async {
    await _repository.softDeleteMany(_selected.toList());
    _selected.clear();
    await load();
  }

  Future<void> hardDeleteSelected() async {
    await _repository.hardDeleteMany(_selected.toList());
    _selected.clear();
    await load();
  }

  void _safeNotify() {
    // Асинхронная операция могла завершиться после закрытия экрана.
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
