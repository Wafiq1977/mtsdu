import 'package:flutter/material.dart';

class StudentMaterialsScreen extends StatelessWidget {
  const StudentMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder for materials - you can expand this with actual materials data
    final materials = [
      {'title': 'Matematika Dasar', 'subject': 'Matematika', 'type': 'PDF'},
      {'title': 'Fisika Mekanika', 'subject': 'Fisika', 'type': 'Video'},
      {
        'title': 'Bahasa Indonesia',
        'subject': 'Bahasa Indonesia',
        'type': 'Dokumen',
      },
      {'title': 'Kimia Organik', 'subject': 'Kimia', 'type': 'PPT'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materi'),
        backgroundColor: const Color(0xFF667EEA),
        elevation: 0,
      ),
      body: Container(
        color: Colors.teal.shade50,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.centerLeft,
              child: Text(
                'Materi Pembelajaran',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade900,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: materials.length,
                itemBuilder: (context, index) {
                  final material = materials[index];
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
                      leading: Icon(
                        _getMaterialIcon(material['type'] as String),
                        color: Colors.teal,
                        size: 32,
                      ),
                      title: Text(
                        material['title'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${material['subject']} - ${material['type']}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.download, color: Colors.teal),
                        onPressed: () {
                          // TODO: Implement download functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Downloading ${material['title']}'),
                            ),
                          );
                        },
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

  IconData _getMaterialIcon(String type) {
    switch (type) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'Video':
        return Icons.video_library;
      case 'PPT':
        return Icons.slideshow;
      case 'Dokumen':
        return Icons.description;
      default:
        return Icons.library_books;
    }
  }
}
