import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../providers/auth_provider.dart';
import '../models/attendance.dart';
import '../models/user.dart';

class AdminAttendanceReports extends StatefulWidget {
  const AdminAttendanceReports({super.key});

  @override
  State<AdminAttendanceReports> createState() => _AdminAttendanceReportsState();
}

class _AdminAttendanceReportsState extends State<AdminAttendanceReports> {
  List<Attendance> _attendances = [];
  List<User> _students = [];
  List<User> _teachers = [];
  bool _isLoading = true;
  String _selectedClass = 'All';
  String _selectedMonth = 'All';
  String _selectedUserType = 'Students';

  final List<String> months = [
    'All', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final attendances = dataProvider.attendances;
    final allUsers = await authProvider.getAllUsers();
    final students = allUsers.where((u) => u.role == UserRole.student).toList();
    final teachers = allUsers.where((u) => u.role == UserRole.teacher).toList();

    setState(() {
      _attendances = attendances;
      _students = students;
      _teachers = teachers;
      _isLoading = false;
    });
  }

  List<Attendance> _getFilteredAttendances() {
    return _attendances.where((attendance) {
      final userList = _selectedUserType == 'Students' ? _students : _teachers;
      final userExists = userList.any((u) => u.id == attendance.studentId);

      if (!userExists) return false;

      if (_selectedClass != 'All') {
        final user = userList.firstWhere((u) => u.id == attendance.studentId);
        if (user.className != _selectedClass) return false;
      }

      if (_selectedMonth != 'All') {
        final attendanceMonth = DateTime.parse(attendance.date).month;
        final selectedMonthIndex = months.indexOf(_selectedMonth);
        if (attendanceMonth != selectedMonthIndex) return false;
      }

      return true;
    }).toList();
  }

  Map<String, Map<String, int>> _calculateAttendanceStats() {
    final filteredAttendances = _getFilteredAttendances();
    final stats = <String, Map<String, int>>{};

    for (final attendance in filteredAttendances) {
      final userId = attendance.studentId;
      
      // 1. Update inisialisasi Map untuk menyertakan 'excused'
      if (!stats.containsKey(userId)) {
        stats[userId] = {'present': 0, 'absent': 0, 'late': 0, 'excused': 0, 'total': 0};
      }

      stats[userId]!['total'] = stats[userId]!['total']! + 1;

      // 2. Perbaikan Switch Case
      switch (attendance.status) {
        case AttendanceStatus.present:
          stats[userId]!['present'] = stats[userId]!['present']! + 1;
          break;
        case AttendanceStatus.absent:
          stats[userId]!['absent'] = stats[userId]!['absent']! + 1;
          break;
        case AttendanceStatus.late:
          stats[userId]!['late'] = stats[userId]!['late']! + 1;
          break;
        case AttendanceStatus.excused: // Case baru ditambahkan
          stats[userId]!['excused'] = stats[userId]!['excused']! + 1;
          break;
      }
    }

    return stats;
  }

  List<String> _getAvailableClasses() { 
    final userList = _selectedUserType == 'Students' ? _students : _teachers;
    final classes = userList
        .map((u) => u.className)
        .where((c) => c != null && c!.isNotEmpty)
        .map((c) => c!)
        .toSet()
        .toList();
    classes.sort();
    return ['All', ...classes];
  }

  @override 
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final filteredAttendances = _getFilteredAttendances();
    final attendanceStats = _calculateAttendanceStats();
    final availableClasses = _getAvailableClasses();
    final userList = _selectedUserType == 'Students' ? _students : _teachers;
    
    // Hitung total stats sekali saja agar efisien
    final totalStats = _calculateTotalStats();

    return Column(
      children: [
        // Filters
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedUserType,
                      decoration: const InputDecoration(labelText: 'User Type'),
                      items: ['Students', 'Teachers'].map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUserType = value!;
                          _selectedClass = 'All'; // Reset class filter
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedClass,
                      decoration: const InputDecoration(labelText: 'Class'),
                      items: availableClasses.map((className) => DropdownMenuItem(
                        value: className,
                        child: Text(className),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedClass = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedMonth,
                      decoration: const InputDecoration(labelText: 'Month'),
                      items: months.map((month) => DropdownMenuItem(
                        value: month,
                        child: Text(month),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMonth = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Summary Stats
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView( // Tambahkan scroll horizontal jika layar sempit
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Total', filteredAttendances.length.toString(), Colors.grey.shade800),
                    const SizedBox(width: 15),
                    _buildStatCard('Present', totalStats['present'].toString(), Colors.green),
                    const SizedBox(width: 15),
                    _buildStatCard('Absent', totalStats['absent'].toString(), Colors.red),
                    const SizedBox(width: 15),
                    _buildStatCard('Late', totalStats['late'].toString(), Colors.orange),
                    const SizedBox(width: 15),
                    _buildStatCard('Excused', totalStats['excused'].toString(), Colors.blue), // UI Baru
                  ],
                ),
              ),
            ),
          ),
        ),

        // Attendance List
        Expanded(
          child: ListView.builder(
            itemCount: attendanceStats.length,
            itemBuilder: (context, index) {
              final userId = attendanceStats.keys.elementAt(index);
              final user = userList.firstWhere(
                (u) => u.id == userId,
                orElse: () => User(id: '', username: '', password: '', role: UserRole.student, name: 'Unknown'),
              );
              final stats = attendanceStats[userId]!;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedUserType == 'Students')
                        Text('Class: ${user.className}'),
                      const SizedBox(height: 4),
                      // Tampilkan detail statistik termasuk Excused
                      Text(
                        'Hadir: ${stats['present']} | Alpha: ${stats['absent']} | Telat: ${stats['late']} | Izin: ${stats['excused']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                      ),
                      Text(
                        'Total Kehadiran: ${((stats['present']! / stats['total']!) * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 3. Update perhitungan total agar menghitung Excused juga
  Map<String, int> _calculateTotalStats() {
    final stats = {'present': 0, 'absent': 0, 'late': 0, 'excused': 0};
    final attendanceStats = _calculateAttendanceStats();

    for (final userStats in attendanceStats.values) {
      stats['present'] = stats['present']! + userStats['present']!;
      stats['absent'] = stats['absent']! + userStats['absent']!;
      stats['late'] = stats['late']! + userStats['late']!;
      stats['excused'] = stats['excused']! + userStats['excused']!;
    }

    return stats;
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}