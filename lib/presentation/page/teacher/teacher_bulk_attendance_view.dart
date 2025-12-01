import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/provider/auth_provider.dart';
import '../../../presentation/provider/data_provider.dart';
import '../../../data/model/attendance.dart';
import '../../../data/model/user.dart';
import '../../../domain/entity/attendance_entity.dart';
import '../../../domain/entity/user_entity.dart';

class TeacherBulkAttendanceView extends StatefulWidget {
  const TeacherBulkAttendanceView({super.key});

  @override
  State<TeacherBulkAttendanceView> createState() =>
      _TeacherBulkAttendanceViewState();
}

class _TeacherBulkAttendanceViewState extends State<TeacherBulkAttendanceView> {
  final _subjectController = TextEditingController();
  final _dateController = TextEditingController();
  Map<String, AttendanceStatus> _attendanceMap = {};
  List<User> _students = [];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toString().split(
      ' ',
    )[0]; // Today's date
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final allUsers = await authProvider.getAllUsers();
    if (mounted) {
      setState(() {
        _students = allUsers.where((u) => u.role == UserRole.student).toList();
        // Initialize all students as present by default
        for (var student in _students) {
          _attendanceMap[student.id] = AttendanceStatus.present;
        }
      });
    }
  }

  void _updateAttendance(String studentId, AttendanceStatus status) {
    setState(() {
      _attendanceMap[studentId] = status;
    });
  }

  void _submitAttendance() async {
    if (_subjectController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter subject')));
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final user = authProvider.currentUser!;

    for (var student in _students) {
      final attendance = Attendance(
        id: '${student.id}_${_dateController.text}_${_subjectController.text}',
        studentId: student.id,
        subject: _subjectController.text,
        date: _dateController.text,
        status: _attendanceMap[student.id] ?? AttendanceStatus.present,
        teacherId: user.id,
      );

      await dataProvider.addAttendance(attendance);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance saved successfully')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Attendance Input'),
        backgroundColor: const Color(0xFF667EEA),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitAttendance,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with subject and date input
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                TextField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.subject),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _dateController.text = pickedDate.toString().split(
                          ' ',
                        )[0];
                      });
                    }
                  },
                ),
              ],
            ),
          ),

          // Student list with checkboxes
          Expanded(
            child: ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                final currentStatus =
                    _attendanceMap[student.id] ?? AttendanceStatus.present;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ID: ${student.id} | Class: ${student.className}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildStatusButton(
                              student.id,
                              AttendanceStatus.present,
                              currentStatus,
                              'Present',
                              Colors.green,
                            ),
                            const SizedBox(width: 8),
                            _buildStatusButton(
                              student.id,
                              AttendanceStatus.absent,
                              currentStatus,
                              'Absent',
                              Colors.red,
                            ),
                            const SizedBox(width: 8),
                            _buildStatusButton(
                              student.id,
                              AttendanceStatus.late,
                              currentStatus,
                              'Late',
                              Colors.orange,
                            ),
                          ],
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

  Widget _buildStatusButton(
    String studentId,
    AttendanceStatus status,
    AttendanceStatus currentStatus,
    String label,
    Color color,
  ) {
    final isSelected = currentStatus == status;

    return Expanded(
      child: ElevatedButton(
        onPressed: () => _updateAttendance(studentId, status),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? color : Colors.grey[300],
          foregroundColor: isSelected ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}
