import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/provider/auth_provider.dart';
import '../../../presentation/provider/data_provider.dart';
import '../../../data/model/attendance.dart';
import '../../../data/model/user.dart';
import '../../../domain/entity/attendance_entity.dart';
import '../../../domain/entity/user_entity.dart';
import '../../../presentation/widgets/user_card.dart';
// WAJIB DITAMBAHKAN: Import UserRole
import '../../../presentation/utils/user_role.dart';

class TeacherInputAttendanceView extends StatefulWidget {
  const TeacherInputAttendanceView({super.key});

  @override
  State<TeacherInputAttendanceView> createState() =>
      _TeacherInputAttendanceViewState();
}

class _TeacherInputAttendanceViewState
    extends State<TeacherInputAttendanceView> {
  final _formKey = GlobalKey<FormState>();

  // State variables
  User? _selectedStudent;
  final _subjectController = TextEditingController();
  final _dateController = TextEditingController();
  AttendanceStatus? _status;
  List<User> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // PERBAIKAN: Inisialisasi tanggal dengan format YYYY-MM-DD yang aman
    final now = DateTime.now();
    _dateController.text =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    _loadStudents();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // Fungsi untuk memuat daftar semua siswa
  Future<void> _loadStudents() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final allUsers = await authProvider.getAllUsers();
      if (mounted) {
        setState(() {
          // Memfilter hanya user dengan role student
          _students = allUsers
              .where((u) => u.role == UserRole.student)
              .toList();
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

  // Fungsi untuk memilih tanggal
  Future<void> _selectDate(BuildContext context) async {
    final initialDate =
        DateTime.tryParse(_dateController.text) ?? DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        // PERBAIKAN: Menggunakan format YYYY-MM-DD yang eksplisit
        _dateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  // Fungsi untuk mengirim data absensi
  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedStudent == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Siswa wajib dipilih')));
      return;
    }
    if (_status == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status absensi wajib dipilih')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    // PERBAIKAN: Cek currentUser dengan aman
    final user = authProvider.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kesalahan Otentikasi: ID Guru tidak ditemukan'),
        ),
      );
      return;
    }

    try {
      // Membuat objek Attendance baru
      final attendance = Attendance(
        // ID unik berdasarkan siswa, tanggal, dan hash subjek
        id: '${_selectedStudent!.id}_${_dateController.text}_${_subjectController.text.hashCode}',
        studentId: _selectedStudent!.id,
        subject: _subjectController.text,
        date: _dateController.text,
        status: _status!,
        teacherId: user.id,
      );

      await dataProvider.addAttendance(attendance);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Absensi berhasil ditambahkan')),
        );

        // Membersihkan form setelah submit
        setState(() {
          _selectedStudent = null;
          _subjectController.clear();
          // _dateController tidak di-clear agar tanggal tetap hari ini
          _status = null;
        });
      }

      // Opsional: Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan absensi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading screen jika data belum dimuat
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Input Attendance'),
          backgroundColor: const Color(0xFF667EEA),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Absensi Satu Siswa'),
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
                // 1. Pemilihan Siswa (Dropdown)
                DropdownButtonFormField<User>(
                  decoration: const InputDecoration(
                    labelText: 'Pilih Siswa',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  value: _selectedStudent,
                  hint: const Text('Ketuk untuk memilih siswa'),
                  items: _students.map((User student) {
                    return DropdownMenuItem<User>(
                      value: student,
                      child: Text(
                        '${student.name} (${student.className ?? ''})',
                      ), // Tampilkan Nama dan Kelas
                    );
                  }).toList(),
                  onChanged: (User? newValue) {
                    setState(() {
                      _selectedStudent = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Siswa wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // 2. Input Tanggal
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal (YYYY-MM-DD)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (value) =>
                      value!.isEmpty ? 'Tanggal wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // 3. Input Mata Pelajaran (Subject)
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Mata Pelajaran',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.subject),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Mata pelajaran wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),

                // 4. Pemilihan Status Absensi (Dropdown)
                DropdownButtonFormField<AttendanceStatus>(
                  decoration: const InputDecoration(
                    labelText: 'Status Absensi',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.checklist),
                  ),
                  value: _status,
                  hint: const Text('Pilih status'),
                  items: AttendanceStatus.values.map((AttendanceStatus status) {
                    // Konversi nama enum menjadi string yang mudah dibaca (e.g., 'present' -> 'Hadir')
                    String statusName = status.toString().split('.').last;
                    statusName =
                        statusName[0].toUpperCase() + statusName.substring(1);

                    // Pilihan terjemahan
                    switch (status) {
                      case AttendanceStatus.present:
                        statusName = 'Hadir';
                        break;
                      case AttendanceStatus.absent:
                        statusName = 'Absen';
                        break;
                      case AttendanceStatus.late:
                        statusName = 'Telat';
                        break;
                      default:
                        break;
                    }

                    return DropdownMenuItem<AttendanceStatus>(
                      value: status,
                      child: Text(statusName),
                    );
                  }).toList(),
                  onChanged: (AttendanceStatus? newValue) {
                    setState(() {
                      _status = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Status absensi wajib diisi' : null,
                ),

                const SizedBox(height: 32),

                // 5. Tombol Submit
                ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save),
                  label: const Text('Tambahkan Absensi'),
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
