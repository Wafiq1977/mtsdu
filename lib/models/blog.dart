// lib/models/blog.dart
class Blog {
  final String id;
  final String title;
<<<<<<< HEAD
  final String content; // Diisi dari 'description' API
  final String author;
  final DateTime createdAt; // Diisi dari 'publishedAt' API
  final String? imageUrl; // Diisi dari 'urlToImage' API
=======
  final String content; // Kita ambil dari field 'description'
  final String author;  // Kita ambil dari field 'creator' (array)
  final DateTime createdAt; // Kita ambil dari field 'pubDate'
  final String? imageUrl; // Kita ambil dari field 'image_url'
  final String? link;
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b

  Blog({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
<<<<<<< HEAD
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
=======
    this.imageUrl,
    this.link,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    // Helper untuk mengambil author karena di NewsData.io 'creator' berbentuk List/Array
    String getAuthor(dynamic creatorField) {
      if (creatorField is List && creatorField.isNotEmpty) {
        return creatorField.first.toString(); // Ambil nama pertama
      }
      return 'Unknown Author';
    }

    return Blog(
      // Gunakan article_id sebagai ID unik
      id: json['article_id'] ?? DateTime.now().toString(),
      title: json['title'] ?? 'No Title',
      // Gunakan description karena content biasanya terkunci (paid plan)
      content: json['description'] ?? 'No Description', 
      author: getAuthor(json['creator']),
      // Parsing tanggal dari format string NewsData.io
      createdAt: json['pubDate'] != null 
          ? DateTime.tryParse(json['pubDate']) ?? DateTime.now() 
          : DateTime.now(),
      imageUrl: json['image_url'],
      link: json['link'],
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b
    );
  }
}