class Subject {
  final String id;
  final String name;
  final String description;
  final String teacherId; // ID of the teacher who teaches this subject

  Subject({
    required this.id,
    required this.name,
    required this.description,
    required this.teacherId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'teacherId': teacherId,
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      teacherId: map['teacherId'],
    );
  }
}
