/// Условия отбора, сортировки и постраничного вывода для списка книг.
///
/// Все параметры собраны в один неизменяемый объект: так их удобнее
/// передавать по слоям и целиком класть в адрес страницы.
class BookQuery {
  static const _unset = Object();

  /// Размеры страницы, доступные пользователю.
  static const List<int> allowedSizes = [10, 25, 50];

  /// Поля, по которым разрешена сортировка.
  static const List<String> sortFields = ['title', 'year', 'pages', 'isbn'];

  final String search;
  final int? genreId;
  final int? publisherId;
  final int? yearFrom;
  final int? yearTo;
  final String sortField;
  final bool sortAscending;
  final int page;
  final int size;
  final bool includeDeleted;

  const BookQuery({
    this.search = '',
    this.genreId,
    this.publisherId,
    this.yearFrom,
    this.yearTo,
    this.sortField = 'title',
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
  });

  /// Восстанавливает условия отбора из адреса страницы.
  factory BookQuery.fromUri(Uri uri) {
    final p = uri.queryParameters;
    final sort = (p['sort'] ?? '').split(',');
    final field =
        sort.isNotEmpty && sortFields.contains(sort.first) ? sort.first : 'title';
    final ascending = sort.length < 2 || sort[1] != 'desc';
    final size = int.tryParse(p['size'] ?? '') ?? 10;
    final page = int.tryParse(p['page'] ?? '') ?? 1;

    return BookQuery(
      search: p['search'] ?? '',
      genreId: int.tryParse(p['genreId'] ?? ''),
      publisherId: int.tryParse(p['publisherId'] ?? ''),
      yearFrom: int.tryParse(p['yearFrom'] ?? ''),
      yearTo: int.tryParse(p['yearTo'] ?? ''),
      sortField: field,
      sortAscending: ascending,
      page: page < 1 ? 1 : page,
      size: allowedSizes.contains(size) ? size : 10,
      includeDeleted: p['includeDeleted'] == 'true',
    );
  }

  /// Преобразует условия отбора в параметры адреса.
  ///
  /// Значения по умолчанию в адрес не попадают — ссылка остаётся короткой.
  Map<String, String> toQueryParameters() {
    final p = <String, String>{};
    if (search.trim().isNotEmpty) p['search'] = search.trim();
    if (genreId != null) p['genreId'] = '$genreId';
    if (publisherId != null) p['publisherId'] = '$publisherId';
    if (yearFrom != null) p['yearFrom'] = '$yearFrom';
    if (yearTo != null) p['yearTo'] = '$yearTo';
    if (sortField != 'title' || !sortAscending) {
      p['sort'] = '$sortField,${sortAscending ? 'asc' : 'desc'}';
    }
    if (page != 1) p['page'] = '$page';
    if (size != 10) p['size'] = '$size';
    if (includeDeleted) p['includeDeleted'] = 'true';
    return p;
  }

  /// Копия с изменёнными условиями.
  ///
  /// Обратите внимание на `page ?? 1`: при смене любого условия отбора
  /// список обязан вернуться на первую страницу, иначе пользователь,
  /// стоящий на седьмой странице, после ввода поискового запроса увидит
  /// пустой экран.
  BookQuery copyWith({
    String? search,
    Object? genreId = _unset,
    Object? publisherId = _unset,
    Object? yearFrom = _unset,
    Object? yearTo = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) {
    return BookQuery(
      search: search ?? this.search,
      genreId: genreId == _unset ? this.genreId : genreId as int?,
      publisherId: publisherId == _unset ? this.publisherId : publisherId as int?,
      yearFrom: yearFrom == _unset ? this.yearFrom : yearFrom as int?,
      yearTo: yearTo == _unset ? this.yearTo : yearTo as int?,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? 1,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }

  bool get hasActiveFilters =>
      search.trim().isNotEmpty ||
      genreId != null ||
      publisherId != null ||
      yearFrom != null ||
      yearTo != null ||
      includeDeleted;

  @override
  bool operator ==(Object other) =>
      other is BookQuery &&
      other.search == search &&
      other.genreId == genreId &&
      other.publisherId == publisherId &&
      other.yearFrom == yearFrom &&
      other.yearTo == yearTo &&
      other.sortField == sortField &&
      other.sortAscending == sortAscending &&
      other.page == page &&
      other.size == size &&
      other.includeDeleted == includeDeleted;

  @override
  int get hashCode => Object.hash(
        search,
        genreId,
        publisherId,
        yearFrom,
        yearTo,
        sortField,
        sortAscending,
        page,
        size,
        includeDeleted,
      );
}
