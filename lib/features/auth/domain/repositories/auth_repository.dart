import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String username, String password);
  Future<UserEntity> register(String username, String email, String password);
  Future<void> recoverPassword(String email);
  Future<void> setNewPassword(String email, String newPassword);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> signInWithGoogle();
}
