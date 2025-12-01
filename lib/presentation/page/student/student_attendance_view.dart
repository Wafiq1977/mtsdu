import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/provider/data_provider.dart';
import '../../../data/model/attendance.dart';

class StudentAttendanceView extends StatelessWidget {
  const StudentAttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final attendances = dataProvider.attendances;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Absensi'),
      ),
      body: ListView.builder(
        itemCount: attendances.length,
        itemBuilder: (context, index) {
          final Attendance attendance = attendances[index];
          return ListTile(
            title: Text(attendance.subject),
            subtitle: Text(
              'Tanggal: ${attendance.date} - Status: ${attendance.status}',
            ),
          );
        },
      ),
    );
  }
}
