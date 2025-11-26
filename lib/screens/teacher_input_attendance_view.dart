import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../models/attendance.dart';
import '../models/user.dart';

class TeacherInputAttendanceView extends StatefulWidget {
  const TeacherInputAttendanceView({super.key});

  @override
  State<TeacherInputAttendanceView> createState() =>
      _TeacherInputAttendanceViewState();
}

class _TeacherInputAttendanceViewState
    extends State<TeacherInputAttendanceView> {
  final _subjectController = TextEditingController();

  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  List<User> _allStudents = [];
  List<User> _filteredStudents = [];

  String _selectedClassFilter = '';
  String _selectedMajorFilter = 'Semua Jurusan';

  List<String> _availableClasses = [];
  List<String> _availableMajors = [];

  final Map<String, AttendanceStatus> _attendanceStatus = {};

  String teacherName = '';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser != null) {
        _subjectController.text = currentUser.subject ?? '';
        teacherName = currentUser.name;
      }

      final allUsers = await authProvider.getAllUsers();
      final validStudents = allUsers
          .where((u) => u.role == UserRole.student)
          .toList();

      final Set<String> uniqueClasses = {};
      final Set<String> uniqueMajors = {};

      for (var student in validStudents) {
        if ((student.className ?? '').isNotEmpty) {
          uniqueClasses.add(student.className!);
        }
        if ((student.major ?? '').isNotEmpty) {
          uniqueMajors.add(student.major!);
        }
        _attendanceStatus[student.id] = AttendanceStatus.present;
      }

      final sortedClasses = uniqueClasses.toList()..sort();
      final sortedMajors = uniqueMajors.toList()..sort();

      if (mounted) {
        setState(() {
          _allStudents = validStudents;
          _availableClasses = sortedClasses;

          _availableMajors = ["Semua Jurusan", ...sortedMajors];

          if (sortedClasses.isNotEmpty) {
            _selectedClassFilter = sortedClasses.first;
            _applyFilters();
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredStudents = _allStudents.where((s) {
        final matchClass = s.className == _selectedClassFilter;

        final matchMajor = _selectedMajorFilter == "Semua Jurusan"
            ? true
            : s.major == _selectedMajorFilter;

        return matchClass && matchMajor;
      }).toList();
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
        content: Text("Semua siswa di kelas ini diset ke: ${status.name}"),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (_subjectController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi Mata Pelajaran dulu!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final teacherId = authProvider.currentUser?.id ?? 'unknown_teacher';

    final String dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);

    try {
      int count = 0;

      for (var student in _filteredStudents) {
        final status =
            _attendanceStatus[student.id] ?? AttendanceStatus.present;

        final attendanceId =
            'att_${DateTime.now().millisecondsSinceEpoch}_${student.id}';

        final attendance = Attendance(
          id: attendanceId,
          studentId: student.id,
          subject: _subjectController.text,
          date: dateString,
          status: status,
          teacherId: teacherId,
        );

        await dataProvider.addAttendance(attendance);
        count++;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil menyimpan $count data absensi!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Absensi'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Guru: $teacherName",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _subjectController,
                              decoration: const InputDecoration(
                                labelText: 'Mata Pelajaran',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: _pickDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Tanggal',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                  ),
                                ),
                                child: Text(
                                  DateFormat(
                                    'dd MMM yyyy',
                                  ).format(_selectedDate),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      /// FILTER KELAS
                      DropdownButtonFormField<String>(
                        value: _selectedClassFilter.isNotEmpty
                            ? _selectedClassFilter
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Pilih Kelas',
                          border: OutlineInputBorder(),
                        ),
                        items: _availableClasses
                            .map(
                              (cls) => DropdownMenuItem(
                                value: cls,
                                child: Text(cls),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedClassFilter = val);
                            _applyFilters();
                          }
                        },
                      ),

                      const SizedBox(height: 12),

                      /// FILTER JURUSAN
                      DropdownButtonFormField<String>(
                        value: _selectedMajorFilter,
                        decoration: const InputDecoration(
                          labelText: 'Pilih Jurusan',
                          border: OutlineInputBorder(),
                        ),
                        items: _availableMajors
                            .map(
                              (mjr) => DropdownMenuItem(
                                value: mjr,
                                child: Text(mjr),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedMajorFilter = val);
                            _applyFilters();
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                /// HEADER
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  color: Colors.grey[200],
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 40,
                        child: Text(
                          "No",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Expanded(
                        flex: 2,
                        child: Text(
                          "Nama Siswa",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      _buildClickableHeader(
                        "Hadir",
                        AttendanceStatus.present,
                        Colors.green,
                      ),
                      _buildClickableHeader(
                        "Alpha",
                        AttendanceStatus.absent,
                        Colors.red,
                      ),
                      _buildClickableHeader(
                        "Telat",
                        AttendanceStatus.late,
                        Colors.orange,
                      ),
                    ],
                  ),
                ),

                /// LIST SISWA
                Expanded(
                  child: _filteredStudents.isEmpty
                      ? const Center(
                          child: Text(
                            "Tidak ada data siswa",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _filteredStudents.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
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

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667EEA),
            padding: const EdgeInsets.symmetric(vertical: 16),
            foregroundColor: Colors.white,
          ),
          child: Text(
            'SIMPAN ABSENSI (${_filteredStudents.length} SISWA)',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  /// =======================
  ///   UI BUILDER
  /// =======================

  Widget _buildClickableHeader(
    String text,
    AttendanceStatus status,
    Color color,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () => _setAllStatus(status),
        child: Column(
          children: [
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
            Icon(Icons.arrow_drop_down, size: 18, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentRow(int index, User student) {
    final currentStatus =
        _attendanceStatus[student.id] ?? AttendanceStatus.present;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              "${index + 1}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          /// NAMA SISWA
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  "${student.className ?? ''} — ${student.major ?? ''}",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),

          _buildStatusButton(
            student.id,
            AttendanceStatus.present,
            Colors.green,
            currentStatus,
          ),
          _buildStatusButton(
            student.id,
            AttendanceStatus.absent,
            Colors.red,
            currentStatus,
          ),
          _buildStatusButton(
            student.id,
            AttendanceStatus.late,
            Colors.orange,
            currentStatus,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(
    String studentId,
    AttendanceStatus selectedStatus,
    Color color,
    AttendanceStatus currentStatus,
  ) {
    final isSelected = currentStatus == selectedStatus;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _attendanceStatus[studentId] = selectedStatus);
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
            color: color,
            size: 20,
          ),
        ),
      ),
    );
  }
}
