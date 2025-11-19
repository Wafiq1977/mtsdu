import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'services/hive_service.dart';
import 'providers/auth_provider.dart';
import 'providers/data_provider.dart';
import 'providers/theme_provider.dart';
import 'routes/app_router.dart';
import 'models/user.dart';
import 'models/schedule.dart';
import 'models/grade.dart';
import 'models/attendance.dart';
import 'models/assignment.dart';
import 'models/announcement.dart';
import 'models/payment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await HiveService.init();
  await _addSampleData();
  runApp(const MyApp());
}

Future<void> _addSampleData() async {
  final userBox = HiveService.getUserBox();
  if (userBox.isEmpty) {
    // Add sample users
    final student = User(
      id: '1',
      username: 'student1',
      password: 'pass',
      role: UserRole.student,
      name: 'John Doe',
      className: '10A',
      major: 'IPA',
    );
    final teacher = User(
      id: '2',
      username: 'teacher1',
      password: 'pass',
      role: UserRole.teacher,
      name: 'Jane Smith',
      nip: '123456',
      subject: 'Mathematics',
    );
    final admin = User(
      id: '3',
      username: 'admin',
      password: 'admin',
      role: UserRole.admin,
      name: 'Admin User',
    );
    await userBox.put(student.id, student.toMap());
    await userBox.put(teacher.id, teacher.toMap());
    await userBox.put(admin.id, admin.toMap());
  }

  // Add sample schedules
  final scheduleBox = HiveService.getScheduleBox();
  if (scheduleBox.isEmpty) {
    final schedules = [
      Schedule(
        id: 's1',
        subject: 'Mathematics',
        assignedToId: '2',
        className: '10A',
        day: 'Monday',
        time: '08:00-09:00',
        room: '101',
        scheduleType: ScheduleType.teacher,
      ),
      Schedule(
        id: 's2',
        subject: 'Physics',
        assignedToId: '2',
        className: '10A',
        day: 'Tuesday',
        time: '09:00-10:00',
        room: '102',
        scheduleType: ScheduleType.teacher,
      ),
      Schedule(
        id: 's3',
        subject: 'Chemistry',
        assignedToId: '2',
        className: '10A',
        day: 'Wednesday',
        time: '10:00-11:00',
        room: '103',
        scheduleType: ScheduleType.teacher,
      ),
    ];
    for (final schedule in schedules) {
      await scheduleBox.put(schedule.id, schedule.toMap());
    }
  }

  // Add sample grades
  final gradeBox = HiveService.getGradeBox();
  if (gradeBox.isEmpty) {
    final grades = [
      Grade(
        id: 'g1',
        studentId: '1',
        subject: 'Mathematics',
        assignment: 'Quiz 1',
        score: 85.0,
        date: '2024-01-15',
        teacherId: '2',
      ),
      Grade(
        id: 'g2',
        studentId: '1',
        subject: 'Physics',
        assignment: 'Lab Report',
        score: 92.0,
        date: '2024-01-20',
        teacherId: '2',
      ),
    ];
    for (final grade in grades) {
      await gradeBox.put(grade.id, grade.toMap());
    }
  }

  // Add sample attendance
  final attendanceBox = HiveService.getAttendanceBox();
  if (attendanceBox.isEmpty) {
    final attendances = [
      Attendance(
        id: 'a1',
        studentId: '1',
        subject: 'Mathematics',
        date: '2024-01-15',
        status: AttendanceStatus.present,
        teacherId: '2',
      ),
      Attendance(
        id: 'a2',
        studentId: '1',
        subject: 'Physics',
        date: '2024-01-16',
        status: AttendanceStatus.present,
        teacherId: '2',
      ),
    ];
    for (final attendance in attendances) {
      await attendanceBox.put(attendance.id, attendance.toMap());
    }
  }

  // Add sample assignments
  final assignmentBox = HiveService.getAssignmentBox();
  if (assignmentBox.isEmpty) {
    final assignments = [
      Assignment(
        id: 'as1',
        title: 'Mathematics Homework!',
        description: 'Complete exercises 1-10 from chapter 5',
        subject: 'Mathematics',
        teacherId: '2',
        className: '10A',
        major: 'IPA',
        dueDate: '2024-01-25',
      ),
      Assignment(
        id: 'as2',
        title: 'Physics Lab Report',
        description: 'Write a report on the pendulum experiment',
        subject: 'Physics',
        teacherId: '2',
        className: '10A',
        major: 'IPA',
        dueDate: '2024-01-30',
      ),
    ];
    for (final assignment in assignments) {
      await assignmentBox.put(assignment.id, assignment.toMap());
    }
  }

  // Add sample announcements
  final announcementBox = HiveService.getAnnouncementBox();
  if (announcementBox.isEmpty) {
    final announcements = [
      Announcement(
        id: 'an1',
        title: 'School Holiday',
        content: 'School will be closed on Monday due to national holiday.',
        authorId: '3',
        date: DateTime.parse('2024-01-10'),
        targetRole: 'all',
      ),
      Announcement(
        id: 'an2',
        title: 'Exam Schedule',
        content: 'Mid-term exams will start next week. Check your schedules.',
        authorId: '3',
        date: DateTime.parse('2024-01-12'),
        targetRole: 'student',
      ),
    ];
    for (final announcement in announcements) {
      await announcementBox.put(announcement.id, announcement.toMap());
    }
  }

  // Add sample payments
  final paymentBox = HiveService.getPaymentBox();
  if (paymentBox.isEmpty) {
    final payments = [
      Payment(
        id: 'p1',
        studentId: '1',
        month: 'January',
        year: 2024,
        amount: 500000.0,
        status: PaymentStatus.paid,
        paymentDate: '2024-01-05',
      ),
      Payment(
        id: 'p2',
        studentId: '1',
        month: 'February',
        year: 2024,
        amount: 500000.0,
        status: PaymentStatus.unpaid,
      ),
    ];
    for (final payment in payments) {
      await paymentBox.put(payment.id, payment.toMap());
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'LPMMTSDU',
            theme: themeProvider.currentTheme,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
