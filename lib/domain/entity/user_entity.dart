enum UserRole { student, teacher, admin }

class UserEntity {
  final String id;
  final String username;
  final String password;
  final UserRole role;
  final String name;
  final String? email;
  final String? profileImagePath;
  final String? contact;
  final String? className; // For students
  final String? major; // For students
  final String? nip; // For teachers
  final String? subject; // For teachers
  final String? nisn; // NISN for students
  final String? gender; // Gender for students
  final String? birthPlace; // Birth place for students
  final DateTime? birthDate; // Birth date for students

  UserEntity({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.name,
    this.email,
    this.profileImagePath,
    this.contact,
    this.className,
    this.major,
    this.nip,
    this.subject,
    this.nisn,
    this.gender,
    this.birthPlace,
    this.birthDate,
  });

  UserEntity copyWith({
    String? id,
    String? username,
    String? password,
    UserRole? role,
    String? name,
    String? email,
    String? profileImagePath,
    String? contact,
    String? className,
    String? major,
    String? nip,
    String? subject,
    String? nisn,
    String? gender,
    String? birthPlace,
    DateTime? birthDate,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      contact: contact ?? this.contact,
      className: className ?? this.className,
      major: major ?? this.major,
      nip: nip ?? this.nip,
      subject: subject ?? this.subject,
      nisn: nisn ?? this.nisn,
      gender: gender ?? this.gender,
      birthPlace: birthPlace ?? this.birthPlace,
      birthDate: birthDate ?? this.birthDate,
    );
  }
}
