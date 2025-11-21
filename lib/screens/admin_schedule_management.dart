import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/schedule.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';

class AdminScheduleManagement extends StatefulWidget {
  const AdminScheduleManagement({super.key});

  @override
  State<AdminScheduleManagement> createState() => _AdminScheduleManagementState();
}

class _AdminScheduleManagementState extends State<AdminScheduleManagement> {
  List<Schedule> _schedules = [];
  List<User> _teachers = [];
  List<User> _students = [];
  bool _isLoading = true;
  String? _selectedDay;
  bool _showTools = false;
<<<<<<< HEAD
=======
  String _selectedView = 'teacher'; // 'teacher' or 'student'
  String? _selectedMajor;
  String? _selectedClass;
  String? _selectedSubject;

  // Data Jurusan
  final List<String> majors = [
    'Multimedia', 
    'Rekayasa Perangkat Lunak', 
    'Teknik Komputer dan Jaringan',
    'Manajemen', 
    'Teknik Kendaraan Ringan Otomotif'
  ];

  // Data Mata Pelajaran Umum
  final List<String> generalSubjects = [
    'Bahasa Indonesia',
    'Matematika', 
    'Bahasa Inggris',
    'Agama',
    'PKN',
    'Olahraga'
  ];

  // Data Mata Pelajaran Jurusan
  final Map<String, Map<String, List<String>>> majorSubjects = {
    'Multimedia': {
      'Kelas 10': ['Desain Grafis Percetakan'],
      'Kelas 11': ['Desain Media Interaktif'],
      'Kelas 12': ['Teknik Animasi 2D dan 3D'],
    },
    'Rekayasa Perangkat Lunak': {
      'Kelas 10': ['Pemrograman Dasar'],
      'Kelas 11': ['Basis Data'],
      'Kelas 12': ['Pemrograman Perangkat Lunak'],
    },
    'Teknik Komputer dan Jaringan': {
      'Kelas 10': ['Sistem Komputer'],
      'Kelas 11': ['Produk Kreatif dan Kewirausahaan'],
      'Kelas 12': ['Arsitektur Jaringan dan Komputer'],
    },
    'Manajemen': {
      'Kelas 10': ['Otomatisasi Tata Kelola Perkantoran'],
      'Kelas 11': ['Pengelolaan Sistem Informasi'],
      'Kelas 12': ['Ekonomi dan Bisnis'],
    },
    'Teknik Kendaraan Ringan Otomotif': {
      'Kelas 10': ['Teknologi Dasar Otomotif'],
      'Kelas 11': ['Pemeliharaan AC Kendaraan Ringan'],
      'Kelas 12': ['Pemeliharaan Kelistrikan'],
    },
  };
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final schedules = dataProvider.schedules;
    final allUsers = await authProvider.getAllUsers();
    final teachers = allUsers.where((u) => u.role == UserRole.teacher).toList();
    final students = allUsers.where((u) => u.role == UserRole.student).toList();

    setState(() {
      _schedules = schedules;
      _teachers = teachers;
      _students = students;
      _isLoading = false;
    });
  }

  void _addSchedule() {
    _showScheduleDialog();
  }

  void _editSchedule(Schedule schedule) {
    _showScheduleDialog(schedule: schedule);
  }

  void _deleteSchedule(Schedule schedule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete schedule for ${schedule.subject}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      await dataProvider.deleteSchedule(schedule.id);
<<<<<<< HEAD
=======
      _loadData();
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schedule deleted')),
      );
    }
  }

<<<<<<< HEAD
  void _showScheduleDialog({Schedule? schedule}) {
    final isEditing = schedule != null;
    final formKey = GlobalKey<FormState>();
=======
  List<String> _getAvailableClasses() {
    if (_selectedMajor == null) return [];
    
    final classes = majorSubjects[_selectedMajor]?.keys.toList() ?? [];
    return ['All', ...classes];
  }

  List<String> _getAvailableSubjects() {
    if (_selectedMajor == null && _selectedClass == null) {
      return ['All', ...generalSubjects];
    }
    
    if (_selectedMajor != null && _selectedClass != null && _selectedClass != 'All') {
      final majorSubs = majorSubjects[_selectedMajor]?[_selectedClass] ?? [];
      return ['All', ...generalSubjects, ...majorSubs];
    }
    
    return ['All', ...generalSubjects];
  }

  void _showScheduleDialog({Schedule? schedule}) {
    final isEditing = schedule != null;
    final formKey = GlobalKey<FormState>();
    
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
    String subject = schedule?.subject ?? '';
    String assignedToId = schedule?.assignedToId ?? '';
    String className = schedule?.className ?? '';
    String day = schedule?.day ?? 'Monday';
    String time = schedule?.time ?? '';
    String room = schedule?.room ?? '';
    ScheduleType scheduleType = schedule?.scheduleType ?? ScheduleType.teacher;
<<<<<<< HEAD

    final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Schedule' : 'Add Schedule'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: subject,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onSaved: (value) => subject = value!,
                ),
                DropdownButtonFormField<ScheduleType>(
                  value: scheduleType,
                  decoration: const InputDecoration(labelText: 'Schedule Type'),
                  items: [
                    DropdownMenuItem(
                      value: ScheduleType.teacher,
                      child: Text('Teacher Schedule'),
                    ),
                    DropdownMenuItem(
                      value: ScheduleType.student,
                      child: Text('Student Schedule'),
                    ),
                  ],
                  onChanged: (value) => setState(() => scheduleType = value!),
                ),
                if (scheduleType == ScheduleType.teacher)
                  DropdownButtonFormField<String>(
                    value: assignedToId.isNotEmpty ? assignedToId : null,
                    decoration: const InputDecoration(labelText: 'Teacher'),
                    items: _teachers.map((teacher) => DropdownMenuItem(
                      value: teacher.id,
                      child: Text(teacher.name),
                    )).toList(),
                    onChanged: (value) => assignedToId = value!,
                    onSaved: (value) => assignedToId = value!,
                    validator: (value) => value == null ? 'Required' : null,
                  )
                else
                  DropdownButtonFormField<String>(
                    value: assignedToId.isNotEmpty ? assignedToId : null,
                    decoration: const InputDecoration(labelText: 'Student'),
                    items: _students.map((student) => DropdownMenuItem(
                      value: student.id,
                      child: Text(student.name),
                    )).toList(),
                    onChanged: (value) => assignedToId = value!,
                    onSaved: (value) => assignedToId = value!,
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                DropdownButtonFormField<String>(
                  value: className.isNotEmpty ? className : null,
                  decoration: const InputDecoration(labelText: 'Class'),
                  items: _students.map((student) => DropdownMenuItem(
                    value: student.className,
                    child: Text(student.className ?? ''),
                  )).toSet().toList(),
                  onChanged: (value) => className = value ?? '',
                  onSaved: (value) => className = value ?? '',
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                DropdownButtonFormField<String>(
                  value: day,
                  decoration: const InputDecoration(labelText: 'Day'),
                  items: daysOfWeek.map((day) => DropdownMenuItem(
                    value: day,
                    child: Text(day),
                  )).toList(),
                  onChanged: (value) => day = value!,
                ),
                TextFormField(
                  initialValue: time,
                  decoration: const InputDecoration(labelText: 'Time (e.g., 08:00-09:00)'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onSaved: (value) => time = value!,
                ),
                TextFormField(
                  initialValue: room,
                  decoration: const InputDecoration(labelText: 'Room'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onSaved: (value) => room = value!,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                final dataProvider = Provider.of<DataProvider>(context, listen: false);

                final newSchedule = Schedule(
                  id: isEditing ? schedule!.id : DateTime.now().millisecondsSinceEpoch.toString(),
                  subject: subject,
                  assignedToId: assignedToId,
                  className: className,
                  day: day,
                  time: time,
                  room: room,
                  scheduleType: scheduleType,
                );

                if (isEditing) {
                  await dataProvider.updateSchedule(newSchedule);
                } else {
                  await dataProvider.addSchedule(newSchedule);
                }
                _loadData();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${isEditing ? 'Updated' : 'Added'} schedule')),
                );
              }
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
=======
    String major = schedule?.major ?? '';
    String grade = schedule?.grade ?? '';

    final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final grades = ['Kelas 10', 'Kelas 11', 'Kelas 12'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isEditing ? 'Edit Schedule' : 'Add Schedule'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Schedule Type
                    DropdownButtonFormField<ScheduleType>(
                      value: scheduleType,
                      decoration: const InputDecoration(
                        labelText: 'Schedule Type',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: ScheduleType.teacher,
                          child: Text('Teacher Schedule'),
                        ),
                        DropdownMenuItem(
                          value: ScheduleType.student,
                          child: Text('Student Schedule'),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() => scheduleType = value!);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Teacher/Student Selection
                    if (scheduleType == ScheduleType.teacher)
                      DropdownButtonFormField<String>(
                        value: assignedToId.isNotEmpty ? assignedToId : null,
                        decoration: const InputDecoration(
                          labelText: 'Teacher',
                          border: OutlineInputBorder(),
                        ),
                        items: _teachers.map((teacher) => DropdownMenuItem(
                          value: teacher.id,
                          child: Text(teacher.name),
                        )).toList(),
                        onChanged: (value) => assignedToId = value!,
                        validator: (value) => value == null ? 'Required' : null,
                      )
                    else
                      Column(
                        children: [
                          // Jurusan
                          DropdownButtonFormField<String>(
                            value: major.isNotEmpty ? major : null,
                            decoration: const InputDecoration(
                              labelText: 'Jurusan',
                              border: OutlineInputBorder(),
                            ),
                            items: majors.map((maj) => DropdownMenuItem(
                              value: maj,
                              child: Text(maj),
                            )).toList(),
                            onChanged: (value) {
                              setDialogState(() {
                                major = value!;
                                className = ''; // Reset class when major changes
                              });
                            },
                            validator: (value) => value == null ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),

                          // Kelas
                          DropdownButtonFormField<String>(
                            value: grade.isNotEmpty ? grade : null,
                            decoration: const InputDecoration(
                              labelText: 'Kelas',
                              border: OutlineInputBorder(),
                            ),
                            items: grades.map((gr) => DropdownMenuItem(
                              value: gr,
                              child: Text(gr),
                            )).toList(),
                            onChanged: (value) => grade = value!,
                            validator: (value) => value == null ? 'Required' : null,
                          ),
                        ],
                      ),

                    const SizedBox(height: 12),

                    // Subject
                    DropdownButtonFormField<String>(
                      value: subject.isNotEmpty ? subject : null,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                      ),
                      items: _getAvailableSubjects().map((sub) => DropdownMenuItem(
                        value: sub,
                        child: Text(sub),
                      )).toList(),
                      onChanged: (value) => subject = value!,
                      validator: (value) => value == null ? 'Required' : null,
                    ),

                    const SizedBox(height: 12),

                    // Class Name (for both teacher and student)
                    TextFormField(
                      initialValue: className,
                      decoration: const InputDecoration(
                        labelText: 'Class Name (e.g., 10A, 11B)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                      onSaved: (value) => className = value!,
                    ),

                    const SizedBox(height: 12),

                    // Day
                    DropdownButtonFormField<String>(
                      value: day,
                      decoration: const InputDecoration(
                        labelText: 'Day',
                        border: OutlineInputBorder(),
                      ),
                      items: daysOfWeek.map((day) => DropdownMenuItem(
                        value: day,
                        child: Text(day),
                      )).toList(),
                      onChanged: (value) => day = value!,
                    ),

                    const SizedBox(height: 12),

                    // Time
                    TextFormField(
                      initialValue: time,
                      decoration: const InputDecoration(
                        labelText: 'Time (e.g., 08:00-09:00)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                      onSaved: (value) => time = value!,
                    ),

                    const SizedBox(height: 12),

                    // Room
                    TextFormField(
                      initialValue: room,
                      decoration: const InputDecoration(
                        labelText: 'Room',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                      onSaved: (value) => room = value!,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    final dataProvider = Provider.of<DataProvider>(context, listen: false);

                    final newSchedule = Schedule(
                      id: isEditing ? schedule!.id : DateTime.now().millisecondsSinceEpoch.toString(),
                      subject: subject,
                      assignedToId: assignedToId,
                      className: className,
                      day: day,
                      time: time,
                      room: room,
                      scheduleType: scheduleType,
                      major: major,
                      grade: grade,
                    );

                    if (isEditing) {
                      await dataProvider.updateSchedule(newSchedule);
                    } else {
                      await dataProvider.addSchedule(newSchedule);
                    }
                    _loadData();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${isEditing ? 'Updated' : 'Added'} schedule')),
                    );
                  }
                },
                child: Text(isEditing ? 'Update' : 'Add'),
              ),
            ],
          );
        },
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
      ),
    );
  }

  void _toggleTools() {
    setState(() {
      _showTools = !_showTools;
    });
  }

  void _selectDay(String day) {
    setState(() {
      _selectedDay = day;
    });
  }

  Widget _buildDayButton(String day) {
<<<<<<< HEAD
    return ElevatedButton(
      onPressed: () => _selectDay(day),
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedDay == day ? const Color(0xFF667EEA) : Colors.grey[300],
        foregroundColor: _selectedDay == day ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        day.substring(0, 3), // Show first 3 letters
        style: const TextStyle(fontSize: 12),
=======
    return FilledButton.tonal(
      onPressed: () => _selectDay(day),
      style: FilledButton.styleFrom(
        backgroundColor: _selectedDay == day ? const Color(0xFF667EEA) : Colors.grey[100],
        foregroundColor: _selectedDay == day ? Colors.white : Colors.black87,
      ),
      child: Text(
        day.substring(0, 3),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
      ),
    );
  }

<<<<<<< HEAD
=======
  List<Schedule> _getFilteredSchedules() {
    var filtered = _schedules.where((s) => s.scheduleType == 
        (_selectedView == 'teacher' ? ScheduleType.teacher : ScheduleType.student)).toList();

    if (_selectedDay != null && _selectedDay!.isNotEmpty) {
      filtered = filtered.where((s) => s.day == _selectedDay).toList();
    }

    if (_selectedMajor != null && _selectedMajor!.isNotEmpty && _selectedMajor != 'All') {
      filtered = filtered.where((s) => s.major == _selectedMajor).toList();
    }

    if (_selectedClass != null && _selectedClass!.isNotEmpty && _selectedClass != 'All') {
      filtered = filtered.where((s) => s.className == _selectedClass).toList();
    }

    if (_selectedSubject != null && _selectedSubject!.isNotEmpty && _selectedSubject != 'All') {
      filtered = filtered.where((s) => s.subject == _selectedSubject).toList();
    }

    return filtered;
  }

>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

<<<<<<< HEAD
    final filteredSchedules = _selectedDay == null || _selectedDay == ''
        ? _schedules
        : _schedules.where((s) => s.day == _selectedDay).toList();

    return Column(
      children: [
        // Toggle Tools Button
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Schedule Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667EEA),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _toggleTools,
                icon: Icon(_showTools ? Icons.close : Icons.filter_list),
                label: Text(_showTools ? 'Hide Tools' : 'Show Tools'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  foregroundColor: Colors.white,
                ),
=======
    final filteredSchedules = _getFilteredSchedules();
    final teacherSchedules = _schedules.where((s) => s.scheduleType == ScheduleType.teacher).toList();
    final studentSchedules = _schedules.where((s) => s.scheduleType == ScheduleType.student).toList();

    return Column(
      children: [
        // Header dengan View Selector
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Schedule Management',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF667EEA),
                    ),
                  ),
                  Row(
                    children: [
                      // Teacher/Student View Toggle
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment<String>(
                            value: 'teacher',
                            label: Text('Teacher'),
                            icon: Icon(Icons.person),
                          ),
                          ButtonSegment<String>(
                            value: 'student',
                            label: Text('Student'),
                            icon: Icon(Icons.school),
                          ),
                        ],
                        selected: {_selectedView},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _selectedView = newSelection.first;
                            _selectedMajor = null;
                            _selectedClass = null;
                            _selectedSubject = null;
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      // Tools Toggle
                      IconButton.filledTonal(
                        onPressed: _toggleTools,
                        icon: Icon(_showTools ? Icons.close : Icons.filter_list),
                        tooltip: _showTools ? 'Hide Filters' : 'Show Filters',
                      ),
                    ],
                  ),
                ],
              ),
              
              // Quick Stats
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatChip('Teachers: ${teacherSchedules.length}'),
                  const SizedBox(width: 8),
                  _buildStatChip('Students: ${studentSchedules.length}'),
                  const SizedBox(width: 8),
                  _buildStatChip('Total: ${_schedules.length}'),
                ],
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
              ),
            ],
          ),
        ),
<<<<<<< HEAD
        if (_showTools)
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Filter by Day',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667EEA),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
=======

        // Filters Section
        if (_showTools)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              children: [
                // Day Filters
                const Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Filter by Day',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
                  children: [
                    _buildDayButton('Monday'),
                    _buildDayButton('Tuesday'),
                    _buildDayButton('Wednesday'),
                    _buildDayButton('Thursday'),
                    _buildDayButton('Friday'),
<<<<<<< HEAD
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => setState(() => _selectedDay = null),
                  child: const Text('Show All'),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _addSchedule,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Schedule'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
=======
                    _buildDayButton('Saturday'),
                    FilledButton.tonal(
                      onPressed: () => setState(() => _selectedDay = null),
                      child: const Text('Show All'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Additional Filters for Student View
                if (_selectedView == 'student') ...[
                  const Divider(),
                  const Row(
                    children: [
                      Icon(Icons.filter_alt, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Additional Filters',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Jurusan Filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedMajor,
                          decoration: const InputDecoration(
                            labelText: 'Jurusan',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: [
                            const DropdownMenuItem(value: 'All', child: Text('All Jurusan')),
                            ...majors.map((maj) => DropdownMenuItem(
                              value: maj,
                              child: Text(maj),
                            )),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedMajor = value;
                              _selectedClass = null;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Class Filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedClass,
                          decoration: const InputDecoration(
                            labelText: 'Class',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: _getAvailableClasses().map((cls) => DropdownMenuItem(
                            value: cls,
                            child: Text(cls),
                          )).toList(),
                          onChanged: (value) => setState(() => _selectedClass = value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Subject Filter
                  DropdownButtonFormField<String>(
                    value: _selectedSubject,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _getAvailableSubjects().map((sub) => DropdownMenuItem(
                      value: sub,
                      child: Text(sub),
                    )).toList(),
                    onChanged: (value) => setState(() => _selectedSubject = value),
                  ),
                ],

                const SizedBox(height: 16),
                
                // Add Schedule Button
                FilledButton.icon(
                  onPressed: _addSchedule,
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Schedule'),
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
                ),
              ],
            ),
          ),
<<<<<<< HEAD
        Expanded(
          child: ListView.builder(
            itemCount: filteredSchedules.length,
            itemBuilder: (context, index) {
              final schedule = filteredSchedules[index];
              final teacher = _teachers.firstWhere(
                (t) => t.id == schedule.assignedToId,
                orElse: () => User(id: '', username: '', password: '', role: UserRole.teacher, name: 'Unknown'),
              );

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text('${schedule.subject} - ${schedule.className}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Teacher: ${teacher.name}'),
                      Text('${schedule.day} ${schedule.time} - Room ${schedule.room}'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _editSchedule(schedule);
                          break;
                        case 'delete':
                          _deleteSchedule(schedule);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
=======

        // Schedules List
        Expanded(
          child: filteredSchedules.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.schedule, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No schedules found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Try changing your filters or add a new schedule',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: filteredSchedules.length,
                  itemBuilder: (context, index) {
                    final schedule = filteredSchedules[index];
                    final teacher = _teachers.firstWhere(
                      (t) => t.id == schedule.assignedToId,
                      orElse: () => User(id: '', username: '', password: '', role: UserRole.teacher, name: 'Unknown Teacher'),
                    );

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      elevation: 2,
                      child: ListTile(
                        leading: Container(
                          width: 4,
                          decoration: BoxDecoration(
                            color: _getScheduleColor(schedule.day),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        title: Text(
                          schedule.subject,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '${schedule.className} • ${teacher.name}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${schedule.day} ${schedule.time} - Room ${schedule.room}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13,
                              ),
                            ),
                            if (schedule.major != null && schedule.major!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Jurusan: ${schedule.major}${schedule.grade != null ? ' • ${schedule.grade}' : ''}',
                                style: TextStyle(
                                  color: Colors.blue[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                _editSchedule(schedule);
                                break;
                              case 'delete':
                                _deleteSchedule(schedule);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
        ),
      ],
    );
  }
<<<<<<< HEAD
}
=======

  Widget _buildStatChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF667EEA).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF667EEA),
        ),
      ),
    );
  }

  Color _getScheduleColor(String day) {
    final colors = {
      'Monday': Colors.blue,
      'Tuesday': Colors.green,
      'Wednesday': Colors.orange,
      'Thursday': Colors.purple,
      'Friday': Colors.red,
      'Saturday': Colors.teal,
      'Sunday': Colors.pink,
    };
    return colors[day] ?? Colors.grey;
  }
}
>>>>>>> 1693423c50ed70637638d99e5a1ee57200c6c6bb
