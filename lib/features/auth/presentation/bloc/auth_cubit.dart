import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
    required this.signInWithGoogleUseCase
  }) : super(AuthInitial());

  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      final user = await loginUseCase.call(username, password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register(String username, String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await registerUseCase.call(username, email, password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    await logoutUseCase.call();
    emit(AuthInitial());
  }

  Future<void> checkLoggedIn() async {
    final isLoggedIn = await isLoggedInUseCase.call();
    if (isLoggedIn) {
      final user = await getCurrentUserUseCase.call();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthInitial());
      }
    } else {
      emit(AuthInitial());
    }
  }

  Future<void> loginWithGoogle() async {
    emit(AuthLoading());
    try {
      final user = await signInWithGoogleUseCase.call();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
