<<<<<<< HEAD
enum AttendanceStatus { present, absent, late, excused }
=======
enum AttendanceStatus { present, absent, late }
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b

class Attendance {
  final String id;
  final String studentId;
  final String subject;
  final String date;
  final AttendanceStatus status;
  final String teacherId;

  Attendance({
    required this.id,
    required this.studentId,
    required this.subject,
    required this.date,
    required this.status,
    required this.teacherId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'subject': subject,
      'date': date,
      'status': status.index,
      'teacherId': teacherId,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      studentId: map['studentId'],
      subject: map['subject'],
      date: map['date'],
      status: AttendanceStatus.values[map['status']],
      teacherId: map['teacherId'],
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b
