import '../models/book.dart';
import '../models/book_query.dart';
import '../models/page_result.dart';

/// Что приложение умеет делать с книгами — безотносительно того,
/// где они хранятся.
///
/// В ПР4 появится реализация поверх учебного API, а экраны и состояние
/// останутся без изменений.
abstract interface class BookRepository {
  Future<PageResult<Book>> find(BookQuery query);

  Future<Book?> findById(int id);

  Future<List<Book>> findByIds(List<int> ids);

  /// Книги указанного автора (для карточки автора).
  Future<List<Book>> findByAuthor(int authorId);

  Future<void> softDelete(int id);

  Future<void> hardDelete(int id);

  Future<void> restore(int id);

  /// Логическое удаление нескольких записей. Возвращает число изменённых.
  Future<int> softDeleteMany(List<int> ids);

  /// Физическое удаление нескольких записей. Возвращает число удалённых.
  Future<int> hardDeleteMany(List<int> ids);
}
