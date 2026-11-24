import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'user.dart';

class AuthStore {
  AuthStore(this._preferences);

  static const _userKey = 'AUTH_USER_JSON';
  static const _usersListKey = 'USERS_LIST_JSON';
  final SharedPreferences _preferences;

  Future<ShopUser> login(String username, String password) async {
    final account = _accounts().firstWhere(
      (account) =>
          account.user.username == username && account.password == password,
      orElse: () => throw Exception('Неверный логин или пароль'),
    );
    await _saveSession(account);
    return account.user;
  }

  Future<ShopUser> register(
    String username,
    String email,
    String password,
  ) async {
    final accounts = _accounts();
    if (accounts.any(
      (account) =>
          account.user.username == username || account.user.email == email,
    )) {
      throw Exception('Такой пользователь уже существует');
    }
    final account = _SavedAccount(
      ShopUser(username: username, email: email),
      password,
    );
    accounts.add(account);
    await _preferences.setString(
      _usersListKey,
      jsonEncode(accounts.map((account) => account.toJson()).toList()),
    );
    await _saveSession(account);
    return account.user;
  }

  Future<ShopUser?> currentUser() async {
    final session = _preferences.getString(_userKey);
    return session == null
        ? null
        : _SavedAccount.fromJson(jsonDecode(session)).user;
  }

  Future<void> logout() async {
    await _preferences.remove(_userKey);
  }

  Future<ShopUser> signInWithGoogle() async {
    final account = await GoogleSignIn().signIn();
    if (account == null) throw Exception('Вход отменён пользователем');
    final user = ShopUser(
      username: account.displayName ?? account.email,
      email: account.email,
    );
    await _saveSession(_SavedAccount(user));
    return user;
  }

  List<_SavedAccount> _accounts() {
    final json = _preferences.getString(_usersListKey);
    if (json == null) return [];
    return (jsonDecode(json) as List)
        .cast<Map<String, dynamic>>()
        .map(_SavedAccount.fromJson)
        .toList();
  }

  Future<void> _saveSession(_SavedAccount account) async {
    await _preferences.setString(_userKey, jsonEncode(account.toJson()));
  }
}

class _SavedAccount {
  const _SavedAccount(this.user, [this.password]);

  final ShopUser user;
  final String? password;

  factory _SavedAccount.fromJson(Map<String, dynamic> json) => _SavedAccount(
    ShopUser(username: json['username'], email: json['email']),
    json['password'],
  );

  Map<String, dynamic> toJson() => {
    'username': user.username,
    'email': user.email,
    if (password != null) 'password': password,
  };
}
