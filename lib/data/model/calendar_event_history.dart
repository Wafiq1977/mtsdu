class CalendarEventHistory {
  final String id;
  final String eventId;
  final String action; // 'created', 'updated', 'deleted'
  final String userId;
  final DateTime timestamp;
  final Map<String, dynamic> oldData; // Data sebelum perubahan
  final Map<String, dynamic> newData; // Data setelah perubahan
  final String description; // Deskripsi perubahan

  CalendarEventHistory({
    required this.id,
    required this.eventId,
    required this.action,
    required this.userId,
    required this.timestamp,
    this.oldData = const {},
    this.newData = const {},
    required this.description,
  });

  factory CalendarEventHistory.fromMap(Map<String, dynamic> map) {
    return CalendarEventHistory(
      id: map['id'] as String,
      eventId: map['eventId'] as String,
      action: map['action'] as String,
      userId: map['userId'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      oldData: Map<String, dynamic>.from(map['oldData'] ?? {}),
      newData: Map<String, dynamic>.from(map['newData'] ?? {}),
      description: map['description'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'action': action,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'oldData': oldData,
      'newData': newData,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'CalendarEventHistory(id: $id, eventId: $eventId, action: $action, timestamp: $timestamp)';
  }
}