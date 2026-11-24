import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_store.dart';
import 'user.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._store) : super(AuthInitial());

  final AuthStore _store;

  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      final user = await _store.login(username, password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> register(String username, String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _store.register(username, email, password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> logout() async {
    await _store.logout();
    emit(AuthInitial());
  }

  Future<void> checkLoggedIn() async {
    try {
      final user = await _store.currentUser();
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
      final user = await _store.signInWithGoogle();
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

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final ShopUser user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}
