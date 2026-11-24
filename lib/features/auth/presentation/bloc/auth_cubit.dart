import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labs/features/auth/domain/usecases/login_usecase.dart';
import 'package:labs/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/entities/user_entity.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final IsLoggedInUseCase isLoggedInUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.isLoggedInUseCase,
    required this.getCurrentUserUseCase,
    required this.signInWithGoogleUseCase,
  }) : super(AuthInitial());

  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      final user = await loginUseCase.call(username, password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> register(String username, String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await registerUseCase.call(username, email, password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> logout() async {
    await logoutUseCase.call();
    emit(AuthInitial());
  }

  Future<void> checkLoggedIn() async {
    try {
      final user = await isLoggedInUseCase.call()
          ? await getCurrentUserUseCase.call()
          : null;
      if (user != null && !isClosed && state is AuthInitial) {
        emit(AuthAuthenticated(user));
      }
    } catch (_) {
      // The shop can still open in guest mode if the local session is invalid.
    }
  }

  Future<void> loginWithGoogle() async {
    emit(AuthLoading());
    try {
      final user = await signInWithGoogleUseCase.call();
      emit(AuthAuthenticated(user));
    } catch (_) {
      emit(
        const AuthError(
          'Не удалось войти через Google. Повторите попытку или войдите по логину.',
        ),
      );
    }
  }
}
