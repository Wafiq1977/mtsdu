import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/model/academic_year.dart';
import '../../../presentation/provider/data_provider.dart';
import '../../../presentation/provider/auth_provider.dart';

class AdminAcademicYearManagement extends StatefulWidget {
  const AdminAcademicYearManagement({super.key});

  @override
  State<AdminAcademicYearManagement> createState() =>
      _AdminAcademicYearManagementState();
}

class _AdminAcademicYearManagementState
    extends State<AdminAcademicYearManagement> {
  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final academicYears = dataProvider.academicYears;
    final user = authProvider.currentUser;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Container(
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
                // Header Section with Back Button and Title
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Back Button Row
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.go('/admin-dashboard'),
                            icon: const Icon(Icons.arrow_back),
                            tooltip: 'Kembali',
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              foregroundColor: Colors.white,
                              fixedSize: const Size(40, 40),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Kembali ke Dashboard',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Title and Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Manajemen Tahun Akademik',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Kelola tahun akademik dan navigasi kalender',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isMobile) ...[
                            const SizedBox(width: 16),
                            FilledButton.icon(
                              onPressed: () => _showAcademicYearDialog(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Tambah Tahun Akademik'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF667EEA),
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Mobile Actions
                      if (isMobile) ...[
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => _showAcademicYearDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Tahun Akademik'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF667EEA),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Academic Years List
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16),
                    child: Card(
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: academicYears.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 80,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Belum ada tahun akademik',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    FilledButton.icon(
                                      onPressed: () =>
                                          _showAcademicYearDialog(context),
                                      icon: const Icon(Icons.add),
                                      label: const Text(
                                        'Tambah Tahun Akademik Pertama',
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: academicYears.length,
                                itemBuilder: (context, index) {
                                  final academicYear = academicYears[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: InkWell(
                                      onTap: () =>
                                          _navigateToAcademicYear(academicYear),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        academicYear
                                                            .displayName,
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        academicYear.year,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .calendar_today,
                                                            size: 16,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Text(
                                                            '${_formatDate(academicYear.startDate)} - ${_formatDate(academicYear.endDate)}',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .grey[600],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (academicYear.isActive) ...[
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      'Aktif',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                PopupMenuButton<String>(
                                                  icon: const Icon(
                                                    Icons.more_vert,
                                                  ),
                                                  onSelected: (value) {
                                                    switch (value) {
                                                      case 'edit':
                                                        _showAcademicYearDialog(
                                                          context,
                                                          academicYear:
                                                              academicYear,
                                                        );
                                                        break;
                                                      case 'delete':
                                                        _deleteAcademicYear(
                                                          context,
                                                          academicYear,
                                                        );
                                                        break;
                                                      case 'set_active':
                                                        _setActiveAcademicYear(
                                                          academicYear,
                                                        );
                                                        break;
                                                    }
                                                  },
                                                  itemBuilder: (context) => [
                                                    const PopupMenuItem(
                                                      value: 'edit',
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.edit,
                                                            size: 18,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text('Edit'),
                                                        ],
                                                      ),
                                                    ),
                                                    if (!academicYear.isActive)
                                                      const PopupMenuItem(
                                                        value: 'set_active',
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .check_circle,
                                                              size: 18,
                                                            ),
                                                            SizedBox(width: 8),
                                                            Text('Set Aktif'),
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
                                                            'Delete',
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            if (academicYear
                                                .description
                                                .isNotEmpty) ...[
                                              const SizedBox(height: 12),
                                              Text(
                                                academicYear.description,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Text(
                                                  '${academicYear.eventIds.length} kegiatan',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  'Dibuat: ${_formatDateTime(academicYear.createdAt)}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
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

  void _navigateToAcademicYear(AcademicYear academicYear) {
    // Navigate to student calendar view for this academic year
    context.go('/student-dashboard/calendar/${academicYear.year}');
  }

  void _showAcademicYearDialog(
    BuildContext context, {
    AcademicYear? academicYear,
  }) {
    showDialog(
      context: context,
      builder: (context) => AcademicYearDialog(
        academicYear: academicYear,
        onSave: (savedAcademicYear) async {
          final dataProvider = Provider.of<DataProvider>(
            context,
            listen: false,
          );
          if (academicYear == null) {
            await dataProvider.addAcademicYear(savedAcademicYear);
          } else {
            await dataProvider.updateAcademicYear(savedAcademicYear);
          }
        },
      ),
    );
  }

  void _deleteAcademicYear(
    BuildContext context,
    AcademicYear academicYear,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tahun Akademik'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${academicYear.displayName}"?',
        ),
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
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      await dataProvider.deleteAcademicYear(academicYear.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tahun akademik berhasil dihapus')),
      );
    }
  }

  void _setActiveAcademicYear(AcademicYear academicYear) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    // Set all academic years to inactive first
    for (final ay in dataProvider.academicYears) {
      if (ay.isActive) {
        final updatedAy = ay.copyWith(isActive: false);
        await dataProvider.updateAcademicYear(updatedAy);
      }
    }

    // Set the selected academic year to active
    final updatedAcademicYear = academicYear.copyWith(isActive: true);
    await dataProvider.updateAcademicYear(updatedAcademicYear);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${academicYear.displayName} telah diaktifkan')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// Dialog for creating/editing academic year
class AcademicYearDialog extends StatefulWidget {
  final AcademicYear? academicYear;
  final Function(AcademicYear) onSave;

  const AcademicYearDialog({
    super.key,
    this.academicYear,
    required this.onSave,
  });

  @override
  State<AcademicYearDialog> createState() => _AcademicYearDialogState();
}

class _AcademicYearDialogState extends State<AcademicYearDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _year = '';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 365));
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    if (widget.academicYear != null) {
      _nameController.text = widget.academicYear!.name;
      _descriptionController.text = widget.academicYear!.description;
      _year = widget.academicYear!.year;
      _startDate = widget.academicYear!.startDate;
      _endDate = widget.academicYear!.endDate;
      _isActive = widget.academicYear!.isActive;
    } else {
      // Generate default year
      final currentYear = DateTime.now().year;
      _year = '$currentYear-${currentYear + 1}';
      _startDate = DateTime(currentYear, 7, 1);
      _endDate = DateTime(currentYear + 1, 6, 30);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.academicYear == null
            ? 'Tambah Tahun Akademik'
            : 'Edit Tahun Akademik',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              TextFormField(
                initialValue: _year,
                decoration: const InputDecoration(
                  labelText: 'Tahun (contoh: 2024-2025)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Tahun wajib diisi';
                  if (!RegExp(r'^\d{4}-\d{4}$').hasMatch(value)) {
                    return 'Format tahun harus YYYY-YYYY';
                  }
                  return null;
                },
                onChanged: (value) => _year = value,
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
                          onPressed: () => _selectDate(true),
                          child: Text(_formatDate(_startDate)),
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
                          onPressed: () => _selectDate(false),
                          child: Text(_formatDate(_endDate)),
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
        FilledButton(onPressed: _saveAcademicYear, child: const Text('Simpan')),
      ],
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 365));
          }
        } else {
          _endDate = date;
        }
      });
    }
  }

  void _saveAcademicYear() {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser!;

      final academicYear = AcademicYear(
        id:
            widget.academicYear?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        year: _year,
        name: _nameController.text,
        startDate: _startDate,
        endDate: _endDate,
        description: _descriptionController.text,
        createdBy: widget.academicYear?.createdBy ?? user.id,
        createdAt: widget.academicYear?.createdAt ?? DateTime.now(),
        updatedAt: widget.academicYear != null ? DateTime.now() : null,
        isActive: _isActive,
        eventIds: widget.academicYear?.eventIds ?? [],
      );

      widget.onSave(academicYear);
      Navigator.of(context).pop();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
