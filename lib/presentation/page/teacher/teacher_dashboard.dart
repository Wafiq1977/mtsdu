import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lpmmtsdu/presentation/page/teacher/teacher_materials_view.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../presentation/provider/auth_provider.dart';
import '../../../presentation/provider/data_provider.dart';
import '../../../presentation/provider/theme_provider.dart';
import '../../../data/model/schedule.dart';
import '../../../data/model/assignment.dart';
import '../../../data/model/announcement.dart';
import '../../../presentation/widgets/animated_navigation_bar.dart';
import '../../../presentation/widgets/statistics_widget.dart';
import 'teacher_input_attendance_view.dart';
import 'teacher_bulk_attendance_view.dart';
import 'assignment_detail_page.dart';
import 'teacher_academic_calendar_view.dart';

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

// Teacher Home View
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
    final materials = dataProvider.materials
        .where((material) => material.teacherId == user.id)
        .toList();

    // Get today's schedule
    final today = DateTime.now();
    final todayName = _getDayName(today.weekday);
    final todaySchedules = dataProvider.schedules
        .where((s) => s.assignedToId == user.id && s.day == todayName)
        .toList();

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
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
            // Update Grid menjadi 2 baris
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Baris pertama
                  Row(
                    children: [
                      Expanded(
                        child: _buildCompactFeatureCard(
                          context,
                          'Lihat Nilai',
                          Icons.grade,
                          Colors.green,
                          grades.length,
                          () => GoRouter.of(
                            context,
                          ).go('/teacher-dashboard/beranda/input-grades'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildCompactFeatureCard(
                          context,
                          'Lihat Kehadiran',
                          Icons.check_circle,
                          Colors.orange,
                          attendances.length,
                          () => _showAttendanceOptionsDialog(context),
                        ),
                      ),
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
                  const SizedBox(height: 12),
                  // Baris kedua - TAMBAHAN
                  Row(
                    children: [
                      Expanded(
                        child: _buildCompactFeatureCard(
                          context,
                          'Materi',
                          Icons.book,
                          Colors.blue,
                          materials.length,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TeacherMaterialsView(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Container()), // Spacer
                      const SizedBox(width: 12),
                      Expanded(child: Container()), // Spacer
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Today's Schedule Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Jadwal Hari Ini - ${_getIndonesianDayName(today.weekday)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (todaySchedules.isEmpty)
                    Text(
                      'Tidak ada jadwal kelas hari ini',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    Column(
                      children: todaySchedules.map((schedule) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.class_,
                                  color: Colors.blue.shade700,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      schedule.subject,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${schedule.time} - Ruang ${schedule.room}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
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

  void _showAttendanceOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Attendance Options'),
        content: const Text('Choose how you want to input attendance:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TeacherInputAttendanceView(),
                ),
              );
            },
            child: const Text('Single Student'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TeacherBulkAttendanceView(),
                ),
              );
            },
            child: const Text('Bulk Input'),
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      default:
        return 'Monday';
    }
  }

  String _getIndonesianDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Senin';
      case 2:
        return 'Selasa';
      case 3:
        return 'Rabu';
      case 4:
        return 'Kamis';
      case 5:
        return 'Jumat';
      default:
        return 'Senin';
    }
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2), Color(0xFFF093FB)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.centerLeft,
              child: Text(
                'Profil',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade900,
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
                              backgroundImage: AssetImage(
                                user.profileImagePath!,
                              ),
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

  static final List<Widget> _widgetOptions = <Widget>[
    const TeacherAnnouncementsView(),
    const TeacherHomeView(),
    const TeacherAcademicCalendarView(),
    const TeacherProfileView(),
  ];

  void _onItemTapped(int index) {
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

    final bool isCalendarPage = _selectedIndex == 2;
    final bool isProfilePage = _selectedIndex == 3;

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
                if (!isCalendarPage && !isProfilePage)
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
                              onTap: () => _showProfileDialog(
                                context,
                                user,
                                authProvider,
                              ),
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
                if (_showTools)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
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
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                label: 'Kalender Akademik',
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
                      child: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
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
