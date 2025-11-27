enum ScheduleType {
  teacher,
  student,
}

class ScheduleEntity {
  final String id;
  final String subject;
  final String assignedToId; // Can be teacherId or studentId
  final String className;
  final String day;
  final String time;
  final String room;
  final ScheduleType scheduleType;
  final String? major;
  final String? grade;

  ScheduleEntity({
    required this.id,
    required this.subject,
    required this.assignedToId,
    required this.className,
    required this.day,
    required this.time,
    required this.room,
    required this.scheduleType,
    this.major,
    this.grade,
  });
}
