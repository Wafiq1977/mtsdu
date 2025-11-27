import '../entity/user_entity.dart';
import '../entity/user_entity.dart' show UserRole;

abstract class UserRepository {
  Future<List<UserEntity>> getAllUsers();
  Future<UserEntity?> getUserById(String id);
  Future<UserEntity?> getUserByUsername(String username);
  Future<void> addUser(UserEntity user);
  Future<void> updateUser(UserEntity user);
  Future<void> deleteUser(String id);
  Future<List<UserEntity>> getUsersByRole(UserRole role);
  Future<List<UserEntity>> getStudents();
  Future<List<UserEntity>> getTeachers();
  Future<List<UserEntity>> getAdmins();
}
