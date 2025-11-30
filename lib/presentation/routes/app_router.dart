import 'package:flutter/material.dart'; // [PENTING] Tambahkan ini untuk menghilangkan error Scaffold
import 'package:go_router/go_router.dart';
import '../../../data/model/blog.dart'; // [PENTING] Import model Blog

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

// Import Views Tambahan (jika diperlukan oleh sub-routes di Dashboard)
import '../../../presentation/page/student/student_grades_view.dart';
import '../../../presentation/page/student/student_attendance_view.dart';
import '../../../presentation/page/student/student_assignments_view.dart';
import '../../../presentation/page/student/student_materials_screen.dart';
import '../../../presentation/page/teacher/teacher_input_assignment_view.dart';
import '../../../presentation/page/shared/about_team_screen.dart';

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
      
      // --- Student Dashboard ---
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
      
      // Sub-routes Student Beranda
      GoRoute(
        path: '/student-dashboard/beranda/grades',
        builder: (context, state) => const GradesView(), // Pastikan nama class sesuai
      ),
      GoRoute(
        path: '/student-dashboard/beranda/attendance',
        builder: (context, state) => const AttendanceView(), // Pastikan nama class sesuai
      ),
      GoRoute(
        path: '/student-dashboard/beranda/assignments',
        builder: (context, state) => const AssignmentsView(), // Pastikan nama class sesuai
      ),
      GoRoute(
        path: '/student-dashboard/beranda/materials',
        builder: (context, state) => const MaterialsView(),
      ),

      // --- Teacher Dashboard ---
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

      // --- Admin Dashboard ---
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

      // --- Blog Detail Route (DIPERBAIKI) ---
      GoRoute(
        path: '/blog/:id', // Menggunakan parameter dinamis :id
        builder: (context, state) {
          // 1. Ambil objek blog yang dikirim via parameter 'extra'
          // Kita cast sebagai Blog? agar aman jika null
          final blog = state.extra as Blog?;

          // 2. Cek validasi
          if (blog != null) {
            // Jika data ada, tampilkan halaman detail dengan data tersebut
            return BlogDetailScreen(blog: blog);
          } else {
            // Jika data null (misal refresh halaman), tampilkan halaman error/fallback
            // Scaffold sekarang sudah dikenali karena kita import material.dart
            return Scaffold(
              appBar: AppBar(
                title: const Text("Error"),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              body: const Center(
                child: Text("Data berita tidak ditemukan. Silakan akses dari halaman list."),
              ),
            );
          }
        },
      ),
      GoRoute(
        path: '/about-team',
        builder: (context, state) => const AboutTeamScreen(),
      ),
    ],
  );
}