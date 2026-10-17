/// Автор книги.
class Author {
  final int id;
  final String firstName;
  final String lastName;
  final String country;
  final int birthYear;

  /// Дата логического удаления. `null` — запись активна.
  final DateTime? deletedAt;

  const Author({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.birthYear,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  String get fullName => '$lastName $firstName';

  /// Копия с изменёнными полями.
  ///
  /// [clearDeletedAt] позволяет снять логическое удаление: без него
  /// передать `null` в [deletedAt] и «не менять поле» неразличимо.
  Author copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? country,
    int? birthYear,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Author(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      country: country ?? this.country,
      birthYear: birthYear ?? this.birthYear,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}
