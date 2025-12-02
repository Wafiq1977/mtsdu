import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/provider/data_provider.dart';
import '../../../data/model/material.dart' as model;

class StudentMaterialsScreen extends StatelessWidget {
  const StudentMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final materials = dataProvider.materials;

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
              child: materials.isEmpty
                  ? const Center(child: Text('Tidak ada materi yang tersedia.'))
                  : ListView.builder(
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
                              _getMaterialIcon(material.type),
                              color: Colors.teal,
                              size: 32,
                            ),
                            title: Text(
                              material.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${material.subject} - ${material.type?.toUpperCase() ?? 'FILE'}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.download,
                                color: Colors.teal,
                              ),
                              onPressed: () {
                                // TODO: Implement download functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Downloading ${material.title}',
                                    ),
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

  IconData _getMaterialIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'mp4':
        return Icons.video_library;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.library_books;
    }
  }
}
