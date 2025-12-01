import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/provider/auth_provider.dart';
import '../../../presentation/provider/data_provider.dart';
import '../../../data/model/assignment.dart';
import '../../../data/model/user.dart';
import '../../../data/model/grade.dart';
import '../../../domain/entity/user_entity.dart';

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
              student.major == widget.assignment.major,
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
