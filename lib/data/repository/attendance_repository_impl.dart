import '../../../domain/entity/attendance_entity.dart';
import '../../domain/repository/attendance_repository.dart';
import '../../domain/entity/attendance_entity.dart';
import '../model/attendance.dart' as model;
import '../source/hive_service.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  @override
  Future<List<AttendanceEntity>> getAllAttendances() async {
    final box = HiveService.getAttendanceBox();
    return box.values
        .map(
          (e) => _mapModelToEntity(
            model.Attendance.fromMap(Map<String, dynamic>.from(e)),
          ),
        )
        .toList();
  }

  @override
  Future<AttendanceEntity?> getAttendanceById(String id) async {
    final box = HiveService.getAttendanceBox();
    final attendanceMap = box.get(id);
    if (attendanceMap != null) {
      return _mapModelToEntity(
        model.Attendance.fromMap(Map<String, dynamic>.from(attendanceMap)),
      );
    }
    return null;
  }

  @override
  Future<List<AttendanceEntity>> getAttendancesByStudent(
    String studentId,
  ) async {
    final attendances = await getAllAttendances();
    return attendances
        .where((attendance) => attendance.studentId == studentId)
        .toList();
  }

  @override
  Future<List<AttendanceEntity>> getAttendancesBySubject(String subject) async {
    final attendances = await getAllAttendances();
    return attendances
        .where((attendance) => attendance.subject == subject)
        .toList();
  }

  @override
  Future<List<AttendanceEntity>> getAttendancesByTeacher(
    String teacherId,
  ) async {
    final attendances = await getAllAttendances();
    return attendances
        .where((attendance) => attendance.teacherId == teacherId)
        .toList();
  }

  @override
  Future<List<AttendanceEntity>> getAttendancesByDate(String date) async {
    final attendances = await getAllAttendances();
    return attendances.where((attendance) => attendance.date == date).toList();
  }

  @override
  Future<Map<String, int>> getAttendanceStatsByStudent(String studentId) async {
    final attendances = await getAttendancesByStudent(studentId);
    int present = 0;
    int absent = 0;
    int late = 0;
    for (final attendance in attendances) {
      switch (attendance.status) {
        case AttendanceStatus.present:
          present++;
          break;
        case AttendanceStatus.absent:
          absent++;
          break;
        case AttendanceStatus.late:
          late++;
          break;
        default:
          break;
      }
    }
    return {
      'present': present,
      'absent': absent,
      'late': late,
      'total': attendances.length,
    };
  }

  @override
  Future<double> getAttendancePercentageByStudent(String studentId) async {
    final stats = await getAttendanceStatsByStudent(studentId);
    final total = stats['total'] ?? 0;
    if (total == 0) return 0.0;
    final present = stats['present'] ?? 0;
    return (present / total) * 100;
  }

  @override
  Future<void> addAttendance(AttendanceEntity attendance) async {
    final box = HiveService.getAttendanceBox();
    await box.put(attendance.id, _mapEntityToModel(attendance).toMap());
  }

  @override
  Future<void> updateAttendance(AttendanceEntity attendance) async {
    final box = HiveService.getAttendanceBox();
    await box.put(attendance.id, _mapEntityToModel(attendance).toMap());
  }

  @override
  Future<void> deleteAttendance(String id) async {
    final box = HiveService.getAttendanceBox();
    await box.delete(id);
  }

  AttendanceEntity _mapModelToEntity(model.Attendance attendance) {
    return AttendanceEntity(
      id: attendance.id,
      studentId: attendance.studentId,
      subject: attendance.subject,
      date: attendance.date,
      status: attendance.status,
      teacherId: attendance.teacherId,
    );
  }

  model.Attendance _mapEntityToModel(AttendanceEntity attendance) {
    return model.Attendance(
      id: attendance.id,
      studentId: attendance.studentId,
      subject: attendance.subject,
      date: attendance.date,
      status: attendance.status,
      teacherId: attendance.teacherId,
    );
  }
}
