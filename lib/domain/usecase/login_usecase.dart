import '../entity/user_entity.dart';
import '../repository/user_repository.dart';

class LoginUseCase {
  final UserRepository userRepository;

  LoginUseCase(this.userRepository);

  Future<UserEntity?> execute(String username, String password) async {
    final users = await userRepository.getAllUsers();
    try {
      return users.firstWhere(
        (user) => user.username == username && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }
}
