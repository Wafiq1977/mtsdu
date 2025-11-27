import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/provider/data_provider.dart';
import '../../../data/model/grade.dart';

class StudentGradesView extends StatelessWidget {
  const StudentGradesView({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final grades = dataProvider.grades;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nilai / Raport'),
      ),
      body: ListView.builder(
        itemCount: grades.length,
        itemBuilder: (context, index) {
          final Grade grade = grades[index];
          return ListTile(
            title: Text(grade.subject),
            subtitle: Text('Tugas: ${grade.assignment} - Nilai: ${grade.score}'),
            trailing: Text(grade.date),
          );
        },
      ),
    );
  }
}
