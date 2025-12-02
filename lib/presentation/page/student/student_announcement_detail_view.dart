import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/model/announcement.dart';

class StudentAnnouncementDetailView extends StatelessWidget {
  final Announcement announcement;

  const StudentAnnouncementDetailView({super.key, required this.announcement});

  Widget _buildAnnouncementImage(String path) {
    if (path.isEmpty) return const SizedBox.shrink();

    Widget imageWidget(ImageProvider imageProvider) {
      return Image(
        image: imageProvider,
        width: 300, 
        height: 250,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 300,
          height: 250,
          color: Colors.white.withOpacity(0.2),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, color: Colors.white),
                Text('Gagal memuat gambar',
                    style: TextStyle(color: Colors.white, fontSize: 10)),
              ],
            ),
          ),
        ),
      );
    }

    if (path.startsWith('assets/')) {
      return imageWidget(AssetImage(path));
    } else if (path.startsWith('http')) {
      return imageWidget(NetworkImage(path));
    } else {
      try {
        final cleanBase64 = path.contains(',') ? path.split(',').last : path;
        Uint8List bytes = base64Decode(cleanBase64);
        return imageWidget(MemoryImage(bytes));
      } catch (e) {
        return Container(
          width: 300,
          height: 250,
          color: Colors.white.withOpacity(0.2),
          child: const Center(child: Icon(Icons.error, color: Colors.white)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. App Bar dengan Gambar (SliverAppBar)
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF667EEA),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                tooltip: 'Kembali',
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/student-dashboard/pengumuman');
                  }
                },
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                ),
                child: Center(
                  // Center widget agar gambar rata tengah
                  child: announcement.imageUrl != null &&
                          announcement.imageUrl!.isNotEmpty
                      ? _buildAnnouncementImage(announcement.imageUrl!)
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.announcement,
                              size: 80,
                              color: Colors.white24,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),

          // 2. Konten Detail
          SliverToBoxAdapter(
            child: Container(
              // Efek overlap agar terlihat seperti sheet yang naik
              transform: Matrix4.translationValues(0.0, -20.0, 0.0),
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indikator kecil di tengah atas sheet (opsional, pemanis UI)
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red.shade100),
                        ),
                        child: Text(
                          announcement.targetRole == 'all'
                              ? 'SEMUA WARGA SEKOLAH'
                              : announcement.targetRole.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "${announcement.date.day}/${announcement.date.month}/${announcement.date.year}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Judul Utama
                  Text(
                    announcement.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Isi Konten
                  Text(
                    announcement.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.8,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}