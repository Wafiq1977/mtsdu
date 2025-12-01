import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/provider/auth_provider.dart';
import '../../../presentation/provider/data_provider.dart';
import '../../../data/model/assignment.dart';

class StudentAssignmentsView extends StatelessWidget {
  const StudentAssignmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.currentUser!;
    final assignments = dataProvider.assignments
        .where((a) => a.className == user.className)
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Tugas'),
      ),
      body: ListView.builder(
        itemCount: assignments.length,
        itemBuilder: (context, index) {
          final Assignment assignment = assignments[index];
          return InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(assignment.title),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Deskripsi: ${assignment.description}'),
                        const SizedBox(height: 8),
                        Text('Mata Pelajaran: ${assignment.subject}'),
                        const SizedBox(height: 8),
                        Text('Deadline: ${assignment.dueDate}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Tutup'),
                      ),
                    ],
                  );
                },
              );
            },
            child: ListTile(
              title: Text(assignment.title),
              subtitle: Text(
                'Mata Pelajaran: ${assignment.subject} - Deadline: ${assignment.dueDate}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.upload),
                onPressed: () {
                  // TODO: Implement upload functionality
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
