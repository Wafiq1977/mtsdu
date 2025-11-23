// lib/screens/blog_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/blog.dart';
// import 'package:url_launcher/url_launcher.dart'; // Aktifkan jika sudah install package url_launcher

class BlogDetailScreen extends StatelessWidget {
  final Blog blog;

  const BlogDetailScreen({super.key, required this.blog});

  // Fungsi helper untuk membuka link (Opsional: butuh package url_launcher)
  // Future<void> _launchURL() async {
  //   final Uri url = Uri.parse(blog.link ?? '');
  //   if (!await launchUrl(url)) {
  //     throw Exception('Could not launch $url');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Berita'),
        backgroundColor: const Color(0xFF667EEA), // Sesuaikan dengan tema app kamu
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gambar Header
            if (blog.imageUrl != null)
              Image.network(
                blog.imageUrl!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(height: 250, color: Colors.grey[300], child: const Icon(Icons.broken_image)),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Tanggal & Penulis
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "${blog.createdAt.day}/${blog.createdAt.month}/${blog.createdAt.year}",
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.person, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          blog.author,
                          style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. Judul Besar
                  Text(
                    blog.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // 4. Konten Berita
                  Text(
                    blog.content,
                    style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                  ),
                  
                  const SizedBox(height: 30),

                  // 5. Tombol Baca Selengkapnya
                  if (blog.link != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // _launchURL(); // Panggil fungsi launch url di sini
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Membuka link asli: ${blog.link}")),
                          );
                        },
                        icon: const Icon(Icons.open_in_browser),
                        label: const Text("Baca Selengkapnya di Web Asli"),
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
}