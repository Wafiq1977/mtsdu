import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../presentation/provider/auth_provider.dart';
import '../../../presentation/provider/data_provider.dart';
import '../../../data/model/assignment.dart';
import '../../../data/model/user.dart';
import '../../../data/model/grade.dart';
import '../../../domain/entity/user_entity.dart';

class AssignmentListPage extends StatelessWidget {
  const AssignmentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.currentUser!;
    final assignments = dataProvider.assignments
        .where((a) => a.teacherId == user.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas'),
        backgroundColor: const Color(0xFF667EEA),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateAssignmentPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: assignments.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada tugas',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap tombol + untuk menambah tugas baru',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final assignment = assignments[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AssignmentDetailPage(assignment: assignment),
                      ),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.assignment,
                                  color: Colors.purple,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      assignment.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      assignment.subject,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildInfoChip(
                                Icons.class_,
                                assignment.className,
                              ),
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                Icons.calendar_today,
                                assignment.dueDate.split(' ')[0],
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
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }
}

class CreateAssignmentPage extends StatefulWidget {
  const CreateAssignmentPage({super.key});

  @override
  State<CreateAssignmentPage> createState() => _CreateAssignmentPageState();
}

class _CreateAssignmentPageState extends State<CreateAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String? _selectedSubject;
  String _dueDate = '';
  List<String> _selectedClasses = [];
  List<String> _availableClasses = [];
  final TextEditingController _dueDateController = TextEditingController();
  List<PlatformFile> _attachedFiles = [];

  // Mapping mata pelajaran ke kelas
  final Map<String, List<String>> _subjectToClasses = {
    'Matematika': ['10A', '10B', '11A', '11B', '12A', '12B'],
    'Fisika': ['10A', '11A', '12A'],
    'Kimia': ['10B', '11B', '12B'],
    'Biologi': ['10A', '10B', '11A', '11B'],
    'Bahasa Indonesia': ['10A', '10B', '11A', '11B', '12A', '12B'],
    'Bahasa Inggris': ['10A', '10B', '11A', '11B', '12A', '12B'],
    'Sejarah': ['10A', '11A', '12A'],
    'Geografi': ['10B', '11B', '12B'],
  };

  @override
  void dispose() {
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          _attachedFiles.addAll(result.files);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${result.files.length} file(s) ditambahkan')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking files: $e')));
    }
  }

  void _removeFile(int index) {
    setState(() {
      _attachedFiles.removeAt(index);
    });
  }

  void _submitAssignment() {
    if (_formKey.currentState!.validate() &&
        _selectedSubject != null &&
        _selectedClasses.isNotEmpty) {
      _formKey.currentState!.save();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final user = authProvider.currentUser!;

      for (String className in _selectedClasses) {
        final assignment = Assignment(
          id: '${DateTime.now().millisecondsSinceEpoch}_${className}_${_selectedSubject}',
          title: _title,
          description: _description,
          subject: _selectedSubject!,
          teacherId: user.id,
          className: className,
          major: [''], // Set default or extract from class
          dueDate: _dueDate,
          attachmentPath: '',
        );

        dataProvider.addAssignment(assignment);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tugas berhasil ditambahkan!')),
      );
      Navigator.pop(context);
    } else {
      String errorMsg = 'Lengkapi semua field yang diperlukan';
      if (_selectedSubject == null) {
        errorMsg = 'Pilih mata pelajaran terlebih dahulu';
      } else if (_selectedClasses.isEmpty) {
        errorMsg = 'Pilih minimal satu kelas';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked.toIso8601String();
        _dueDateController.text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  String _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return '🖼️';
      default:
        return '📎';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Tugas Baru'),
        backgroundColor: const Color(0xFF667EEA),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Judul Tugas
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Judul Tugas',
                  prefixIcon: const Icon(Icons.title, color: Color(0xFF667EEA)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Judul harus diisi' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),

              // Mata Pelajaran Dropdown
              DropdownButtonFormField<String>(
                value: _selectedSubject,
                decoration: InputDecoration(
                  labelText: 'Mata Pelajaran',
                  prefixIcon: const Icon(
                    Icons.subject,
                    color: Color(0xFF667EEA),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _subjectToClasses.keys.map((subject) {
                  return DropdownMenuItem<String>(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSubject = value;
                    _availableClasses = _subjectToClasses[value!] ?? [];
                    _selectedClasses.clear();
                  });
                },
                validator: (value) =>
                    value == null ? 'Pilih mata pelajaran' : null,
              ),
              const SizedBox(height: 16),

              // Kelas Selection
              if (_selectedSubject != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pilih Kelas Yang Diajar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF667EEA),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: _availableClasses.map((className) {
                          final isSelected = _selectedClasses.contains(
                            className,
                          );
                          return FilterChip(
                            label: Text(className),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedClasses.add(className);
                                } else {
                                  _selectedClasses.remove(className);
                                }
                              });
                            },
                            selectedColor: const Color(0xFF667EEA),
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            backgroundColor: Colors.white,
                          );
                        }).toList(),
                      ),
                      if (_selectedClasses.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            '⚠️ Pilih minimal satu kelas',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Deskripsi
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Deskripsi Tugas',
                  prefixIcon: const Icon(
                    Icons.description,
                    color: Color(0xFF667EEA),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) =>
                    value!.isEmpty ? 'Deskripsi harus diisi' : null,
                onSaved: (value) => _description = value!,
              ),
              const SizedBox(height: 16),

              // Deadline
              TextFormField(
                controller: _dueDateController,
                decoration: InputDecoration(
                  labelText: 'Deadline Pengumpulan',
                  prefixIcon: const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF667EEA),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                readOnly: true,
                onTap: () => _selectDueDate(context),
                validator: (value) =>
                    value!.isEmpty ? 'Tentukan deadline' : null,
              ),
              const SizedBox(height: 24),

              // File Attachment Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Lampiran File',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _pickFiles,
                          icon: const Icon(Icons.attach_file, size: 18),
                          label: const Text('Pilih File'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Format: JPG, PNG, PDF, DOC, DOCX',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (_attachedFiles.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      ...List.generate(_attachedFiles.length, (index) {
                        final file = _attachedFiles[index];
                        final extension = file.extension ?? '';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.purple[100]!),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _getFileIcon(extension),
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      file.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${(file.size / 1024).toStringAsFixed(1)} KB',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeFile(index),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton.icon(
                onPressed: _submitAssignment,
                icon: const Icon(Icons.send),
                label: const Text('Simpan dan Publikasikan Tugas'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: const Color(0xFF667EEA),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AssignmentDetailPage extends StatefulWidget {
  final Assignment assignment;

  const AssignmentDetailPage({super.key, required this.assignment});

  @override
  State<AssignmentDetailPage> createState() => _AssignmentDetailPageState();
}

class _AssignmentDetailPageState extends State<AssignmentDetailPage> {
  List<User> _students = [];
  List<Grade> _grades = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    final allUsers = await authProvider.getAllUsers();
    final students = allUsers.where((u) => u.role == UserRole.student).toList();

    // Filter students by class and major
    final filteredStudents = students
        .where(
          (student) =>
              student.className == widget.assignment.className &&
              (student.major != null &&
                  widget.assignment.major.contains(student.major!)),
        )
        .toList();

    // Get grades for this assignment
    final grades = dataProvider.grades
        .where(
          (g) =>
              g.assignment == widget.assignment.id &&
              g.subject == widget.assignment.subject,
        )
        .toList();

    setState(() {
      _students = filteredStudents;
      _grades = grades;
      _isLoading = false;
    });
  }

  Grade? _getGradeForStudent(String studentId) {
    return _grades.firstWhere(
      (grade) => grade.studentId == studentId,
      orElse: () => Grade(
        id: '',
        studentId: studentId,
        subject: widget.assignment.subject,
        assignment: widget.assignment.id,
        score: 0.0,
        date: '',
        teacherId: '',
      ),
    );
  }

  int get _totalStudents => _students.length;
  int get _submittedCount => _grades.length;
  int get _notSubmittedCount => _totalStudents - _submittedCount;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tugas'),
        backgroundColor: const Color(0xFF667EEA),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Assignment Details
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.assignment.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.assignment.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.subject,
                          widget.assignment.subject,
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          Icons.class_,
                          widget.assignment.className,
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          Icons.calendar_today,
                          widget.assignment.dueDate.split(' ')[0],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Statistics
            const Text(
              'Statistik Pengumpulan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Siswa',
                    _totalStudents.toString(),
                    Colors.blue,
                    Icons.people,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Sudah Submit',
                    _submittedCount.toString(),
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Belum Submit',
                    _notSubmittedCount.toString(),
                    Colors.orange,
                    Icons.pending,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Input Grades Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssignmentGradeInputPage(
                      assignment: widget.assignment,
                      students: _students,
                      existingGrades: _grades,
                    ),
                  ),
                ).then((_) => _loadData()); // Refresh data after returning
              },
              icon: const Icon(Icons.grade),
              label: const Text('Input Nilai'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Student Submissions
            const Text(
              'Pengumpulan Siswa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_students.isEmpty)
              const Center(child: Text('Tidak ada siswa di kelas ini'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _students.length,
                itemBuilder: (context, index) {
                  final student = _students[index];
                  final grade = _getGradeForStudent(student.id);
                  final hasSubmitted = grade!.id.isNotEmpty;

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'NISN: ${student.nisn ?? 'N/A'} | Kelas: ${student.className} | Jurusan: ${student.major}',
                                      style: TextStyle(
                                        fontSize: 12,
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
                                  color: hasSubmitted
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  hasSubmitted
                                      ? 'Sudah Submit'
                                      : 'Belum Submit',
                                  style: TextStyle(
                                    color: hasSubmitted
                                        ? Colors.green
                                        : Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (hasSubmitted) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Nilai: ${grade.score}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Tanggal: ${grade.date}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
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
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class AssignmentGradeInputPage extends StatefulWidget {
  final Assignment assignment;
  final List<User> students;
  final List<Grade> existingGrades;

  const AssignmentGradeInputPage({
    super.key,
    required this.assignment,
    required this.students,
    required this.existingGrades,
  });

  @override
  State<AssignmentGradeInputPage> createState() =>
      _AssignmentGradeInputPageState();
}

class _AssignmentGradeInputPageState extends State<AssignmentGradeInputPage> {
  final Map<String, TextEditingController> _scoreControllers = {};
  final Map<String, bool> _submittedStates = {};

  @override
  void initState() {
    super.initState();
    for (final student in widget.students) {
      final existingGrade = widget.existingGrades.firstWhere(
        (grade) => grade.studentId == student.id,
        orElse: () => Grade(
          id: '',
          studentId: student.id,
          subject: widget.assignment.subject,
          assignment: widget.assignment.id,
          score: 0.0,
          date: '',
          teacherId: '',
        ),
      );

      _scoreControllers[student.id] = TextEditingController(
        text: existingGrade.id.isNotEmpty ? existingGrade.score.toString() : '',
      );
      _submittedStates[student.id] = existingGrade.id.isNotEmpty;
    }
  }

  @override
  void dispose() {
    for (final controller in _scoreControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveGrade(String studentId) async {
    final scoreText = _scoreControllers[studentId]!.text;
    if (scoreText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nilai terlebih dahulu')),
      );
      return;
    }

    final score = double.tryParse(scoreText);
    if (score == null || score < 0 || score > 100) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nilai harus antara 0-100')));
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final teacher = authProvider.currentUser!;

    final grade = Grade(
      id: '${widget.assignment.id}_${studentId}_${DateTime.now().millisecondsSinceEpoch}',
      studentId: studentId,
      subject: widget.assignment.subject,
      assignment: widget.assignment.id,
      score: score,
      date: DateTime.now().toIso8601String(),
      teacherId: teacher.id,
    );

    await dataProvider.addGrade(grade);

    setState(() {
      _submittedStates[studentId] = true;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Nilai berhasil disimpan')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Nilai Tugas'),
        backgroundColor: const Color(0xFF667EEA),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.assignment.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Kelas: ${widget.assignment.className} | Jurusan: ${widget.assignment.major}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.students.length,
              itemBuilder: (context, index) {
                final student = widget.students[index];
                final hasSubmitted = _submittedStates[student.id] ?? false;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'NISN: ${student.nisn ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (hasSubmitted)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _scoreControllers[student.id],
                                decoration: const InputDecoration(
                                  labelText: 'Nilai (0-100)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () => _saveGrade(student.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: hasSubmitted
                                    ? Colors.green
                                    : const Color(0xFF667EEA),
                              ),
                              child: Text(hasSubmitted ? 'Update' : 'Simpan'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
