import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'auth_local_data_source.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _userKey = 'AUTH_USER_JSON';
  static const _usersListKey = 'USERS_LIST_JSON';
  final SharedPreferences prefs;

  AuthLocalDataSourceImpl(this.prefs);

  @override
  Future<UserModel?> getSavedUser() async {
    final jsonStr = prefs.getString(_userKey);
    if (jsonStr == null) return null;
    return UserModel.fromJson(json.decode(jsonStr));
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  @override
  Future<void> clearUser() async {
    await prefs.remove(_userKey);
  }

  @override
  Future<bool> isLoggedIn() async {
    return prefs.containsKey(_userKey);
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    final jsonStr = prefs.getString(_usersListKey);
    if (jsonStr == null) return [];
    final list = (json.decode(jsonStr) as List)
        .map((e) => UserModel.fromJson(e))
        .toList();
    return list;
  }

  @override
  Future<void> saveUserToList(UserModel user) async {
    final users = await getAllUsers();
    users.add(user);
    final jsonList = users.map((u) => u.toJson()).toList();
    await prefs.setString(_usersListKey, json.encode(jsonList));
  }
}
