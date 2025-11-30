// File: lib/presentation/page/teacher/teacher_input_grades_view.dart

import 'package:flutter/material.dart';
import 'package:lpmmtsdu/domain/entity/user_entity.dart';
import 'package:provider/provider.dart';
import '../../../presentation/provider/auth_provider.dart';
import '../../../data/model/grade.dart';
import '../../../data/model/user.dart';
import '../../../presentation/utils/user_role.dart';

class TeacherInputGradesView extends StatefulWidget {
  // Tambahkan parameter opsional untuk menerima data dari halaman Detail Tugas
  final User? preSelectedStudent;
  final String? preSelectedSubject;
  final String? preSelectedAssignmentTitle;

  const TeacherInputGradesView({
    super.key,
    this.preSelectedStudent,
    this.preSelectedSubject,
    this.preSelectedAssignmentTitle,
  });

  @override
  State<TeacherInputGradesView> createState() => _TeacherInputGradesViewState();
}

class _TeacherInputGradesViewState extends State<TeacherInputGradesView> {
  final _formKey = GlobalKey<FormState>();
  User? _selectedStudent;
  late TextEditingController _subjectController;
  late TextEditingController _assignmentController;
  late TextEditingController _scoreController;

  List<User> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data lemparan jika ada
    _selectedStudent = widget.preSelectedStudent;
    _subjectController = TextEditingController(
      text: widget.preSelectedSubject ?? '',
    );
    _assignmentController = TextEditingController(
      text: widget.preSelectedAssignmentTitle ?? '',
    );
    _scoreController = TextEditingController();

    _loadStudents();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _assignmentController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final allUsers = await authProvider.getAllUsers();

    if (mounted) {
      setState(() {
        _students = allUsers.where((u) => u.role == UserRole.student).toList();
        _isLoading = false;
      });
    }
  }

  void _submitGrade() {
    if (_formKey.currentState!.validate() && _selectedStudent != null) {
      _formKey.currentState!.save();

      // Logika simpan grade (bisa ditambahkan provider call di sini)
      // final grade = Grade(..., studentId: _selectedStudent!.id, ...);
      // context.read<DataProvider>().addGrade(grade);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Nilai untuk ${_selectedStudent!.name} berhasil disimpan',
          ),
        ),
      );
      Navigator.pop(context); // Kembali ke layar sebelumnya
    } else if (_selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih siswa terlebih dahulu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Nilai Siswa'),
        backgroundColor: const Color(0xFF667EEA),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dropdown Siswa (Disable jika sudah ada preSelectedStudent)
                    DropdownButtonFormField<User>(
                      value: _students.any((s) => s.id == _selectedStudent?.id)
                          ? _selectedStudent
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Pilih Siswa',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: _students.map((student) {
                        return DropdownMenuItem(
                          value: student,
                          child: Text(student.name),
                        );
                      }).toList(),
                      onChanged: widget.preSelectedStudent != null
                          ? null // Disable jika dari detail screen
                          : (value) => setState(() => _selectedStudent = value),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                        labelText: 'Mata Pelajaran',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.book),
                      ),
                      // ReadOnly jika data dilempar dari screen sebelumnya
                      readOnly: widget.preSelectedSubject != null,
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _assignmentController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Tugas / Ujian',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.assignment),
                      ),
                      readOnly: widget.preSelectedAssignmentTitle != null,
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _scoreController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nilai (0-100)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.grade),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Masukkan nilai';
                        final n = double.tryParse(value);
                        if (n == null || n < 0 || n > 100)
                          return 'Nilai tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submitGrade,
                        icon: const Icon(Icons.save),
                        label: const Text('Simpan Nilai'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF667EEA),
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
