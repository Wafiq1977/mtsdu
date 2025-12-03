class Announcement {
  String _id;
  String _title;
  String _content;
  String _authorId;
  DateTime _date;
  String _targetRole;
  String? _imageUrl;

  Announcement({
    required String id,
    required String title,
    required String content,
    required String authorId,
    required DateTime date,
    required String targetRole,
    String? imageUrl,
  }) : _id = id,
       _title = title,
       _content = content,
       _authorId = authorId,
       _date = date,
       _targetRole = targetRole,
       _imageUrl = imageUrl;

  // Getters
  String get id => _id;
  String get title => _title;
  String get content => _content;
  String get authorId => _authorId;
  DateTime get date => _date;
  String get targetRole => _targetRole;
  String? get imageUrl => _imageUrl;

  // Setters with validation for data integrity
  set id(String value) {
    if (value.isNotEmpty) {
      _id = value;
    }
  }

  set title(String value) {
    if (value.isNotEmpty) {
      _title = value;
    }
  }

  set content(String value) {
    if (value.isNotEmpty) {
      _content = value;
    }
  }

  set authorId(String value) {
    if (value.isNotEmpty) {
      _authorId = value;
    }
  }

  set date(DateTime value) {
    _date = value;
  }

  set targetRole(String value) {
    if (value.isNotEmpty) {
      _targetRole = value;
    }
  }

  set imageUrl(String? value) {
    _imageUrl = value;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'date': date.toIso8601String(),
      'targetRole': targetRole,
      'imageUrl': imageUrl,
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
      imageUrl: map['imageUrl'],
    );
  }
}
