// File: lib/presentation/page/teacher/teacher_input_grades_view.dart

import 'package:flutter/material.dart';
import 'package:lpmmtsdu/domain/entity/user_entity.dart';
import 'package:provider/provider.dart';
import '../../../presentation/provider/auth_provider.dart';
import '../../../data/model/grade.dart';
import '../../../data/model/user.dart';
import '../../../presentation/utils/user_role.dart';

class TeacherInputGradesView extends StatefulWidget {
  // Parameter opsional untuk menerima data dari halaman Detail Tugas
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

  List<User> _allStudents = []; // Daftar semua siswa yang dimuat
  bool _isLoading = true;

  // --- Variabel untuk Filtrasi Tiga Tingkat ---
  List<User> _filteredStudentsList = []; // Daftar siswa yang difilter

  String? _selectedMajor;
  String? _selectedGrade;
  String? _selectedClass;

  List<String> _majorOptions = [];
  List<String> _gradeOptions = [];
  List<String> _classOptions = [];
  final List<String> _staticGradeOptions = ['10', '11', '12'];

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

  // --- Helper: Mengambil Angkatan dari className ---
  String? _extractGrade(String? className) {
    if (className == null || className.length < 2) return null;
    // Ambil 2 karakter pertama (contoh: "10A" -> "10")
    final grade = className.substring(0, 2);
    return _staticGradeOptions.contains(grade) ? grade : null;
  }

  Future<void> _loadStudents() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final allUsers = await authProvider.getAllUsers();

    if (mounted) {
      setState(() {
        _allStudents = allUsers
            .where((u) => u.role == UserRole.student)
            .toList();

        // 1. Inisialisasi Opsi Penjurusan
        _majorOptions =
            _allStudents
                .where((s) => s.major != null && s.major!.isNotEmpty)
                .map((s) => s.major!)
                .toSet()
                .toList()
              ..sort();

        // 2. Jika ada siswa pre-selected (dari assignment), set filter awal
        if (widget.preSelectedStudent != null) {
          _selectedStudent = widget.preSelectedStudent;

          // Set filter berdasarkan data siswa
          _selectedClass = _selectedStudent!.className;
          _selectedMajor = _selectedStudent!.major;
          _selectedGrade = _extractGrade(_selectedStudent!.className);

          // Muat siswa yang sesuai dengan filter (hanya untuk mengisi dropdown/list)
          _filterStudents(initialLoad: true);
        }

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
      _selectedStudent = null; // Reset siswa
      _gradeOptions = [];
      _classOptions = [];
      _filteredStudentsList = []; // Reset siswa yang ditampilkan

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
      _selectedStudent = null; // Reset siswa
      _classOptions = [];
      _filteredStudentsList = []; // Reset siswa yang ditampilkan

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

  // FINAL FILTER: Menerapkan semua filter dan mengisi dropdown siswa
  void _filterStudents({bool initialLoad = false}) {
    if (!mounted) return;
    setState(() {
      if (_selectedMajor == null ||
          _selectedGrade == null ||
          _selectedClass == null) {
        _filteredStudentsList = [];
      } else {
        _filteredStudentsList = _allStudents.where((student) {
          return student.className == _selectedClass &&
              student.major == _selectedMajor &&
              _extractGrade(student.className) == _selectedGrade;
        }).toList();

        // Pastikan siswa yang sudah terpilih tetap terpilih jika dia ada di list
        if (!initialLoad &&
            _selectedStudent != null &&
            !_filteredStudentsList.any((s) => s.id == _selectedStudent!.id)) {
          _selectedStudent = null;
        }
      }
      // Urutkan siswa berdasarkan nama
      _filteredStudentsList.sort((a, b) => a.name.compareTo(b.name));
    });
  }

  void _submitGrade() {
    if (_formKey.currentState!.validate() && _selectedStudent != null) {
      _formKey.currentState!.save();

      // Logika simpan grade (panggil provider di sini)
      // final teacherId = context.read<AuthProvider>().currentUser?.id;
      // final grade = Grade(
      //   id: UniqueKey().toString(),
      //   studentId: _selectedStudent!.id,
      //   subject: _subjectController.text,
      //   gradeType: _assignmentController.text, // Menggunakan assignmentController sebagai jenis nilai
      //   date: DateTime.now().toIso8601String().split('T')[0],
      //   score: double.parse(_scoreController.text),
      //   teacherId: teacherId!,
      // );
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
    // Tentukan apakah form ini diakses dari detail tugas atau manual
    final bool isPreSelectedMode = widget.preSelectedStudent != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isPreSelectedMode ? 'Input Nilai Tugas' : 'Input Nilai Siswa Tunggal',
        ),
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
                    // ===================================
                    // 1. Dropdown Filter (Hanya tampil jika tidak ada pre-selected student)
                    // ===================================
                    if (!isPreSelectedMode) ...[
                      const Text(
                        'Cari Siswa Berdasarkan Kelas:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 1.1 Penjurusan
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Pilih Penjurusan',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedMajor,
                        items: _majorOptions
                            .map(
                              (major) => DropdownMenuItem(
                                value: major,
                                child: Text(major),
                              ),
                            )
                            .toList(),
                        onChanged: _updateGradeOptions, // CASCADE
                        hint: const Text('Pilih Penjurusan'),
                        validator: (value) =>
                            value == null ? 'Penjurusan wajib dipilih' : null,
                      ),
                      const SizedBox(height: 12),

                      // 1.2 Angkatan
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
                        validator: (value) =>
                            value == null ? 'Angkatan wajib dipilih' : null,
                      ),
                      const SizedBox(height: 12),

                      // 1.3 Kelas
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
                            : (value) {
                                setState(() {
                                  _selectedClass = value;
                                  _filterStudents(); // FINAL FILTER: Muat siswa ke dropdown
                                });
                              },
                        hint: const Text('Pilih Kelas'),
                        validator: (value) =>
                            value == null ? 'Kelas wajib dipilih' : null,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ===================================
                    // 2. Dropdown Siswa
                    // ===================================
                    DropdownButtonFormField<User>(
                      value: _selectedStudent,
                      decoration: InputDecoration(
                        labelText: isPreSelectedMode
                            ? 'Siswa (Dari Tugas)'
                            : 'Pilih Siswa',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      // Jika PreSelected, tampilkan hanya siswa tersebut dan nonaktifkan
                      items: isPreSelectedMode
                          ? [
                              DropdownMenuItem(
                                value: _selectedStudent,
                                child: Text(
                                  '${_selectedStudent!.name} (${_selectedStudent!.className})',
                                ),
                              ),
                            ]
                          // Jika mode manual, tampilkan daftar siswa yang sudah difilter
                          : _filteredStudentsList.map((student) {
                              return DropdownMenuItem(
                                value: student,
                                child: Text(
                                  '${student.name} (${student.className})',
                                ),
                              );
                            }).toList(),

                      // Nonaktifkan interaksi jika isPreSelectedMode=true
                      onChanged: isPreSelectedMode
                          ? null
                          : (value) => setState(() => _selectedStudent = value),

                      validator: (value) =>
                          value == null ? 'Siswa wajib dipilih' : null,
                    ),
                    const SizedBox(height: 16),

                    // ===================================
                    // 3. Input Detail Nilai
                    // ===================================
                    TextFormField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                        labelText: 'Mata Pelajaran',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.book),
                      ),
                      // Baca Saja jika sudah diisi dari detail tugas
                      readOnly: widget.preSelectedSubject != null,
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _assignmentController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Tugas / Ujian (Jenis Nilai)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.assignment),
                      ),
                      // Baca Saja jika sudah diisi dari detail tugas
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
                          return 'Nilai tidak valid (0-100)';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // ===================================
                    // 4. Tombol Submit
                    // ===================================
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submitGrade,
                        icon: const Icon(Icons.save),
                        label: const Text('Simpan Nilai'),
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
                ),
              ),
            ),
    );
  }
}
