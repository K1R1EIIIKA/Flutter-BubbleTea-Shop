import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'set_new_password_screen.dart';

class RecoverPasswordScreen extends StatefulWidget {
  const RecoverPasswordScreen({super.key});

  @override
  State<RecoverPasswordScreen> createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  final TextEditingController _usernameController = TextEditingController();

  Future<void> _checkUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('users') ?? [];
    final username = _usernameController.text.trim();

    final userExists = users.any((entry) => entry.split('|')[0] == username);

    if (userExists) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SetNewPasswordScreen(username: username),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Ошибка'),
          content: const Text('Пользователь не найден'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ОК'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8DDB8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8DDB8),
        elevation: 0,
        title: const Text('Восстановление пароля', style: TextStyle(color: Color(0xFF5C3A21))),
        iconTheme: const IconThemeData(color: Color(0xFF5C3A21)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Введите логин',
                filled: true,
                fillColor: const Color(0xFFB99B7A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: Color(0xFF3A2A1C)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _checkUsername,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5C3A21)),
              child: const Text('Продолжить', style: TextStyle(color: Color(0xFFF5E8D0))),
            ),
          ],
        ),
      ),
    );
  }
}
