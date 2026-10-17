import 'package:flutter/foundation.dart';

import '../models/author.dart';
import '../models/author_query.dart';
import '../models/page_result.dart';
import '../repositories/author_repository.dart';
import 'book_list_notifier.dart';

/// Состояние экрана справочника авторов.
class AuthorListNotifier extends ChangeNotifier {
  AuthorListNotifier(this._repository);

  final AuthorRepository _repository;

  AuthorQuery _query = const AuthorQuery();
  PageResult<Author> _result = PageResult<Author>.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;
  final Set<int> _selected = <int>{};
  bool _disposed = false;

  AuthorQuery get query => _query;
  PageResult<Author> get result => _result;
  LoadStatus get status => _status;
  String? get error => _error;
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

  Future<void> applyQuery(AuthorQuery next) async {
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
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
