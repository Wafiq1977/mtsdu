import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../models/attendance.dart';
import '../models/user.dart';
import '../widgets/user_card.dart';

class TeacherInputAttendanceView extends StatefulWidget {
  const TeacherInputAttendanceView({super.key});

  @override
  State<TeacherInputAttendanceView> createState() => _TeacherInputAttendanceViewState();
}

class _TeacherInputAttendanceViewState extends State<TeacherInputAttendanceView> {
  final _formKey = GlobalKey<FormState>();
  User? _selectedStudent;
  final _subjectController = TextEditingController();
  AttendanceStatus? _status;
  List<User> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final allUsers = await authProvider.getAllUsers();
    setState(() {
      _students = allUsers.where((u) => u.role == UserRole.student).toList();
      _isLoading = false;
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _status != null && _selectedStudent != null) {
      _formKey.currentState!.save();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final user = authProvider.currentUser!;

      final attendance = Attendance(
        id: DateTime.now().toString(),
        studentId: _selectedStudent!.id,
        subject: _subjectController.text,
        date: DateTime.now().toString(),
        status: _status!,
        teacherId: user.id,
      );

      await dataProvider.addAttendance(attendance);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance added successfully')),
      );
      _formKey.currentState!.reset();
      _subjectController.clear();
      setState(() {
        _selectedStudent = null;
        _status = null;
      });
    } else if (_selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a student')),
      );
    } else if (_status == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select attendance status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser!;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Student Attendance'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          UserCard(user: user),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            DropdownButtonFormField<User>(
                              value: _selectedStudent,
                              decoration: const InputDecoration(
                                labelText: 'Select Student',
                                prefixIcon: Icon(Icons.person, color: Colors.blue),
                                border: OutlineInputBorder(),
                              ),
                              items: _students.map((student) {
                                return DropdownMenuItem<User>(
                                  value: student,
                                  child: Text('${student.name} (ID: ${student.id})'),
                                );
                              }).toList(),
                              onChanged: (User? newValue) {
                                setState(() {
                                  _selectedStudent = newValue;
                                });
                              },
                              validator: (value) => value == null ? 'Please select a student' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _subjectController,
                              decoration: const InputDecoration(
                                labelText: 'Subject',
                                prefixIcon: Icon(Icons.subject, color: Colors.blue),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Subject is required' : null,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<AttendanceStatus>(
                              value: _status,
                              decoration: const InputDecoration(
                                labelText: 'Attendance Status',
                                prefixIcon: Icon(Icons.check_circle, color: Colors.blue),
                                border: OutlineInputBorder(),
                              ),
                              items: AttendanceStatus.values.map((AttendanceStatus status) {
                                return DropdownMenuItem<AttendanceStatus>(
                                  value: status,
                                  child: Text(status.toString().split('.').last),
                                );
                              }).toList(),
                              onChanged: (AttendanceStatus? newValue) {
                                setState(() {
                                  _status = newValue;
                                });
                              },
                              validator: (value) =>
                                  value == null ? 'Select attendance status' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.save),
                      label: const Text('Add Attendance'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
