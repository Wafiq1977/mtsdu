import 'package:flutter/material.dart';
import 'package:lpmmtsdu/domain/entity/user_entity.dart';
import 'package:provider/provider.dart';
import '../../../presentation/provider/auth_provider.dart';
import '../../../presentation/provider/data_provider.dart';
import '../../../data/model/assignment.dart';
import '../../../data/model/user.dart';

// WAJIB DITAMBAHKAN: Import UserRole
import '../../../presentation/utils/user_role.dart';

class TeacherInputAssignmentView extends StatefulWidget {
  const TeacherInputAssignmentView({super.key});

  @override
  State<TeacherInputAssignmentView> createState() =>
      _TeacherInputAssignmentViewState();
}

class _TeacherInputAssignmentViewState
    extends State<TeacherInputAssignmentView> {
  final _formKey = GlobalKey<FormState>();

  // State Input
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  // Data Siswa (digunakan untuk memuat opsi filter)
  List<User> _students = [];
  bool _isLoading = true;

  // --- Variabel untuk Filtrasi Tiga Tingkat ---
  String? _selectedMajor; // Penjurusan
  String? _selectedGrade; // Angkatan
  String? _selectedClass; // Kelas tujuan Assignment

  // Opsi Dropdown
  List<String> _majorOptions = [];
  List<String> _gradeOptions = [];
  List<String> _classOptions = [];
  final List<String> _staticGradeOptions = ['10', '11', '12'];

  @override
  void initState() {
    super.initState();
    // Inisialisasi tanggal jatuh tempo hari ini (hanya untuk tampilan)
    final now = DateTime.now();
    _dueDateController.text =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    _loadStudents();

    // Pre-fill subject from teacher's data
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final teacherSubject = authProvider.currentUser?.subject;
    _subjectController.text = teacherSubject ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  // --- Helper: Mengambil Angkatan dari className ---
  String? _extractGrade(String? className) {
    if (className == null || className.length < 2) return null;
    final grade = className.substring(0, 2);
    return _staticGradeOptions.contains(grade) ? grade : null;
  }

  // Memuat data siswa dan opsi Penjurusan
  Future<void> _loadStudents() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final allUsers = await authProvider.getAllUsers();
      if (mounted) {
        setState(() {
          _students = allUsers
              .where((u) => u.role == UserRole.student)
              .toList();

          // Inisialisasi Opsi Penjurusan (Filter pertama)
          _majorOptions =
              _students
                  .where((s) => s.major != null && s.major!.isNotEmpty)
                  .map((s) => s.major!)
                  .toSet()
                  .toList()
                ..sort();

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data siswa: $e')));
        setState(() {
          _isLoading = false;
        });
      }
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

      if (_selectedMajor != null) {
        // Filter Angkatan berdasarkan Penjurusan (Major)
        _gradeOptions =
            _students
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

      if (_selectedMajor != null && _selectedGrade != null) {
        // Filter Kelas berdasarkan Penjurusan DAN Angkatan
        _classOptions =
            _students
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

  // Fungsi untuk memilih tanggal
  Future<void> _selectDueDate(BuildContext context) async {
    final initialDate =
        DateTime.tryParse(_dueDateController.text) ?? DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(
        const Duration(days: 365),
      ), // Set batas
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _dueDateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  // Fungsi untuk mengirim data penugasan
  void _submitAssignment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validasi tambahan untuk filter kelas
    if (_selectedMajor == null ||
        _selectedGrade == null ||
        _selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pilih Penjurusan, Angkatan, dan Kelas target penugasan.',
          ),
        ),
      );
      return;
    }

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final teacherId = authProvider.currentUser?.id;

    if (teacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kesalahan Otentikasi: ID Guru tidak ditemukan'),
        ),
      );
      return;
    }

    // Membuat objek Assignment
    final assignment = Assignment(
      // Buat ID unik (misal menggunakan timestamp)
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text,
      subject: _subjectController.text,
      dueDate: _dueDateController.text,
      teacherId: teacherId,
      className: _selectedClass!,
      major: [_selectedMajor!], // The model expects a List<String>
    );

    try {
      await dataProvider.addAssignment(
        assignment,
      ); // Asumsi fungsi ini tersedia

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Penugasan berhasil ditambahkan')),
        );
        // Membersihkan form setelah submit
        setState(() {
          _titleController.clear();
          _descriptionController.clear();
          _subjectController.clear();
          // _dueDateController tetap pada tanggal hari ini (atau diatur ulang)
          _selectedMajor = null;
          _selectedGrade = null;
          _selectedClass = null;
          _gradeOptions = [];
          _classOptions = [];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan penugasan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Input Penugasan'),
          backgroundColor: const Color(0xFF667EEA),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Penugasan Baru'),
        backgroundColor: const Color(0xFF667EEA),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Input Judul
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Penugasan',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Judul wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // Input Deskripsi
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi / Instruksi',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (value) =>
                      value!.isEmpty ? 'Deskripsi wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // Input Mata Pelajaran
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Mata Pelajaran',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true, // Subject is based on logged-in teacher
                  validator: (value) =>
                      value!.isEmpty ? 'Mata pelajaran wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // Input Tanggal Jatuh Tempo
                TextFormField(
                  controller: _dueDateController,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Jatuh Tempo (YYYY-MM-DD)',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () => _selectDueDate(context),
                  validator: (value) =>
                      value!.isEmpty ? 'Tanggal jatuh tempo wajib diisi' : null,
                ),
                const SizedBox(height: 24),

                const Text(
                  'Target Penerima Penugasan:',
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
                        (major) =>
                            DropdownMenuItem(value: major, child: Text(major)),
                      )
                      .toList(),
                  onChanged: (value) {
                    _updateGradeOptions(value); // CASCADE
                  },
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
                      : (value) {
                          _updateClassOptions(value); // CASCADE
                        },
                  hint: const Text('Pilih Angkatan'),
                  validator: (value) =>
                      value == null ? 'Angkatan wajib dipilih' : null,
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
                      : (value) {
                          setState(() {
                            _selectedClass = value;
                          });
                        },
                  hint: const Text('Pilih Kelas'),
                  validator: (value) =>
                      value == null ? 'Kelas wajib dipilih' : null,
                ),

                const SizedBox(height: 32),

                // Tombol Submit
                ElevatedButton.icon(
                  onPressed: _submitAssignment,
                  icon: const Icon(Icons.save),
                  label: const Text('Buat Penugasan'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color(0xFF667EEA),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
