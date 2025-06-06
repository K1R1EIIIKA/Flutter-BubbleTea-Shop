import 'package:labs/features/auth/domain/entities/user_entity.dart';

class UserModel {
  final String username;
  final String email;
  final String? password; // теперь nullable

  UserModel({
    required this.username,
    required this.email,
    this.password, // nullable
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    username: json['username'],
    email: json['email'],
    password: json['password'], // если null — ок
  );

  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    if (password != null) 'password': password,
  };

  UserEntity toEntity() => UserEntity(
    username: username,
    email: email,
  );

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
    username: entity.username,
    email: entity.email,
  );
}
