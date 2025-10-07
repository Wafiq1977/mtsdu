import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../models/grade.dart';
import '../models/user.dart';
import '../widgets/user_card.dart';

class TeacherInputGradesView extends StatefulWidget {
  const TeacherInputGradesView({super.key});

  @override
  State<TeacherInputGradesView> createState() => _TeacherInputGradesViewState();
}

class _TeacherInputGradesViewState extends State<TeacherInputGradesView> {
  final _formKey = GlobalKey<FormState>();
  User? _selectedStudent;
  String _subject = '';
  String _assignment = '';
  double _score = 0.0;
  List<User> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final allUsers = await authProvider.getAllUsers();
    setState(() {
      _students = allUsers.where((u) => u.role == UserRole.student).toList();
      _isLoading = false;
    });
  }

  void _submitGrade() {
    if (_formKey.currentState!.validate() && _selectedStudent != null) {
      _formKey.currentState!.save();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final user = authProvider.currentUser!;

      final grade = Grade(
        id: DateTime.now().toString(),
        studentId: _selectedStudent!.id,
        subject: _subject,
        assignment: _assignment,
        score: _score,
        date: DateTime.now().toString(),
        teacherId: user.id,
      );

      dataProvider.addGrade(grade);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Grade added successfully')),
      );
      _formKey.currentState!.reset();
      setState(() {
        _selectedStudent = null;
      });
    } else if (_selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a student')),
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
        title: const Text('Input Student Grades'),
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
                              decoration: const InputDecoration(
                                labelText: 'Subject',
                                prefixIcon: Icon(Icons.subject, color: Colors.blue),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => value!.isEmpty ? 'Subject is required' : null,
                              onSaved: (value) => _subject = value!,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Assignment',
                                prefixIcon: Icon(Icons.assignment, color: Colors.blue),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => value!.isEmpty ? 'Assignment is required' : null,
                              onSaved: (value) => _assignment = value!,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Score (0-100)',
                                prefixIcon: Icon(Icons.grade, color: Colors.blue),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value!.isEmpty) return 'Score is required';
                                final score = double.tryParse(value);
                                if (score == null || score < 0 || score > 100) {
                                  return 'Enter a valid score between 0 and 100';
                                }
                                return null;
                              },
                              onSaved: (value) => _score = double.parse(value!),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _submitGrade,
                      icon: const Icon(Icons.save),
                      label: const Text('Add Grade'),
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
