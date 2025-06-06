import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<UserEntity> login(String username, String password) async {
    final users = await localDataSource.getAllUsers();
    final found = users.firstWhere(
          (u) => u.username == username && u.password == password,
      orElse: () => throw Exception('Неверный логин или пароль'),
    );
    await localDataSource.saveUser(found); // "логиним" пользователя
    return found.toEntity();
  }

  @override
  Future<UserEntity> register(String username, String email, String password) async {
    final users = await localDataSource.getAllUsers();
    final exists = users.any((u) => u.username == username || u.email == email);
    if (exists) throw Exception('Такой пользователь уже существует');
    final user = UserModel(username: username, email: email, password: password);
    await localDataSource.saveUserToList(user);
    await localDataSource.saveUser(user); // сразу логиним после регистрации
    return user.toEntity();
  }

  @override
  Future<void> recoverPassword(String email) async {
    // Здесь отправка email для восстановления пароля через сервис
    return;
  }

  @override
  Future<void> setNewPassword(String email, String newPassword) async {
    // Здесь обновление пароля в сервисе
    return;
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearUser();
  }

  @override
  Future<bool> isLoggedIn() async {
    return localDataSource.isLoggedIn();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = await localDataSource.getSavedUser();
    return user?.toEntity();
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    final account = await googleSignIn.signIn();
    if (account == null) throw Exception("Вход отменён пользователем");
    final user = UserModel(
      username: account.displayName ?? account.email,
      email: account.email,
      password: null, // Явно null!
    );
    await localDataSource.saveUser(user);
    return user.toEntity();
  }

}
