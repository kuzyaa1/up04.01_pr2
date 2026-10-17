/// Страница результатов постраничной выборки.
///
/// Структура намеренно повторяет оболочку ответа учебного API, поэтому
/// в ПР4 достаточно заменить источник данных, а экраны останутся прежними.
class PageResult<T> {
  final List<T> items;
  final int page;
  final int size;
  final int total;

  const PageResult({
    required this.items,
    required this.page,
    required this.size,
    required this.total,
  });

  int get totalPages => total == 0 ? 1 : (total / size).ceil();
  bool get hasPrevious => page > 1;
  bool get hasNext => page < totalPages;

  /// Пустая страница — начальное значение состояния экрана.
  ///
  /// Конструктор намеренно не `const`: пустой константный список с
  /// параметром типа `T` в Dart запрещён, поэтому используется `<T>[]`.
  PageResult.empty()
      : items = <T>[],
        page = 1,
        size = 10,
        total = 0;
}
