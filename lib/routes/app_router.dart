import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/student_dashboard.dart';
import '../screens/student_grades_screen.dart';
import '../screens/student_attendance_screen.dart';
import '../screens/student_assignments_screen.dart';
import '../screens/student_materials_screen.dart';
<<<<<<< HEAD
// --- PERBAIKAN: Hapus "hide TeacherDashboard" ---
import '../screens/teacher_dashboard.dart'; 
import '../screens/admin_dashboard.dart';
// import '../screens/admin_user_management.dart';
// import '../screens/admin_schedule_management.dart';
// import '../screens/admin_attendance_reports.dart';
import '../screens/teacher_input_grades_view.dart';
import '../screens/teacher_input_attendance_view.dart';
import '../screens/teacher_input_assignment_view.dart';
=======
import '../screens/teacher_dashboard.dart';
import '../screens/admin_dashboard.dart';
import '../screens/admin_user_management.dart';
import '../screens/admin_schedule_management.dart';
import '../screens/admin_attendance_reports.dart';
import '../screens/teacher_grades_input.dart';
import '../screens/teacher_input_attendance_view.dart';
import '../screens/teacher_input_assignment_view.dart';
import '../screens/teacher_bulk_attendance_view.dart';
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
<<<<<<< HEAD
      // 1. Public Routes
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // 2. Student Routes
=======
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      // Student routes
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
      GoRoute(
        path: '/student-dashboard',
        builder: (context, state) => const StudentDashboard(),
        routes: [
          GoRoute(
            path: 'pengumuman',
            builder: (context, state) => const StudentDashboard(initialIndex: 0),
          ),
          GoRoute(
            path: 'beranda',
            builder: (context, state) => const StudentDashboard(initialIndex: 1),
            routes: [
              GoRoute(
                path: 'grades',
                builder: (context, state) => const StudentGradesScreen(),
              ),
              GoRoute(
                path: 'attendance',
                builder: (context, state) => const StudentAttendanceScreen(),
              ),
              GoRoute(
                path: 'assignments',
                builder: (context, state) => const StudentAssignmentsScreen(),
              ),
              GoRoute(
                path: 'materials',
                builder: (context, state) => const StudentMaterialsScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'kalender',
            builder: (context, state) => const StudentDashboard(initialIndex: 2),
          ),
          GoRoute(
            path: 'profil',
            builder: (context, state) => const StudentDashboard(initialIndex: 3),
          ),
        ],
      ),
<<<<<<< HEAD

      // 3. Teacher Routes
=======
      // Teacher routes
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
      GoRoute(
        path: '/teacher-dashboard',
        builder: (context, state) => const TeacherDashboard(),
        routes: [
          GoRoute(
            path: 'pengumuman',
            builder: (context, state) => const TeacherDashboard(initialIndex: 0),
          ),
          GoRoute(
            path: 'beranda',
            builder: (context, state) => const TeacherDashboard(initialIndex: 1),
            routes: [
              GoRoute(
                path: 'input-grades',
<<<<<<< HEAD
                builder: (context, state) => const TeacherInputGradesView(),
=======
                builder: (context, state) => const TeacherGradesInput(),
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
              ),
              GoRoute(
                path: 'input-attendance',
                builder: (context, state) => const TeacherInputAttendanceView(),
              ),
              GoRoute(
                path: 'input-assignments',
                builder: (context, state) => const TeacherInputAssignmentView(),
              ),
<<<<<<< HEAD
=======
              GoRoute(
                path: 'bulk-attendance',
                builder: (context, state) => const TeacherBulkAttendanceView(),
              ),
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
            ],
          ),
          GoRoute(
            path: 'kalender',
            builder: (context, state) => const TeacherDashboard(initialIndex: 2),
          ),
          GoRoute(
            path: 'profil',
            builder: (context, state) => const TeacherDashboard(initialIndex: 3),
          ),
        ],
      ),
<<<<<<< HEAD

      // 4. Admin Routes
=======
      // Admin routes
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
      GoRoute(
        path: '/admin-dashboard',
        redirect: (context, state) => '/admin-dashboard/usermanagements',
      ),
      GoRoute(
        path: '/admin-dashboard/usermanagements',
        builder: (context, state) => const AdminDashboard(initialIndex: 0),
      ),
      GoRoute(
        path: '/admin-dashboard/academic',
        builder: (context, state) => const AdminDashboard(initialIndex: 1),
      ),
      GoRoute(
        path: '/admin-dashboard/reports',
        builder: (context, state) => const AdminDashboard(initialIndex: 2),
      ),
    ],
  );
<<<<<<< HEAD
}
=======
}
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
