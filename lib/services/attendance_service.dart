import '../models/attendance.dart';
import 'hive_service.dart';

class AttendanceService {
  Future<List<Attendance>> getAllAttendances() async {
    final box = HiveService.getAttendanceBox();
<<<<<<< HEAD
    return box.values
        .map((e) => Attendance.fromMap(Map<String, dynamic>.from(e)))
        .toList();
=======
    return box.values.map((e) => Attendance.fromMap(Map<String, dynamic>.from(e))).toList();
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
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
<<<<<<< HEAD
    final attendances = box.values
        .map((e) => Attendance.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    return attendances
        .where((attendance) => attendance.studentId == studentId)
        .toList();
=======
    final attendances = box.values.map((e) => Attendance.fromMap(Map<String, dynamic>.from(e))).toList();
    return attendances.where((attendance) => attendance.studentId == studentId).toList();
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
  }

  Future<List<Attendance>> getAttendancesBySubject(String subject) async {
    final box = HiveService.getAttendanceBox();
<<<<<<< HEAD
    final attendances = box.values
        .map((e) => Attendance.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    return attendances
        .where((attendance) => attendance.subject == subject)
        .toList();
=======
    final attendances = box.values.map((e) => Attendance.fromMap(Map<String, dynamic>.from(e))).toList();
    return attendances.where((attendance) => attendance.subject == subject).toList();
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
  }

  Future<List<Attendance>> getAttendancesByTeacher(String teacherId) async {
    final box = HiveService.getAttendanceBox();
<<<<<<< HEAD
    final attendances = box.values
        .map((e) => Attendance.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    return attendances
        .where((attendance) => attendance.teacherId == teacherId)
        .toList();
=======
    final attendances = box.values.map((e) => Attendance.fromMap(Map<String, dynamic>.from(e))).toList();
    return attendances.where((attendance) => attendance.teacherId == teacherId).toList();
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
  }

  Future<List<Attendance>> getAttendancesByDate(String date) async {
    final box = HiveService.getAttendanceBox();
<<<<<<< HEAD
    final attendances = box.values
        .map((e) => Attendance.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    return attendances.where((attendance) => attendance.date == date).toList();
  }

  // --- BAGIAN YANG DIPERBAIKI ADA DI SINI ---
=======
    final attendances = box.values.map((e) => Attendance.fromMap(Map<String, dynamic>.from(e))).toList();
    return attendances.where((attendance) => attendance.date == date).toList();
  }

>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
  Future<Map<String, int>> getAttendanceStatsByStudent(String studentId) async {
    final attendances = await getAttendancesByStudent(studentId);
    int present = 0;
    int absent = 0;
    int late = 0;
<<<<<<< HEAD
    int excused = 0; // 1. Tambah variabel untuk Izin/Sakit
=======
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb

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
<<<<<<< HEAD
        case AttendanceStatus.excused: // 2. Tambah case untuk Excused
          excused++;
          break;
=======
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
      }
    }

    return {
      'present': present,
      'absent': absent,
      'late': late,
<<<<<<< HEAD
      'excused': excused, // 3. Masukkan ke output
=======
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
      'total': attendances.length,
    };
  }

  Future<double> getAttendancePercentageByStudent(String studentId) async {
    final stats = await getAttendanceStatsByStudent(studentId);
    final total = stats['total'] ?? 0;
    if (total == 0) return 0.0;
<<<<<<< HEAD

    final present = stats['present'] ?? 0;
    // Opsional: Kamu bisa menambahkan logika jika 'late' atau 'excused' mau dihitung sebagian
    // Contoh: final score = present + (stats['late']! * 0.5);

=======
    final present = stats['present'] ?? 0;
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
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
