import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getSavedUser();
  Future<void> saveUser(UserModel user);
  Future<void> clearUser();
  Future<bool> isLoggedIn();

  Future<List<UserModel>> getAllUsers();
  Future<void> saveUserToList(UserModel user);
}
