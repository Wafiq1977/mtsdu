import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../domain/entity/attendance_entity.dart';
import '../../../domain/entity/user_entity.dart';
import '../../../data/model/user.dart';
import '../../../data/model/attendance.dart';
import '../../../presentation/provider/data_provider.dart';
import '../../../presentation/provider/auth_provider.dart';

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
  String _selectedSubject = 'All';

  final List<String> months = [
    'All',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final List<String> subjects = [
    'All',
    'Math',
    'Science',
    'English',
    'History',
    'Religion',
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

      if (_selectedUserType == 'Students' && _selectedClass != 'All') {
        final user = userList.firstWhere((u) => u.id == attendance.studentId);
        if (user.className != _selectedClass) return false;
      }

      if (_selectedUserType == 'Teachers' && _selectedSubject != 'All') {
        final user = userList.firstWhere((u) => u.id == attendance.studentId);
        if (user.subject != _selectedSubject) return false;
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
      if (!stats.containsKey(userId)) {
        stats[userId] = {'present': 0, 'absent': 0, 'late': 0, 'total': 0};
      }

      stats[userId]!['total'] = stats[userId]!['total']! + 1;

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
        default:
          break;
      }
    }

    return stats;
  }

  Map<String, Map<String, int>> _getMonthlyStats() {
    final monthlyStats = <String, Map<String, int>>{};

    for (final attendance in _attendances) {
      final month = months[DateTime.parse(attendance.date).month];
      if (!monthlyStats.containsKey(month)) {
        monthlyStats[month] = {'present': 0, 'absent': 0, 'late': 0};
      }

      switch (attendance.status) {
        case AttendanceStatus.present:
          monthlyStats[month]!['present'] =
              monthlyStats[month]!['present']! + 1;
          break;
        case AttendanceStatus.absent:
          monthlyStats[month]!['absent'] = monthlyStats[month]!['absent']! + 1;
          break;
        case AttendanceStatus.late:
          monthlyStats[month]!['late'] = monthlyStats[month]!['late']! + 1;
          break;
        default:
          break;
      }
    }

    return monthlyStats;
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

  Map<String, int> _calculateTotalStats() {
    final stats = {'present': 0, 'absent': 0, 'late': 0};
    final attendanceStats = _calculateAttendanceStats();

    for (final userStats in attendanceStats.values) {
      stats['present'] = stats['present']! + userStats['present']!;
      stats['absent'] = stats['absent']! + userStats['absent']!;
      stats['late'] = stats['late']! + userStats['late']!;
    }

    return stats;
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
    final totalStats = _calculateTotalStats();
    final monthlyStats = _getMonthlyStats();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Tombol Kembali
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go('/admin-dashboard'),
                        icon: const Icon(Icons.arrow_back),
                        tooltip: 'Kembali',
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF667EEA),
                          foregroundColor: Colors.white,
                          fixedSize: const Size(40, 40),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Kembali',
                        style: TextStyle(
                          color: Color(0xFF667EEA),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // MODERN FILTERS - RESPONSIVE
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: isMobile
                        ? _buildMobileFilters(availableClasses)
                        : _buildDesktopFilters(availableClasses),
                  ),
                ),

                const SizedBox(height: 16),

                // STATISTICS CARDS - RESPONSIVE
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isMobile ? 2 : 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: isMobile ? 1.1 : 1.2,
                  children: [
                    _buildModernStatCard(
                      'Total Records',
                      filteredAttendances.length.toString(),
                      Icons.list_alt,
                      Colors.blue,
                    ),
                    _buildModernStatCard(
                      'Present',
                      totalStats['present'].toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildModernStatCard(
                      'Absent',
                      totalStats['absent'].toString(),
                      Icons.cancel,
                      Colors.red,
                    ),
                    _buildModernStatCard(
                      'Late',
                      totalStats['late'].toString(),
                      Icons.watch_later,
                      Colors.orange,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // MONTHLY STATISTICS CHART
                if (monthlyStats.isNotEmpty) ...[
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Monthly Attendance Overview',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: _buildMonthlyChart(monthlyStats, isMobile),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ATTENDANCE TABLE - RESPONSIVE
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Attendance Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        attendanceStats.isEmpty
                            ? _buildEmptyState()
                            : isMobile
                            ? _buildMobileTable(attendanceStats, userList)
                            : _buildDesktopTable(attendanceStats, userList),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // MOBILE FILTERS
  Widget _buildMobileFilters(List<String> availableClasses) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _selectedUserType,
          decoration: const InputDecoration(
            labelText: 'User Type',
            border: OutlineInputBorder(),
          ),
          items: ['Students', 'Teachers']
              .map((type) => DropdownMenuItem(value: type, child: Text(type)))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedUserType = value!;
              _selectedClass = 'All';
              _selectedSubject = 'All';
            });
          },
        ),
        const SizedBox(height: 12),

        if (_selectedUserType == 'Students')
          DropdownButtonFormField<String>(
            value: _selectedClass,
            decoration: const InputDecoration(
              labelText: 'Class',
              border: OutlineInputBorder(),
            ),
            items: availableClasses
                .map(
                  (className) => DropdownMenuItem(
                    value: className,
                    child: Text(className),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _selectedClass = value!),
          )
        else
          DropdownButtonFormField<String>(
            value: _selectedSubject,
            decoration: const InputDecoration(
              labelText: 'Subject',
              border: OutlineInputBorder(),
            ),
            items: subjects
                .map(
                  (subject) =>
                      DropdownMenuItem(value: subject, child: Text(subject)),
                )
                .toList(),
            onChanged: (value) => setState(() => _selectedSubject = value!),
          ),

        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedMonth,
          decoration: const InputDecoration(
            labelText: 'Month',
            border: OutlineInputBorder(),
          ),
          items: months
              .map(
                (month) => DropdownMenuItem(value: month, child: Text(month)),
              )
              .toList(),
          onChanged: (value) => setState(() => _selectedMonth = value!),
        ),
      ],
    );
  }

  // DESKTOP FILTERS
  Widget _buildDesktopFilters(List<String> availableClasses) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedUserType,
            decoration: const InputDecoration(
              labelText: 'User Type',
              border: OutlineInputBorder(),
            ),
            items: ['Students', 'Teachers']
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedUserType = value!;
                _selectedClass = 'All';
                _selectedSubject = 'All';
              });
            },
          ),
        ),
        const SizedBox(width: 12),

        if (_selectedUserType == 'Students')
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedClass,
              decoration: const InputDecoration(
                labelText: 'Class',
                border: OutlineInputBorder(),
              ),
              items: availableClasses
                  .map(
                    (className) => DropdownMenuItem(
                      value: className,
                      child: Text(className),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedClass = value!),
            ),
          )
        else
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedSubject,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
              items: subjects
                  .map(
                    (subject) =>
                        DropdownMenuItem(value: subject, child: Text(subject)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedSubject = value!),
            ),
          ),

        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedMonth,
            decoration: const InputDecoration(
              labelText: 'Month',
              border: OutlineInputBorder(),
            ),
            items: months
                .map(
                  (month) => DropdownMenuItem(value: month, child: Text(month)),
                )
                .toList(),
            onChanged: (value) => setState(() => _selectedMonth = value!),
          ),
        ),
      ],
    );
  }

  // MONTHLY CHART
  Widget _buildMonthlyChart(
    Map<String, Map<String, int>> monthlyStats,
    bool isMobile,
  ) {
    final chartMonths = months
        .where((month) => month != 'All' && monthlyStats.containsKey(month))
        .toList();

    return ListView(
      scrollDirection: Axis.horizontal,
      children: chartMonths.map((month) {
        final stats = monthlyStats[month]!;
        final total = stats['present']! + stats['absent']! + stats['late']!;
        final presentRate = total > 0 ? (stats['present']! / total * 100) : 0;

        return Container(
          width: isMobile ? 80 : 100,
          margin: const EdgeInsets.only(right: 12),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    FractionallySizedBox(
                      heightFactor: presentRate / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: presentRate >= 80
                              ? Colors.green
                              : presentRate >= 60
                              ? Colors.orange
                              : Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                month.substring(0, 3),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${presentRate.toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // MOBILE TABLE
  Widget _buildMobileTable(
    Map<String, Map<String, int>> attendanceStats,
    List<User> userList,
  ) {
    return Column(
      children: attendanceStats.entries.map((entry) {
        final userId = entry.key;
        final user = userList.firstWhere(
          (u) => u.id == userId,
          orElse: () => User(
            id: '',
            username: '',
            password: '',
            role: UserRole.student,
            name: 'Unknown',
          ),
        );
        final stats = entry.value;
        final rate = ((stats['present']! / stats['total']!) * 100);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Class: ${user.className ?? '-'}'),
                          Text('Present: ${stats['present']}'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Absent: ${stats['absent']}'),
                          Text('Late: ${stats['late']}'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: rate / 100,
                  backgroundColor: Colors.grey[300],
                  color: rate >= 80
                      ? Colors.green
                      : rate >= 60
                      ? Colors.orange
                      : Colors.red,
                ),
                const SizedBox(height: 4),
                Text(
                  'Attendance Rate: ${rate.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // DESKTOP TABLE
  Widget _buildDesktopTable(
    Map<String, Map<String, int>> attendanceStats,
    List<User> userList,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        dataRowMinHeight: 40,
        dataRowMaxHeight: 60,
        columns: [
          const DataColumn(
            label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          if (_selectedUserType == 'Students')
            const DataColumn(
              label: Text(
                'Class',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          else
            const DataColumn(
              label: Text(
                'Subject',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          const DataColumn(
            label: Text(
              'Present',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const DataColumn(
            label: Text(
              'Absent',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const DataColumn(
            label: Text('Late', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const DataColumn(
            label: Text('Rate', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        rows: attendanceStats.entries.map((entry) {
          final userId = entry.key;
          final user = userList.firstWhere(
            (u) => u.id == userId,
            orElse: () => User(
              id: '',
              username: '',
              password: '',
              role: UserRole.student,
              name: 'Unknown',
            ),
          );
          final stats = entry.value;
          final rate = ((stats['present']! / stats['total']!) * 100);

          return DataRow(
            cells: [
              DataCell(Text(user.name)),
              DataCell(
                Text(
                  _selectedUserType == 'Students'
                      ? user.className ?? '-'
                      : user.subject ?? '-',
                ),
              ),
              DataCell(
                Text(
                  stats['present'].toString(),
                  style: TextStyle(color: Colors.green.shade600),
                ),
              ),
              DataCell(
                Text(
                  stats['absent'].toString(),
                  style: TextStyle(color: Colors.red.shade600),
                ),
              ),
              DataCell(
                Text(
                  stats['late'].toString(),
                  style: TextStyle(color: Colors.orange.shade600),
                ),
              ),
              DataCell(
                Chip(
                  label: Text('${rate.toStringAsFixed(1)}%'),
                  backgroundColor: rate >= 80
                      ? Colors.green.shade100
                      : rate >= 60
                      ? Colors.orange.shade100
                      : Colors.red.shade100,
                  labelStyle: TextStyle(
                    color: rate >= 80
                        ? Colors.green.shade800
                        : rate >= 60
                        ? Colors.orange.shade800
                        : Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // EMPTY STATE
  Widget _buildEmptyState() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inbox, size: 64, color: Colors.grey),
        SizedBox(height: 16),
        Text(
          'No attendance records found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        SizedBox(height: 8),
        Text(
          'Try changing your filters or check back later',
          style: TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // MODERN STAT CARD
  Widget _buildModernStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
