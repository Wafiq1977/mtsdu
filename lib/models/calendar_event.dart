import 'base_model.dart';
import 'package:flutter/material.dart';
enum EventType {
  academic,
  holiday,
  exam,
  meeting,
  reminder,
}

class CalendarEvent extends BaseModel {
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final Color color;
  final EventType type;

  CalendarEvent({
    required String id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.color,
    required this.type,
  }) : super(id: id);

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'color': color.value,
      'type': type.toString(),
    };
  }

  factory CalendarEvent.fromMap(Map<String, dynamic> map) {
    return CalendarEvent(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      color: Color(map['color']),
      type: EventType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => EventType.academic,
      ),
    );
  }
}