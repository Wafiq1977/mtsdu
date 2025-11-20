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
    // Add admin
    final admin = User(
      id: 'admin',
      username: 'admin',
      password: 'admin',
      role: UserRole.admin,
      name: 'Admin User',
    );
    await userBox.put(admin.id, admin.toMap());

    // Add 20 teachers
    final subjects = ['B. Indo', 'Matematika', 'B. Inggris', 'Agama', 'PKN', 'Olahraga', 'Sistem Komputer', 'Produk Kreatif dan Kewirausahaan', 'Arsitektur Jaringan dan Komputer', 'Desain Grafis Percetakan', 'Desain Media Interaktif', 'Teknik Animasi 2D dan 3D', 'Pemrograman Dasar', 'Basis Data', 'Pemrograman Perangkat Lunak', 'Otomatisasi Tata Kelola Perkantoran', 'Pengelolaan Sistem Informasi', 'Ekonomi dan Bisnis', 'Teknologi Dasar Otomotif', 'Pemeliharaan AC Kendaraan Ringan'];
    final teacherNames = ['Egin', 'Iqbal', 'Izaz', 'Ahmad', 'Budi', 'Cici', 'Dedi', 'Eka', 'Fani', 'Gina', 'Hadi', 'Ika', 'Joko', 'Kiki', 'Lina', 'Miko', 'Nina', 'Oki', 'Pipi', 'Rina'];
    for (int i = 1; i <= 20; i++) {
      final teacher = User(
        id: 'teacher$i',
        username: teacherNames[i - 1],
        password: 'pass',
        role: UserRole.teacher,
        name: teacherNames[i - 1],
        nip: 'NIP${i.toString().padLeft(3, '0')}',
        subject: subjects[i - 1],
      );
      await userBox.put(teacher.id, teacher.toMap());
    }

    // Add students for classes 10A, 11A, 12A for each major
    final majors = ['Multimedia', 'Rekayasa Perangkat Lunak', 'Teknik Komputer dan Jaringan', 'Manajemen', 'Teknik Kendaraan Ringan Otomotif'];
    final classes = [
      for (final major in majors)
        for (int grade = 10; grade <= 12; grade++)
          {'name': '${grade}A', 'major': major}
    ];
    final studentNames = ['Egin', 'Iqbal', 'Izaz', 'Ahmad', 'Budi', 'Cici', 'Dedi', 'Eka', 'Fani', 'Gina', 'Hadi', 'Ika', 'Joko', 'Kiki', 'Lina', 'Miko', 'Nina', 'Oki', 'Pipi', 'Rina', 'Sari', 'Tono', 'Umi', 'Vivi', 'Wawan', 'Xena', 'Yudi', 'Zara', 'Ali', 'Bella'];
    int studentId = 1;
    for (final classInfo in classes) {
      for (int j = 1; j <= 5; j++) {
        final name = studentNames[(studentId - 1) % studentNames.length];
        final username = '$name ${classInfo['name']}';
        final student = User(
          id: 'student$studentId',
          username: username,
          password: 'pass',
          role: UserRole.student,
          name: name,
          className: classInfo['name'],
          major: classInfo['major'],
        );
        await userBox.put(student.id, student.toMap());
        studentId++;
      }
    }
  }

  // Add sample schedules
  final scheduleBox = HiveService.getScheduleBox();
  if (scheduleBox.isEmpty) {
    final schedules = [
      Schedule(
        id: 's1',
        subject: 'B. Indo',
        assignedToId: 'Egin',
        className: '10A',
        day: 'Monday',
        time: '08:00-09:00',
        room: '101',
        scheduleType: ScheduleType.teacher,
      ),
      Schedule(
        id: 's2',
        subject: 'Matematika',
        assignedToId: 'Iqbal',
        className: '10A',
        day: 'Tuesday',
        time: '09:00-10:00',
        room: '102',
        scheduleType: ScheduleType.teacher,
      ),
      Schedule(
        id: 's3',
        subject: 'B. Inggris',
        assignedToId: 'Izaz',
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
        studentId: 'student1',
        subject: 'Mathematics',
        assignment: 'Quiz 1',
        score: 85.0,
        date: '2024-01-15',
        teacherId: 'teacher1',
      ),
      Grade(
        id: 'g2',
        studentId: 'student1',
        subject: 'Physics',
        assignment: 'Lab Report',
        score: 92.0,
        date: '2024-01-20',
        teacherId: 'teacher2',
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
        studentId: 'student1',
        subject: 'Mathematics',
        date: '2024-01-15',
        status: AttendanceStatus.present,
        teacherId: 'teacher1',
      ),
      Attendance(
        id: 'a2',
        studentId: 'student1',
        subject: 'Physics',
        date: '2024-01-16',
        status: AttendanceStatus.present,
        teacherId: 'teacher2',
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
        teacherId: 'teacher1',
        className: '10A',
        major: 'IPA',
        dueDate: '2024-01-25',
      ),
      Assignment(
        id: 'as2',
        title: 'Physics Lab Report',
        description: 'Write a report on the pendulum experiment',
        subject: 'Physics',
        teacherId: 'teacher2',
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
        authorId: 'admin',
        date: DateTime.parse('2024-01-10'),
        targetRole: 'all',
      ),
      Announcement(
        id: 'an2',
        title: 'Exam Schedule',
        content: 'Mid-term exams will start next week. Check your schedules.',
        authorId: 'admin',
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
