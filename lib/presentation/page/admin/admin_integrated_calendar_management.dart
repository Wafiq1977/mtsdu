import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../presentation/provider/auth_provider.dart';
import '../../../presentation/provider/data_provider.dart';
import '../../../data/model/calendar_event.dart';
import '../../../data/model/academic_year.dart';
import 'admin_calendar_history.dart';

class AdminIntegratedCalendarManagement extends StatefulWidget {
  const AdminIntegratedCalendarManagement({super.key});

  @override
  State<AdminIntegratedCalendarManagement> createState() =>
      _AdminIntegratedCalendarManagementState();
}

class _AdminIntegratedCalendarManagementState
    extends State<AdminIntegratedCalendarManagement>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _userRole = 'admin';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserRole();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadUserRole() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user != null) {
      setState(() {
        _userRole = user.role.toString().split('.').last;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
              Color(0xFFF093FB),
              Color(0xFFF5576C),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              _buildHeader(),

              // Tab Bar
              _buildTabBar(),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAcademicYearsTab(),
                    _buildCalendarEventsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back Button
          IconButton(
            onPressed: () => context.go('/admin-dashboard'),
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Kembali ke Dashboard',
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              fixedSize: const Size(40, 40),
            ),
          ),
          const SizedBox(width: 16),

          // Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manajemen Kalender Akademik',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Kelola tahun akademik dan kegiatan kalender',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // History Button
          IconButton(
            onPressed: () => _viewHistory(),
            icon: const Icon(Icons.history),
            tooltip: 'Riwayat Perubahan',
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              fixedSize: const Size(40, 40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.7),
        tabs: const [
          Tab(icon: Icon(Icons.calendar_today), text: 'Tahun Akademik'),
          Tab(icon: Icon(Icons.event), text: 'Kegiatan Kalender'),
        ],
      ),
    );
  }

  Widget _buildAcademicYearsTab() {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final academicYears = dataProvider.academicYears;

        return Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              // Header with Add Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF667EEA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daftar Tahun Akademik',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (_userRole == 'admin')
                      FilledButton.icon(
                        onPressed: () => _showAddAcademicYearDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF667EEA),
                        ),
                      ),
                  ],
                ),
              ),

              // Academic Years List
              Expanded(
                child: academicYears.isEmpty
                    ? _buildEmptyState(
                        'Tahun Akademik',
                        'Belum ada tahun akademik yang terdaftar',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: academicYears.length,
                        itemBuilder: (context, index) {
                          final academicYear = academicYears[index];
                          return _buildAcademicYearCard(academicYear);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendarEventsTab() {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final events = dataProvider.calendarEvents
            .where((event) => _filterEventByRole(event))
            .toList();

        return Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              // Header with Add Button and Filters
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF667EEA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Daftar Kegiatan Kalender',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (_canAddEvent())
                          FilledButton.icon(
                            onPressed: () => _showAddEventDialog(),
                            icon: const Icon(Icons.add),
                            label: const Text('Tambah'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF667EEA),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Quick Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatChip(
                          '${events.length}',
                          'Total Events',
                          Icons.event,
                        ),
                        _buildStatChip(
                          '${events.where((e) => e.type == EventType.academic).length}',
                          'Akademik',
                          Icons.school,
                        ),
                        _buildStatChip(
                          '${events.where((e) => e.type == EventType.exam).length}',
                          'Ujian',
                          Icons.assignment,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Events List
              Expanded(
                child: events.isEmpty
                    ? _buildEmptyState(
                        'Kegiatan Kalender',
                        'Belum ada kegiatan yang terdaftar',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return _buildEventCard(event);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAcademicYearCard(AcademicYear academicYear) {
    final eventCount = Provider.of<DataProvider>(context, listen: false)
        .calendarEvents
        .where((event) => _isEventInAcademicYear(event, academicYear))
        .length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showAcademicYearDetail(academicYear),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          academicYear.displayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${academicYear.startDate.year} - ${academicYear.endDate.year}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: academicYear.isActive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      academicYear.isActive ? 'Aktif' : 'Tidak Aktif',
                      style: TextStyle(
                        fontSize: 12,
                        color: academicYear.isActive
                            ? Colors.green
                            : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.event, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '$eventCount kegiatan',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              if (_userRole == 'admin') ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () =>
                          _showEditAcademicYearDialog(academicYear),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () =>
                          _showDeleteAcademicYearDialog(academicYear),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Hapus'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: event.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_formatDate(event.startDate)} • ${_getEventTypeName(event.type)}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (_canEditEvent(event))
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showEditEventDialog(event);
                          break;
                        case 'delete':
                          _showDeleteEventDialog(event);
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
              ],
            ),
            if (event.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                event.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada $title',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper Methods
  bool _canAddEvent() => _userRole == 'admin' || _userRole == 'teacher';

  bool _canEditEvent(CalendarEvent event) {
    if (_userRole == 'admin') return true;
    if (_userRole == 'teacher') {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      return user != null && event.createdBy == user.id;
    }
    return false;
  }

  bool _filterEventByRole(CalendarEvent event) {
    switch (event.target) {
      case EventTarget.all:
        return true;
      case EventTarget.students:
        return _userRole == 'student' || _userRole == 'admin';
      case EventTarget.teachers:
        return _userRole == 'teacher' || _userRole == 'admin';
      case EventTarget.admin:
        return _userRole == 'admin';
    }
  }

  bool _isEventInAcademicYear(CalendarEvent event, AcademicYear academicYear) {
    final eventYear = event.startDate.year;
    final eventMonth = event.startDate.month;
    final startYear = academicYear.startYear;
    final endYear = academicYear.endYear;

    if (eventYear == startYear && eventMonth >= 7) return true;
    if (eventYear == endYear && eventMonth <= 6) return true;
    return false;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getEventTypeName(EventType type) {
    switch (type) {
      case EventType.academic:
        return 'Akademik';
      case EventType.holiday:
        return 'Libur';
      case EventType.exam:
        return 'Ujian';
      case EventType.meeting:
        return 'Rapat';
      case EventType.reminder:
        return 'Pengingat';
    }
  }

  // Dialog Methods
  void _showAddAcademicYearDialog() {
    final _formKey = GlobalKey<FormState>();
    final _yearController = TextEditingController();
    final _nameController = TextEditingController();
    final _descriptionController = TextEditingController();
    DateTime _startDate = DateTime(DateTime.now().year, 7, 1);
    DateTime _endDate = DateTime(DateTime.now().year + 1, 6, 30);
    bool _isActive = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tambah Tahun Akademik'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _yearController,
                    decoration: const InputDecoration(
                      labelText: 'Tahun Akademik (contoh: 2024-2025)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tahun akademik wajib diisi';
                      }
                      if (!RegExp(r'^\d{4}-\d{4}$').hasMatch(value)) {
                        return 'Format harus YYYY-YYYY';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Tahun Akademik',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tanggal Mulai'),
                            FilledButton.tonal(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (date != null) {
                                  setState(() => _startDate = date);
                                }
                              },
                              child: Text(
                                '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tanggal Selesai'),
                            FilledButton.tonal(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _endDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (date != null) {
                                  setState(() => _endDate = date);
                                }
                              },
                              child: Text(
                                '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Aktifkan Tahun Akademik'),
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  final dataProvider = Provider.of<DataProvider>(
                    context,
                    listen: false,
                  );
                  final user = authProvider.currentUser!;

                  final academicYear = AcademicYear(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    year: _yearController.text,
                    name: _nameController.text,
                    startDate: _startDate,
                    endDate: _endDate,
                    description: _descriptionController.text,
                    createdBy: user.id,
                    createdAt: DateTime.now(),
                    isActive: _isActive,
                  );

                  await dataProvider.addAcademicYear(academicYear);
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tahun akademik berhasil ditambahkan'),
                    ),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAcademicYearDialog(AcademicYear academicYear) {
    final _formKey = GlobalKey<FormState>();
    final _yearController = TextEditingController(text: academicYear.year);
    final _nameController = TextEditingController(text: academicYear.name);
    final _descriptionController = TextEditingController(
      text: academicYear.description,
    );
    DateTime _startDate = academicYear.startDate;
    DateTime _endDate = academicYear.endDate;
    bool _isActive = academicYear.isActive;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Tahun Akademik'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _yearController,
                    decoration: const InputDecoration(
                      labelText: 'Tahun Akademik',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Tahun akademik wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Tahun Akademik',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tanggal Mulai'),
                            FilledButton.tonal(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (date != null) {
                                  setState(() => _startDate = date);
                                }
                              },
                              child: Text(
                                '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tanggal Selesai'),
                            FilledButton.tonal(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _endDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (date != null) {
                                  setState(() => _endDate = date);
                                }
                              },
                              child: Text(
                                '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Aktifkan Tahun Akademik'),
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final dataProvider = Provider.of<DataProvider>(
                    context,
                    listen: false,
                  );

                  final updatedAcademicYear = academicYear.copyWith(
                    year: _yearController.text,
                    name: _nameController.text,
                    startDate: _startDate,
                    endDate: _endDate,
                    description: _descriptionController.text,
                    updatedAt: DateTime.now(),
                    isActive: _isActive,
                  );

                  await dataProvider.updateAcademicYear(updatedAcademicYear);
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tahun akademik berhasil diperbarui'),
                    ),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAcademicYearDialog(AcademicYear academicYear) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tahun Akademik'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${academicYear.displayName}"? '
          'Semua data terkait akan terpengaruh.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final dataProvider = Provider.of<DataProvider>(
                context,
                listen: false,
              );
              await dataProvider.deleteAcademicYear(academicYear.id);
              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tahun akademik berhasil dihapus'),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showAcademicYearDetail(AcademicYear academicYear) {
    final events = Provider.of<DataProvider>(context, listen: false)
        .calendarEvents
        .where((event) => _isEventInAcademicYear(event, academicYear))
        .toList();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    academicYear.displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: events.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada kegiatan untuk tahun akademik ini',
                        ),
                      )
                    : ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return ListTile(
                            leading: Container(
                              width: 4,
                              height: 40,
                              color: event.color,
                            ),
                            title: Text(event.title),
                            subtitle: Text(event.description),
                            trailing: Text(_formatDate(event.startDate)),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddEventDialog() {
    final _formKey = GlobalKey<FormState>();
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();
    DateTime _startDate = DateTime.now();
    DateTime _endDate = DateTime.now().add(const Duration(hours: 1));
    Color _selectedColor = Colors.blue;
    EventType _selectedType = EventType.academic;
    EventTarget _selectedTarget = EventTarget.all;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tambah Kegiatan Kalender'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul Kegiatan',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Judul wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tanggal Mulai'),
                            FilledButton.tonal(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (date != null) {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(
                                      _startDate,
                                    ),
                                  );
                                  if (time != null) {
                                    setState(
                                      () => _startDate = DateTime(
                                        date.year,
                                        date.month,
                                        date.day,
                                        time.hour,
                                        time.minute,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Text(
                                '${_startDate.day}/${_startDate.month}/${_startDate.year} ${_startDate.hour}:${_startDate.minute.toString().padLeft(2, '0')}',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tanggal Selesai'),
                            FilledButton.tonal(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _endDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (date != null) {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(
                                      _endDate,
                                    ),
                                  );
                                  if (time != null) {
                                    setState(
                                      () => _endDate = DateTime(
                                        date.year,
                                        date.month,
                                        date.day,
                                        time.hour,
                                        time.minute,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Text(
                                '${_endDate.day}/${_endDate.month}/${_endDate.year} ${_endDate.hour}:${_endDate.minute.toString().padLeft(2, '0')}',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<EventType>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipe Kegiatan',
                      border: OutlineInputBorder(),
                    ),
                    items: EventType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getEventTypeName(type)),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedType = value!),
                  ),
                  const SizedBox(height: 12),
                  const Text('Warna'),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildColorOption(
                        Colors.blue,
                        _selectedColor,
                        (color) => setState(() => _selectedColor = color),
                      ),
                      _buildColorOption(
                        Colors.green,
                        _selectedColor,
                        (color) => setState(() => _selectedColor = color),
                      ),
                      _buildColorOption(
                        Colors.orange,
                        _selectedColor,
                        (color) => setState(() => _selectedColor = color),
                      ),
                      _buildColorOption(
                        Colors.red,
                        _selectedColor,
                        (color) => setState(() => _selectedColor = color),
                      ),
                      _buildColorOption(
                        Colors.purple,
                        _selectedColor,
                        (color) => setState(() => _selectedColor = color),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<EventTarget>(
                    value: _selectedTarget,
                    decoration: const InputDecoration(
                      labelText: 'Target Audience',
                      border: OutlineInputBorder(),
                    ),
                    items: EventTarget.values.map((target) {
                      return DropdownMenuItem(
                        value: target,
                        child: Text(_getTargetLabel(target)),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedTarget = value!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  final dataProvider = Provider.of<DataProvider>(
                    context,
                    listen: false,
                  );
                  final user = authProvider.currentUser!;

                  final event = CalendarEvent(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: _titleController.text,
                    description: _descriptionController.text,
                    startDate: _startDate,
                    endDate: _endDate,
                    type: _selectedType,
                    createdBy: user.id,
                    color: _selectedColor,
                    target: _selectedTarget,
                  );

                  await dataProvider.addCalendarEvent(event);
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kegiatan berhasil ditambahkan'),
                    ),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditEventDialog(CalendarEvent event) {
    final _formKey = GlobalKey<FormState>();
    final _titleController = TextEditingController(text: event.title);
    final _descriptionController = TextEditingController(
      text: event.description,
    );
    DateTime _startDate = event.startDate;
    DateTime _endDate =
        event.endDate ?? event.startDate.add(const Duration(hours: 1));
    Color _selectedColor = event.color;
    EventType _selectedType = event.type;
    EventTarget _selectedTarget = event.target;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Kegiatan Kalender'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul Kegiatan',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Judul wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tanggal Mulai'),
                            FilledButton.tonal(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (date != null) {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(
                                      _startDate,
                                    ),
                                  );
                                  if (time != null) {
                                    setState(
                                      () => _startDate = DateTime(
                                        date.year,
                                        date.month,
                                        date.day,
                                        time.hour,
                                        time.minute,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Text(
                                '${_startDate.day}/${_startDate.month}/${_startDate.year} ${_startDate.hour}:${_startDate.minute.toString().padLeft(2, '0')}',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tanggal Selesai'),
                            FilledButton.tonal(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _endDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (date != null) {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(
                                      _endDate,
                                    ),
                                  );
                                  if (time != null) {
                                    setState(
                                      () => _endDate = DateTime(
                                        date.year,
                                        date.month,
                                        date.day,
                                        time.hour,
                                        time.minute,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Text(
                                '${_endDate.day}/${_endDate.month}/${_endDate.year} ${_endDate.hour}:${_endDate.minute.toString().padLeft(2, '0')}',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<EventType>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipe Kegiatan',
                      border: OutlineInputBorder(),
                    ),
                    items: EventType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getEventTypeName(type)),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedType = value!),
                  ),
                  const SizedBox(height: 12),
                  const Text('Warna'),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildColorOption(
                        Colors.blue,
                        _selectedColor,
                        (color) => setState(() => _selectedColor = color),
                      ),
                      _buildColorOption(
                        Colors.green,
                        _selectedColor,
                        (color) => setState(() => _selectedColor = color),
                      ),
                      _buildColorOption(
                        Colors.orange,
                        _selectedColor,
                        (color) => setState(() => _selectedColor = color),
                      ),
                      _buildColorOption(
                        Colors.red,
                        _selectedColor,
                        (color) => setState(() => _selectedColor = color),
                      ),
                      _buildColorOption(
                        Colors.purple,
                        _selectedColor,
                        (color) => setState(() => _selectedColor = color),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<EventTarget>(
                    value: _selectedTarget,
                    decoration: const InputDecoration(
                      labelText: 'Target Audience',
                      border: OutlineInputBorder(),
                    ),
                    items: EventTarget.values.map((target) {
                      return DropdownMenuItem(
                        value: target,
                        child: Text(_getTargetLabel(target)),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedTarget = value!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final dataProvider = Provider.of<DataProvider>(
                    context,
                    listen: false,
                  );

                  final updatedEvent = CalendarEvent(
                    id: event.id,
                    title: _titleController.text,
                    description: _descriptionController.text,
                    startDate: _startDate,
                    endDate: _endDate,
                    type: _selectedType,
                    createdBy: event.createdBy,
                    color: _selectedColor,
                    target: _selectedTarget,
                    history: event.history,
                  );

                  await dataProvider.updateCalendarEvent(updatedEvent);
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kegiatan berhasil diperbarui'),
                    ),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteEventDialog(CalendarEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kegiatan'),
        content: Text('Apakah Anda yakin ingin menghapus "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final dataProvider = Provider.of<DataProvider>(
                context,
                listen: false,
              );
              await dataProvider.deleteCalendarEvent(event.id);
              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kegiatan berhasil dihapus')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(
    Color color,
    Color selectedColor,
    Function(Color) onSelect,
  ) {
    return GestureDetector(
      onTap: () => onSelect(color),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selectedColor == color
              ? Border.all(color: Colors.black, width: 2)
              : null,
        ),
      ),
    );
  }

  String _getTargetLabel(EventTarget target) {
    switch (target) {
      case EventTarget.all:
        return 'Semua Pengguna';
      case EventTarget.students:
        return 'Hanya Siswa';
      case EventTarget.teachers:
        return 'Hanya Guru';
      case EventTarget.admin:
        return 'Hanya Admin';
    }
  }

  void _viewHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AdminCalendarHistory()),
    );
  }
}
