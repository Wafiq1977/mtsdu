 class Grade {
  final String id;
  final String studentId;
  final String subject;
  final String assignment;
  final double score;
  final String date;
  final String teacherId;

  Grade({
    required this.id,
    required this.studentId,
    required this.subject,
    required this.assignment,
    required this.score,
    required this.date,
    required this.teacherId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'subject': subject,
      'assignment': assignment,
      'score': score,
      'date': date,
      'teacherId': teacherId,
    };
  }

  factory Grade.fromMap(Map<String, dynamic> map) {
    return Grade(
      id: map['id'],
      studentId: map['studentId'],
      subject: map['subject'],
      assignment: map['assignment'],
      score: map['score'],
      date: map['date'],
      teacherId: map['teacherId'],
    );
  }
}
