import '../model/user.dart';
import '../model/grade.dart';
import '../model/attendance.dart';
import '../model/payment.dart';
import 'user_service.dart';
import 'grade_service.dart';
import 'attendance_service.dart';
import 'payment_service.dart';

class StudentService {
  final UserService _userService = UserService();
  final GradeService _gradeService = GradeService();
  final AttendanceService _attendanceService = AttendanceService();
  final PaymentService _paymentService = PaymentService();

  Future<List<User>> getAllStudents() async {
    return _userService.getStudents();
  }

  Future<User?> getStudentById(String id) async {
    return _userService.getUserById(id);
  }

  Future<List<Grade>> getStudentGrades(String studentId) async {
    return _gradeService.getGradesByStudent(studentId);
  }

  Future<double> getStudentAverageGrade(String studentId) async {
    return _gradeService.getAverageGradeByStudent(studentId);
  }

  Future<List<Attendance>> getStudentAttendance(String studentId) async {
    return _attendanceService.getAttendancesByStudent(studentId);
  }

  Future<Map<String, int>> getStudentAttendanceStats(String studentId) async {
    return _attendanceService.getAttendanceStatsByStudent(studentId);
  }

  Future<double> getStudentAttendancePercentage(String studentId) async {
    return _attendanceService.getAttendancePercentageByStudent(studentId);
  }

  Future<List<Payment>> getStudentPayments(String studentId) async {
    return _paymentService.getPaymentsByStudent(studentId);
  }

  Future<Map<String, double>> getStudentPaymentStats(String studentId) async {
    return _paymentService.getPaymentStatsByStudent(studentId);
  }

  Future<List<User>> getStudentsByClass(String className) async {
    final students = await getAllStudents();
    return students.where((student) => student.className == className).toList();
  }

  Future<List<User>> getStudentsByMajor(String major) async {
    final students = await getAllStudents();
    return students.where((student) => student.major == major).toList();
  }

  Future<Map<String, dynamic>> getStudentDashboardData(String studentId) async {
    final student = await getStudentById(studentId);
    final grades = await getStudentGrades(studentId);
    final attendanceStats = await getStudentAttendanceStats(studentId);
    final payments = await getStudentPayments(studentId);

    return {
      'student': student,
      'grades': grades,
      'attendanceStats': attendanceStats,
      'payments': payments,
      'averageGrade': await getStudentAverageGrade(studentId),
      'attendancePercentage': await getStudentAttendancePercentage(studentId),
    };
  }
}
