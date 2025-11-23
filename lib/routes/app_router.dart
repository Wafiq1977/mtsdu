import 'package:flutter/material.dart'; // Tambahkan ini untuk Scaffold, Icon, dll
import 'package:go_router/go_router.dart';
import '../models/blog.dart'; // Sesuaikan path relative jika perlu
import '../screens/blog_detail_screen.dart'; // Sesuaikan path relative jika perlu
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/student_dashboard.dart';
import '../screens/student_grades_screen.dart';
import '../screens/student_attendance_screen.dart';
import '../screens/student_assignments_screen.dart';
import '../screens/student_materials_screen.dart';
import '../screens/teacher_dashboard.dart';
import '../screens/admin_dashboard.dart';
import '../screens/admin_user_management.dart';
import '../screens/admin_schedule_management.dart';
import '../screens/admin_attendance_reports.dart';
import '../screens/teacher_grades_input.dart';
import '../screens/teacher_input_attendance_view.dart';
import '../screens/teacher_input_assignment_view.dart';
import '../screens/teacher_bulk_attendance_view.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      
      // -----------------------------------------------------------------
      // ROUTE DETAIL BERITA (DIPERBARUI UNTUK WEB)
      // -----------------------------------------------------------------
      GoRoute(
        path: '/beritadetail/:id',
        builder: (context, state) {
          // 1. Cek apakah objek 'blog' ada di state.extra
          // Ini terjadi jika user masuk lewat klik di aplikasi
          if (state.extra != null && state.extra is Blog) {
            final blog = state.extra as Blog;
            return BlogDetailScreen(blog: blog);
          } 
          
          // 2. HANDLING ERROR WEB (Refresh Page):
          // Jika user refresh halaman di browser, state.extra akan hilang (null).
          // Kita tampilkan halaman error yang ramah user.
          return Scaffold(
            appBar: AppBar(
              title: const Text("Artikel Tidak Ditemukan"),
              backgroundColor: const Color(0xFF667EEA),
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.link_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "Data artikel tidak tersedia saat refresh.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Silakan kembali ke dashboard untuk memilih berita.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/student-dashboard'),
                    icon: const Icon(Icons.dashboard),
                    label: const Text("Kembali ke Dashboard"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      // Student routes
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
      
      // Teacher routes
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
                builder: (context, state) => const TeacherGradesInput(),
              ),
              GoRoute(
                path: 'input-attendance',
                builder: (context, state) => const TeacherInputAttendanceView(),
              ),
              GoRoute(
                path: 'input-assignments',
                builder: (context, state) => const TeacherInputAssignmentView(),
              ),
              GoRoute(
                path: 'bulk-attendance',
                builder: (context, state) => const TeacherBulkAttendanceView(),
              ),
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
      
      // Admin routes
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
}