import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/model/schedule.dart';
import '../../../data/model/user.dart';
import '../../../presentation/provider/data_provider.dart';
import '../../../presentation/provider/auth_provider.dart';
import '../../../domain/entity/schedule_entity.dart';
import '../../../domain/entity/user_entity.dart';

class AdminScheduleManagement extends StatefulWidget {
  const AdminScheduleManagement({super.key});

  @override
  State<AdminScheduleManagement> createState() =>
      _AdminScheduleManagementState();
}

class _AdminScheduleManagementState extends State<AdminScheduleManagement> {
  List<Schedule> _schedules = [];
  List<User> _teachers = [];
  List<User> _students = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String? _selectedDay;
  bool _showTools = false;
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
    'Teknik Kendaraan Ringan Otomotif',
  ];

  // Data Mata Pelajaran Umum
  final List<String> generalSubjects = [
    'Bahasa Indonesia',
    'Matematika',
    'Bahasa Inggris',
    'Agama',
    'PKN',
    'Olahraga',
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final schedules = dataProvider.schedules;
      final allUsers = await authProvider.getAllUsers();
      final teachers = allUsers
          .where((u) => u.role == UserRole.teacher)
          .toList();
      final students = allUsers
          .where((u) => u.role == UserRole.student)
          .toList();

      if (mounted) {
        setState(() {
          _schedules = schedules;
          _teachers = teachers;
          _students = students;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data: ${e.toString()}';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
        );
      }
    }
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
        title: const Text('Konfirmasi Hapus'),
        content: Text('Hapus jadwal untuk ${schedule.subject}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final dataProvider = Provider.of<DataProvider>(context, listen: false);
        await dataProvider.deleteSchedule(schedule.id);
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Jadwal berhasil dihapus')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus jadwal: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  List<String> _getAvailableClasses() {
    if (_selectedMajor == null) return [];

    final classes = majorSubjects[_selectedMajor]?.keys.toList() ?? [];
    return ['All', ...classes];
  }

  List<String> _getAvailableSubjects() {
    if (_selectedMajor == null && _selectedClass == null) {
      return ['All', ...generalSubjects];
    }

    if (_selectedMajor != null &&
        _selectedClass != null &&
        _selectedClass != 'All') {
      final majorSubs = majorSubjects[_selectedMajor]?[_selectedClass] ?? [];
      return ['All', ...generalSubjects, ...majorSubs];
    }

    return ['All', ...generalSubjects];
  }

  void _showScheduleDialog({Schedule? schedule}) {
    final isEditing = schedule != null;
    final formKey = GlobalKey<FormState>();
    String? dialogError;

    String subject = schedule?.subject ?? '';
    String assignedToId = schedule?.assignedToId ?? '';
    String className = schedule?.className ?? '';
    String day = schedule?.day ?? 'Monday';
    String time = schedule?.time ?? '';
    String room = schedule?.room ?? '';
    ScheduleType scheduleType = schedule?.scheduleType ?? ScheduleType.teacher;
    String major = schedule?.major ?? '';
    String grade = schedule?.grade ?? '';

    final daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final grades = ['Kelas 10', 'Kelas 11', 'Kelas 12'];

    showDialog(
      context: context,
      barrierDismissible: !_isSaving,
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;
        final isMobileDialog = screenSize.width < 600;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            List<Widget> actions;
            if (isMobileDialog) {
              actions = [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton.icon(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              if (formKey.currentState!.validate()) {
                                formKey.currentState!.save();

                                setDialogState(() {
                                  _isSaving = true;
                                  dialogError = null;
                                });

                                try {
                                  final dataProvider =
                                      Provider.of<DataProvider>(
                                        context,
                                        listen: false,
                                      );

                                  final newSchedule = Schedule(
                                    id: isEditing
                                        ? schedule!.id
                                        : DateTime.now().millisecondsSinceEpoch
                                              .toString(),
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
                                    await dataProvider.updateSchedule(
                                      newSchedule,
                                    );
                                  } else {
                                    await dataProvider.addSchedule(newSchedule);
                                  }

                                  await _loadData();
                                  if (mounted) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isEditing
                                              ? 'Jadwal berhasil diperbarui'
                                              : 'Jadwal berhasil ditambahkan',
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  setDialogState(() {
                                    _isSaving = false;
                                    dialogError =
                                        'Gagal menyimpan jadwal: ${e.toString()}';
                                  });
                                }
                              }
                            },
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(isEditing ? 'Perbarui' : 'Tambah'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Batal'),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                      ),
                    ),
                  ],
                ),
              ];
            } else {
              actions = [
                TextButton(
                  onPressed: _isSaving
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();

                            setDialogState(() {
                              _isSaving = true;
                              dialogError = null;
                            });

                            try {
                              final dataProvider = Provider.of<DataProvider>(
                                context,
                                listen: false,
                              );

                              final newSchedule = Schedule(
                                id: isEditing
                                    ? schedule!.id
                                    : DateTime.now().millisecondsSinceEpoch
                                          .toString(),
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

                              await _loadData();
                              if (mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isEditing
                                          ? 'Jadwal berhasil diperbarui'
                                          : 'Jadwal berhasil ditambahkan',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              setDialogState(() {
                                _isSaving = false;
                                dialogError =
                                    'Gagal menyimpan jadwal: ${e.toString()}';
                              });
                            }
                          }
                        },
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(isEditing ? 'Perbarui' : 'Tambah'),
                ),
              ];
            }

            return AlertDialog(
              title: Text(isEditing ? 'Edit Jadwal' : 'Tambah Jadwal'),
              content: SizedBox(
                width: isMobileDialog ? screenSize.width * 0.9 : 500,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (dialogError != null)
                          Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              dialogError!,
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontSize: 12,
                              ),
                            ),
                          ),

                        // Schedule Type
                        DropdownButtonFormField<ScheduleType>(
                          value: scheduleType,
                          decoration: const InputDecoration(
                            labelText: 'Tipe Jadwal',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: ScheduleType.teacher,
                              child: Text('Jadwal Guru'),
                            ),
                            DropdownMenuItem(
                              value: ScheduleType.student,
                              child: Text('Jadwal Siswa'),
                            ),
                          ],
                          onChanged: _isSaving
                              ? null
                              : (value) {
                                  setDialogState(() => scheduleType = value!);
                                },
                        ),
                        const SizedBox(height: 12),

                        // Teacher/Student Selection
                        if (scheduleType == ScheduleType.teacher)
                          DropdownButtonFormField<String>(
                            value: assignedToId.isNotEmpty
                                ? assignedToId
                                : null,
                            decoration: const InputDecoration(
                              labelText: 'Guru',
                              border: OutlineInputBorder(),
                            ),
                            items: _teachers
                                .map(
                                  (teacher) => DropdownMenuItem(
                                    value: teacher.id,
                                    child: Text(teacher.name),
                                  ),
                                )
                                .toList(),
                            onChanged: _isSaving
                                ? null
                                : (value) => assignedToId = value!,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Guru wajib dipilih'
                                : null,
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
                                items: majors
                                    .map(
                                      (maj) => DropdownMenuItem(
                                        value: maj,
                                        child: Text(maj),
                                      ),
                                    )
                                    .toList(),
                                onChanged: _isSaving
                                    ? null
                                    : (value) {
                                        setDialogState(() {
                                          major = value!;
                                          className =
                                              ''; // Reset class when major changes
                                        });
                                      },
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Jurusan wajib dipilih'
                                    : null,
                              ),
                              const SizedBox(height: 12),

                              // Kelas
                              DropdownButtonFormField<String>(
                                value: grade.isNotEmpty ? grade : null,
                                decoration: const InputDecoration(
                                  labelText: 'Kelas',
                                  border: OutlineInputBorder(),
                                ),
                                items: grades
                                    .map(
                                      (gr) => DropdownMenuItem(
                                        value: gr,
                                        child: Text(gr),
                                      ),
                                    )
                                    .toList(),
                                onChanged: _isSaving
                                    ? null
                                    : (value) => grade = value!,
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Kelas wajib dipilih'
                                    : null,
                              ),
                            ],
                          ),

                        const SizedBox(height: 12),

                        // Subject
                        DropdownButtonFormField<String>(
                          value: subject.isNotEmpty ? subject : null,
                          decoration: const InputDecoration(
                            labelText: 'Mata Pelajaran',
                            border: OutlineInputBorder(),
                          ),
                          items: _getAvailableSubjects()
                              .map(
                                (sub) => DropdownMenuItem(
                                  value: sub,
                                  child: Text(sub),
                                ),
                              )
                              .toList(),
                          onChanged: _isSaving
                              ? null
                              : (value) => subject = value!,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Mata pelajaran wajib dipilih'
                              : null,
                        ),

                        const SizedBox(height: 12),

                        // Class Name (for both teacher and student)
                        TextFormField(
                          initialValue: className,
                          decoration: const InputDecoration(
                            labelText: 'Nama Kelas (contoh: 10A, 11B)',
                            border: OutlineInputBorder(),
                          ),
                          enabled: !_isSaving,
                          validator: (value) =>
                              value!.isEmpty ? 'Nama kelas wajib diisi' : null,
                          onSaved: (value) => className = value!,
                        ),

                        const SizedBox(height: 12),

                        // Day
                        DropdownButtonFormField<String>(
                          value: day,
                          decoration: const InputDecoration(
                            labelText: 'Hari',
                            border: OutlineInputBorder(),
                          ),
                          items: daysOfWeek
                              .map(
                                (day) => DropdownMenuItem(
                                  value: day,
                                  child: Text(day),
                                ),
                              )
                              .toList(),
                          onChanged: _isSaving ? null : (value) => day = value!,
                        ),

                        const SizedBox(height: 12),

                        // Time
                        TextFormField(
                          initialValue: time,
                          decoration: const InputDecoration(
                            labelText: 'Waktu (contoh: 08:00-09:00)',
                            border: OutlineInputBorder(),
                          ),
                          enabled: !_isSaving,
                          validator: (value) =>
                              value!.isEmpty ? 'Waktu wajib diisi' : null,
                          onSaved: (value) => time = value!,
                        ),

                        const SizedBox(height: 12),

                        // Room
                        TextFormField(
                          initialValue: room,
                          decoration: const InputDecoration(
                            labelText: 'Ruangan',
                            border: OutlineInputBorder(),
                          ),
                          enabled: !_isSaving,
                          validator: (value) =>
                              value!.isEmpty ? 'Ruangan wajib diisi' : null,
                          onSaved: (value) => room = value!,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: actions,
            );
          },
        );
      },
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
    return FilledButton.tonal(
      onPressed: () => _selectDay(day),
      style: FilledButton.styleFrom(
        backgroundColor: _selectedDay == day
            ? const Color(0xFF667EEA)
            : Colors.grey[100],
        foregroundColor: _selectedDay == day ? Colors.white : Colors.black87,
      ),
      child: Text(
        day.substring(0, 3),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  List<Schedule> _getFilteredSchedules() {
    var filtered = _schedules
        .where(
          (s) =>
              s.scheduleType ==
              (_selectedView == 'teacher'
                  ? ScheduleType.teacher
                  : ScheduleType.student),
        )
        .toList();

    if (_selectedDay != null && _selectedDay!.isNotEmpty) {
      filtered = filtered.where((s) => s.day == _selectedDay).toList();
    }

    if (_selectedMajor != null &&
        _selectedMajor!.isNotEmpty &&
        _selectedMajor != 'All') {
      filtered = filtered.where((s) => s.major == _selectedMajor).toList();
    }

    if (_selectedClass != null &&
        _selectedClass!.isNotEmpty &&
        _selectedClass != 'All') {
      filtered = filtered.where((s) => s.className == _selectedClass).toList();
    }

    if (_selectedSubject != null &&
        _selectedSubject!.isNotEmpty &&
        _selectedSubject != 'All') {
      filtered = filtered.where((s) => s.subject == _selectedSubject).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _loadData, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }

    final filteredSchedules = _getFilteredSchedules();
    final teacherSchedules = _schedules
        .where((s) => s.scheduleType == ScheduleType.teacher)
        .toList();
    final studentSchedules = _schedules
        .where((s) => s.scheduleType == ScheduleType.student)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1200;

        return Column(
          children: [
            // Tombol Kembali - Responsif
            Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/admin-dashboard'),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Kembali',
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                      fixedSize: Size(isMobile ? 36 : 40, isMobile ? 36 : 40),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Kembali',
                    style: TextStyle(
                      color: const Color(0xFF667EEA),
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                ],
              ),
            ),

            // Header dengan View Selector - Responsif
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
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
                  // Header Row - Responsif
                  isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Schedule Management',
                              style: TextStyle(
                                fontSize: isMobile ? 18 : 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF667EEA),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                // Teacher/Student View Toggle - Compact untuk mobile
                                Expanded(
                                  child: SegmentedButton<String>(
                                    segments: const [
                                      ButtonSegment<String>(
                                        value: 'teacher',
                                        label: Text(
                                          'Teacher',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        icon: Icon(Icons.person, size: 16),
                                      ),
                                      ButtonSegment<String>(
                                        value: 'student',
                                        label: Text(
                                          'Student',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        icon: Icon(Icons.school, size: 16),
                                      ),
                                    ],
                                    selected: {_selectedView},
                                    onSelectionChanged:
                                        (Set<String> newSelection) {
                                          setState(() {
                                            _selectedView = newSelection.first;
                                            _selectedMajor = null;
                                            _selectedClass = null;
                                            _selectedSubject = null;
                                          });
                                        },
                                    style: ButtonStyle(
                                      padding: MaterialStateProperty.all(
                                        const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 6,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Tools Toggle
                                IconButton.filledTonal(
                                  onPressed: _toggleTools,
                                  icon: Icon(
                                    _showTools
                                        ? Icons.close
                                        : Icons.filter_list,
                                    size: isMobile ? 20 : 24,
                                  ),
                                  tooltip: _showTools
                                      ? 'Hide Filters'
                                      : 'Show Filters',
                                  style: IconButton.styleFrom(
                                    fixedSize: Size(
                                      isMobile ? 32 : 40,
                                      isMobile ? 32 : 40,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Schedule Management',
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF667EEA),
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
                                  onSelectionChanged:
                                      (Set<String> newSelection) {
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
                                  icon: Icon(
                                    _showTools
                                        ? Icons.close
                                        : Icons.filter_list,
                                  ),
                                  tooltip: _showTools
                                      ? 'Hide Filters'
                                      : 'Show Filters',
                                ),
                              ],
                            ),
                          ],
                        ),

                  // Quick Stats - Responsif
                  SizedBox(height: isMobile ? 8 : 12),
                  isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatChip(
                              'Teachers: ${teacherSchedules.length}',
                            ),
                            const SizedBox(height: 4),
                            _buildStatChip(
                              'Students: ${studentSchedules.length}',
                            ),
                            const SizedBox(height: 4),
                            _buildStatChip('Total: ${_schedules.length}'),
                          ],
                        )
                      : Row(
                          children: [
                            _buildStatChip(
                              'Teachers: ${teacherSchedules.length}',
                            ),
                            const SizedBox(width: 8),
                            _buildStatChip(
                              'Students: ${studentSchedules.length}',
                            ),
                            const SizedBox(width: 8),
                            _buildStatChip('Total: ${_schedules.length}'),
                          ],
                        ),
                ],
              ),
            ),

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
                      children: [
                        _buildDayButton('Monday'),
                        _buildDayButton('Tuesday'),
                        _buildDayButton('Wednesday'),
                        _buildDayButton('Thursday'),
                        _buildDayButton('Friday'),
                        _buildDayButton('Saturday'),
                        FilledButton.tonal(
                          onPressed: () => setState(() => _selectedDay = null),
                          child: const Text('Show All'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Additional Filters for Student View - Responsif
                    if (_selectedView == 'student') ...[
                      const Divider(),
                      const Row(
                        children: [
                          Icon(Icons.filter_alt, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Filter Tambahan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Responsif: Column untuk mobile, Row untuk desktop
                      isMobile
                          ? Column(
                              children: [
                                // Jurusan Filter
                                DropdownButtonFormField<String>(
                                  value: _selectedMajor,
                                  decoration: const InputDecoration(
                                    labelText: 'Jurusan',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  items: [
                                    const DropdownMenuItem(
                                      value: 'All',
                                      child: Text('Semua Jurusan'),
                                    ),
                                    ...majors.map(
                                      (maj) => DropdownMenuItem(
                                        value: maj,
                                        child: Text(maj),
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedMajor = value;
                                      _selectedClass = null;
                                    });
                                  },
                                ),
                                const SizedBox(height: 12),
                                // Class Filter
                                DropdownButtonFormField<String>(
                                  value: _selectedClass,
                                  decoration: const InputDecoration(
                                    labelText: 'Kelas',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  items: _getAvailableClasses()
                                      .map(
                                        (cls) => DropdownMenuItem(
                                          value: cls,
                                          child: Text(cls),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) =>
                                      setState(() => _selectedClass = value),
                                ),
                                const SizedBox(height: 12),
                                // Subject Filter
                                DropdownButtonFormField<String>(
                                  value: _selectedSubject,
                                  decoration: const InputDecoration(
                                    labelText: 'Mata Pelajaran',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  items: _getAvailableSubjects()
                                      .map(
                                        (sub) => DropdownMenuItem(
                                          value: sub,
                                          child: Text(sub),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) =>
                                      setState(() => _selectedSubject = value),
                                ),
                              ],
                            )
                          : Row(
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
                                      const DropdownMenuItem(
                                        value: 'All',
                                        child: Text('Semua Jurusan'),
                                      ),
                                      ...majors.map(
                                        (maj) => DropdownMenuItem(
                                          value: maj,
                                          child: Text(maj),
                                        ),
                                      ),
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
                                      labelText: 'Kelas',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                    items: _getAvailableClasses()
                                        .map(
                                          (cls) => DropdownMenuItem(
                                            value: cls,
                                            child: Text(cls),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) =>
                                        setState(() => _selectedClass = value),
                                  ),
                                ),
                              ],
                            ),
                      if (!isMobile) ...[
                        const SizedBox(height: 12),
                        // Subject Filter
                        DropdownButtonFormField<String>(
                          value: _selectedSubject,
                          decoration: const InputDecoration(
                            labelText: 'Mata Pelajaran',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: _getAvailableSubjects()
                              .map(
                                (sub) => DropdownMenuItem(
                                  value: sub,
                                  child: Text(sub),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedSubject = value),
                        ),
                      ],
                    ],

                    const SizedBox(height: 16),

                    // Add Schedule Button
                    FilledButton.icon(
                      onPressed: _addSchedule,
                      icon: const Icon(Icons.add),
                      label: const Text('Add New Schedule'),
                    ),
                  ],
                ),
              ),

            // Schedules List - Responsif
            Expanded(
              child: filteredSchedules.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: isMobile ? 48 : 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: isMobile ? 12 : 16),
                          Text(
                            'Tidak ada jadwal ditemukan',
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: isMobile ? 6 : 8),
                          Text(
                            'Coba ubah filter atau tambahkan jadwal baru',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 16,
                        vertical: 8,
                      ),
                      itemCount: filteredSchedules.length,
                      itemBuilder: (context, index) {
                        final schedule = filteredSchedules[index];
                        final teacher = _teachers.firstWhere(
                          (t) => t.id == schedule.assignedToId,
                          orElse: () => User(
                            id: '',
                            username: '',
                            password: '',
                            role: UserRole.teacher,
                            name: 'Guru Tidak Diketahui',
                          ),
                        );

                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: isMobile ? 4 : 0,
                            vertical: 4,
                          ),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 16,
                              vertical: isMobile ? 8 : 12,
                            ),
                            leading: Container(
                              width: 4,
                              decoration: BoxDecoration(
                                color: _getScheduleColor(schedule.day),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            title: Text(
                              schedule.subject,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: isMobile ? 14 : 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: isMobile ? 2 : 4),
                                Text(
                                  '${schedule.className} • ${teacher.name}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: isMobile ? 12 : 14,
                                  ),
                                ),
                                SizedBox(height: isMobile ? 1 : 2),
                                Text(
                                  '${schedule.day} ${schedule.time} - Ruang ${schedule.room}',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: isMobile ? 11 : 13,
                                  ),
                                ),
                                if (schedule.major != null &&
                                    schedule.major!.isNotEmpty) ...[
                                  SizedBox(height: isMobile ? 1 : 2),
                                  Text(
                                    'Jurusan: ${schedule.major}${schedule.grade != null ? ' • ${schedule.grade}' : ''}',
                                    style: TextStyle(
                                      color: Colors.blue[600],
                                      fontSize: isMobile ? 10 : 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                size: isMobile ? 20 : 24,
                              ),
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
                                      Icon(
                                        Icons.delete,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Hapus',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
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
      },
    );
  }

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
