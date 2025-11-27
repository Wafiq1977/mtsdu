import 'package:go_router/go_router.dart';
import '../../../presentation/page/shared/splash_screen.dart';
import '../../../presentation/page/shared/login_screen.dart';
import '../../../presentation/page/student/student_dashboard.dart';
import '../../../presentation/page/teacher/teacher_dashboard.dart';
import '../../../presentation/page/admin/admin_dashboard.dart';
import '../../../presentation/page/shared/blog_detail_screen.dart';
import '../../../presentation/page/teacher/teacher_input_grades_view.dart';
import '../../../presentation/page/teacher/teacher_input_attendance_view.dart';
import '../../../presentation/page/teacher/teacher_bulk_attendance_view.dart';
import '../../../presentation/page/admin/admin_academic_calendar.dart';
import '../../../presentation/page/admin/admin_user_management.dart';
import '../../../presentation/page/admin/admin_schedule_management.dart';
import '../../../presentation/page/admin/admin_attendance_reports.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // Student Dashboard and sub-routes
      GoRoute(
        path: '/student-dashboard',
        builder: (context, state) => const StudentDashboard(),
      ),
      GoRoute(
        path: '/student-dashboard/pengumuman',
        builder: (context, state) => const StudentDashboard(initialIndex: 0),
      ),
      GoRoute(
        path: '/student-dashboard/beranda',
        builder: (context, state) => const StudentDashboard(initialIndex: 1),
      ),
      GoRoute(
        path: '/student-dashboard/jadwal',
        builder: (context, state) => const StudentDashboard(initialIndex: 2),
      ),
      GoRoute(
        path: '/student-dashboard/profil',
        builder: (context, state) => const StudentDashboard(initialIndex: 3),
      ),
      GoRoute(
        path: '/student-dashboard/beranda/grades',
        builder: (context, state) => const GradesView(),
      ),
      GoRoute(
        path: '/student-dashboard/beranda/attendance',
        builder: (context, state) => const AttendanceView(),
      ),
      GoRoute(
        path: '/student-dashboard/beranda/assignments',
        builder: (context, state) => const AssignmentsView(),
      ),
      GoRoute(
        path: '/student-dashboard/beranda/materials',
        builder: (context, state) => const MaterialsView(),
      ),
      // Teacher Dashboard and sub-routes
      GoRoute(
        path: '/teacher-dashboard',
        builder: (context, state) => const TeacherDashboard(),
      ),
      GoRoute(
        path: '/teacher-dashboard/pengumuman',
        builder: (context, state) => const TeacherDashboard(initialIndex: 0),
      ),
      GoRoute(
        path: '/teacher-dashboard/beranda',
        builder: (context, state) => const TeacherDashboard(initialIndex: 1),
      ),
      GoRoute(
        path: '/teacher-dashboard/kalender',
        builder: (context, state) => const TeacherDashboard(initialIndex: 2),
      ),
      GoRoute(
        path: '/teacher-dashboard/profil',
        builder: (context, state) => const TeacherDashboard(initialIndex: 3),
      ),
      GoRoute(
        path: '/teacher-dashboard/beranda/input-grades',
        builder: (context, state) => const TeacherInputGradesView(),
      ),
      // Admin Dashboard and sub-routes
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/admin-dashboard/usermanagements',
        builder: (context, state) => const AdminUserManagement(),
      ),
      GoRoute(
        path: '/admin-dashboard/calendar',
        builder: (context, state) => const AdminAcademicCalendar(),
      ),
      GoRoute(
        path: '/admin-dashboard/academic',
        builder: (context, state) => const AdminScheduleManagement(),
      ),
      GoRoute(
        path: '/admin-dashboard/reports',
        builder: (context, state) => const AdminAttendanceReports(),
      ),
      GoRoute(
        path: '/blog/:id',
        builder: (context, state) {
          final blogId = state.pathParameters['id']!;
          // For now, return a placeholder - you can implement blog detail later
          return BlogDetailScreen(blogId: blogId);
        },
      ),
    ],
  );
}
