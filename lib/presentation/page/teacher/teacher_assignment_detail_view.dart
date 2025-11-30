// File: lib/presentation/page/teacher/teacher_assignment_detail_view.dart

import 'package:flutter/material.dart';
import 'package:lpmmtsdu/domain/entity/user_entity.dart';
import 'package:provider/provider.dart';
import '../../../data/model/assignment.dart';
import '../../../data/model/user.dart';
import '../../../presentation/provider/auth_provider.dart';
import '../../../presentation/utils/user_role.dart';
import 'teacher_input_grades_view.dart';

class TeacherAssignmentDetailView extends StatefulWidget {
  final Assignment assignment;

  const TeacherAssignmentDetailView({super.key, required this.assignment});

  @override
  State<TeacherAssignmentDetailView> createState() =>
      _TeacherAssignmentDetailViewState();
}

class _TeacherAssignmentDetailViewState
    extends State<TeacherAssignmentDetailView> {
  List<User> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    // Di sini kita mengambil semua siswa
    // Idealnya, filter siswa berdasarkan Kelas yang ditugaskan pada assignment
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final allUsers = await authProvider.getAllUsers();

    if (mounted) {
      setState(() {
        _students = allUsers.where((u) => u.role == UserRole.student).toList();
        _isLoading = false;
      });
    }
  }

  void _navigateToGrading(User student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherInputGradesView(
          preSelectedStudent: student,
          preSelectedSubject: widget.assignment.subject,
          preSelectedAssignmentTitle: widget.assignment.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tugas & Pengumpulan'),
        backgroundColor: const Color(0xFF667EEA),
      ),
      body: Column(
        children: [
          // Bagian Detail Tugas (Header)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.assignment.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Deadline: ${widget.assignment.dueDate}",
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.assignment.description,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                const Divider(),
                Row(
                  children: [
                    const Icon(Icons.subject, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      widget.assignment.subject,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bagian List Pengumpulan Siswa
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      // Simulasi status pengumpulan (Random/Mock)
                      // Nanti diganti dengan cek database apakah siswa sudah submit
                      final bool isSubmitted = index % 3 != 0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSubmitted
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            child: Icon(
                              Icons.person,
                              color: isSubmitted ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(student.name),
                          subtitle: Text(
                            isSubmitted
                                ? "Sudah Mengumpulkan"
                                : "Belum Mengumpulkan",
                            style: TextStyle(
                              color: isSubmitted ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => _navigateToGrading(student),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667EEA),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text("Nilai"),
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
