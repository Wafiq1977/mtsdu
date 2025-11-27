import '../../domain/entity/user_entity.dart';

class User {
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

  User({
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role.index,
      'name': name,
      'email': email,
      'profileImagePath': profileImagePath,
      'contact': contact,
      'className': className,
      'major': major,
      'nip': nip,
      'subject': subject,
      'nisn': nisn,
      'gender': gender,
      'birthPlace': birthPlace,
      'birthDate': birthDate?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      role: UserRole.values[map['role']],
      name: map['name'],
      email: map['email'],
      profileImagePath: map['profileImagePath'],
      contact: map['contact'],
      className: map['className'],
      major: map['major'],
      nip: map['nip'],
      subject: map['subject'],
      nisn: map['nisn'],
      gender: map['gender'],
      birthPlace: map['birthPlace'],
      birthDate: map['birthDate'] != null ? DateTime.parse(map['birthDate']) : null,
    );
  }

  User copyWith({
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
    return User(
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
