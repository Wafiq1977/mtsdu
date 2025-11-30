import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../presentation/provider/auth_provider.dart';
import '../../../presentation/provider/data_provider.dart';
import '../../../data/model/material.dart' as material_model;

class StudentMaterialsView extends StatefulWidget {
  const StudentMaterialsView({super.key});

  @override
  State<StudentMaterialsView> createState() => _StudentMaterialsViewState();
}

class _StudentMaterialsViewState extends State<StudentMaterialsView> {
  String? _selectedSubject;

  IconData _getMaterialIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'video':
        return Icons.video_library;
      case 'ppt':
      case 'powerpoint':
        return Icons.slideshow;
      case 'doc':
      case 'document':
        return Icons.description;
      default:
        return Icons.library_books;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DataProvider, AuthProvider>(
      builder: (context, dataProvider, authProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final allMaterials = dataProvider.materials
            .where((m) => m.className == user.className)
            .toList();

        final filteredMaterials = _selectedSubject == null
            ? allMaterials
            : allMaterials.where((m) => m.subject == _selectedSubject).toList();

        final availableSubjects =
            allMaterials.map((m) => m.subject).toSet().toList()..sort();

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go('/student-dashboard/beranda');
                }
              },
            ),
            title: const Text('Materi Pembelajaran'),
          ),
          body: Column(
            children: [
              // Filter Section
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.teal.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter berdasarkan Mata Pelajaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('Semua'),
                            selected: _selectedSubject == null,
                            onSelected: (selected) {
                              setState(() {
                                _selectedSubject = null;
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: Colors.teal.shade100,
                            checkmarkColor: Colors.teal,
                          ),
                          const SizedBox(width: 8),
                          ...availableSubjects.map(
                            (subject) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(subject),
                                selected: _selectedSubject == subject,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedSubject = selected
                                        ? subject
                                        : null;
                                  });
                                },
                                backgroundColor: Colors.white,
                                selectedColor: Colors.teal.shade100,
                                checkmarkColor: Colors.teal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Materials List
              Expanded(
                child: filteredMaterials.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.library_books,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedSubject == null
                                  ? 'Belum ada materi tersedia'
                                  : 'Tidak ada materi untuk mata pelajaran ini',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredMaterials.length,
                        itemBuilder: (context, index) {
                          final material = filteredMaterials[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () {
                                // TODO: Implement material viewing/downloading
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Membuka ${material.title}'),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.teal.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _getMaterialIcon(material.type),
                                        color: Colors.teal,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            material.title,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            material.subject,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Tipe: ${material.type} • Upload: ${material.uploadDate}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.download, color: Colors.teal),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
