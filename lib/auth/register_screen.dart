import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  static const Color _bgColor = Color(0xFFF8DDB8);
  static const Color _inputBgColor = Color(0xFFB99B7A);
  static const Color _textDark = Color(0xFF3A2A1C);
  static const Color _textLight = Color(0xFFF5E8D0);
  static const Color _buttonColor = Color(0xFF5C3A21);

  void _register() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showError('Все поля обязательны');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList('users') ?? [];

    // Проверим, существует ли пользователь уже
    final exists = existing.any((entry) {
      final parts = entry.split('|');
      return parts.length == 2 && parts[0] == username;
    });

    if (exists) {
      _showError('Пользователь с таким логином уже существует');
      return;
    }

    existing.add('$username|$password');
    await prefs.setStringList('users', existing);

    Navigator.pop(context);
  }


  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ОК'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        title: const Text('Регистрация', style: TextStyle(color: _textDark)),
        iconTheme: const IconThemeData(color: _textDark),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildTextField(_usernameController, 'Придумайте логин', Icons.person_outline),
            const SizedBox(height: 16),
            _buildTextField(_passwordController, 'Придумайте пароль', Icons.lock_outline, obscure: true),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Зарегистрироваться',
                  style: TextStyle(fontSize: 18, color: _textLight),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        filled: true,
        fillColor: _inputBgColor,
        prefixIcon: Icon(icon, color: _textLight),
        hintText: hint,
        hintStyle: TextStyle(color: _textLight.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: _textDark),
    );
  }
}
