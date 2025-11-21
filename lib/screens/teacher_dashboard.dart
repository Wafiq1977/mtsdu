import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../providers/theme_provider.dart';
import '../models/schedule.dart';
import '../models/grade.dart';
import '../models/attendance.dart';
import '../models/assignment.dart';
import '../models/announcement.dart';
import '../models/user.dart'; // Pastikan import ini ada
import '../widgets/animated_navigation_bar.dart';
import '../widgets/statistics_widget.dart';
import 'teacher_input_grades_view.dart';
import 'teacher_input_attendance_view.dart';
// import 'teacher_bulk_attendance_view.dart'; // SUDAH DIHAPUS

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _showTools = false;
  String? _selectedDay;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  late AnimationController _contentAnimationController;
  late Animation<double> _contentAnimation;

  static const List<Widget> _widgetOptions = <Widget>[
    TeacherAnnouncementsView(),
    TeacherHomeView(),
    TeacherScheduleView(),
    TeacherProfileView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        GoRouter.of(context).go('/teacher-dashboard/pengumuman');
        break;
      case 1:
        GoRouter.of(context).go('/teacher-dashboard/beranda');
        break;
      case 2:
        GoRouter.of(context).go('/teacher-dashboard/kalender');
        break;
      case 3:
        GoRouter.of(context).go('/teacher-dashboard/profil');
        break;
    }
  }

  void _toggleTools() {
    setState(() {
      _showTools = !_showTools;
    });
    if (_showTools) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _contentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _contentAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  void _selectDay(String day) {
    setState(() {
      _selectedDay = day;
    });
    _showDaySchedule(day);
  }

  void _showDaySchedule(String day) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final user = authProvider.currentUser!;
    final daySchedules = dataProvider.schedules
        .where((s) => s.assignedToId == user.id && s.day == day)
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 400,
          child: Column(
            children: [
              Text(
                'Schedule for $day',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667EEA),
                ),
              ),
              const SizedBox(height: 20),
              if (daySchedules.isEmpty)
                const Text('No classes scheduled for this day')
              else
                Expanded(
                  child: ListView(
                    children: daySchedules
                        .map(
                          (schedule) => Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: Icon(
                                Icons.schedule,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: Text(schedule.subject),
                              subtitle: Text(
                                '${schedule.time} - Room: ${schedule.room} - Class: ${schedule.className}',
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayButton(String day) {
    return ElevatedButton(
      onPressed: () => _selectDay(day),
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedDay == day
            ? const Color(0xFF667EEA)
            : Colors.grey[300],
        foregroundColor: _selectedDay == day ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(day.substring(0, 3), style: const TextStyle(fontSize: 12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
              Color(0xFFF093FB),
              Color(0xFFF5576C),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _contentAnimation,
            child: Column(
              children: [
                // Header with full width profile
                SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, -0.5),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _contentAnimationController,
                          curve: const Interval(
                            0.1,
                            0.6,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                      ),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _contentAnimationController,
                        curve: const Interval(0.1, 0.5, curve: Curves.easeIn),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () =>
                                _showProfileDialog(context, user, authProvider),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                image: user.profileImagePath != null
                                    ? DecorationImage(
                                        image: AssetImage(
                                          user.profileImagePath!,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: user.profileImagePath == null
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 30,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome, ${user.name}!',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Subject: ${user.subject ?? "General"}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Content Area
                Expanded(
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _contentAnimationController,
                        curve: const Interval(
                          0.3,
                          0.9,
                          curve: Curves.elasticOut,
                        ),
                      ),
                    ),
                    child: FadeTransition(
                      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _contentAnimationController,
                          curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position:
                                          Tween<Offset>(
                                            begin: const Offset(0.5, 0.0),
                                            end: Offset.zero,
                                          ).animate(
                                            CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeOutCubic,
                                            ),
                                          ),
                                      child: child,
                                    ),
                                  );
                                },
                            child: _widgetOptions.elementAt(_selectedIndex),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Collapsible Tools Section
                AnimatedSize(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOutCubic,
                  child: _showTools
                      ? FadeTransition(
                          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _fabAnimationController,
                              curve: Curves.easeIn,
                            ),
                          ),
                          child: SlideTransition(
                            position:
                                Tween<Offset>(
                                  begin: const Offset(0, 0.3),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: _fabAnimationController,
                                    curve: Curves.easeOutCubic,
                                  ),
                                ),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Schedule Tools',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF667EEA),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildDayButton('Monday'),
                                      _buildDayButton('Tuesday'),
                                      _buildDayButton('Wednesday'),
                                      _buildDayButton('Thursday'),
                                      _buildDayButton('Friday'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FadeTransition(
          opacity: Tween<double>(
            begin: 0.7,
            end: 1.0,
          ).animate(_fabAnimationController),
          child: FloatingActionButton(
            onPressed: _toggleTools,
            backgroundColor: const Color(0xFF667EEA),
            elevation: 8,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return RotationTransition(
                  turns: Tween<double>(begin: 0.0, end: 0.25).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                  ),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Icon(
                _showTools ? Icons.close : Icons.build,
                key: ValueKey<bool>(_showTools),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: AnimatedNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.announcement),
                label: 'Pengumuman',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Jadwal',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedColor: const Color(0xFF667EEA),
            unselectedColor: Colors.grey,
          ),
        ),
      ),
    );
  }

  void _showProfileDialog(
    BuildContext context,
    user,
    AuthProvider authProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return AlertDialog(
              title: const Text('Profile'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: user.profileImagePath != null
                          ? CircleAvatar(
                              radius: 40,
                              backgroundImage: AssetImage(
                                user.profileImagePath!,
                              ),
                            )
                          : const CircleAvatar(
                              radius: 40,
                              child: Icon(Icons.person, size: 40),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Text('Name: ${user.name}'),
                    Text('Role: ${user.role.toString().split('.').last}'),
                    Text('Subject: ${user.subject ?? "N/A"}'),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Dark Mode',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Switch(
                          value: themeProvider.isDarkMode,
                          onChanged: (value) {
                            themeProvider.toggleTheme();
                          },
                          activeColor: const Color(0xFF667EEA),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const StatisticsWidget(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        authProvider.logout();
                        Navigator.of(context).pop();
                        context.go('/');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ==========================================
// 2. HALAMAN BERANDA (TeacherHomeView)
// Bagian ini yang DIUBAH sesuai request
// ==========================================
class TeacherHomeView extends StatelessWidget {
  const TeacherHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.currentUser!;
    final grades = dataProvider.grades
        .where((g) => g.teacherId == user.id)
        .toList();
    final attendances = dataProvider.attendances
        .where((a) => a.teacherId == user.id)
        .toList();
    final assignments = dataProvider.assignments
        .where((a) => a.teacherId == user.id)
        .toList();

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Text(
              'Beranda',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildCompactFeatureCard(
                    context,
                    'Input Nilai',
                    Icons.grade,
                    Colors.green,
                    grades.length,
                    () => GoRouter.of(
                      context,
                    ).go('/teacher-dashboard/beranda/input-grades'),
                  ),
                ),
                const SizedBox(width: 12),

                // --- BAGIAN ABSEN YANG DIPERBAIKI (TANPA DIALOG) ---
                Expanded(
                  child: _buildCompactFeatureCard(
                    context,
                    'Absen',
                    Icons.check_circle,
                    Colors.orange,
                    attendances.length,
                    () {
                      // Langsung buka halaman input absen baru
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const TeacherInputAttendanceView(),
                        ),
                      );
                    },
                  ),
                ),

                // ---------------------------------------------------
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCompactFeatureCard(
                    context,
                    'Tugas',
                    Icons.assignment,
                    Colors.purple,
                    assignments.length,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AssignmentListPage(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: const Center(
                child: Text(
                  'Selamat datang di Dashboard Guru',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    int count,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$count',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- SISA KODE DI BAWAH TIDAK DIUBAH (TUGAS, PENGUMUMAN, JADWAL, DLL) ---
// ... (Kode AssignmentListPage, CreateAssignmentPage, TeacherAnnouncementsView, dll tetap ada) ...

// Assignment List Page (New Page)
class AssignmentListPage extends StatelessWidget {
  const AssignmentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.currentUser!;
    final assignments = dataProvider.assignments
        .where((a) => a.teacherId == user.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas'),
        backgroundColor: const Color(0xFF667EEA),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateAssignmentPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: assignments.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada tugas',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap tombol + untuk menambah tugas baru',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final assignment = assignments[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => _showAssignmentDetail(context, assignment),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.assignment,
                                  color: Colors.purple,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      assignment.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      assignment.subject,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildInfoChip(
                                Icons.class_,
                                assignment.className,
                              ),
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                Icons.calendar_today,
                                assignment.dueDate.split(' ')[0],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  void _showAssignmentDetail(BuildContext context, Assignment assignment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(assignment.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Mata Pelajaran', assignment.subject),
              _buildDetailRow('Kelas', assignment.className),
              _buildDetailRow('Jurusan', assignment.major),
              _buildDetailRow('Deadline', assignment.dueDate.split(' ')[0]),
              const SizedBox(height: 12),
              const Text(
                'Deskripsi:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(assignment.description),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// Create Assignment Page
class CreateAssignmentPage extends StatefulWidget {
  const CreateAssignmentPage({super.key});

  @override
  State<CreateAssignmentPage> createState() => _CreateAssignmentPageState();
}

class _CreateAssignmentPageState extends State<CreateAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String? _selectedSubject;
  String _dueDate = '';
  List<String> _selectedClasses = [];
  List<String> _availableClasses = [];
  final TextEditingController _dueDateController = TextEditingController();
  List<PlatformFile> _attachedFiles = [];

  // Mapping mata pelajaran ke kelas
  final Map<String, List<String>> _subjectToClasses = {
    'Matematika': ['10A', '10B', '11A', '11B', '12A', '12B'],
    'Fisika': ['10A', '11A', '12A'],
    'Kimia': ['10B', '11B', '12B'],
    'Biologi': ['10A', '10B', '11A', '11B'],
    'Bahasa Indonesia': ['10A', '10B', '11A', '11B', '12A', '12B'],
    'Bahasa Inggris': ['10A', '10B', '11A', '11B', '12A', '12B'],
    'Sejarah': ['10A', '11A', '12A'],
    'Geografi': ['10B', '11B', '12B'],
  };

  @override
  void dispose() {
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          _attachedFiles.addAll(result.files);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${result.files.length} file(s) ditambahkan')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking files: $e')));
    }
  }

  void _removeFile(int index) {
    setState(() {
      _attachedFiles.removeAt(index);
    });
  }

  void _submitAssignment() {
    if (_formKey.currentState!.validate() &&
        _selectedSubject != null &&
        _selectedClasses.isNotEmpty) {
      _formKey.currentState!.save();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final user = authProvider.currentUser!;

      for (String className in _selectedClasses) {
        final assignment = Assignment(
          id: '${DateTime.now().millisecondsSinceEpoch}_${className}_${_selectedSubject}',
          title: _title,
          description: _description,
          subject: _selectedSubject!,
          teacherId: user.id,
          className: className,
          major: '', // Set default or extract from class
          dueDate: _dueDate,
        );

        dataProvider.addAssignment(assignment);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tugas berhasil ditambahkan!')),
      );
      Navigator.pop(context);
    } else {
      String errorMsg = 'Lengkapi semua field yang diperlukan';
      if (_selectedSubject == null) {
        errorMsg = 'Pilih mata pelajaran terlebih dahulu';
      } else if (_selectedClasses.isEmpty) {
        errorMsg = 'Pilih minimal satu kelas';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked.toIso8601String();
        _dueDateController.text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  String _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return '🖼️';
      default:
        return '📎';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Tugas Baru'),
        backgroundColor: const Color(0xFF667EEA),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Judul Tugas
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Judul Tugas',
                  prefixIcon: const Icon(Icons.title, color: Color(0xFF667EEA)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Judul harus diisi' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),

              // Mata Pelajaran Dropdown
              DropdownButtonFormField<String>(
                value: _selectedSubject,
                decoration: InputDecoration(
                  labelText: 'Mata Pelajaran',
                  prefixIcon: const Icon(
                    Icons.subject,
                    color: Color(0xFF667EEA),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _subjectToClasses.keys.map((subject) {
                  return DropdownMenuItem<String>(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSubject = value;
                    _availableClasses = _subjectToClasses[value!] ?? [];
                    _selectedClasses.clear();
                  });
                },
                validator: (value) =>
                    value == null ? 'Pilih mata pelajaran' : null,
              ),
              const SizedBox(height: 16),

              // Kelas Selection
              if (_selectedSubject != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pilih Kelas Yang Diajar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF667EEA),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: _availableClasses.map((className) {
                          final isSelected = _selectedClasses.contains(
                            className,
                          );
                          return FilterChip(
                            label: Text(className),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedClasses.add(className);
                                } else {
                                  _selectedClasses.remove(className);
                                }
                              });
                            },
                            selectedColor: const Color(0xFF667EEA),
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            backgroundColor: Colors.white,
                          );
                        }).toList(),
                      ),
                      if (_selectedClasses.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            '⚠️ Pilih minimal satu kelas',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Deskripsi
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Deskripsi Tugas',
                  prefixIcon: const Icon(
                    Icons.description,
                    color: Color(0xFF667EEA),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) =>
                    value!.isEmpty ? 'Deskripsi harus diisi' : null,
                onSaved: (value) => _description = value!,
              ),
              const SizedBox(height: 16),

              // Deadline
              TextFormField(
                controller: _dueDateController,
                decoration: InputDecoration(
                  labelText: 'Deadline Pengumpulan',
                  prefixIcon: const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF667EEA),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                readOnly: true,
                onTap: () => _selectDueDate(context),
                validator: (value) =>
                    value!.isEmpty ? 'Tentukan deadline' : null,
              ),
              const SizedBox(height: 24),

              // File Attachment Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Lampiran File',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _pickFiles,
                          icon: const Icon(Icons.attach_file, size: 18),
                          label: const Text('Pilih File'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Format: JPG, PNG, PDF, DOC, DOCX',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (_attachedFiles.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      ...List.generate(_attachedFiles.length, (index) {
                        final file = _attachedFiles[index];
                        final extension = file.extension ?? '';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.purple[100]!),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _getFileIcon(extension),
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      file.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${(file.size / 1024).toStringAsFixed(1)} KB',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeFile(index),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton.icon(
                onPressed: _submitAssignment,
                icon: const Icon(Icons.send),
                label: const Text('Simpan dan Publikasikan Tugas'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: const Color(0xFF667EEA),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Teacher Announcements View
class TeacherAnnouncementsView extends StatelessWidget {
  const TeacherAnnouncementsView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.currentUser!;
    final announcements = dataProvider.announcements
        .where((a) => a.authorId == user.id)
        .toList();

    return Container(
      color: Colors.red.shade50,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pengumuman Saya',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade900,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle,
                    color: Color(0xFF667EEA),
                    size: 28,
                  ),
                  onPressed: () => _showAddAnnouncementDialog(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: announcements.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.announcement, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Belum ada pengumuman'),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: announcements.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final announcement = announcements[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.announcement, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      announcement.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                announcement.content,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Target: ${announcement.targetRole}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddAnnouncementDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String targetRole = 'all';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Pengumuman'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contentController,
                    decoration: const InputDecoration(
                      labelText: 'Konten',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: targetRole,
                    decoration: const InputDecoration(
                      labelText: 'Target',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Semua')),
                      DropdownMenuItem(value: 'student', child: Text('Siswa')),
                      DropdownMenuItem(value: 'teacher', child: Text('Guru')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        targetRole = value!;
                      });
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isEmpty ||
                  contentController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lengkapi semua field')),
                );
                return;
              }

              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              final dataProvider = Provider.of<DataProvider>(
                context,
                listen: false,
              );
              final user = authProvider.currentUser!;

              final announcement = Announcement(
                id: DateTime.now().toString(),
                title: titleController.text,
                content: contentController.text,
                authorId: user.id,
                date: DateTime.now(),
                targetRole: targetRole,
              );

              await dataProvider.addAnnouncement(announcement);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengumuman berhasil ditambahkan'),
                ),
              );
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}

// Teacher Schedule View
class TeacherScheduleView extends StatelessWidget {
  const TeacherScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.currentUser!;
    final schedules = dataProvider.schedules
        .where((s) => s.assignedToId == user.id)
        .toList();

    final Map<String, List<Schedule>> schedulesByDay = {
      'Monday': [],
      'Tuesday': [],
      'Wednesday': [],
      'Thursday': [],
      'Friday': [],
    };

    for (var schedule in schedules) {
      if (schedulesByDay.containsKey(schedule.day)) {
        schedulesByDay[schedule.day]!.add(schedule);
      }
    }

    return Container(
      color: Colors.purple.shade50,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Text(
              'Jadwal Mengajar',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade900,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: schedulesByDay.entries.map((entry) {
                final day = entry.key;
                final daySchedules = entry.value;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      day,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text('${daySchedules.length} kelas'),
                    children: daySchedules.isEmpty
                        ? [
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('Tidak ada jadwal'),
                            ),
                          ]
                        : daySchedules.map((schedule) {
                            return ListTile(
                              leading: const Icon(
                                Icons.class_,
                                color: Color(0xFF667EEA),
                              ),
                              title: Text(schedule.subject),
                              subtitle: Text(
                                'Class: ${schedule.className}\n${schedule.time} - Room: ${schedule.room}',
                              ),
                              isThreeLine: true,
                            );
                          }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// Teacher Profile View
class TeacherProfileView extends StatelessWidget {
  const TeacherProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser!;

    return Container(
      color: Colors.blue.shade50,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Text(
              'Profil',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: user.profileImagePath != null
                        ? CircleAvatar(
                            radius: 60,
                            backgroundImage: AssetImage(user.profileImagePath!),
                          )
                        : const CircleAvatar(
                            radius: 60,
                            child: Icon(Icons.person, size: 60),
                          ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Guru',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF667EEA),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildProfileInfo('Nama Lengkap', user.name),
                        _buildProfileInfo('Role', 'Teacher'),
                        _buildProfileInfo(
                          'Mata Pelajaran',
                          user.subject ?? 'General',
                        ),
                        _buildProfileInfo('Email', user.email ?? 'Tidak ada'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        authProvider.logout();
                        context.go('/');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade300, height: 1),
        ],
      ),
    );
  }
}
