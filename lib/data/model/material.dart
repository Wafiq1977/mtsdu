class Material {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String teacherId;
  final String className;
  final String major;
  final DateTime uploadDate;
  final String? filePath;
  final String? fileType; // pdf, doc, video, etc
  final double? fileSize; // in MB

  Material({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.teacherId,
    required this.className,
    required this.major,
    required this.uploadDate,
    this.filePath,
    this.fileType,
    this.fileSize,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'teacherId': teacherId,
      'className': className,
      'major': major,
      'uploadDate': uploadDate.toIso8601String(),
      'filePath': filePath,
      'fileType': fileType,
      'fileSize': fileSize,
    };
  }

  factory Material.fromMap(Map<String, dynamic> map) {
    return Material(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      subject: map['subject'],
      teacherId: map['teacherId'],
      className: map['className'],
      major: map['major'],
      uploadDate: DateTime.parse(map['uploadDate']),
      filePath: map['filePath'],
      fileType: map['fileType'],
      fileSize: map['fileSize'],
    );
  }
}
