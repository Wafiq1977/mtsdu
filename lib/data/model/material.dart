class Material {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String type; // PDF, Video, PPT, Dokumen
  final String url; // URL atau path ke file
  final String major;
  final String teacherId;
  final String className;
  final String uploadDate;

  Material({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.type,
    required this.url,
    required this.major,
    required this.teacherId,
    required this.className,
    required this.uploadDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'type': type,
      'url': url,
      'major': major,
      'teacherId': teacherId,
      'className': className,
      'uploadDate': uploadDate,
    };
  }

  factory Material.fromMap(Map<String, dynamic> map) {
    return Material(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      subject: map['subject'],
      type: map['type'],
      url: map['url'],
      major: map['major'],
      teacherId: map['teacherId'],
      className: map['className'],
      uploadDate: map['uploadDate'],
    );
  }
}
