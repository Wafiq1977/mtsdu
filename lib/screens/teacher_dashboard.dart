import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../providers/theme_provider.dart';
import '../models/schedule.dart';
import '../models/grade.dart';
import '../models/attendance.dart';
import '../models/assignment.dart';
import '../models/announcement.dart';
import '../widgets/animated_navigation_bar.dart';
import '../widgets/statistics_widget.dart';
import 'teacher_input_grades_view.dart';
import 'teacher_input_attendance_view.dart';
import 'teacher_bulk_attendance_view.dart';
import 'teacher_input_assignment_view.dart';

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

    // Update URL sesuai tab (opsional, agar sinkron dengan browser back button)
    switch (index) {
      case 0:
        context.go('/teacher-dashboard/pengumuman');
        break;
      case 1:
        context.go('/teacher-dashboard/beranda');
        break;
      case 2:
        context.go('/teacher-dashboard/kalender');
        break;
      case 3:
        context.go('/teacher-dashboard/profil');
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
    final user = authProvider.currentUser;

    if (user == null) return;

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
    // 1. PERBAIKAN ERROR: Menggunakan user tanpa '!' dan cek null
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 2. LOGIKA TAMPILAN KHUSUS PROFIL
    // Cek apakah tab aktif adalah Profil (index 3)
    final bool isProfilePage = _selectedIndex == 3;

    return Scaffold(
      body: Container(
        // Hapus gradient hanya jika di halaman profile
        decoration: isProfilePage
            ? null
            : const BoxDecoration(
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
                // Header hanya muncul jika BUKAN halaman profile
                if (!isProfilePage)
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
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => _selectedIndex =
                                  3, // Pindah ke profil saat diklik
                              child: user.profileImagePath != null
                                  ? CircleAvatar(
                                      radius: 20,
                                      backgroundImage: AssetImage(
                                        user.profileImagePath!,
                                      ),
                                    )
                                  : const CircleAvatar(
                                      radius: 20,
                                      child: Icon(Icons.person),
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
                      // 3. LOGIKA CONTAINER:
                      // Jika Profile: Tampilkan langsung (Full Screen)
                      // Jika Bukan Profile: Bungkus dengan Container putih melengkung
                      child: isProfilePage
                          ? AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child: _widgetOptions.elementAt(_selectedIndex),
                            )
                          : Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
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
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  transitionBuilder:
                                      (
                                        Widget child,
                                        Animation<double> animation,
                                      ) {
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
                                  child: _widgetOptions.elementAt(
                                    _selectedIndex,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Collapsible Tools Section - Sembunyikan di profil jika mau, atau biarkan
                if (!isProfilePage)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOutCubic,
                    child: _showTools
                        ? FadeTransition(
                            opacity: Tween<double>(begin: 0.0, end: 1.0)
                                .animate(
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

                if (!isProfilePage) const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton:
          !isProfilePage // Sembunyikan FAB di halaman profil
          ? ScaleTransition(
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
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return RotationTransition(
                            turns: Tween<double>(begin: 0.0, end: 0.25).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOut,
                              ),
                            ),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                    child: Icon(
                      _showTools ? Icons.close : Icons.build,
                      key: ValueKey<bool>(_showTools),
                    ),
                  ),
                ),
              ),
            )
          : null,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
}

// ... (KELAS LAIN SEPERTI TeacherHomeView, TeacherAnnouncementsView TETAP SAMA)
// ... (Hanya sertakan kembali kelas-kelas tersebut agar file lengkap)

class TeacherHomeView extends StatelessWidget {
  const TeacherHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.currentUser;
    if (user == null) return const SizedBox.shrink(); // Safe return

    final grades = dataProvider.grades
        .where((g) => g.teacherId == user.id)
        .toList();
    final attendances = dataProvider.attendances
        .where((a) => a.teacherId == user.id)
        .toList();
    final assignments = dataProvider.assignments
        .where((a) => a.teacherId == user.id)
        .toList();
    final announcements = dataProvider.announcements
        .where((a) => a.authorId == user.id)
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    context,
                    'Input Nilai',
                    Icons.grade,
                    Colors.green,
                    grades.length,
                    () => _navigateToView(context, 0),
                  ),
                  _buildFeatureCard(
                    context,
                    'Input Kehadiran',
                    Icons.check_circle,
                    Colors.orange,
                    attendances.length,
                    () => _navigateToView(context, 1),
                  ),
                  _buildFeatureCard(
                    context,
                    'Tugas',
                    Icons.assignment,
                    Colors.purple,
                    assignments.length,
                    () => _navigateToView(context, 2),
                  ),
                  _buildFeatureCard(
                    context,
                    'Pengumuman',
                    Icons.announcement,
                    Colors.red,
                    announcements.length,
                    () => _navigateToView(context, 3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    int count,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '$count item${count != 1 ? 's' : ''}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToView(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/teacher-dashboard/beranda/input-grades');
        break;
      case 1:
        context.go('/teacher-dashboard/beranda/input-attendance');
        break;
      case 2:
        context.go('/teacher-dashboard/beranda/input-assignments');
        break;
      case 3:
        // Untuk pengumuman, karena ada di tab terpisah, kita bisa navigasi ke tab itu
        // Atau buka dialog
        // Disini contohnya buka dialog
        break;
    }
  }
}

class GradesInputView extends StatelessWidget {
  const GradesInputView({super.key});
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.currentUser;
    if (user == null) return const Center(child: CircularProgressIndicator());
    final grades = dataProvider.grades
        .where((g) => g.teacherId == user.id)
        .toList();
    return Container(
      color: Colors.green.shade50,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Text(
              'Daftar Nilai',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: grades.length,
              itemBuilder: (context, index) {
                final grade = grades[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 4,
                  child: ListTile(
                    title: Text(grade.assignment),
                    subtitle: Text('${grade.subject} - Score: ${grade.score}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AttendanceInputView extends StatelessWidget {
  const AttendanceInputView({super.key});
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.currentUser;
    if (user == null) return const Center(child: CircularProgressIndicator());
    final attendances = dataProvider.attendances
        .where((a) => a.teacherId == user.id)
        .toList();
    return Container(
      color: Colors.orange.shade50,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Text(
              'Daftar Kehadiran',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade900,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: attendances.length,
              itemBuilder: (context, index) {
                final attendance = attendances[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 4,
                  child: ListTile(
                    title: Text(attendance.subject),
                    subtitle: Text('${attendance.date} - ${attendance.status}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AssignmentsView extends StatelessWidget {
  const AssignmentsView({super.key});
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.currentUser;
    if (user == null) return const Center(child: CircularProgressIndicator());
    final assignments = dataProvider.assignments
        .where((a) => a.teacherId == user.id)
        .toList();
    return Container(
      color: Colors.purple.shade50,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Text(
              'Daftar Tugas',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade900,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final assignment = assignments[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 4,
                  child: ListTile(
                    title: Text(assignment.title),
                    subtitle: Text(assignment.description),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TeacherAnnouncementsView extends StatelessWidget {
  const TeacherAnnouncementsView({super.key});
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.currentUser;
    if (user == null) return const Center(child: CircularProgressIndicator());
    final announcements = dataProvider.announcements
        .where((a) => a.authorId == user.id)
        .toList();
    return Container(
      color: Colors.red.shade50,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Text(
              'Pengumuman Saya',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade900,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final announcement = announcements[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 4,
                  child: ListTile(
                    title: Text(announcement.title),
                    subtitle: Text(announcement.content),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TeacherScheduleView extends StatelessWidget {
  const TeacherScheduleView({super.key});
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.currentUser;
    if (user == null) return const Center(child: CircularProgressIndicator());
    final schedules = dataProvider.schedules
        .where((s) => s.assignedToId == user.id)
        .toList();
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
            child: ListView.builder(
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 4,
                  child: ListTile(
                    title: Text(schedule.subject),
                    subtitle: Text('${schedule.day} - ${schedule.time}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// INI ADALAH TEACHER PROFILE VIEW YANG DIPERBAIKI
// ==========================================
class TeacherProfileView extends StatelessWidget {
  const TeacherProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    // PERBAIKAN UTAMA: Menggunakan 'user' tanpa '!' dan cek null
    final user = authProvider.currentUser;

    if (user == null) {
      return Container(
        color: Colors.blue.shade50,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

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
