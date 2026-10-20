class StudioHall {
  final int id;
  final String name;
  final String code;
  final String style;
  final int capacity;
  final int hourlyRate;
  final List<int> equipmentIds;
  final DateTime? deletedAt;

  const StudioHall({
    required this.id, required this.name, required this.code, required this.style,
    required this.capacity, required this.hourlyRate, required this.equipmentIds,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  StudioHall copyWith({String? name, String? code, String? style, int? capacity,
      int? hourlyRate, List<int>? equipmentIds, DateTime? deletedAt,
      bool clearDeletedAt = false}) => StudioHall(
    id: id, name: name ?? this.name, code: code ?? this.code,
    style: style ?? this.style, capacity: capacity ?? this.capacity,
    hourlyRate: hourlyRate ?? this.hourlyRate,
    equipmentIds: equipmentIds ?? this.equipmentIds,
    deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
  );
}
