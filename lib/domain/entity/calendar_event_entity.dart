enum EventType {
  academic,
  holiday,
  exam,
  meeting,
  reminder,
}

class CalendarEventEntity {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final String location;
  final EventType type;
  final String createdBy;
  final DateTime createdAt;

  const CalendarEventEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.location,
    required this.type,
    required this.createdBy,
    required this.createdAt,
  });

  CalendarEventEntity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    EventType? type,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return CalendarEventEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      type: type ?? this.type,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}