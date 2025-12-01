import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String userBox = 'users';
  static const String scheduleBox = 'schedules';
  static const String gradeBox = 'grades';
  static const String attendanceBox = 'attendances';
  static const String assignmentBox = 'assignments';
  static const String assignmentSubmissionBox = 'assignment_submissions';
  static const String announcementBox = 'announcements';
  static const String paymentBox = 'payments';
  static const String calendarEventBox = 'calendar_events'; // TAMBAH INI
  static const String materialBox = 'materials'; // TAMBAH INI

  static Future<void> init() async {
    await Hive.initFlutter();
    // Register adapters here if needed in the future
    await Hive.openBox(userBox);
    await Hive.openBox(scheduleBox);
    await Hive.openBox(gradeBox);
    await Hive.openBox(attendanceBox);
    await Hive.openBox(assignmentBox);
    await Hive.openBox(assignmentSubmissionBox);
    await Hive.openBox(announcementBox);
    await Hive.openBox(paymentBox);
    await Hive.openBox(calendarEventBox); // TAMBAH INI
    await Hive.openBox(materialBox); // TAMBAH INI
  }

  static Box getUserBox() {
    return Hive.box(userBox);
  }

  static Box getScheduleBox() {
    return Hive.box(scheduleBox);
  }

  static Box getGradeBox() {
    return Hive.box(gradeBox);
  }

  static Box getAttendanceBox() {
    return Hive.box(attendanceBox);
  }

  static Box getAssignmentBox() {
    return Hive.box(assignmentBox);
  }

  static Box getAnnouncementBox() {
    return Hive.box(announcementBox);
  }

  static Box getPaymentBox() {
    return Hive.box(paymentBox);
  }

  static Box getCalendarEventBox() {
    return Hive.box(calendarEventBox);
  }

  // TAMBAH INI - Materials Box
  static Box getMaterialBox() {
    return Hive.box(materialBox);
  }
}
