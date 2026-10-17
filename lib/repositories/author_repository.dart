import '../models/author.dart';
import '../models/author_query.dart';
import '../models/page_result.dart';

/// Интерфейс доступа к авторам.
abstract interface class AuthorRepository {
  Future<PageResult<Author>> find(AuthorQuery query);

  Future<List<Author>> findByIds(List<int> ids);

  Future<Author?> findById(int id);

  Future<void> softDelete(int id);

  Future<void> hardDelete(int id);

  Future<void> restore(int id);

  /// Логическое удаление нескольких записей. Возвращает число изменённых.
  Future<int> softDeleteMany(List<int> ids);

  /// Физическое удаление нескольких записей. Возвращает число удалённых.
  Future<int> hardDeleteMany(List<int> ids);
}
