
import 'package:flutter/material.dart';

enum EventType { academic, holiday, exam, meeting, reminder }

class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final EventType type;
  final String? location;
  final String createdBy;
  final Color color;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.type,
    this.location,
    required this.createdBy,
    this.color = Colors.blue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'type': type.index,
      'location': location,
      'createdBy': createdBy,
      'color': color.toARGB32(),
    };
  }

  factory CalendarEvent.fromMap(Map<String, dynamic> map) {
    return CalendarEvent(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      type: EventType.values[map['type']],
      location: map['location'],
      createdBy: map['createdBy'],
      color: Color(map['color'] ?? Colors.blue.toARGB32()),
    );
  }
}
