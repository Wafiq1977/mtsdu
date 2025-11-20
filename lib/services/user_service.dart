import '../models/user.dart';
import 'hive_service.dart';

class UserService {
  Future<List<User>> getAllUsers() async {
    final box = HiveService.getUserBox();
    return box.values.map((e) => User.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  Future<User?> getUserById(String id) async {
    final box = HiveService.getUserBox();
    final userMap = box.get(id);
    if (userMap != null) {
      return User.fromMap(Map<String, dynamic>.from(userMap));
    }
    return null;
  }

  Future<User?> getUserByUsername(String username) async {
    final box = HiveService.getUserBox();
    final users = box.values.map((e) => User.fromMap(Map<String, dynamic>.from(e))).toList();
    try {
      return users.firstWhere((user) => user.username == username);
    } catch (e) {
      return null;
    }
  }

  Future<void> addUser(User user) async {
    final box = HiveService.getUserBox();
    await box.put(user.id, user.toMap());
  }

  Future<void> updateUser(User user) async {
    final box = HiveService.getUserBox();
    await box.put(user.id, user.toMap());
  }

  Future<void> deleteUser(String id) async {
    final box = HiveService.getUserBox();
    await box.delete(id);
  }

  Future<List<User>> getUsersByRole(UserRole role) async {
    final box = HiveService.getUserBox();
    final users = box.values.map((e) => User.fromMap(Map<String, dynamic>.from(e))).toList();
    return users.where((user) => user.role == role).toList();
  }

  Future<List<User>> getStudents() async {
    return getUsersByRole(UserRole.student);
  }

  Future<List<User>> getTeachers() async {
    return getUsersByRole(UserRole.teacher);
  }

  Future<List<User>> getAdmins() async {
    return getUsersByRole(UserRole.admin);
  }
}
