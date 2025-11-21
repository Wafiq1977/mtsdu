import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../models/attendance.dart';
import '../models/user.dart';
import '../services/student_service.dart';

class TeacherInputAttendanceView extends StatefulWidget {
  const TeacherInputAttendanceView({super.key});

  @override
  State<TeacherInputAttendanceView> createState() =>
      _TeacherInputAttendanceViewState();
}

class _TeacherInputAttendanceViewState
    extends State<TeacherInputAttendanceView> {
  // --- VARIABLES ---
  final _subjectController = TextEditingController();
  final StudentService _studentService = StudentService();

  // Data List
  List<User> _allStudents = []; // Database lengkap murid
  List<User> _filteredStudents = []; // Murid yang tampil di layar

  // Filter Configuration
  String _selectedClassFilter = 'Semua Kelas';
  List<String> _availableClasses = ['Semua Kelas'];

  // State Management
  bool _isLoading = true;
  // Menyimpan status absen: Key = ID Murid, Value = Status Absen
  final Map<String, AttendanceStatus> _attendanceStatus = {};

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

  // --- LOGIC 1: LOAD DATA & SIAPKAN FILTER ---
  Future<void> _loadStudents() async {
    try {
      // 1. Ambil semua user
      final students = await _studentService.getAllStudents();

      // 2. Filter hanya role 'student'
      final validStudents = students
          .where((u) => u.role == UserRole.student)
          .toList();

      // 3. Ambil daftar kelas unik untuk dropdown filter
      final Set<String> uniqueClasses = {};
      for (var student in validStudents) {
        final cls = student.className ?? '';
        if (cls.isNotEmpty) {
          uniqueClasses.add(cls);
        }
        // Default status awal: Hadir (Present)
        _attendanceStatus[student.id] = AttendanceStatus.present;
      }

      // 4. Urutkan nama kelas abjad
      final sortedClasses = uniqueClasses.toList()..sort();

      if (mounted) {
        setState(() {
          _allStudents = validStudents;
          _filteredStudents = validStudents; // Default tampilkan semua
          _availableClasses = ['Semua Kelas', ...sortedClasses];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
    }
  }

  // --- LOGIC 2: FILTER SISWA BERDASARKAN KELAS ---
  void _filterStudents(String className) {
    setState(() {
      _selectedClassFilter = className;
      if (className == 'Semua Kelas') {
        _filteredStudents = _allStudents;
      } else {
        _filteredStudents = _allStudents
            .where((s) => s.className == className)
            .toList();
      }
    });
  }

  // --- LOGIC 3: QUICK ACTION (SET SEMUA HADIR/SAKIT) ---
  void _setAllStatus(AttendanceStatus status) {
    setState(() {
      // Hanya ubah status murid yang sedang TAMPIL (Filtered)
      for (var student in _filteredStudents) {
        _attendanceStatus[student.id] = status;
      }
    });
  }

  // --- LOGIC 4: SIMPAN DATA KE DATABASE ---
  Future<void> _submit() async {
    // Validasi Input
    if (_subjectController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi Mata Pelajaran dulu!')),
      );
      return;
    }

    if (_filteredStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada murid yang dipilih.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final teacher = authProvider.currentUser!;

    int successCount = 0;

    try {
      // Loop hanya pada murid yang sedang difilter/tampil
      for (var student in _filteredStudents) {
        final status =
            _attendanceStatus[student.id] ?? AttendanceStatus.present;

        final attendance = Attendance(
          id:
              DateTime.now().microsecondsSinceEpoch.toString() +
              student.id, // ID Unik
          studentId: student.id,
          subject: _subjectController.text,
          date: DateTime.now().toString(),
          status: status,
          teacherId: teacher.id,
        );

        await dataProvider.addAttendance(attendance);
        successCount++;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Berhasil menyimpan absen untuk $successCount murid.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Kembali ke dashboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  // --- UI BUILDER ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Input Absensi Kelas'),
        backgroundColor: const Color(0xFF667EEA),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // BAGIAN ATAS: INPUT & FILTER
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 1. Input Mata Pelajaran
                      TextField(
                        controller: _subjectController,
                        decoration: InputDecoration(
                          labelText: 'Mata Pelajaran',
                          hintText: 'Contoh: Matematika Wajib',
                          prefixIcon: const Icon(
                            Icons.book,
                            color: Color(0xFF667EEA),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 2. Filter Kelas Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.filter_alt, color: Colors.grey),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedClassFilter,
                                  isExpanded: true,
                                  icon: const Icon(Icons.arrow_drop_down),
                                  items: _availableClasses.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) _filterStudents(val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // BAGIAN TENGAH: QUICK ACTIONS (CHIPS)
                if (_filteredStudents.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          const Center(
                            child: Text(
                              "Set Semua:  ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          _buildQuickActionChip(
                            "Hadir",
                            AttendanceStatus.present,
                            Colors.green,
                          ),
                          const SizedBox(width: 8),
                          _buildQuickActionChip(
                            "Sakit",
                            AttendanceStatus.excused,
                            Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          _buildQuickActionChip(
                            "Alpha",
                            AttendanceStatus.absent,
                            Colors.red,
                          ),
                          const SizedBox(width: 8),
                          _buildQuickActionChip(
                            "Telat",
                            AttendanceStatus.late,
                            Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  ),

                const Divider(),

                // BAGIAN BAWAH: LIST SISWA
                Expanded(
                  child: _filteredStudents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.class_outlined,
                                size: 64,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Tidak ada murid di $_selectedClassFilter",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: _filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = _filteredStudents[index];
                            return _buildStudentItem(student);
                          },
                        ),
                ),
              ],
            ),

      // TOMBOL SIMPAN DI POJOK KANAN BAWAH
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _submit,
        backgroundColor: const Color(0xFF667EEA),
        icon: const Icon(Icons.save),
        label: Text('Simpan (${_filteredStudents.length})'),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  // 1. Chip Tombol Cepat
  Widget _buildQuickActionChip(
    String label,
    AttendanceStatus status,
    Color color,
  ) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color.withOpacity(0.9),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () => _setAllStatus(status),
    );
  }

  // 2. Card Item Murid
  Widget _buildStudentItem(User student) {
    final status = _attendanceStatus[student.id] ?? AttendanceStatus.present;
    final color = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.blue.shade50,
              backgroundImage: student.profileImagePath != null
                  ? AssetImage(student.profileImagePath!)
                  : null,
              child: student.profileImagePath == null
                  ? Text(
                      student.name.isNotEmpty
                          ? student.name[0].toUpperCase()
                          : "?",
                      style: const TextStyle(
                        color: Color(0xFF667EEA),
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Nama & Kelas
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${student.className ?? '-'} • ID: ${student.id}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),

            // Dropdown Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.5)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<AttendanceStatus>(
                  value: status,
                  icon: Icon(Icons.arrow_drop_down, color: color),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  items: AttendanceStatus.values.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(_getStatusLabel(s)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _attendanceStatus[student.id] = val;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Text Label
  String _getStatusLabel(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return "Hadir";
      case AttendanceStatus.absent:
        return "Alpha";
      case AttendanceStatus.late:
        return "Telat";
      case AttendanceStatus.excused:
        return "Izin";
    }
  }

  // Helper Color Label
  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.excused:
        return Colors.blue;
    }
  }
}
