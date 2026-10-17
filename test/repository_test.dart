import 'package:flutter_test/flutter_test.dart';
import 'package:library_web/models/book_query.dart';
import 'package:library_web/models/page_result.dart';
import 'package:library_web/models/author_query.dart';
import 'package:library_web/repositories/in_memory_author_repository.dart';
import 'package:library_web/repositories/in_memory_book_repository.dart';

void main() {
  group('InMemoryBookRepository.find', () {
    test('возвращает первую страницу заданного размера', () async {
      final repo = InMemoryBookRepository();
      final result = await repo.find(const BookQuery(size: 10));

      expect(result.items, hasLength(10));
      expect(result.page, 1);
      expect(result.total, greaterThanOrEqualTo(20));
      expect(result.totalPages, (result.total / 10).ceil());
    });

    test('вторая страница не пересекается с первой', () async {
      final repo = InMemoryBookRepository();
      final first = await repo.find(const BookQuery(size: 10));
      final second = await repo.find(const BookQuery(page: 2, size: 10));

      final firstIds = first.items.map((b) => b.id).toSet();
      final secondIds = second.items.map((b) => b.id).toSet();
      expect(firstIds.intersection(secondIds), isEmpty);
    });

    test('поиск идёт по названию и ISBN, а не по идентификатору', () async {
      final repo = InMemoryBookRepository();
      final byTitle = await repo.find(const BookQuery(search: 'дюна'));
      expect(byTitle.items, isNotEmpty);
      expect(byTitle.items.every((b) => b.title.toLowerCase().contains('дюна')),
          isTrue);

      final byIsbn = await repo.find(const BookQuery(search: '978-5-17-118775-4'));
      expect(byIsbn.items, hasLength(1));
      expect(byIsbn.items.first.isbn, '978-5-17-118775-4');
    });

    test('фильтры комбинируются: жанр, издательство и диапазон года', () async {
      final repo = InMemoryBookRepository();
      final result = await repo.find(
        const BookQuery(genreId: 1, publisherId: 2, yearFrom: 2014, yearTo: 2018),
      );

      expect(result.items, isNotEmpty);
      for (final book in result.items) {
        expect(book.genreIds, contains(1));
        expect(book.publisherId, 2);
        expect(book.year, inInclusiveRange(2014, 2018));
      }
    });

    test('сортировка по году переключает направление', () async {
      final repo = InMemoryBookRepository();
      final asc = await repo.find(
        const BookQuery(sortField: 'year', size: 50),
      );
      final desc = await repo.find(
        const BookQuery(sortField: 'year', sortAscending: false, size: 50),
      );

      expect(asc.items.first.year, lessThanOrEqualTo(asc.items.last.year));
      expect(desc.items.first.year, greaterThanOrEqualTo(desc.items.last.year));
    });

    test('логически удалённая запись исчезает из выборки, но видна '
        'при включённом флаге', () async {
      final repo = InMemoryBookRepository();
      final before = await repo.find(const BookQuery(size: 50));
      final targetId = before.items.first.id;

      await repo.softDelete(targetId);

      final after = await repo.find(const BookQuery(size: 50));
      expect(after.items.any((b) => b.id == targetId), isFalse);
      expect(after.total, before.total - 1);

      final withDeleted =
          await repo.find(const BookQuery(size: 50, includeDeleted: true));
      expect(withDeleted.items.any((b) => b.id == targetId), isTrue);
    });

    test('восстановление возвращает запись в выборку', () async {
      final repo = InMemoryBookRepository();
      final before = await repo.find(const BookQuery(size: 50));
      final targetId = before.items.first.id;

      await repo.softDelete(targetId);
      await repo.restore(targetId);

      final after = await repo.find(const BookQuery(size: 50));
      expect(after.items.any((b) => b.id == targetId), isTrue);
      expect(after.total, before.total);
    });

    test('множественное логическое удаление пропускает уже удалённые '
        'и не падает (исправленная ошибка deleteMany)', () async {
      final repo = InMemoryBookRepository();
      final page = await repo.find(const BookQuery(size: 5));
      final ids = page.items.map((b) => b.id).toList();

      // Первый вызов удаляет все переданные записи.
      expect(await repo.softDeleteMany(ids), ids.length);
      // Второй — ни одной: они уже удалены.
      expect(await repo.softDeleteMany(ids), 0);
    });

    test('множественное физическое удаление стирает записи насовсем', () async {
      final repo = InMemoryBookRepository();
      final before = await repo.find(const BookQuery(size: 50));
      final ids = before.items.take(3).map((b) => b.id).toList();

      expect(await repo.hardDeleteMany(ids), 3);

      final withDeleted =
          await repo.find(const BookQuery(size: 50, includeDeleted: true));
      expect(withDeleted.total, before.total - 3);
    });

    test('неверный диапазон года приводит к ошибке, а не к пустому списку',
        () async {
      final repo = InMemoryBookRepository();
      expect(
        () => repo.find(const BookQuery(yearFrom: 2020, yearTo: 2000)),
        throwsArgumentError,
      );
    });
  });

  group('BookQuery и адрес страницы', () {
    test('условия отбора переживают переход в адрес и обратно', () {
      const query = BookQuery(
        search: 'война',
        genreId: 2,
        publisherId: 3,
        yearFrom: 1990,
        yearTo: 2020,
        sortField: 'year',
        sortAscending: false,
        page: 3,
        size: 25,
      );

      final uri = Uri(path: '/books', queryParameters: query.toQueryParameters());
      final restored = BookQuery.fromUri(uri);

      expect(restored, query);
    });

    test('смена фильтра возвращает на первую страницу', () {
      const query = BookQuery(page: 7, genreId: 1);
      final next = query.copyWith(genreId: 2);
      expect(next.page, 1);
    });

    test('сброс фильтра через copyWith отличается от «не передали параметр»',
        () {
      const query = BookQuery(genreId: 1, publisherId: 2);
      final cleared = query.copyWith(genreId: null);
      expect(cleared.genreId, isNull);
      expect(cleared.publisherId, 2);
    });
  });

  group('PageResult', () {
    test('пустая страница имеет одну страницу и не имеет соседей', () {
      final empty = PageResult<int>.empty();
      expect(empty.totalPages, 1);
      expect(empty.hasPrevious, isFalse);
      expect(empty.hasNext, isFalse);
    });
  });

  group('InMemoryAuthorRepository', () {
    test('поиск по фамилии и стране, фильтр по году рождения', () async {
      final repo = InMemoryAuthorRepository();

      final byCountry = await repo.find(const AuthorQuery(country: 'США'));
      expect(byCountry.items, isNotEmpty);
      expect(byCountry.items.every((a) => a.country == 'США'), isTrue);

      final byYears = await repo.find(
        const AuthorQuery(yearFrom: 1900, yearTo: 1960, size: 50),
      );
      expect(
        byYears.items.every(
          (a) => a.birthYear >= 1900 && a.birthYear <= 1960,
        ),
        isTrue,
      );
    });
  });
}
