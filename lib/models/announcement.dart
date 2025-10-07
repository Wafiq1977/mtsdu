class Announcement {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final DateTime date;
  final String targetRole;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.date,
    required this.targetRole,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'date': date.toIso8601String(),
      'targetRole': targetRole,
    };
  }

  factory Announcement.fromMap(Map<String, dynamic> map) {
    return Announcement(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      authorId: map['authorId'],
      date: DateTime.parse(map['date']),
      targetRole: map['targetRole'],
    );
  }
}
