import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../models/attendance.dart' as attendance_model;

class StudentAttendanceScreen extends StatelessWidget {
  const StudentAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.currentUser!;
    final attendances = dataProvider.attendances
        .where((a) => a.studentId == user.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kehadiran'),
        backgroundColor: const Color(0xFF667EEA),
        elevation: 0,
      ),
      body: Container(
        color: Colors.orange.shade50,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.centerLeft,
              child: Text(
                'Your Attendance',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: attendances.length,
                itemBuilder: (context, index) {
                  final attendance = attendances[index];
                  Color statusColor;
                  switch (attendance.status) {
                    case attendance_model.AttendanceStatus.present:
                      statusColor = Colors.green;
                      break;
                    case attendance_model.AttendanceStatus.absent:
                      statusColor = Colors.red;
                      break;
                    case attendance_model.AttendanceStatus.late:
                      statusColor = Colors.orange;
                      break;
<<<<<<< HEAD
                    case attendance_model.AttendanceStatus.excused:
                      // TODO: Handle this case.
                      throw UnimplementedError();
=======
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b
                  }
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.check_circle, color: statusColor),
                      title: Text(
                        attendance.subject,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(attendance.date),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          attendance.status.toString().split('.').last,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b
