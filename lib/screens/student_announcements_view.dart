import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/announcement.dart';

class StudentAnnouncementsView extends StatelessWidget {
  const StudentAnnouncementsView({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final announcements = dataProvider.announcements;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumuman Sekolah'),
      ),
      body: ListView.builder(
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          final Announcement announcement = announcements[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(announcement.title),
              subtitle: Text('${announcement.content}\nTanggal: ${announcement.date}'),
            ),
          );
        },
      ),
    );
  }
}
