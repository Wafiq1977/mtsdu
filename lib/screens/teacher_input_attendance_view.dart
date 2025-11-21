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

  bool _isLoading = true;
  List<User> _allStudents = [];
  List<User> _filteredStudents = [];
  String _selectedClassFilter = '';
  List<String> _availableClasses = ['Semua Kelas'];
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

  Future<void> _loadStudents() async {
    try {
      final students = await _studentService.getAllStudents();
      final validStudents = students
          .where((u) => u.role == UserRole.student)
          .toList();

      final Set<String> uniqueClasses = {};
      for (var student in validStudents) {
        final cls = student.className ?? '';
        if (cls.isNotEmpty) uniqueClasses.add(cls);
        _attendanceStatus[student.id] = AttendanceStatus.present;
      }

      final sortedClasses = uniqueClasses.toList()..sort();

      if (mounted) {
        setState(() {
          _allStudents = validStudents;
          _availableClasses = sortedClasses;
          if (sortedClasses.isNotEmpty) {
            _selectedClassFilter = sortedClasses.first;
            _filteredStudents = _allStudents
                .where((s) => s.className == sortedClasses.first)
                .toList();
          } else {
            _filteredStudents = [];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterStudents(String className) {
    setState(() {
      _selectedClassFilter = className;
      _filteredStudents = _allStudents
          .where((s) => s.className == className)
          .toList();
    });
  }

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

  Future<void> _submit() async {
    if (_subjectController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi Mata Pelajaran dulu!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final teacherId = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).currentUser!.id;
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    try {
      for (var student in _filteredStudents) {
        final status =
            _attendanceStatus[student.id] ?? AttendanceStatus.present;
        final attendance = Attendance(
          id: DateTime.now().microsecondsSinceEpoch.toString() + student.id,
          studentId: student.id,
          subject: _subjectController.text,
          date: DateTime.now().toString(),
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
                      TextField(
                        controller: _subjectController,
                        decoration: const InputDecoration(
                          labelText: 'Mata Pelajaran',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _availableClasses.contains(_selectedClassFilter)
                            ? _selectedClassFilter
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Kelas',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: _availableClasses.map((cls) {
                          return DropdownMenuItem(value: cls, child: Text(cls));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) _filterStudents(val);
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1),

                // --- HEADER TABEL (Full Text & Clickable) ---
                Container(
                  color: Colors.grey[200],
                  // PERBAIKAN: Padding horizontal diperbesar jadi 16 agar tidak mepet
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      // PERBAIKAN: Lebar kolom No diperbesar jadi 40
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

                // --- LIST DAFTAR SISWA ---
                Expanded(
                  child: ListView.separated(
                    itemCount: _filteredStudents.length,
                    separatorBuilder: (ctx, i) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      return _buildStudentRow(index, _filteredStudents[index]);
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
      // PERBAIKAN: Padding horizontal diperbesar jadi 16 agar sinkron dengan header
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          // PERBAIKAN: Lebar kolom No diperbesar jadi 40
          SizedBox(
            width: 40,
            child: Text('${index + 1}.', style: const TextStyle(fontSize: 13)),
          ),

          Expanded(
            flex: 2,
            child: Text(
              student.name,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
