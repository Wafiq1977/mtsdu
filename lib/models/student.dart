import 'user.dart';

class Student extends User {
  Student({
    required String id,
    required String username,
    required String password,
    required String name,
    String? profileImagePath,
    String? contact,
    required String className,
    required String major,
  }) : super(
          id: id,
          username: username,
          password: password,
          role: UserRole.student,
          name: name,
          profileImagePath: profileImagePath,
          contact: contact,
          className: className,
          major: major,
        );

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      name: map['name'],
      profileImagePath: map['profileImagePath'],
      contact: map['contact'],
      className: map['className'],
      major: map['major'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['role'] = UserRole.student.index;
    return map;
  }
}
