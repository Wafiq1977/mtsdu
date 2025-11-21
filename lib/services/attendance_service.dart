import '../models/attendance.dart';
import 'hive_service.dart';

class AttendanceService {
  Future<List<Attendance>> getAllAttendances() async {
    final box = HiveService.getAttendanceBox();
    return box.values
        .map((e) => Attendance.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Attendance?> getAttendanceById(String id) async {
    final box = HiveService.getAttendanceBox();
    final attendanceMap = box.get(id);
    if (attendanceMap != null) {
      return Attendance.fromMap(Map<String, dynamic>.from(attendanceMap));
    }
    return null;
  }

  Future<List<Attendance>> getAttendancesByStudent(String studentId) async {
    final box = HiveService.getAttendanceBox();
    final attendances = box.values
        .map((e) => Attendance.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    return attendances
        .where((attendance) => attendance.studentId == studentId)
        .toList();
  }

  Future<List<Attendance>> getAttendancesBySubject(String subject) async {
    final box = HiveService.getAttendanceBox();
    final attendances = box.values
        .map((e) => Attendance.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    return attendances
        .where((attendance) => attendance.subject == subject)
        .toList();
  }

  Future<List<Attendance>> getAttendancesByTeacher(String teacherId) async {
    final box = HiveService.getAttendanceBox();
    final attendances = box.values
        .map((e) => Attendance.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    return attendances
        .where((attendance) => attendance.teacherId == teacherId)
        .toList();
  }

  Future<List<Attendance>> getAttendancesByDate(String date) async {
    final box = HiveService.getAttendanceBox();
    final attendances = box.values
        .map((e) => Attendance.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    return attendances.where((attendance) => attendance.date == date).toList();
  }

  // --- BAGIAN YANG DIPERBAIKI ADA DI SINI ---
  Future<Map<String, int>> getAttendanceStatsByStudent(String studentId) async {
    final attendances = await getAttendancesByStudent(studentId);
    int present = 0;
    int absent = 0;
    int late = 0;
    int excused = 0; // 1. Tambah variabel untuk Izin/Sakit

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
        case AttendanceStatus.excused: // 2. Tambah case untuk Excused
          excused++;
          break;
      }
    }

    return {
      'present': present,
      'absent': absent,
      'late': late,
      'excused': excused, // 3. Masukkan ke output
      'total': attendances.length,
    };
  }

  Future<double> getAttendancePercentageByStudent(String studentId) async {
    final stats = await getAttendanceStatsByStudent(studentId);
    final total = stats['total'] ?? 0;
    if (total == 0) return 0.0;

    final present = stats['present'] ?? 0;
    // Opsional: Kamu bisa menambahkan logika jika 'late' atau 'excused' mau dihitung sebagian
    // Contoh: final score = present + (stats['late']! * 0.5);

    return (present / total) * 100;
  }

  Future<void> addAttendance(Attendance attendance) async {
    final box = HiveService.getAttendanceBox();
    await box.put(attendance.id, attendance.toMap());
  }

  Future<void> updateAttendance(Attendance attendance) async {
    final box = HiveService.getAttendanceBox();
    await box.put(attendance.id, attendance.toMap());
  }

  Future<void> deleteAttendance(String id) async {
    final box = HiveService.getAttendanceBox();
    await box.delete(id);
  }
}
