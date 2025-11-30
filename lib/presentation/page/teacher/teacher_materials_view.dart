import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../presentation/provider/auth_provider.dart';
import '../../../presentation/provider/data_provider.dart';
import '../../../data/model/material.dart' as model;

class TeacherMaterialsView extends StatefulWidget {
  const TeacherMaterialsView({super.key});

  @override
  State<TeacherMaterialsView> createState() => _TeacherMaterialsViewState();
}

class _TeacherMaterialsViewState extends State<TeacherMaterialsView> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.currentUser!;
    final materials = dataProvider.getMaterialsByTeacher(user.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Materi Pembelajaran'),
        backgroundColor: const Color(0xFF667EEA),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, size: 30),
            onPressed: () => _showAddMaterialDialog(context),
          ),
        ],
      ),
      body: materials.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada materi',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap tombol + untuk menambah materi baru',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: materials.length,
              itemBuilder: (context, index) {
                final material = materials[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => _showMaterialDetail(context, material),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getFileIcon(material.fileType),
                                  color: Colors.blue,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditMaterialDialog(context, material);
                                  } else if (value == 'delete') {
                                    _deleteMaterial(context, material);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 20),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Hapus',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildInfoChip(Icons.class_, material.className),
                              const SizedBox(width: 8),
                              _buildInfoChip(Icons.school, material.major),
                              const SizedBox(width: 8),
                              if (material.fileSize != null)
                                _buildInfoChip(
                                  Icons.file_present,
                                  '${material.fileSize!.toStringAsFixed(1)} MB',
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  IconData _getFileIcon(String? fileType) {
    switch (fileType?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'video':
      case 'mp4':
        return Icons.video_library;
      default:
        return Icons.insert_drive_file;
    }
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  void _showMaterialDetail(BuildContext context, model.Material material) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(material.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Mata Pelajaran', material.subject),
              _buildDetailRow('Kelas', material.className),
              _buildDetailRow('Jurusan', material.major),
              _buildDetailRow(
                'Tanggal Upload',
                material.uploadDate.toString().split(' ')[0],
              ),
              if (material.fileType != null)
                _buildDetailRow('Tipe File', material.fileType!.toUpperCase()),
              if (material.fileSize != null)
                _buildDetailRow(
                  'Ukuran File',
                  '${material.fileSize!.toStringAsFixed(2)} MB',
                ),
              const SizedBox(height: 12),
              const Text(
                'Deskripsi:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(material.description),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showAddMaterialDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateMaterialPage()),
    );
  }

  void _showEditMaterialDialog(BuildContext context, model.Material material) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateMaterialPage(material: material),
      ),
    );
  }

  void _deleteMaterial(BuildContext context, model.Material material) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Materi'),
        content: Text(
          'Apakah Anda yakin ingin menghapus materi "${material.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final dataProvider = Provider.of<DataProvider>(
                context,
                listen: false,
              );
              dataProvider.deleteMaterial(material.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Materi berhasil dihapus')),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Create/Edit Material Page
class CreateMaterialPage extends StatefulWidget {
  final model.Material? material;

  const CreateMaterialPage({super.key, this.material});

  @override
  State<CreateMaterialPage> createState() => _CreateMaterialPageState();
}

class _CreateMaterialPageState extends State<CreateMaterialPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  String? _selectedSubject;
  List<String> _selectedClasses = [];
  List<String> _availableClasses = [];
  PlatformFile? _attachedFile;

  final Map<String, List<String>> _subjectToClasses = {
    'Matematika': ['10A', '10B', '11A', '11B', '12A', '12B'],
    'Fisika': ['10A', '11A', '12A'],
    'Kimia': ['10B', '11B', '12B'],
    'Biologi': ['10A', '10B', '11A', '11B'],
    'Bahasa Indonesia': ['10A', '10B', '11A', '11B', '12A', '12B'],
    'Bahasa Inggris': ['10A', '10B', '11A', '11B', '12A', '12B'],
  };

  @override
  void initState() {
    super.initState();
    if (widget.material != null) {
      _title = widget.material!.title;
      _description = widget.material!.description;
      _selectedSubject = widget.material!.subject;
      _selectedClasses = [widget.material!.className];
      _availableClasses = _subjectToClasses[_selectedSubject] ?? [];
    } else {
      _title = '';
      _description = '';
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'mp4'],
      );

      if (result != null) {
        setState(() {
          _attachedFile = result.files.first;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() &&
        _selectedSubject != null &&
        _selectedClasses.isNotEmpty) {
      _formKey.currentState!.save();

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final user = authProvider.currentUser!;

      for (String className in _selectedClasses) {
        final material = model.Material(
          id:
              widget.material?.id ??
              '${DateTime.now().millisecondsSinceEpoch}_$className',
          title: _title,
          description: _description,
          subject: _selectedSubject!,
          teacherId: user.id,
          className: className,
          major: 'Multimedia', // Adjust based on your needs
          uploadDate: DateTime.now(),
          filePath: _attachedFile?.path,
          fileType: _attachedFile?.extension,
          fileSize: _attachedFile != null
              ? _attachedFile!.size / (1024 * 1024)
              : null,
        );

        if (widget.material != null) {
          dataProvider.updateMaterial(material);
        } else {
          dataProvider.addMaterial(material);
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.material != null
                ? 'Materi berhasil diupdate!'
                : 'Materi berhasil ditambahkan!',
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.material != null ? 'Edit Materi' : 'Tambah Materi'),
        backgroundColor: const Color(0xFF667EEA),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(
                  labelText: 'Judul Materi',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Judul harus diisi' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSubject,
                decoration: InputDecoration(
                  labelText: 'Mata Pelajaran',
                  prefixIcon: const Icon(Icons.subject),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _subjectToClasses.keys.map((subject) {
                  return DropdownMenuItem(value: subject, child: Text(subject));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSubject = value;
                    _availableClasses = _subjectToClasses[value!] ?? [];
                    _selectedClasses.clear();
                  });
                },
                validator: (value) =>
                    value == null ? 'Pilih mata pelajaran' : null,
              ),
              const SizedBox(height: 16),
              if (_selectedSubject != null) ...[
                const Text(
                  'Pilih Kelas:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _availableClasses.map((className) {
                    final isSelected = _selectedClasses.contains(className);
                    return FilterChip(
                      label: Text(className),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedClasses.add(className);
                          } else {
                            _selectedClasses.remove(className);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 4,
                validator: (value) =>
                    value!.isEmpty ? 'Deskripsi harus diisi' : null,
                onSaved: (value) => _description = value!,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(
                  _attachedFile == null
                      ? 'Pilih File'
                      : 'File: ${_attachedFile!.name}',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: const Color(0xFF667EEA),
                ),
                child: Text(
                  widget.material != null ? 'Update Materi' : 'Simpan Materi',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
