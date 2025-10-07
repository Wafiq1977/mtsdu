import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';
import '../services/hive_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final box = HiveService.getUserBox();
      final users = box.values.map((e) => User.fromMap(Map<String, dynamic>.from(e))).toList();

      final user = users.firstWhere(
        (u) => u.username == username && u.password == password,
        orElse: () => throw Exception('Invalid credentials'),
      );

      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? account = await googleSignIn.signIn();

      if (account != null) {
        final box = HiveService.getUserBox();
        final users = box.values.map((e) => User.fromMap(Map<String, dynamic>.from(e))).toList();

        User? user = users.cast<User?>().firstWhere(
          (u) => u?.email == account.email,
          orElse: () => null,
        );

        if (user == null) {
          // Create new user as student
          user = User(
            id: account.id,
            username: account.email!,
            password: '', // No password for Google login
            email: account.email,
            role: UserRole.student,
            name: account.displayName ?? 'Google User',
          );
          await register(user);
        }

        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> register(User user) async {
    final box = HiveService.getUserBox();
    await box.put(user.id, user.toMap());
    notifyListeners();
  }

  Future<List<User>> getAllUsers() async {
    final box = HiveService.getUserBox();
    return box.values.map((e) => User.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> updateUser(User user) async {
    final box = HiveService.getUserBox();
    await box.put(user.id, user.toMap());
    if (_currentUser?.id == user.id) {
      _currentUser = user;
    }
    notifyListeners();
  }

  Future<void> deleteUser(String id) async {
    final box = HiveService.getUserBox();
    await box.delete(id);
    if (_currentUser?.id == id) {
      _currentUser = null;
    }
    notifyListeners();
  }
}
