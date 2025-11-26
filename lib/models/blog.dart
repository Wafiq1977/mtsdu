// lib/models/blog.dart
class Blog {
  final String id;
  final String title;
  final String content; // Kita ambil dari field 'description'
  final String author;  // Kita ambil dari field 'creator' (array)
  final DateTime createdAt; // Kita ambil dari field 'pubDate'
  final String? imageUrl; // Kita ambil dari field 'image_url'
  final String? link;

  Blog({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
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
    );
  }
}