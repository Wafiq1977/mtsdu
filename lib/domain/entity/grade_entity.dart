class GradeEntity {
  final String id;
  final String studentId;
  final String subject;
  final String assignment;
  final double score;
  final String date;
  final String teacherId;

  GradeEntity({
    required this.id,
    required this.studentId,
    required this.subject,
    required this.assignment,
    required this.score,
    required this.date,
    required this.teacherId,
  });
}
