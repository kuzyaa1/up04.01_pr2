class Photographer {
  final int id;
  final String firstName;
  final String lastName;
  final String specialization;
  final int experienceYears;
  final int hourlyRate;
  final DateTime? deletedAt;

  const Photographer({required this.id, required this.firstName, required this.lastName,
    required this.specialization, required this.experienceYears, required this.hourlyRate,
    this.deletedAt});

  String get fullName => '$lastName $firstName';
  bool get isDeleted => deletedAt != null;

  Photographer copyWith({String? firstName, String? lastName, String? specialization,
      int? experienceYears, int? hourlyRate, DateTime? deletedAt,
      bool clearDeletedAt = false}) => Photographer(
    id: id, firstName: firstName ?? this.firstName, lastName: lastName ?? this.lastName,
    specialization: specialization ?? this.specialization,
    experienceYears: experienceYears ?? this.experienceYears,
    hourlyRate: hourlyRate ?? this.hourlyRate,
    deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
  );
}
