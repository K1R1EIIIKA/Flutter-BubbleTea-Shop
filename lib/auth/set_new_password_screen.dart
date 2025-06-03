import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetNewPasswordScreen extends StatefulWidget {
  final String username;
  const SetNewPasswordScreen({super.key, required this.username});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _updatePassword() async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('users') ?? [];

    final updatedUsers = users.map((entry) {
      final parts = entry.split('|');
      if (parts[0] == widget.username) {
        return '${widget.username}|${_passwordController.text.trim()}';
      }
      return entry;
    }).toList();

    await prefs.setStringList('users', updatedUsers);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Готово'),
        content: const Text('Пароль обновлён'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // закрыть диалог
              Navigator.pop(context); // закрыть экран смены
              Navigator.pop(context); // вернуться на логин
            },
            child: const Text('ОК'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8DDB8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8DDB8),
        elevation: 0,
        title: const Text('Новый пароль', style: TextStyle(color: Color(0xFF5C3A21))),
        iconTheme: const IconThemeData(color: Color(0xFF5C3A21)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Введите новый пароль',
                filled: true,
                fillColor: const Color(0xFFB99B7A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: Color(0xFF3A2A1C)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updatePassword,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5C3A21)),
              child: const Text('Сохранить', style: TextStyle(color: Color(0xFFF5E8D0))),
            ),
          ],
        ),
      ),
    );
  }
}
