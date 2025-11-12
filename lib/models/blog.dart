// lib/models/blog.dart
class Blog {
  final String id;
  final String title;
  final String content; // Diisi dari 'description' API
  final String author;
  final DateTime createdAt; // Diisi dari 'publishedAt' API
  final String? imageUrl; // Diisi dari 'urlToImage' API

  Blog({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    this.imageUrl, // Dijadikan opsional
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['url'] ?? '', // Menggunakan URL sebagai ID unik
      title: json['title'] ?? 'No Title',
      content: json['description'] ?? 'No Content', // Menggunakan 'description'
      author: json['author'] ?? 'Unknown Author',
      createdAt: DateTime.parse(json['publishedAt'] ?? DateTime.now().toIso8601String()), // Menggunakan 'publishedAt'
      imageUrl: json['urlToImage'], // Mengambil URL gambar
    );
  }
}