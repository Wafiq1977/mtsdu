// File: lib/presentation/page/teacher/teacher_grades_input.dart

import 'package:flutter/material.dart';
import 'package:lpmmtsdu/domain/entity/user_entity.dart';
import 'package:provider/provider.dart';
import '../../../presentation/provider/auth_provider.dart';
import '../../../data/model/user.dart';
// Asumsi Anda memiliki model Grade dan DataProvider yang relevan
// import '../../../data/model/grade.dart';
// import '../../../presentation/provider/data_provider.dart';
import '../../../presentation/utils/user_role.dart';

class TeacherGradesInput extends StatefulWidget {
  const TeacherGradesInput({super.key});

  @override
  State<TeacherGradesInput> createState() => _TeacherGradesInputState();
}

class _TeacherGradesInputState extends State<TeacherGradesInput> {
  final _formKey = GlobalKey<FormState>();

  // Input Controllers untuk informasi kolektif
  final _subjectController = TextEditingController();
  final _gradeTypeController =
      TextEditingController(); // Misalnya: Quiz, UTS, UAS
  final _dateController = TextEditingController();

  // Filter Variables
  String? _selectedMajor;
  String? _selectedGrade;
  String? _selectedClass;

  List<String> _majorOptions = [];
  List<String> _gradeOptions = [];
  List<String> _classOptions = [];
  final List<String> _staticGradeOptions = ['10', '11', '12'];

  // Data Siswa
  List<User> _allStudents = []; // Semua siswa yang dimuat
  List<User> _filteredStudents = []; // Siswa dari kelas yang dipilih
  bool _isLoading = true;

  // Map untuk menyimpan TextEditingController score per siswa
  Map<String, TextEditingController> _scoreControllers = {};

  @override
  void initState() {
    super.initState();
    // Inisialisasi tanggal hari ini
    _dateController.text = DateTime.now().toString().split(' ')[0];
    _loadStudents();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _gradeTypeController.dispose();
    _dateController.dispose();
    _disposeScoreControllers();
    super.dispose();
  }

  void _disposeScoreControllers() {
    _scoreControllers.values.forEach((controller) => controller.dispose());
    _scoreControllers.clear();
  }

  // --- Helper: Mengambil Angkatan dari className ---
  String? _extractGrade(String? className) {
    if (className == null || className.length < 2) return null;
    final grade = className.substring(0, 2);
    return _staticGradeOptions.contains(grade) ? grade : null;
  }

  Future<void> _loadStudents() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Mengambil semua user (asumsi User Role sudah benar)
    final allUsers = await authProvider.getAllUsers();

    if (mounted) {
      setState(() {
        _allStudents = allUsers
            .where((u) => u.role == UserRole.student)
            .toList();

        // Inisialisasi Opsi Penjurusan
        _majorOptions =
            _allStudents
                .where((s) => s.major != null && s.major!.isNotEmpty)
                .map((s) => s.major!)
                .toSet()
                .toList()
              ..sort();

        _isLoading = false;
      });
    }
  }

  // CASCADE 1: Memperbarui opsi Angkatan berdasarkan Penjurusan
  void _updateGradeOptions(String? major) {
    if (!mounted) return;
    setState(() {
      _selectedMajor = major;
      _selectedGrade = null; // Reset
      _selectedClass = null; // Reset
      _gradeOptions = [];
      _classOptions = [];
      _filteredStudents = []; // Reset siswa
      _disposeScoreControllers(); // Hapus controller nilai lama

      if (_selectedMajor != null) {
        _gradeOptions =
            _allStudents
                .where(
                  (s) =>
                      s.major == _selectedMajor &&
                      _extractGrade(s.className) != null,
                )
                .map((s) => _extractGrade(s.className)!)
                .toSet()
                .toList()
              ..sort();
      }
    });
  }

  // CASCADE 2: Memperbarui opsi Kelas berdasarkan Penjurusan & Angkatan
  void _updateClassOptions(String? grade) {
    if (!mounted) return;
    setState(() {
      _selectedGrade = grade;
      _selectedClass = null; // Reset
      _classOptions = [];
      _filteredStudents = []; // Reset siswa
      _disposeScoreControllers(); // Hapus controller nilai lama

      if (_selectedMajor != null && _selectedGrade != null) {
        _classOptions =
            _allStudents
                .where(
                  (s) =>
                      s.major == _selectedMajor &&
                      _extractGrade(s.className) == _selectedGrade &&
                      s.className != null &&
                      s.className!.isNotEmpty,
                )
                .map((s) => s.className!)
                .toSet()
                .toList()
              ..sort();
      }
    });
  }

  // FINAL FILTER: Menerapkan semua filter dan memuat siswa ke tabel
  void _filterStudents(String? className) {
    if (!mounted) return;
    setState(() {
      _selectedClass = className;
      _filteredStudents = [];
      _disposeScoreControllers(); // Hapus controller nilai lama

      if (_selectedMajor != null &&
          _selectedGrade != null &&
          _selectedClass != null) {
        _filteredStudents = _allStudents.where((student) {
          return student.className == _selectedClass &&
              student.major == _selectedMajor &&
              _extractGrade(student.className) == _selectedGrade;
        }).toList();

        // Inisialisasi score controller untuk siswa yang difilter
        for (var student in _filteredStudents) {
          _scoreControllers[student.id] = TextEditingController();
        }
      }
      // Urutkan siswa berdasarkan nama
      _filteredStudents.sort((a, b) => a.name.compareTo(b.name));
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = picked.toString().split(' ')[0];
      });
    }
  }

  void _submitBulkGrades() {
    if (_formKey.currentState!.validate() && _filteredStudents.isNotEmpty) {
      _formKey.currentState!.save();

      final String subject = _subjectController.text;
      final String gradeType = _gradeTypeController.text;
      final String date = _dateController.text;
      final String? teacherId = context.read<AuthProvider>().currentUser?.id;

      if (teacherId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Teacher ID not found.')),
        );
        return;
      }

      List<Map<String, dynamic>> gradesToSave = [];

      // Kumpulkan semua nilai
      for (var student in _filteredStudents) {
        final scoreController = _scoreControllers[student.id];
        final scoreText = scoreController?.text.trim();

        if (scoreText != null && scoreText.isNotEmpty) {
          final score = double.tryParse(scoreText);

          if (score != null && score >= 0 && score <= 100) {
            // Asumsi model Grade Anda memiliki konstruktor ini
            // final grade = Grade(
            //   id: UniqueKey().toString(),
            //   studentId: student.id,
            //   subject: subject,
            //   gradeType: gradeType,
            //   date: date,
            //   score: score,
            //   teacherId: teacherId,
            // );
            // gradesToSave.add(grade.toMap());

            // Simulasi data yang akan disimpan:
            gradesToSave.add({
              'studentName': student.name,
              'score': score,
              'subject': subject,
              'gradeType': gradeType,
              'date': date,
            });
          }
        }
      }

      if (gradesToSave.isNotEmpty) {
        // TODO: Panggil DataProvider untuk menyimpan gradesToSave
        // context.read<DataProvider>().addBulkGrades(gradesToSave);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${gradesToSave.length} nilai untuk kelas $_selectedClass berhasil disimpan!',
            ),
          ),
        );
        // Clear form setelah simpan
        _subjectController.clear();
        _gradeTypeController.clear();
        _dateController.text = DateTime.now().toString().split(' ')[0];
        _scoreControllers.values.forEach((c) => c.clear());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada nilai yang valid untuk disimpan.'),
          ),
        );
      }
    } else if (_filteredStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih Kelas Siswa terlebih dahulu')),
      );
    }
  }

  // Widget untuk menampilkan daftar siswa dan kolom input nilai
  Widget _buildStudentGradeList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Input Nilai untuk ${_selectedClass ?? 'Pilih Kelas'} (${_filteredStudents.length} Siswa)',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Divider(),

        // Header Tabel
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Nama Siswa',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    'Nilai',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Daftar Siswa
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredStudents.length,
          itemBuilder: (context, index) {
            final student = _filteredStudents[index];
            final controller = _scoreControllers[student.id]!;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          student.className ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: TextFormField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          hintText: 'Nilai',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return null; // Opsional dikosongkan
                          final n = double.tryParse(value);
                          if (n == null || n < 0 || n > 100) return '0-100';
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _filteredStudents.isEmpty ? null : _submitBulkGrades,
            icon: const Icon(Icons.save),
            label: const Text('Simpan Semua Nilai'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF667EEA),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Nilai Massal Per Kelas'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
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
                    // --- Filter Kelas (3 Tingkat) ---
                    _buildFilterSection(),

                    const SizedBox(height: 24),

                    // --- Input Data Kolektif Tugas ---
                    _buildAssignmentDetailsInput(),

                    // --- Daftar Siswa dan Input Nilai Massal ---
                    if (_filteredStudents.isNotEmpty) _buildStudentGradeList(),
                  ],
                ),
              ),
            ),
    );
  }

  // Widget terpisah untuk bagian Filter
  Widget _buildFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Kelas Tujuan:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        // 1. Penjurusan
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Pilih Penjurusan',
            border: OutlineInputBorder(),
          ),
          value: _selectedMajor,
          items: _majorOptions
              .map(
                (major) => DropdownMenuItem(value: major, child: Text(major)),
              )
              .toList(),
          onChanged: _updateGradeOptions, // CASCADE
          hint: const Text('Pilih Penjurusan'),
          validator: (value) =>
              value == null ? 'Penjurusan wajib dipilih' : null,
        ),
        const SizedBox(height: 12),

        // 2. Angkatan
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Pilih Angkatan',
            border: OutlineInputBorder(),
          ),
          value: _selectedGrade,
          items: _selectedMajor == null || _gradeOptions.isEmpty
              ? [
                  const DropdownMenuItem(
                    value: null,
                    child: Text(
                      'Pilih Penjurusan dulu',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ]
              : _gradeOptions
                    .map(
                      (grade) => DropdownMenuItem(
                        value: grade,
                        child: Text('Kelas $grade'),
                      ),
                    )
                    .toList(),
          onChanged: _selectedMajor == null
              ? null
              : _updateClassOptions, // CASCADE
          hint: const Text('Pilih Angkatan'),
          validator: (value) => value == null ? 'Angkatan wajib dipilih' : null,
        ),
        const SizedBox(height: 12),

        // 3. Kelas
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Pilih Kelas',
            border: OutlineInputBorder(),
          ),
          value: _selectedClass,
          items: _selectedGrade == null || _classOptions.isEmpty
              ? [
                  const DropdownMenuItem(
                    value: null,
                    child: Text(
                      'Pilih Angkatan dulu',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ]
              : _classOptions
                    .map(
                      (className) => DropdownMenuItem(
                        value: className,
                        child: Text(className),
                      ),
                    )
                    .toList(),
          onChanged: _selectedGrade == null
              ? null
              : _filterStudents, // FINAL FILTER: Muat siswa ke tabel
          hint: const Text('Pilih Kelas'),
          validator: (value) => value == null ? 'Kelas wajib dipilih' : null,
        ),
      ],
    );
  }

  // Widget terpisah untuk Input Detail Tugas
  Widget _buildAssignmentDetailsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detail Penugasan:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        TextFormField(
          controller: _subjectController,
          decoration: const InputDecoration(
            labelText: 'Mata Pelajaran',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.book),
          ),
          validator: (v) => v!.isEmpty ? 'Mata Pelajaran wajib diisi' : null,
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _gradeTypeController,
          decoration: const InputDecoration(
            labelText: 'Jenis Nilai (Contoh: Quiz, UTS, UAS)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.assignment),
          ),
          validator: (v) => v!.isEmpty ? 'Jenis Nilai wajib diisi' : null,
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _dateController,
          decoration: const InputDecoration(
            labelText: 'Tanggal Penilaian',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.calendar_today),
          ),
          readOnly: true,
          onTap: () => _selectDate(context),
          validator: (v) => v!.isEmpty ? 'Tanggal wajib diisi' : null,
        ),
      ],
    );
  }
}
