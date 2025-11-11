import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../models/attendance.dart';
import '../models/grade.dart';
import '../models/payment.dart';
import '../models/user.dart';

class StatisticsWidget extends StatelessWidget {
  const StatisticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.currentUser;
    if (user == null) {
      return const Text('User not logged in');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistical History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF667EEA),
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<User>>(
          future: authProvider.getAllUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return const Text('Error loading statistics');
            }

            final allUsers = snapshot.data ?? [];
            return _buildStatisticsCards(context, user, dataProvider, allUsers);
          },
        ),
      ],
    );
  }

  Widget _buildStatisticsCards(BuildContext context, User user, DataProvider dataProvider, List<User> allUsers) {
    switch (user.role) {
      case UserRole.student:
        return _buildStudentStatistics(context, user, dataProvider);
      case UserRole.teacher:
        return _buildTeacherStatistics(context, user, dataProvider);
      case UserRole.admin:
        return _buildAdminStatistics(context, user, dataProvider, allUsers);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStudentStatistics(BuildContext context, User user, DataProvider dataProvider) {
    final userAttendances = dataProvider.attendances.where((a) => a.studentId == user.id).toList();
    final userGrades = dataProvider.grades.where((g) => g.studentId == user.id).toList();
    final userPayments = dataProvider.payments.where((p) => p.studentId == user.id).toList();

    // Calculate attendance rate
    final totalAttendance = userAttendances.length;
    final presentCount = userAttendances.where((a) => a.status == AttendanceStatus.present).length;
    final attendanceRate = totalAttendance > 0 ? (presentCount / totalAttendance) * 100 : 0.0;

    // Calculate average grade
    final averageGrade = userGrades.isNotEmpty
        ? userGrades.map((g) => g.score).reduce((a, b) => a + b) / userGrades.length
        : 0.0;

    // Calculate payment statistics
    final paidPayments = userPayments.where((p) => p.status == PaymentStatus.paid).length;
    final totalPayments = userPayments.length;
    final paymentRate = totalPayments > 0 ? (paidPayments / totalPayments) * 100 : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Attendance Rate',
                '${attendanceRate.toStringAsFixed(1)}%',
                Icons.check_circle,
                Colors.green,
                '${presentCount}/${totalAttendance} Present',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Average Grade',
                '${averageGrade.toStringAsFixed(1)}',
                Icons.grade,
                Colors.blue,
                '${userGrades.length} Grades',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Payment Rate',
                '${paymentRate.toStringAsFixed(1)}%',
                Icons.payment,
                Colors.orange,
                '${paidPayments}/${totalPayments} Paid',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Total Records',
                '${userAttendances.length + userGrades.length + userPayments.length}',
                Icons.analytics,
                Colors.purple,
                'All Activities',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTeacherStatistics(BuildContext context, User user, DataProvider dataProvider) {
    final teacherAttendances = dataProvider.attendances.where((a) => a.teacherId == user.id).toList();
    final teacherGrades = dataProvider.grades.where((g) => g.teacherId == user.id).toList();
    final teacherSchedules = dataProvider.schedules.where((s) => s.assignedToId == user.id).toList();

    // Calculate unique students taught
    final uniqueStudents = <String>{};
    teacherAttendances.forEach((a) => uniqueStudents.add(a.studentId));
    teacherGrades.forEach((g) => uniqueStudents.add(g.studentId));
    final totalStudents = uniqueStudents.length;

    // Calculate average attendance rate for teacher's classes
    final totalAttendance = teacherAttendances.length;
    final presentCount = teacherAttendances.where((a) => a.status == AttendanceStatus.present).length;
    final avgAttendanceRate = totalAttendance > 0 ? (presentCount / totalAttendance) * 100 : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Students Taught',
                '$totalStudents',
                Icons.people,
                Colors.blue,
                'Unique Students',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Classes',
                '${teacherSchedules.length}',
                Icons.school,
                Colors.green,
                'Scheduled',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Attendance Records',
                '${teacherAttendances.length}',
                Icons.check_circle,
                Colors.orange,
                '${avgAttendanceRate.toStringAsFixed(1)}% Avg Rate',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Grades Entered',
                '${teacherGrades.length}',
                Icons.grade,
                Colors.purple,
                'Total Records',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdminStatistics(BuildContext context, User user, DataProvider dataProvider, List<User> allUsers) {
    final totalUsers = allUsers.length;
    final totalStudents = allUsers.where((u) => u.role == UserRole.student).length;
    final totalTeachers = allUsers.where((u) => u.role == UserRole.teacher).length;

    final allAttendances = dataProvider.attendances;
    final totalAttendance = allAttendances.length;
    final presentCount = allAttendances.where((a) => a.status == AttendanceStatus.present).length;
    final overallAttendanceRate = totalAttendance > 0 ? (presentCount / totalAttendance) * 100 : 0.0;

    final allGrades = dataProvider.grades;
    final averageGrade = allGrades.isNotEmpty
        ? allGrades.map((g) => g.score).reduce((a, b) => a + b) / allGrades.length
        : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Users',
                '$totalUsers',
                Icons.people,
                Colors.blue,
                '$totalStudents Students',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Teachers',
                '$totalTeachers',
                Icons.admin_panel_settings,
                Colors.green,
                'Active Staff',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Overall Attendance',
                '${overallAttendanceRate.toStringAsFixed(1)}%',
                Icons.check_circle,
                Colors.orange,
                '$totalAttendance Records',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Average Grade',
                '${averageGrade.toStringAsFixed(1)}',
                Icons.grade,
                Colors.purple,
                '${allGrades.length} Grades',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
