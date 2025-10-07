import '../models/user.dart';
import '../models/schedule.dart';
import '../models/grade.dart';
import '../models/attendance.dart';
import '../models/assignment.dart';
import '../models/announcement.dart';
import 'user_service.dart';
import 'schedule_service.dart';
import 'grade_service.dart';
import 'attendance_service.dart';
import 'assignment_service.dart';
import 'announcement_service.dart';

class TeacherService {
  final UserService _userService = UserService();
  final ScheduleService _scheduleService = ScheduleService();
  final GradeService _gradeService = GradeService();
  final AttendanceService _attendanceService = AttendanceService();
  final AssignmentService _assignmentService = AssignmentService();
  final AnnouncementService _announcementService = AnnouncementService();

  Future<List<User>> getAllTeachers() async {
    return _userService.getTeachers();
  }

  Future<User?> getTeacherById(String id) async {
    return _userService.getUserById(id);
  }

  Future<List<Schedule>> getTeacherSchedules(String teacherId) async {
    return _scheduleService.getSchedulesByTeacher(teacherId);
  }

  Future<List<Grade>> getTeacherGrades(String teacherId) async {
    return _gradeService.getGradesByTeacher(teacherId);
  }

  Future<List<Attendance>> getTeacherAttendance(String teacherId) async {
    return _attendanceService.getAttendancesByTeacher(teacherId);
  }

  Future<List<Assignment>> getTeacherAssignments(String teacherId) async {
    return _assignmentService.getAssignmentsByTeacher(teacherId);
  }

  Future<List<Announcement>> getTeacherAnnouncements(String teacherId) async {
    return _announcementService.getAnnouncementsByAuthor(teacherId);
  }

  Future<List<String>> getTeacherSubjects(String teacherId) async {
    final schedules = await getTeacherSchedules(teacherId);
    return schedules.map((schedule) => schedule.subject).toSet().toList();
  }

  Future<List<String>> getTeacherClasses(String teacherId) async {
    final schedules = await getTeacherSchedules(teacherId);
    return schedules.map((schedule) => schedule.className).toSet().toList();
  }

  Future<Map<String, dynamic>> getTeacherDashboardData(String teacherId) async {
    final teacher = await getTeacherById(teacherId);
    final schedules = await getTeacherSchedules(teacherId);
    final assignments = await getTeacherAssignments(teacherId);
    final announcements = await getTeacherAnnouncements(teacherId);

    return {
      'teacher': teacher,
      'schedules': schedules,
      'assignments': assignments,
      'announcements': announcements,
      'subjects': await getTeacherSubjects(teacherId),
      'classes': await getTeacherClasses(teacherId),
    };
  }

  Future<void> addGrade(Grade grade) async {
    await _gradeService.addGrade(grade);
  }

  Future<void> updateGrade(Grade grade) async {
    await _gradeService.updateGrade(grade);
  }

  Future<void> addAttendance(Attendance attendance) async {
    await _attendanceService.addAttendance(attendance);
  }

  Future<void> updateAttendance(Attendance attendance) async {
    await _attendanceService.updateAttendance(attendance);
  }

  Future<void> addAssignment(Assignment assignment) async {
    await _assignmentService.addAssignment(assignment);
  }

  Future<void> updateAssignment(Assignment assignment) async {
    await _assignmentService.updateAssignment(assignment);
  }

  Future<void> addAnnouncement(Announcement announcement) async {
    await _announcementService.addAnnouncement(announcement);
  }

  Future<void> updateAnnouncement(Announcement announcement) async {
    await _announcementService.updateAnnouncement(announcement);
  }
}
