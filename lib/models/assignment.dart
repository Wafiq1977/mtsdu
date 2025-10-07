class Assignment {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String teacherId;
  final String className;
  final String major;
  final String dueDate;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.teacherId,
    required this.className,
    required this.major,
    required this.dueDate,
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
      'dueDate': dueDate,
    };
  }

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      subject: map['subject'],
      teacherId: map['teacherId'],
      className: map['className'],
      major: map['major'],
      dueDate: map['dueDate'],
    );
  }
}
