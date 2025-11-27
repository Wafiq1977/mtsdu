import 'package:flutter/material.dart';

class TeacherGradesInput extends StatefulWidget {
  const TeacherGradesInput({super.key});

  @override
  State<TeacherGradesInput> createState() => _TeacherGradesInputState();
}

class _TeacherGradesInputState extends State<TeacherGradesInput> {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _subjectController = TextEditingController();
  final _scoreController = TextEditingController();

  @override
  void dispose() {
    _studentIdController.dispose();
    _subjectController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save grade to local storage
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Grade submitted')),
      );
      _studentIdController.clear();
      _subjectController.clear();
      _scoreController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Student Grades'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _studentIdController,
                decoration: const InputDecoration(labelText: 'Student ID'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter student ID' : null,
              ),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Subject'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter subject' : null,
              ),
              TextFormField(
                controller: _scoreController,
                decoration: const InputDecoration(labelText: 'Score'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter score';
                  }
                  final score = double.tryParse(value);
                  if (score == null || score < 0 || score > 100) {
                    return 'Enter valid score 0-100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
