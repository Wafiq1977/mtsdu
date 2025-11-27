import '../../domain/repository/user_repository.dart';
import '../../domain/entity/user_entity.dart';
import '../model/user.dart' as model;
import '../source/hive_service.dart';

class UserRepositoryImpl implements UserRepository {
  @override
  Future<List<UserEntity>> getAllUsers() async {
    final box = HiveService.getUserBox();
    return box.values.map((e) => _mapModelToEntity(model.User.fromMap(Map<String, dynamic>.from(e)))).toList();
  }

  @override
  Future<UserEntity?> getUserById(String id) async {
    final box = HiveService.getUserBox();
    final userMap = box.get(id);
    if (userMap != null) {
      return _mapModelToEntity(model.User.fromMap(Map<String, dynamic>.from(userMap)));
    }
    return null;
  }

  @override
  Future<UserEntity?> getUserByUsername(String username) async {
    final users = await getAllUsers();
    try {
      return users.firstWhere((user) => user.username == username);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addUser(UserEntity user) async {
    final box = HiveService.getUserBox();
    await box.put(user.id, _mapEntityToModel(user).toMap());
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    final box = HiveService.getUserBox();
    await box.put(user.id, _mapEntityToModel(user).toMap());
  }

  @override
  Future<void> deleteUser(String id) async {
    final box = HiveService.getUserBox();
    await box.delete(id);
  }

  @override
  Future<List<UserEntity>> getUsersByRole(dynamic role) async {
    final users = await getAllUsers();
    return users.where((user) => user.role == role).toList();
  }

  @override
  Future<List<UserEntity>> getStudents() async {
    return getUsersByRole(UserRole.student);
  }

  @override
  Future<List<UserEntity>> getTeachers() async {
    return getUsersByRole(UserRole.teacher);
  }

  @override
  Future<List<UserEntity>> getAdmins() async {
    return getUsersByRole(UserRole.admin);
  }

  UserEntity _mapModelToEntity(model.User user) {
    return UserEntity(
      id: user.id,
      username: user.username,
      password: user.password,
      role: user.role,
      name: user.name,
      email: user.email,
      profileImagePath: user.profileImagePath,
      contact: user.contact,
      className: user.className,
      major: user.major,
      nip: user.nip,
      subject: user.subject,
      nisn: user.nisn,
      gender: user.gender,
      birthPlace: user.birthPlace,
      birthDate: user.birthDate,
    );
  }

  model.User _mapEntityToModel(UserEntity user) {
    return model.User(
      id: user.id,
      username: user.username,
      password: user.password,
      role: user.role,
      name: user.name,
      email: user.email,
      profileImagePath: user.profileImagePath,
      contact: user.contact,
      className: user.className,
      major: user.major,
      nip: user.nip,
      subject: user.subject,
      nisn: user.nisn,
      gender: user.gender,
      birthPlace: user.birthPlace,
      birthDate: user.birthDate,
    );
  }
}
