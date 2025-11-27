import 'base_model.dart';
import '../../domain/entity/schedule_entity.dart';

class Schedule extends BaseModel {
  String _subject;
  String _assignedToId; // Can be teacherId or studentId
  String _className;
  String _day;
  String _time;
  String _room;
  ScheduleType _scheduleType;
  String? _major; // TAMBAH INI
  String? _grade; // TAMBAH INI

  Schedule({
    required String id,
    required String subject,
    required String assignedToId,
    required String className,
    required String day,
    required String time,
    required String room,
    required ScheduleType scheduleType,
    String? major, // TAMBAH INI
    String? grade, // TAMBAH INI
  })  : _subject = subject,
        _assignedToId = assignedToId,
        _className = className,
        _day = day,
        _time = time,
        _room = room,
        _scheduleType = scheduleType,
        _major = major, // TAMBAH INI
        _grade = grade, // TAMBAH INI
        super(id: id);

  // Getters
  String get subject => _subject;
  String get assignedToId => _assignedToId;
  String get className => _className;
  String get day => _day;
  String get time => _time;
  String get room => _room;
  ScheduleType get scheduleType => _scheduleType;
  String? get major => _major; // TAMBAH INI
  String? get grade => _grade; // TAMBAH INI

  // Setters
  set subject(String value) => _subject = value;
  set assignedToId(String value) => _assignedToId = value;
  set className(String value) => _className = value;
  set day(String value) => _day = value;
  set time(String value) => _time = value;
  set room(String value) => _room = value;
  set scheduleType(ScheduleType value) => _scheduleType = value;
  set major(String? value) => _major = value; // TAMBAH INI
  set grade(String? value) => _grade = value; // TAMBAH INI

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
      'major': _major, // TAMBAH INI
      'grade': _grade, // TAMBAH INI
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
      major: map['major'], // TAMBAH INI
      grade: map['grade'], // TAMBAH INI
    );
  }
}
