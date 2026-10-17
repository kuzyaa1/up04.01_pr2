import '../models/author.dart';
import '../models/book.dart';
import '../models/reference.dart';

/// Начальный набор данных в памяти.
///
/// При перезагрузке страницы данные восстанавливаются из этих списков.
/// До ПР4 сервер не участвует.

const List<Genre> genres = [
  Genre(1, 'Фантастика'),
  Genre(2, 'Детектив'),
  Genre(3, 'Роман'),
  Genre(4, 'История'),
  Genre(5, 'Наука'),
  Genre(6, 'Поэзия'),
  Genre(7, 'Фэнтези'),
  Genre(8, 'Приключения'),
];

const List<Publisher> publishers = [
  Publisher(1, 'Эксмо'),
  Publisher(2, 'АСТ'),
  Publisher(3, 'Азбука'),
  Publisher(4, 'Питер'),
  Publisher(5, 'Альпина Паблишер'),
  Publisher(6, 'МИФ'),
  Publisher(7, 'Росмэн'),
];

/// Название жанра по идентификатору (для карточек и таблиц).
String genreName(int id) =>
    genres.firstWhere((g) => g.id == id, orElse: () => Genre(id, 'Жанр $id')).name;

/// Название издательства по идентификатору.
String publisherName(int id) => publishers
    .firstWhere((p) => p.id == id, orElse: () => Publisher(id, 'Издательство $id'))
    .name;

/// Страны, встречающиеся в наборе авторов (для выпадающего списка).
const List<String> countries = [
  'Великобритания',
  'Израиль',
  'Колумбия',
  'Польша',
  'Россия',
  'США',
];

const List<Author> seedAuthors = [
  Author(id: 1, firstName: 'Лев', lastName: 'Толстой', country: 'Россия', birthYear: 1828),
  Author(id: 2, firstName: 'Фёдор', lastName: 'Достоевский', country: 'Россия', birthYear: 1821),
  Author(id: 3, firstName: 'Михаил', lastName: 'Булгаков', country: 'Россия', birthYear: 1891),
  Author(id: 4, firstName: 'Александр', lastName: 'Пушкин', country: 'Россия', birthYear: 1799),
  Author(id: 5, firstName: 'Джордж', lastName: 'Оруэлл', country: 'Великобритания', birthYear: 1903),
  Author(id: 6, firstName: 'Рэй', lastName: 'Брэдбери', country: 'США', birthYear: 1920),
  Author(id: 7, firstName: 'Агата', lastName: 'Кристи', country: 'Великобритания', birthYear: 1890),
  Author(id: 8, firstName: 'Станислав', lastName: 'Лем', country: 'Польша', birthYear: 1921),
  Author(id: 9, firstName: 'Борис', lastName: 'Стругацкий', country: 'Россия', birthYear: 1933),
  Author(id: 10, firstName: 'Аркадий', lastName: 'Стругацкий', country: 'Россия', birthYear: 1925),
  Author(id: 11, firstName: 'Габриэль', lastName: 'Гарсиа Маркес', country: 'Колумбия', birthYear: 1927),
  Author(id: 12, firstName: 'Эрнест', lastName: 'Хемингуэй', country: 'США', birthYear: 1899),
  Author(id: 13, firstName: 'Роберт', lastName: 'Мартин', country: 'США', birthYear: 1952),
  Author(id: 14, firstName: 'Фрэнк', lastName: 'Герберт', country: 'США', birthYear: 1920),
  Author(id: 15, firstName: 'Джоан', lastName: 'Роулинг', country: 'Великобритания', birthYear: 1965),
  Author(id: 16, firstName: 'Даниэль', lastName: 'Канеман', country: 'Израиль', birthYear: 1934),
  Author(id: 17, firstName: 'Юваль Ной', lastName: 'Харари', country: 'Израиль', birthYear: 1976),
  Author(id: 18, firstName: 'Нил', lastName: 'Гейман', country: 'Великобритания', birthYear: 1960),
];

const List<Book> seedBooks = [
  Book(id: 1, title: 'Война и мир. Том 1', isbn: '978-5-04-116622-3', year: 2018, pages: 704, publisherId: 1, authorIds: [1], genreIds: [4, 3], copiesTotal: 5, copiesAvailable: 3),
  Book(id: 2, title: 'Преступление и наказание', isbn: '978-5-04-118564-4', year: 2019, pages: 608, publisherId: 1, authorIds: [2], genreIds: [3, 4], copiesTotal: 4, copiesAvailable: 2),
  Book(id: 3, title: 'Мастер и Маргарита', isbn: '978-5-17-118888-1', year: 2020, pages: 480, publisherId: 2, authorIds: [3], genreIds: [3, 7], copiesTotal: 6, copiesAvailable: 5),
  Book(id: 4, title: 'Евгений Онегин', isbn: '978-5-389-10875-3', year: 2016, pages: 320, publisherId: 3, authorIds: [4], genreIds: [6, 3], copiesTotal: 3, copiesAvailable: 3),
  Book(id: 5, title: '1984', isbn: '978-5-17-118775-4', year: 2021, pages: 320, publisherId: 2, authorIds: [5], genreIds: [1], copiesTotal: 8, copiesAvailable: 6),
  Book(id: 6, title: 'Скотный двор', isbn: '978-5-17-103245-0', year: 2017, pages: 256, publisherId: 2, authorIds: [5], genreIds: [1], copiesTotal: 4, copiesAvailable: 4),
  Book(id: 7, title: '451° по Фаренгейту', isbn: '978-5-04-155259-7', year: 2019, pages: 256, publisherId: 1, authorIds: [6], genreIds: [1], copiesTotal: 5, copiesAvailable: 1),
  Book(id: 8, title: 'Марсианские хроники', isbn: '978-5-04-098512-1', year: 2015, pages: 320, publisherId: 1, authorIds: [6], genreIds: [1, 8], copiesTotal: 3, copiesAvailable: 2),
  Book(id: 9, title: 'Вино из одуванчиков', isbn: '978-5-04-099515-1', year: 2018, pages: 288, publisherId: 1, authorIds: [6], genreIds: [3, 7], copiesTotal: 2, copiesAvailable: 2),
  Book(id: 10, title: 'Убийство в «Восточном экспрессе»', isbn: '978-5-04-100965-4', year: 2017, pages: 320, publisherId: 1, authorIds: [7], genreIds: [2], copiesTotal: 6, copiesAvailable: 4),
  Book(id: 11, title: 'Десять негритят', isbn: '978-5-04-101430-8', year: 2015, pages: 288, publisherId: 1, authorIds: [7], genreIds: [2], copiesTotal: 7, copiesAvailable: 5),
  Book(id: 12, title: 'Смерть на Ниле', isbn: '978-5-04-108558-0', year: 2018, pages: 352, publisherId: 1, authorIds: [7], genreIds: [2], copiesTotal: 3, copiesAvailable: 3),
  Book(id: 13, title: 'Солярис', isbn: '978-5-17-092999-2', year: 2016, pages: 288, publisherId: 2, authorIds: [8], genreIds: [1], copiesTotal: 4, copiesAvailable: 3),
  Book(id: 14, title: 'Эдем', isbn: '978-5-17-094146-1', year: 2014, pages: 352, publisherId: 2, authorIds: [8], genreIds: [1], copiesTotal: 2, copiesAvailable: 1),
  Book(id: 15, title: 'Пикник на обочине', isbn: '978-5-17-091113-4', year: 2017, pages: 256, publisherId: 2, authorIds: [9, 10], genreIds: [1, 8], copiesTotal: 5, copiesAvailable: 5),
  Book(id: 16, title: 'Трудно быть богом', isbn: '978-5-17-088003-5', year: 2015, pages: 320, publisherId: 2, authorIds: [9, 10], genreIds: [1, 4], copiesTotal: 4, copiesAvailable: 2),
  Book(id: 17, title: 'Обитаемый остров', isbn: '978-5-17-090001-4', year: 2016, pages: 416, publisherId: 2, authorIds: [9, 10], genreIds: [1, 8], copiesTotal: 3, copiesAvailable: 1),
  Book(id: 18, title: 'Сто лет одиночества', isbn: '978-5-04-102350-2', year: 2019, pages: 448, publisherId: 1, authorIds: [11], genreIds: [3, 7], copiesTotal: 5, copiesAvailable: 3),
  Book(id: 19, title: 'Любовь во время чумы', isbn: '978-5-04-108143-4', year: 2020, pages: 448, publisherId: 1, authorIds: [11], genreIds: [3], copiesTotal: 2, copiesAvailable: 2),
  Book(id: 20, title: 'Старик и море', isbn: '978-5-17-088769-1', year: 2014, pages: 160, publisherId: 2, authorIds: [12], genreIds: [3, 8], copiesTotal: 6, copiesAvailable: 6),
  Book(id: 21, title: 'Прощай, оружие!', isbn: '978-5-17-094145-0', year: 2016, pages: 352, publisherId: 2, authorIds: [12], genreIds: [3, 4], copiesTotal: 3, copiesAvailable: 2),
  Book(id: 22, title: 'Анна Каренина', isbn: '978-5-04-116611-7', year: 2018, pages: 864, publisherId: 1, authorIds: [1], genreIds: [3], copiesTotal: 4, copiesAvailable: 4),
  Book(id: 23, title: 'Идиот', isbn: '978-5-04-118566-8', year: 2020, pages: 640, publisherId: 1, authorIds: [2], genreIds: [3], copiesTotal: 3, copiesAvailable: 2),
  Book(id: 24, title: 'Белая гвардия', isbn: '978-5-17-118899-7', year: 2021, pages: 352, publisherId: 2, authorIds: [3], genreIds: [3, 4], copiesTotal: 2, copiesAvailable: 2),
  Book(id: 25, title: 'Пиковая дама', isbn: '978-5-389-11876-1', year: 2017, pages: 192, publisherId: 3, authorIds: [4], genreIds: [6], copiesTotal: 5, copiesAvailable: 5),
  Book(id: 26, title: 'Капитанская дочка', isbn: '978-5-389-12877-8', year: 2019, pages: 224, publisherId: 3, authorIds: [4], genreIds: [3, 4], copiesTotal: 4, copiesAvailable: 3),
  Book(id: 27, title: 'Чистый код', isbn: '978-5-4461-0960-9', year: 2019, pages: 464, publisherId: 4, authorIds: [13], genreIds: [5], copiesTotal: 3, copiesAvailable: 2),
  Book(id: 28, title: 'Дюна', isbn: '978-5-17-134901-6', year: 2021, pages: 800, publisherId: 2, authorIds: [14], genreIds: [1, 8], copiesTotal: 7, copiesAvailable: 4),
  Book(id: 29, title: 'Гарри Поттер и философский камень', isbn: '978-5-353-07783-6', year: 2020, pages: 432, publisherId: 7, authorIds: [15], genreIds: [7, 8], copiesTotal: 9, copiesAvailable: 7),
  Book(id: 30, title: 'Гарри Поттер и Тайная комната', isbn: '978-5-353-07784-3', year: 2019, pages: 480, publisherId: 7, authorIds: [15], genreIds: [7, 8], copiesTotal: 8, copiesAvailable: 6),
  Book(id: 31, title: 'Думай медленно… решай быстро', isbn: '978-5-17-080053-8', year: 2021, pages: 656, publisherId: 2, authorIds: [16], genreIds: [5], copiesTotal: 4, copiesAvailable: 3),
  Book(id: 32, title: 'Sapiens. Краткая история человечества', isbn: '978-5-00146-234-5', year: 2020, pages: 520, publisherId: 6, authorIds: [17], genreIds: [4, 5], copiesTotal: 6, copiesAvailable: 4),
  Book(id: 33, title: 'Homo Deus. Краткая история будущего', isbn: '978-5-00146-235-2', year: 2021, pages: 496, publisherId: 6, authorIds: [17], genreIds: [4, 5], copiesTotal: 3, copiesAvailable: 2),
  Book(id: 34, title: 'Американские боги', isbn: '978-5-17-134900-9', year: 2020, pages: 640, publisherId: 2, authorIds: [18], genreIds: [7, 1], copiesTotal: 5, copiesAvailable: 3),
  Book(id: 35, title: 'Никогде', isbn: '978-5-00146-236-9', year: 2019, pages: 448, publisherId: 6, authorIds: [18], genreIds: [7, 8], copiesTotal: 2, copiesAvailable: 2),
];
