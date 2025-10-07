import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../providers/theme_provider.dart';
import '../models/schedule.dart';
import '../models/grade.dart';
import '../models/attendance.dart';
import '../models/assignment.dart';
import '../models/announcement.dart';
import '../widgets/user_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/animated_navigation_bar.dart';
import '../widgets/statistics_widget.dart';
import 'teacher_input_grades_view.dart';
import 'teacher_input_attendance_view.dart';
import 'teacher_bulk_attendance_view.dart';
import 'teacher_input_assignment_view.dart';


class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _selectedIndex = 0;
  bool _showTools = false;
  String? _selectedDay;

  static const List<Widget> _widgetOptions = <Widget>[
    GradesInputView(),
    AttendanceInputView(),
    AssignmentsView(),
    AnnouncementsView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleTools() {
    setState(() {
      _showTools = !_showTools;
    });
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
                    children: daySchedules.map((schedule) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Icon(Icons.schedule, color: Theme.of(context).primaryColor),
                        title: Text(schedule.subject),
                        subtitle: Text('${schedule.time} - Room: ${schedule.room} - Class: ${schedule.className}'),
                      ),
                    )).toList(),
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
        backgroundColor: _selectedDay == day ? const Color(0xFF667EEA) : Colors.grey[300],
        foregroundColor: _selectedDay == day ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        day.substring(0, 3), // Show first 3 letters
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  void _showProfileDialog(BuildContext context, user, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) {
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
                            backgroundImage: AssetImage(user.profileImagePath!),
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
                  // Theme Toggle Section
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return Row(
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
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Statistics Section
                  const StatisticsWidget(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      authProvider.logout();
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacementNamed('/');
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
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _showProfileDialog(context, user, authProvider),
                      child: user.profileImagePath != null
                          ? CircleAvatar(
                              radius: 20,
                              backgroundImage: AssetImage(user.profileImagePath!),
                            )
                          : const CircleAvatar(
                              radius: 20,
                              child: Icon(Icons.person),
                            ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LPMMTSDU',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Welcome, ${user.name}!',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          'Subject: ${user.subject ?? "General"}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () {
                        authProvider.logout();
                        Navigator.of(context).pushReplacementNamed('/');
                      },
                    ),
                  ],
                ),
              ),

              // Content Area
              Expanded(
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
                    child: _widgetOptions.elementAt(_selectedIndex),
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              onPressed: _toggleTools,
              backgroundColor: const Color(0xFF667EEA),
              child: Icon(_showTools ? Icons.close : Icons.build),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 80),
            child: FloatingActionButton(
              onPressed: () => _showAddDialog(context),
              backgroundColor: const Color(0xFF667EEA),
              child: const Icon(Icons.add),
            ),
          ),
        ],
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
                icon: Icon(Icons.grade),
                label: 'Input Grades',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_circle),
                label: 'Attendance',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment),
                label: 'Assignments',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.announcement),
                label: 'Announcements',
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

  void _showAddDialog(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        // Navigate to dedicated grades input screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TeacherInputGradesView()),
        );
        break;
      case 1:
        // Show attendance options dialog
        _showAttendanceOptionsDialog(context);
        break;
      case 2:
        _showAddAssignmentDialog(context);
        break;
      case 3:
        _showAddAnnouncementDialog(context);
        break;
    }
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
              Navigator.pop(context); // Close dialog
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TeacherInputAttendanceView()),
              );
            },
            child: const Text('Single Student'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TeacherBulkAttendanceView()),
              );
            },
            child: const Text('Bulk Input'),
          ),
        ],
      ),
    );
  }

  void _showAddGradeDialog(BuildContext context) {
    final studentIdController = TextEditingController();
    final subjectController = TextEditingController();
    final assignmentController = TextEditingController();
    final scoreController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Grade'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: studentIdController, decoration: const InputDecoration(labelText: 'Student ID')),
            TextField(controller: subjectController, decoration: const InputDecoration(labelText: 'Subject')),
            TextField(controller: assignmentController, decoration: const InputDecoration(labelText: 'Assignment')),
            TextField(controller: scoreController, decoration: const InputDecoration(labelText: 'Score'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final dataProvider = Provider.of<DataProvider>(context, listen: false);
              final user = authProvider.currentUser!;

              final grade = Grade(
                id: DateTime.now().toString(),
                studentId: studentIdController.text,
                subject: subjectController.text,
                assignment: assignmentController.text,
                score: double.parse(scoreController.text),
                date: DateTime.now().toString(),
                teacherId: user.id,
              );

              await dataProvider.addGrade(grade);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddAttendanceDialog(BuildContext context) {
    final studentIdController = TextEditingController();
    final subjectController = TextEditingController();
    AttendanceStatus selectedStatus = AttendanceStatus.present;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Attendance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: studentIdController, decoration: const InputDecoration(labelText: 'Student ID')),
            TextField(controller: subjectController, decoration: const InputDecoration(labelText: 'Subject')),
            DropdownButton<AttendanceStatus>(
              value: selectedStatus,
              items: AttendanceStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedStatus = value!),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final dataProvider = Provider.of<DataProvider>(context, listen: false);
              final user = authProvider.currentUser!;

              final attendance = Attendance(
                id: DateTime.now().toString(),
                studentId: studentIdController.text,
                subject: subjectController.text,
                date: DateTime.now().toString(),
                status: selectedStatus,
                teacherId: user.id,
              );

              await dataProvider.addAttendance(attendance);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddAssignmentDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TeacherInputAssignmentView()),
    );
  }

  void _showAddAnnouncementDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Announcement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: contentController, decoration: const InputDecoration(labelText: 'Content'), maxLines: 3),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final dataProvider = Provider.of<DataProvider>(context, listen: false);
              final user = authProvider.currentUser!;

              final announcement = Announcement(
                id: DateTime.now().toString(),
                title: titleController.text,
                content: contentController.text,
                authorId: user.id,
                date: DateTime.now(),
                targetRole: 'all',
              );

              await dataProvider.addAnnouncement(announcement);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }


}

class GradesInputView extends StatelessWidget {
  const GradesInputView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.currentUser!;
    final grades = dataProvider.grades.where((g) => g.teacherId == user.id).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.purple[100],
          width: double.infinity,
          child: const Text(
            'Grades Input',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: grades.length,
            itemBuilder: (context, index) {
              final grade = grades[index];
              Color scoreColor;
              if (grade.score >= 80) {
                scoreColor = Colors.green;
              } else if (grade.score >= 60) {
                scoreColor = Colors.orange;
              } else {
                scoreColor = Colors.red;
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.grade, color: Colors.purple),
                  title: Text(
                    grade.assignment,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${grade.subject} - Student ID: ${grade.studentId}'),
                      Text('Date: ${grade.date}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: scoreColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${grade.score.toStringAsFixed(1)}',
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
    );
  }
}

class AttendanceInputView extends StatelessWidget {
  const AttendanceInputView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.currentUser!;
    final attendances = dataProvider.attendances.where((a) => a.teacherId == user.id).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.teal[100],
          width: double.infinity,
          child: const Text(
            'Attendance Input',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
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
                case AttendanceStatus.present:
                  statusColor = Colors.green;
                  break;
                case AttendanceStatus.absent:
                  statusColor = Colors.red;
                  break;
                case AttendanceStatus.late:
                  statusColor = Colors.orange;
                  break;
                default:
                  statusColor = Colors.grey;
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.teal),
                  title: Text(
                    attendance.subject,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Student ID: ${attendance.studentId}'),
                      Text('Date: ${attendance.date}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    final assignments = dataProvider.assignments.where((a) => a.teacherId == user.id).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue[100],
          width: double.infinity,
          child: const Text(
            'Assignments',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final assignment = assignments[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.assignment, color: Colors.blue),
                  title: Text(
                    assignment.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(assignment.description),
                      const SizedBox(height: 4),
                      Text(
                        '${assignment.subject} - Class: ${assignment.className}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Due: ${assignment.dueDate}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.grey),
                    onPressed: () {
                      // TODO: Implement edit assignment
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class AnnouncementsView extends StatelessWidget {
  const AnnouncementsView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.currentUser!;
    final announcements = dataProvider.announcements.where((a) => a.authorId == user.id).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.orange[100],
          width: double.infinity,
          child: const Text(
            'Announcements',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.announcement, color: Colors.orange),
                  title: Text(
                    announcement.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Posted: ${announcement.date}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Target: ${announcement.targetRole}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.grey),
                    onPressed: () {
                      // TODO: Implement edit announcement
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


