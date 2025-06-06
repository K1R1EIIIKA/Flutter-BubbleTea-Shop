import '../repositories/auth_repository.dart';
import '../entities/user_entity.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity> call(String username, String password) {
    return repository.login(username, password);
  }
}

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserEntity> call(String username, String email, String password) {
    return repository.register(username, email, password);
  }
}

class SetNewPasswordUseCase {
  final AuthRepository repository;

  SetNewPasswordUseCase(this.repository);

  Future<void> call(String email, String newPassword) {
    return repository.setNewPassword(email, newPassword);
  }
}

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call() {
    return repository.logout();
  }
}

class IsLoggedInUseCase {
  final AuthRepository repository;

  IsLoggedInUseCase(this.repository);

  Future<bool> call() {
    return repository.isLoggedIn();
  }
}

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<UserEntity?> call() {
    return repository.getCurrentUser();
  }
}