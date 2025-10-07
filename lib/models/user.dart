enum UserRole { student, teacher, admin }

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
    );
  }
}
