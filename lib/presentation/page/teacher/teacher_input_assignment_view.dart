import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/provider/auth_provider.dart';
import '../../../presentation/provider/data_provider.dart';
import '../../../data/model/assignment.dart';
import '../../../data/model/user.dart';
import '../../../data/model/teacher.dart';
import '../../../presentation/widgets/user_card.dart';
import '../../../domain/entity/user_entity.dart';

class TeacherInputAssignmentView extends StatefulWidget {
  const TeacherInputAssignmentView({super.key});

  @override
  State<TeacherInputAssignmentView> createState() =>
      _TeacherInputAssignmentViewState();
}

class _TeacherInputAssignmentViewState
    extends State<TeacherInputAssignmentView> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _subject = '';
  String _dueDate = '';
  List<String> _selectedClasses = [];
  List<String> _selectedMajors = [];
  List<String> _availableClasses = [];
  List<String> _availableMajors = [];
  List<User> _students = [];
  bool _isLoading = true;
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _dueDateController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    if (currentUser != null) {
      // Logika: Kita asumsikan user yang login adalah Teacher atau memiliki field subject
      // Anda mungkin perlu casting jika User base class tidak mengekspos subject secara langsung
      // Contoh: if (currentUser is Teacher) { ... }

      // Mengambil subject dari property user (pastikan User/Teacher model mendukung ini)
      if (currentUser.subject != null && currentUser.subject!.isNotEmpty) {
        _subject = currentUser.subject!;
        _subjectController.text = _subject;
      } else {
        // Fallback jika tidak ada subject (misal admin yang login)
        _subject = '';
      }
    }
    final allUsers = await authProvider.getAllUsers();
    final students = allUsers.where((u) => u.role == UserRole.student).toList();
    final classes = students
        .map((s) => s.className)
        .where((c) => c != null && c.isNotEmpty)
        .toSet()
        .toList();
    final majors = students
        .map((s) => s.major)
        .where((m) => m != null && m.isNotEmpty)
        .toSet()
        .toList();

    setState(() {
      _students = students;
      _availableClasses = classes.cast<String>();
      _availableMajors = majors.cast<String>();
      _isLoading = false;
    });
  }

  void _submitAssignment() {
    if (_formKey.currentState!.validate() &&
        _selectedClasses.isNotEmpty &&
        _selectedMajors.isNotEmpty) {
      _formKey.currentState!.save();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final user = authProvider.currentUser!;

      // Create assignments for each combination of class and major
      for (String className in _selectedClasses) {
        for (String major in _selectedMajors) {
          final assignment = Assignment(
            id: '${DateTime.now().millisecondsSinceEpoch}_${className}_${major}',
            title: _title,
            description: _description,
            subject: _subject,
            teacherId: user.id,
            className: className,
            major: [major],
            dueDate: _dueDate,
            attachmentPath: '',
          );

          dataProvider.addAssignment(assignment);
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignments added successfully')),
      );
      _formKey.currentState!.reset();
      _dueDateController.clear();
      setState(() {
        _selectedClasses = [];
        _selectedMajors = [];
      });
    } else if (_selectedClasses.isEmpty || _selectedMajors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one class and one major'),
        ),
      );
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked.toIso8601String();
        _dueDateController.text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser!;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Assignment'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          UserCard(user: user),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Multi-select for Classes
                    const Text(
                      'Select Classes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      children: _availableClasses.map((className) {
                        final isSelected = _selectedClasses.contains(className);
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
                          selectedColor: Colors.blue.withOpacity(0.2),
                          checkmarkColor: Colors.blue,
                        );
                      }).toList(),
                    ),
                    if (_selectedClasses.isEmpty)
                      const Text(
                        'Please select at least one class',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    const SizedBox(height: 16),

                    // Multi-select for Majors
                    const Text(
                      'Select Majors',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      children: _availableMajors.map((major) {
                        final isSelected = _selectedMajors.contains(major);
                        return FilterChip(
                          label: Text(major),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedMajors.add(major);
                              } else {
                                _selectedMajors.remove(major);
                              }
                            });
                          },
                          selectedColor: Colors.blue.withOpacity(0.2),
                          checkmarkColor: Colors.blue,
                        );
                      }).toList(),
                    ),
                    if (_selectedMajors.isEmpty)
                      const Text(
                        'Please select at least one major',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    const SizedBox(height: 16),

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.title, color: Colors.blue),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Title is required' : null,
                      onSaved: (value) => _title = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description, color: Colors.blue),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) =>
                          value!.isEmpty ? 'Description is required' : null,
                      onSaved: (value) => _description = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller:
                          _subjectController, // Gunakan controller yang sudah diisi di initState
                      readOnly: true, // User tidak bisa mengubah ini
                      enabled: false, // Visual cue bahwa ini disabled
                      decoration: const InputDecoration(
                        labelText: 'Subject(Auto-filled)',
                        prefixIcon: Icon(Icons.subject, color: Colors.grey),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color(0xFFEEEEEE),
                      ),
                      validator: (value) => value!.isEmpty
                          ? 'Subject is missing for this teacher'
                          : null,
                      onSaved: (value) => _subject = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dueDateController,
                      decoration: const InputDecoration(
                        labelText: 'Due Date',
                        prefixIcon: Icon(
                          Icons.calendar_today,
                          color: Colors.blue,
                        ),
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () => _selectDueDate(context),
                      validator: (value) =>
                          value!.isEmpty ? 'Due date is required' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _submitAssignment,
                      icon: const Icon(Icons.save),
                      label: const Text('Add Assignment'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
