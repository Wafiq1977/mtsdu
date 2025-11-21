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
  final _subjectController = TextEditingController();
  final StudentService _studentService = StudentService();

  // --- STATE TANGGAL MANUAL ---
  DateTime _selectedDate = DateTime.now(); // Default hari ini

  bool _isLoading = true;
  List<User> _allStudents = [];
  List<User> _filteredStudents = [];

  // Filter
  String _selectedClass = 'Semua Kelas';
  String _selectedMajor = 'Semua Jurusan';
  List<String> _availableClasses = ['Semua Kelas'];
  List<String> _availableMajors = ['Semua Jurusan'];

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

  // --- HELPER: FORMAT TANGGAL INDONESIA (Disesuaikan dengan _selectedDate) ---
  String _getFormattedDate(DateTime date) {
    final List<String> days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    final List<String> months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    String dayName = days[date.weekday == 7 ? 0 : date.weekday];
    String monthName = months[date.month - 1];

    return "$dayName, ${date.day} $monthName ${date.year}";
  }

  // --- FUNGSI BUKA KALENDER (DATE PICKER) ---
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020), // Batas bawah tanggal
      lastDate: DateTime.now().add(
        const Duration(days: 30),
      ), // Batas atas (bisa input kedepan)
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF667EEA), // Warna header kalender
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // --- LOGIC LOAD DATA ---
  Future<void> _loadStudents() async {
    try {
      final students = await _studentService.getAllStudents();
      final validStudents = students
          .where((u) => u.role == UserRole.student)
          .toList();

      final Set<String> uniqueClasses = {};
      final Set<String> uniqueMajors = {};

      for (var student in validStudents) {
        if (student.className != null && student.className!.isNotEmpty) {
          uniqueClasses.add(student.className!);
        }
        if (student.major != null && student.major!.isNotEmpty) {
          uniqueMajors.add(student.major!);
        }
        _attendanceStatus[student.id] = AttendanceStatus.present;
      }

      final sortedClasses = uniqueClasses.toList()..sort();
      final sortedMajors = uniqueMajors.toList()..sort();

      if (mounted) {
        setState(() {
          _allStudents = validStudents;
          _filteredStudents = validStudents;
          _availableClasses = ['Semua Kelas', ...sortedClasses];
          _availableMajors = ['Semua Jurusan', ...sortedMajors];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIC FILTER ---
  void _applyFilter() {
    setState(() {
      _filteredStudents = _allStudents.where((student) {
        bool matchClass = true;
        if (_selectedClass != 'Semua Kelas') {
          matchClass = student.className == _selectedClass;
        }
        bool matchMajor = true;
        if (_selectedMajor != 'Semua Jurusan') {
          matchMajor = student.major == _selectedMajor;
        }
        return matchClass && matchMajor;
      }).toList();
    });
  }

  // --- LOGIC SET ALL ---
  void _setAllStatus(AttendanceStatus status) {
    setState(() {
      for (var student in _filteredStudents) {
        _attendanceStatus[student.id] = status;
      }
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Semua diset ke: ${status.toString().split('.').last}"),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  // --- LOGIC SUBMIT ---
  Future<void> _submit() async {
    if (_subjectController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Isi Mata Pelajaran dulu!')));
      return;
    }

    if (_filteredStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada siswa yang dipilih!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final teacher = authProvider.currentUser;
    if (teacher == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User tidak ditemukan.')));
      setState(() => _isLoading = false);
      return;
    }
    final teacherId = teacher.id;
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    try {
      for (var student in _filteredStudents) {
        final status =
            _attendanceStatus[student.id] ?? AttendanceStatus.present;
        final attendance = Attendance(
          id: DateTime.now().microsecondsSinceEpoch.toString() + student.id,
          studentId: student.id,
          subject: _subjectController.text,
          date: _selectedDate.toIso8601String(),
          status: status,
          teacherId: teacherId,
        );
        await dataProvider.addAttendance(attendance);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Absensi berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;
    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Absensi'),
        backgroundColor: const Color(0xFF667EEA),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // HEADER INPUT
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    children: [
                      // 1. ROW TANGGAL & PENGAJAR
                      Row(
                        children: [
                          // KOLOM TANGGAL (BISA DIKLIK/MANUAL)
                          Expanded(
                            child: InkWell(
                              onTap: _pickDate, // Klik untuk buka kalender
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: "Tanggal",
                                  prefixIcon: Icon(
                                    Icons.calendar_month,
                                    color: Color(0xFF667EEA),
                                  ),
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                child: Text(
                                  _getFormattedDate(_selectedDate),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // KOLOM PENGAJAR (Tetap Read-Only)
                          Expanded(
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: "Pengajar",
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                ),
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Color(
                                  0xFFF5F5F5,
                                ), // Abu-abu tanda read-only
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              child: Text(
                                currentUser.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 2. INPUT MATA PELAJARAN
                      TextField(
                        controller: _subjectController,
                        decoration: const InputDecoration(
                          labelText: 'Mata Pelajaran',
                          prefixIcon: Icon(
                            Icons.book,
                            color: Color(0xFF667EEA),
                          ),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 3. FILTER KELAS & JURUSAN
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedClass,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Kelas',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items: _availableClasses.map((cls) {
                                return DropdownMenuItem(
                                  value: cls,
                                  child: Text(cls),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedClass = val;
                                  });
                                  _applyFilter();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedMajor,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Jurusan',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items: _availableMajors.map((mjr) {
                                return DropdownMenuItem(
                                  value: mjr,
                                  child: Text(
                                    mjr,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedMajor = val;
                                  });
                                  _applyFilter();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1),

                // --- HEADER TABEL ---
                Container(
                  color: Colors.grey[200],
                  padding: const EdgeInsets.fromLTRB(24, 12, 16, 12),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 40,
                        child: Text(
                          'No',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Expanded(
                        flex: 2,
                        child: Text(
                          'Nama Siswa',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),

                      _buildClickableHeader(
                        'Hadir',
                        AttendanceStatus.present,
                        Colors.green,
                      ),
                      _buildClickableHeader(
                        'Sakit',
                        AttendanceStatus.excused,
                        Colors.blue,
                      ),
                      _buildClickableHeader(
                        'Alpha',
                        AttendanceStatus.absent,
                        Colors.red,
                      ),
                      _buildClickableHeader(
                        'Telat',
                        AttendanceStatus.late,
                        Colors.orange,
                      ),
                    ],
                  ),
                ),

                // --- LIST SISWA ---
                Expanded(
                  child: _filteredStudents.isEmpty
                      ? Center(
                          child: Text(
                            "Tidak ada siswa ditemukan",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _filteredStudents.length,
                          separatorBuilder: (ctx, i) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            return _buildStudentRow(
                              index,
                              _filteredStudents[index],
                            );
                          },
                        ),
                ),
              ],
            ),

      // TOMBOL SIMPAN
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667EEA),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            'SIMPAN ABSENSI (${_filteredStudents.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // Widget Field Read-Only (Pengajar) & Clickable (Tanggal)
  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildClickableHeader(
    String text,
    AttendanceStatus status,
    Color color,
  ) {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: () => _setAllStatus(status),
        child: Column(
          children: [
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: color.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentRow(int index, User student) {
    return Container(
      color: index % 2 == 0 ? Colors.white : Colors.grey[50],
      padding: const EdgeInsets.fromLTRB(24, 8, 16, 8),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text('${index + 1}.', style: const TextStyle(fontSize: 13)),
          ),

          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "${student.className ?? ''} - ${student.major ?? ''}",
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          _buildRadioCell(student.id, AttendanceStatus.present, Colors.green),
          _buildRadioCell(student.id, AttendanceStatus.excused, Colors.blue),
          _buildRadioCell(student.id, AttendanceStatus.absent, Colors.red),
          _buildRadioCell(student.id, AttendanceStatus.late, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildRadioCell(
    String studentId,
    AttendanceStatus value,
    Color color,
  ) {
    return Expanded(
      flex: 1,
      child: Center(
        child: Transform.scale(
          scale: 1.1,
          child: Radio<AttendanceStatus>(
            value: value,
            groupValue: _attendanceStatus[studentId],
            activeColor: color,
            onChanged: (val) {
              setState(() {
                _attendanceStatus[studentId] = val!;
              });
            },
          ),
        ),
      ),
    );
  }
}
