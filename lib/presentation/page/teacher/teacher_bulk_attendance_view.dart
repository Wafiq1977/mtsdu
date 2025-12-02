import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/provider/auth_provider.dart';
import '../../../presentation/provider/data_provider.dart';
import '../../../data/model/attendance.dart';
import '../../../data/model/user.dart';
import '../../../domain/entity/attendance_entity.dart';
import '../../../domain/entity/user_entity.dart';
import '../../../presentation/utils/user_role.dart';

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
  List<User> _students = []; // Semua siswa yang dimuat (Master List)

  // --- Variabel untuk Filtrasi Tiga Tingkat ---
  String? _selectedMajor; // Penjurusan (misalnya IPA, IPS)
  String? _selectedGrade; // Angkatan (10, 11, 12)
  String? _selectedClass; // Kelas (misalnya 10 IPA 1)

  List<User> _filteredStudents = []; // Siswa yang sudah difilter

  // Opsi Angkatan yang bersifat statis untuk validasi
  final List<String> _staticGradeOptions = ['10', '11', '12'];

  List<String> _majorOptions = []; // Opsi Jurusan (dimuat saat init)
  List<String> _gradeOptions =
      []; // Opsi Angkatan (berantai, tergantung Penjurusan)
  List<String> _classOptions =
      []; // Opsi Kelas (berantai, tergantung Angkatan & Penjurusan)

  @override
  void initState() {
    super.initState();
    // Mengatur tanggal hari ini dengan format YYYY-MM-DD
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

  // --- Helper: Mengambil Angkatan dari className ---
  String? _extractGrade(String? className) {
    if (className == null || className.length < 2) return null;
    final grade = className.substring(0, 2);
    // Hanya mengembalikan Angkatan jika valid (10, 11, atau 12)
    return _staticGradeOptions.contains(grade) ? grade : null;
  }

  // Memuat data siswa
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

          _filterStudents(); // Filter awal (daftar kosong)
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data siswa: $e')));
      }
    }
  }

  // --- Perubahan: Memperbarui opsi Angkatan berdasarkan Penjurusan ---
  void _updateGradeOptions() {
    if (!mounted) return;
    setState(() {
      _selectedGrade = null; // Reset Angkatan
      _selectedClass = null; // Reset Kelas
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
      _filterStudents();
    });
  }

  // --- Perubahan: Memperbarui opsi Kelas berdasarkan Penjurusan & Angkatan ---
  void _updateClassOptions() {
    if (!mounted) return;
    setState(() {
      _selectedClass = null; // Reset Kelas
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
      _filterStudents();
    });
  }

  // Menerapkan semua filter ke daftar siswa
  void _filterStudents() {
    if (!mounted) return;
    setState(() {
      // Hanya tampilkan siswa jika Penjurusan, Angkatan, DAN Kelas sudah dipilih
      if (_selectedMajor == null ||
          _selectedGrade == null ||
          _selectedClass == null) {
        _filteredStudents = [];
      } else {
        _filteredStudents = _students.where((student) {
          return student.className == _selectedClass &&
              student.major == _selectedMajor &&
              _extractGrade(student.className) == _selectedGrade;
        }).toList();
      }

      // Inisialisasi/reset status absensi untuk siswa yang terfilter
      _attendanceMap = Map.fromIterable(
        _filteredStudents,
        key: (student) => (student as User).id,
        value: (_) => AttendanceStatus.present, // Status default: Hadir
      );
    });
  }

  // Mengubah status absensi siswa tertentu
  void _updateAttendance(String studentId, AttendanceStatus status) {
    setState(() {
      _attendanceMap[studentId] = status;
    });
  }

  // Mengirim data absensi kolektif
  Future<void> _submitAttendance() async {
    if (_subjectController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mata pelajaran wajib diisi')),
      );
      return;
    }
    if (_filteredStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pilih Penjurusan, Angkatan, dan Kelas, atau tidak ada siswa di kelas ini',
          ),
        ),
      );
      return;
    }

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final currentUser = authProvider.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kesalahan otentikasi: ID Guru tidak ditemukan'),
        ),
      );
      return;
    }
    final teacherId = currentUser.id;

    // Persiapan data dan submit
    try {
      for (var student in _filteredStudents) {
        final attendance = Attendance(
          id: '${student.id}_${_dateController.text}_${_subjectController.text.hashCode}',
          studentId: student.id,
          subject: _subjectController.text,
          date: _dateController.text,
          status: _attendanceMap[student.id] ?? AttendanceStatus.present,
          teacherId: teacherId,
        );

        await dataProvider.addAttendance(attendance);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_filteredStudents.length} absensi berhasil ditambahkan',
            ),
          ),
        );
        // Reset filter dan form
        setState(() {
          _selectedMajor = null;
          _selectedGrade = null;
          _selectedClass = null;
          _subjectController.clear();
          // Muat ulang opsi Penjurusan yang lengkap dan filter siswa (akan kosong)
          _loadStudents();
        });
        Navigator.pop(context);
      }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Absensi Kolektif'),
        backgroundColor: const Color(0xFF667EEA),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitAttendance,
            tooltip: 'Simpan Absensi',
          ),
        ],
      ),
      body: Column(
        children: [
          // Bagian Input dan Filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Input Mapel
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Mata Pelajaran',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.book),
                  ),
                ),
                const SizedBox(height: 12),

                // Input Tanggal
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal (YYYY-MM-DD)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final initialDate =
                        DateTime.tryParse(_dateController.text) ??
                        DateTime.now();
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: initialDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (pickedDate != null && mounted) {
                      setState(() {
                        _dateController.text = pickedDate
                            .toIso8601String()
                            .split('T')[0];
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Dropdown 1: Penjurusan (Major)
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
                    setState(() {
                      _selectedMajor = value;
                      _updateGradeOptions(); // CASCADE: Update Angkatan
                    });
                  },
                  hint: const Text('Pilih Penjurusan (IPA, IPS, dll.)'),
                ),
                const SizedBox(height: 12),

                // Dropdown 2: Angkatan (Grade)
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
                          setState(() {
                            _selectedGrade = value;
                            _updateClassOptions(); // CASCADE: Update Kelas
                          });
                        },
                  hint: const Text('Pilih Angkatan (10, 11, 12)'),
                ),
                const SizedBox(height: 12),

                // Dropdown 3: Kelas
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
                            _filterStudents(); // FINAL FILTER: Tampilkan siswa
                          });
                        },
                  hint: const Text('Pilih Kelas'),
                ),
              ],
            ),
          ),

          // Bagian Daftar Siswa
          Expanded(
            child: _students.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _filteredStudents.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        _selectedClass == null
                            ? 'Silakan pilih Penjurusan, Angkatan, dan Kelas untuk menampilkan daftar siswa.'
                            : 'Tidak ada siswa ditemukan di kelas yang dipilih.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = _filteredStudents[index];
                      final currentStatus =
                          _attendanceMap[student.id] ??
                          AttendanceStatus.present;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '${student.className ?? 'No Class'} | ${student.major ?? 'No Major'}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              // Tombol Absensi menggunakan ToggleButtons
                              _buildAttendanceToggle(student.id, currentStatus),
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

  // Widget untuk status absensi menggunakan ToggleButtons (Segmented Control)
  Widget _buildAttendanceToggle(
    String studentId,
    AttendanceStatus currentStatus,
  ) {
    // Definisi Opsi (Status, Label, Warna)
    final statusOptions = [
      (AttendanceStatus.present, 'Hadir', Colors.green),
      (AttendanceStatus.absent, 'Absen', Colors.red),
      (AttendanceStatus.late, 'Telat', Colors.orange),
    ];

    final selectedIndex = statusOptions.indexWhere(
      (opt) => opt.$1 == currentStatus,
    );

    final effectiveSelectedIndex = selectedIndex == -1 ? 0 : selectedIndex;

    return ToggleButtons(
      borderRadius: BorderRadius.circular(8),
      constraints: const BoxConstraints(minHeight: 32.0, minWidth: 55.0),
      isSelected: List.generate(
        statusOptions.length,
        (i) => i == effectiveSelectedIndex,
      ),
      onPressed: (index) {
        _updateAttendance(studentId, statusOptions[index].$1);
      },
      children: statusOptions
          .map(
            (opt) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(opt.$2, style: const TextStyle(fontSize: 12)),
            ),
          )
          .toList(),
      selectedColor: Colors.white,
      fillColor: statusOptions[effectiveSelectedIndex].$3,
      color: Colors.black54,
      borderColor: Colors.grey.shade300,
      selectedBorderColor:
          Colors.grey.shade400, // Warna border tidak perlu terlalu tebal
      borderWidth: 1.5,
    );
  }
}
