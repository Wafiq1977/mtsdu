import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../providers/theme_provider.dart';
import '../models/user.dart';
import '../models/attendance.dart' as attendance_model;

import '../widgets/statistics_widget.dart';
import '../widgets/animated_navigation_bar.dart';
<<<<<<< HEAD
// removed unused screen imports (local inline widgets used instead)
=======
import 'student_grades_screen.dart';
import 'student_attendance_screen.dart';
import 'student_assignments_screen.dart';
import 'student_materials_screen.dart';
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b

// -------------------------------------------------------------------
// PERUBAHAN: Pastikan import untuk BlogView sudah ada
// -------------------------------------------------------------------
import '../blog/blog_view.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _showTools = false;
  String? _selectedDay;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  late AnimationController _contentAnimationController;
  late Animation<double> _contentAnimation;

  static const List<Widget> _widgetOptions = <Widget>[
    AnnouncementsView(),
    HomeView(),
    AcademicCalendarView(),
    ProfileView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigate to the corresponding sub-route
    switch (index) {
      case 0:
        context.go('/student-dashboard/pengumuman');
        break;
      case 1:
        context.go('/student-dashboard/beranda');
        break;
      case 2:
        context.go('/student-dashboard/kalender');
        break;
      case 3:
        context.go('/student-dashboard/profil');
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
    // Theme is already loaded in ThemeProvider constructor

    // Initialize animations
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _contentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Staggered animation for different elements
    Future.delayed(const Duration(milliseconds: 50), () {
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
        .where((s) => s.className == user.className && s.day == day)
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
                                '${schedule.time} - Room: ${schedule.room}',
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
      child: Text(
        day.substring(0, 3), // Show first 3 letters
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  // Example usage of intl package to format current date
  String getFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat.yMMMMd('en_US');
    return formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    if (user == null) {
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
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

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
                // Header with slide animation
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
                            onTap: () =>
                                _showProfileDialog(context, user, authProvider),
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
                          Text(
                            'Welcome, ${user.name}!',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Content Area with scale animation
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
                        margin: const EdgeInsets.symmetric(horizontal: 20),
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
<<<<<<< HEAD
                          child: AnimatedSwitcher(
=======
                            child: AnimatedSwitcher(
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b
                            duration: const Duration(milliseconds: 150),
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

                // Collapsible Tools Section with smooth animation
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
                label: 'Kalender',
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
    User user,
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
                    Text('Class: ${user.className}'),
                    Text('Major: ${user.major}'),
                    const SizedBox(height: 20),
                    // Theme Toggle Section
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
                    // Statistics Section
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

class GradesView extends StatelessWidget {
  const GradesView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
<<<<<<< HEAD
    final user = authProvider.currentUser!;
    final dataProvider = Provider.of<DataProvider>(context);
=======
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.currentUser!;
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b
    final grades = dataProvider.grades
        .where((g) => g.studentId == user.id)
        .toList();

    return Container(
      color: Colors.green.shade50,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Text(
              'Your Grades',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // Simulate refresh
                await Future.delayed(const Duration(seconds: 1));
              },
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.grade, color: Colors.green),
                      title: Text(
                        grade.assignment,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${grade.subject} - Score: ${grade.score}',
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: grade.score >= 80
                              ? Colors.green
                              : grade.score >= 60
                              ? Colors.orange
                              : Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${grade.score}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AttendanceView extends StatelessWidget {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.currentUser!;
    final attendances = dataProvider.attendances
        .where((a) => a.studentId == user.id)
        .toList();

    return Container(
      color: Colors.orange.shade50,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Text(
              'Your Attendance',
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
                Color statusColor;
                switch (attendance.status) {
                  case attendance_model.AttendanceStatus.present:
                    statusColor = Colors.green;
                    break;
                  case attendance_model.AttendanceStatus.absent:
                    statusColor = Colors.red;
                    break;
                  case attendance_model.AttendanceStatus.late:
                    statusColor = Colors.orange;
                    break;
<<<<<<< HEAD
                  case attendance_model.AttendanceStatus.excused:
                    statusColor = Colors.blue;
                    break;
                  // no default needed; all enum cases handled
=======
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b
                }
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.check_circle, color: statusColor),
                    title: Text(
                      attendance.subject,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(attendance.date),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        attendance.status.toString().split('.').last,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}

class AssignmentsView extends StatelessWidget {
  const AssignmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.currentUser!;
    final assignments = dataProvider.assignments
        .where((a) => a.className == user.className)
        .toList();

    return Container(
      color: Colors.purple.shade50,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Text(
              'Your Assignments',
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(assignment.title),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Deskripsi: ${assignment.description}'),
                                const SizedBox(height: 8),
                                Text('Mata Pelajaran: ${assignment.subject}'),
                                const SizedBox(height: 8),
                                Text('Deadline: ${assignment.dueDate}'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Tutup'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: ListTile(
                      leading: Icon(Icons.assignment, color: Colors.purple),
                      title: Text(
                        assignment.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${assignment.subject} - Due: ${assignment.dueDate}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.currentUser!;
    final grades = dataProvider.grades
        .where((g) => g.studentId == user.id)
        .toList();
    final attendances = dataProvider.attendances
        .where((a) => a.studentId == user.id)
        .toList();
    final assignments = dataProvider.assignments
        .where((a) => a.className == user.className)
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
                    'Nilai',
                    Icons.grade,
                    Colors.green,
                    grades.length,
                    () => _navigateToView(context, 0), // Grades
                  ),
                  _buildFeatureCard(
                    context,
                    'Kehadiran',
                    Icons.check_circle,
                    Colors.orange,
                    attendances.length,
                    () => _navigateToView(context, 1), // Attendance
                  ),
                  _buildFeatureCard(
                    context,
                    'Tugas',
                    Icons.assignment,
                    Colors.purple,
                    assignments.length,
                    () => _navigateToView(context, 2), // Assignments
                  ),
                  _buildFeatureCard(
                    context,
                    'Materi',
                    Icons.library_books,
                    Colors.teal,
                    0, // Placeholder for materials count
                    () => _navigateToView(context, 3), // Materials
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
    // Cards navigate to specific tool views
    // Card indices: 0=Grades, 1=Attendance, 2=Assignments, 3=Materials, 4=Announcements
    switch (index) {
      case 0:
        context.go('/student-dashboard/beranda/grades');
        break;
      case 1:
        context.go('/student-dashboard/beranda/attendance');
        break;
      case 2:
        context.go('/student-dashboard/beranda/assignments');
        break;
      case 3:
        context.go('/student-dashboard/beranda/materials');
        break;
      case 4:
        // Announcements: Keep modal since no separate screen exists
        _showToolView(context, index);
        break;
      default:
        break;
    }
  }

  void _showToolView(BuildContext context, int toolIndex) {
    Widget toolView = const SizedBox.shrink();
    String title = '';

    switch (toolIndex) {
      case 0:
        toolView = const GradesView();
        title = 'Nilai';
        break;
      case 1:
        toolView = const AttendanceView();
        title = 'Kehadiran';
        break;
      case 2:
        toolView = const AssignmentsView();
        title = 'Tugas';
        break;
      case 3:
        toolView = const MaterialsView();
        title = 'Materi';
        break;
      case 4:
        toolView = const AnnouncementsView();
        title = 'Pengumuman';
        break;
      default:
        return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF667EEA),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(child: toolView),
          ],
        ),
      ),
    );
  }
}

class MaterialsView extends StatelessWidget {
  const MaterialsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder for materials - you can expand this with actual materials data
    final materials = [
      {'title': 'Matematika Dasar', 'subject': 'Matematika', 'type': 'PDF'},
      {'title': 'Fisika Mekanika', 'subject': 'Fisika', 'type': 'Video'},
      {
        'title': 'Bahasa Indonesia',
        'subject': 'Bahasa Indonesia',
        'type': 'Dokumen',
      },
      {'title': 'Kimia Organik', 'subject': 'Kimia', 'type': 'PPT'},
    ];

    return Container(
      color: Colors.teal.shade50,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Text(
              'Materi Pembelajaran',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade900,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: materials.length,
              itemBuilder: (context, index) {
                final material = materials[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      _getMaterialIcon(material['type'] as String),
                      color: Colors.teal,
                      size: 32,
                    ),
                    title: Text(
                      material['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${material['subject']} - ${material['type']}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.download, color: Colors.teal),
                      onPressed: () {
                        // TODO: Implement download functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Downloading ${material['title']}'),
                          ),
                        );
                      },
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

  IconData _getMaterialIcon(String type) {
    switch (type) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'Video':
        return Icons.video_library;
      case 'PPT':
        return Icons.slideshow;
      case 'Dokumen':
        return Icons.description;
      default:
        return Icons.library_books;
    }
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
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
                          'Informasi Siswa',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF667EEA),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildProfileInfo('Nama Lengkap', user.name),
                        _buildProfileInfo('Jurusan', user.major ?? 'Tidak ada'),
                        _buildProfileInfo('NISN', user.nisn ?? 'Tidak ada'),
                        _buildProfileInfo(
                          'Jenis Kelamin',
                          user.gender ?? 'Tidak ada',
                        ),
                        _buildProfileInfo(
                          'Tempat Tanggal Lahir',
                          user.birthPlace != null && user.birthDate != null
                              ? '${user.birthPlace}, ${user.birthDate!.toLocal().toString().split(' ')[0]}'
                              : 'Tidak ada',
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

class AcademicCalendarView extends StatelessWidget {
  const AcademicCalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);

    // Sample academic events - you can replace with actual data
    final academicEvents = [
      {
        'date': DateTime(now.year, now.month, 15),
        'title': 'Ujian Tengah Semester',
        'type': 'exam',
      },
      {
        'date': DateTime(now.year, now.month, 20),
        'title': 'Libur Nasional',
        'type': 'holiday',
      },
      {
        'date': DateTime(now.year, now.month + 1, 5),
        'title': 'Workshop Matematika',
        'type': 'event',
      },
      {
        'date': DateTime(now.year, now.month + 1, 12),
        'title': 'Ujian Akhir Semester',
        'type': 'exam',
      },
    ];

    return Container(
      color: Colors.purple.shade50,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Text(
              'Kalender Akademik',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade900,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Current Month Calendar
                  _buildMonthCalendar(
                    currentMonth,
                    academicEvents,
                    'Bulan Ini',
                  ),
                  const SizedBox(height: 20),
                  // Next Month Calendar
                  _buildMonthCalendar(nextMonth, academicEvents, 'Bulan Depan'),
                  const SizedBox(height: 20),
                  // Upcoming Events
                  Container(
                    padding: const EdgeInsets.all(16),
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
                          'Acara Mendatang',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF667EEA),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...academicEvents
                            .where(
                              (event) =>
                                  (event['date'] as DateTime).isAfter(now) ||
                                  (event['date'] as DateTime).isAtSameMomentAs(
                                    DateTime(now.year, now.month, now.day),
                                  ),
                            )
                            .map((event) {
                              final date = event['date'] as DateTime;
                              final title = event['title'] as String;
                              final type = event['type'] as String;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: _getEventColor(type),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            '${date.day}/${date.month}/${date.year}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                      ],
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

  Widget _buildMonthCalendar(
    DateTime month,
    List<Map<String, dynamic>> events,
    String title,
  ) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final startingWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday

    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF667EEA),
            ),
          ),
          const SizedBox(height: 16),
          // Day headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                .map(
                  (day) => Container(
                    width: 32,
                    alignment: Alignment.center,
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: List.generate(daysInMonth + startingWeekday - 1, (index) {
              if (index < startingWeekday - 1) {
                return const SizedBox(width: 32, height: 32);
              }

              final day = index - startingWeekday + 2;
              final currentDate = DateTime(month.year, month.month, day);
              final hasEvent = events.any(
                (event) => event['date'] == currentDate,
              );

              return Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: hasEvent ? Colors.purple.shade100 : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: hasEvent ? FontWeight.bold : FontWeight.normal,
                    color: hasEvent ? Colors.purple.shade900 : Colors.black87,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'exam':
        return Colors.red;
      case 'holiday':
        return Colors.green;
      case 'event':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

// -------------------------------------------------------------------
// PERUBAHAN: class AnnouncementsView dimodifikasi
// -------------------------------------------------------------------
class AnnouncementsView extends StatelessWidget {
  const AnnouncementsView({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final announcements = dataProvider.announcements
        .where((a) => a.targetRole == 'all' || a.targetRole == 'student')
        .toList();

    return Container(
      color: Colors.red.shade50,
      // Mengganti Column -> ListView agar bisa di-scroll
      child: ListView(
        children: [
          // 1. Judul Pengumuman (dari DataProvider)
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Text(
              'Pengumuman',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade900,
              ),
            ),
          ),

          // 2. List Pengumuman (dari DataProvider)
          ListView.builder(
            itemCount: announcements.length,
            // Properti ini penting agar ListView.builder bisa ada di dalam ListView
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return Card(
<<<<<<< HEAD
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
=======
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b
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
                          const Icon(Icons.announcement, color: Colors.red),
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
<<<<<<< HEAD
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
=======
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
<<<<<<< HEAD

=======
          
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b
          // Menangani jika tidak ada pengumuman
          if (announcements.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Center(
                child: Text(
                  'Tidak ada pengumuman internal.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),

<<<<<<< HEAD
          // 3. Pemisah dan Judul Blog (dari API)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
=======

          // 3. Pemisah dan Judul Blog (dari API)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b
            child: Divider(thickness: 1, color: Colors.red.shade100),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              'Blog Terbaru (dari API)',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900, // Warna berbeda
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 4. Widget BlogView (dari API)
          const BlogView(),
<<<<<<< HEAD

=======
          
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b
          // 5. Padding di bagian bawah
          const SizedBox(height: 20),
        ],
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b
