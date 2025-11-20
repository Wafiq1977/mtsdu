import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../providers/auth_provider.dart';
import '../models/schedule.dart';

class StudentScheduleView extends StatelessWidget {
  const StudentScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser!;
    final schedules = dataProvider.schedules.where((s) => s.className == user.className).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Pelajaran'),
      ),
      body: ListView.builder(
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final Schedule schedule = schedules[index];
          return ListTile(
            title: Text(schedule.subject),
            subtitle: Text('${schedule.day} - ${schedule.time} - Room: ${schedule.room}'),
          );
        },
      ),
    );
  }
}
