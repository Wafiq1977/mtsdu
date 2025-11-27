enum AttendanceStatus { present, absent, late }

class AttendanceEntity {
  final String id;
  final String studentId;
  final String subject;
  final String date;
  final AttendanceStatus status;
  final String teacherId;

  AttendanceEntity({
    required this.id,
    required this.studentId,
    required this.subject,
    required this.date,
    required this.status,
    required this.teacherId,
  });
}
