import '../../../data/model/user.dart';
import '../../../domain/entity/user_entity.dart';

class Teacher extends User {
  Teacher({
    required String id,
    required String username,
    required String password,
    required String name,
    String? profileImagePath,
    String? contact,
    required String nip,
    required String subject,
  }) : super(
        id: id,
        username: username,
        password: password,
        role: UserRole.teacher,
        name: name,
        profileImagePath: profileImagePath,
        contact: contact,
        nip: nip,
        subject: subject,
      );

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      name: map['name'],
      profileImagePath: map['profileImagePath'],
      contact: map['contact'],
      nip: map['nip'],
      subject: map['subject'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['role'] = UserRole.teacher.index;
    return map;
  }
}
