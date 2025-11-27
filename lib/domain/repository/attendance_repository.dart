import '../entity/attendance_entity.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceEntity>> getAllAttendances();
  Future<AttendanceEntity?> getAttendanceById(String id);
  Future<List<AttendanceEntity>> getAttendancesByStudent(String studentId);
  Future<List<AttendanceEntity>> getAttendancesBySubject(String subject);
  Future<List<AttendanceEntity>> getAttendancesByTeacher(String teacherId);
  Future<List<AttendanceEntity>> getAttendancesByDate(String date);
  Future<Map<String, int>> getAttendanceStatsByStudent(String studentId);
  Future<double> getAttendancePercentageByStudent(String studentId);
  Future<void> addAttendance(AttendanceEntity attendance);
  Future<void> updateAttendance(AttendanceEntity attendance);
  Future<void> deleteAttendance(String id);
}
