/// Условия отбора, сортировки и постраничного вывода для списка авторов.
class AuthorQuery {
  static const _unset = Object();

  static const List<int> allowedSizes = [10, 25, 50];
  static const List<String> sortFields = [
    'lastName',
    'firstName',
    'country',
    'birthYear',
  ];

  final String search;
  final String? country;
  final int? yearFrom;
  final int? yearTo;
  final String sortField;
  final bool sortAscending;
  final int page;
  final int size;
  final bool includeDeleted;

  const AuthorQuery({
    this.search = '',
    this.country,
    this.yearFrom,
    this.yearTo,
    this.sortField = 'lastName',
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
  });

  factory AuthorQuery.fromUri(Uri uri) {
    final p = uri.queryParameters;
    final sort = (p['sort'] ?? '').split(',');
    final field =
        sort.isNotEmpty && sortFields.contains(sort.first) ? sort.first : 'lastName';
    final ascending = sort.length < 2 || sort[1] != 'desc';
    final size = int.tryParse(p['size'] ?? '') ?? 10;
    final page = int.tryParse(p['page'] ?? '') ?? 1;

    return AuthorQuery(
      search: p['search'] ?? '',
      country: (p['country'] != null && p['country']!.isNotEmpty)
          ? p['country']
          : null,
      yearFrom: int.tryParse(p['yearFrom'] ?? ''),
      yearTo: int.tryParse(p['yearTo'] ?? ''),
      sortField: field,
      sortAscending: ascending,
      page: page < 1 ? 1 : page,
      size: allowedSizes.contains(size) ? size : 10,
      includeDeleted: p['includeDeleted'] == 'true',
    );
  }

  Map<String, String> toQueryParameters() {
    final p = <String, String>{};
    if (search.trim().isNotEmpty) p['search'] = search.trim();
    if (country != null) p['country'] = country!;
    if (yearFrom != null) p['yearFrom'] = '$yearFrom';
    if (yearTo != null) p['yearTo'] = '$yearTo';
    if (sortField != 'lastName' || !sortAscending) {
      p['sort'] = '$sortField,${sortAscending ? 'asc' : 'desc'}';
    }
    if (page != 1) p['page'] = '$page';
    if (size != 10) p['size'] = '$size';
    if (includeDeleted) p['includeDeleted'] = 'true';
    return p;
  }

  AuthorQuery copyWith({
    String? search,
    Object? country = _unset,
    Object? yearFrom = _unset,
    Object? yearTo = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) {
    return AuthorQuery(
      search: search ?? this.search,
      country: country == _unset ? this.country : country as String?,
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
      country != null ||
      yearFrom != null ||
      yearTo != null ||
      includeDeleted;

  @override
  bool operator ==(Object other) =>
      other is AuthorQuery &&
      other.search == search &&
      other.country == country &&
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
        country,
        yearFrom,
        yearTo,
        sortField,
        sortAscending,
        page,
        size,
        includeDeleted,
      );
}
