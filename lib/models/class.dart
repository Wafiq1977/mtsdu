class ClassModel {
  final String id;
  final String name; // e.g., "10A", "11B"
  final String major; // e.g., "IPA", "IPS"
  final String homeroomTeacherId; // ID of the homeroom teacher

  ClassModel({
    required this.id,
    required this.name,
    required this.major,
    required this.homeroomTeacherId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'major': major,
      'homeroomTeacherId': homeroomTeacherId,
    };
  }

  factory ClassModel.fromMap(Map<String, dynamic> map) {
    return ClassModel(
      id: map['id'],
      name: map['name'],
      major: map['major'],
      homeroomTeacherId: map['homeroomTeacherId'],
    );
  }
}
