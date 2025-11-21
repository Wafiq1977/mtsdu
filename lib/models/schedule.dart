import 'base_model.dart';

enum ScheduleType {
  teacher,
  student,
}

class Schedule extends BaseModel {
  String _subject;
  String _assignedToId; // Can be teacherId or studentId
  String _className;
  String _day;
  String _time;
  String _room;
  ScheduleType _scheduleType;
<<<<<<< HEAD
=======
  String? _major; // TAMBAH INI
  String? _grade; // TAMBAH INI
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb

  Schedule({
    required String id,
    required String subject,
    required String assignedToId,
    required String className,
    required String day,
    required String time,
    required String room,
    required ScheduleType scheduleType,
<<<<<<< HEAD
=======
    String? major, // TAMBAH INI
    String? grade, // TAMBAH INI
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
  })  : _subject = subject,
        _assignedToId = assignedToId,
        _className = className,
        _day = day,
        _time = time,
        _room = room,
        _scheduleType = scheduleType,
<<<<<<< HEAD
=======
        _major = major, // TAMBAH INI
        _grade = grade, // TAMBAH INI
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
        super(id: id);

  // Getters
  String get subject => _subject;
  String get assignedToId => _assignedToId;
  String get className => _className;
  String get day => _day;
  String get time => _time;
  String get room => _room;
  ScheduleType get scheduleType => _scheduleType;
<<<<<<< HEAD
=======
  String? get major => _major; // TAMBAH INI
  String? get grade => _grade; // TAMBAH INI
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb

  // Setters
  set subject(String value) => _subject = value;
  set assignedToId(String value) => _assignedToId = value;
  set className(String value) => _className = value;
  set day(String value) => _day = value;
  set time(String value) => _time = value;
  set room(String value) => _room = value;
  set scheduleType(ScheduleType value) => _scheduleType = value;
<<<<<<< HEAD
=======
  set major(String? value) => _major = value; // TAMBAH INI
  set grade(String? value) => _grade = value; // TAMBAH INI
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': _subject,
      'assignedToId': _assignedToId,
      'className': _className,
      'day': _day,
      'time': _time,
      'room': _room,
      'scheduleType': _scheduleType.toString().split('.').last,
<<<<<<< HEAD
=======
      'major': _major, // TAMBAH INI
      'grade': _grade, // TAMBAH INI
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'],
      subject: map['subject'],
      assignedToId: map['assignedToId'] ?? map['teacherId'] ?? '', // Backward compatibility
      className: map['className'],
      day: map['day'],
      time: map['time'],
      room: map['room'],
      scheduleType: ScheduleType.values.firstWhere(
        (e) => e.toString().split('.').last == (map['scheduleType'] ?? 'teacher'),
        orElse: () => ScheduleType.teacher,
      ),
<<<<<<< HEAD
    );
  }
}
=======
      major: map['major'], // TAMBAH INI
      grade: map['grade'], // TAMBAH INI
    );
  }
}
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
