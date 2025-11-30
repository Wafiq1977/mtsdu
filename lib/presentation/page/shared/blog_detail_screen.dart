import 'package:flutter/material.dart';
import '../../../data/model/blog.dart'; // [PENTING] Pastikan import ini ada

class BlogDetailScreen extends StatelessWidget {
  // Ubah parameter dari String blogId menjadi objek Blog
  final Blog blog;

  const BlogDetailScreen({super.key, required this.blog});

  @override
  Widget build(BuildContext context) {
    // Kita gunakan data dari objek 'blog' yang dikirim, bukan membuat map baru
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Berita'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BAGIAN GAMBAR ---
            _buildHeroImage(blog.imageUrl), // Panggil fungsi helper gambar

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- BAGIAN TANGGAL & PENULIS ---
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      // Gunakan data tanggal dari blog.createdAt
                      Text(
                        "${blog.createdAt.day}/${blog.createdAt.month}/${blog.createdAt.year}",
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.person, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        // Gunakan data penulis dari blog.author
                        child: Text(
                          blog.author,
                          style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- BAGIAN JUDUL ---
                  Text(
                    blog.title, // Gunakan blog.title
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // --- BAGIAN KONTEN ---
                  Text(
                    blog.content, // Gunakan blog.content
                    style: const TextStyle(
                        fontSize: 16, height: 1.6, color: Colors.black87),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 30),

                  // --- TOMBOL BACA SELENGKAPNYA ---
                  if (blog.link != null && blog.link!.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Implementasi buka link browser bisa ditambahkan di sini
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Link sumber: ${blog.link}")),
                          );
                        },
                        icon: const Icon(Icons.open_in_browser),
                        label: const Text("Baca Sumber Asli"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667EEA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk menampilkan gambar dengan penanganan error
  Widget _buildHeroImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: 250,
        width: double.infinity,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.article, size: 64, color: Colors.grey),
        ),
      );
    }

    return Image.network(
      imageUrl,
      height: 250,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 250,
          width: double.infinity,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
          ),
        );
      },
    );
  }
}