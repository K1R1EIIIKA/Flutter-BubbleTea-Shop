import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:labs/auth/account_manager.dart';
import 'package:labs/base/main.dart';
import 'package:labs/shop/shop.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Контроллеры для полей ввода (username, password)
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Цветовая палитра из макета
  static const Color _bgColor = Color(0xFFF8DDB8); // фон всего экрана
  static const Color _circleBgColor = Color(0xFFFFE6C1); // позади изображения
  static const Color _inputBgColor = Color(0xFFB99B7A); // фон TextField-ов
  static const Color _buttonColor = Color(0xFF5C3A21); // цвет кнопки Sign In
  static const Color _textDark = Color(0xFF3A2A1C); // тёмный текст
  static const Color _textLight = Color(
    0xFFF5E8D0,
  ); // светлый текст (на кнопках)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ===== 1. Изображение бабл-ти в круглом фоне =====
                Container(
                  width: 160,
                  height: 160,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _circleBgColor,
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/img/biba_and_boba.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ===== 2. Заголовок “Biba & Boba” =====
                Text(
                  'Biba & Boba',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // ===== 3. Поле “Username” =====
                _buildTextField(
                  controller: _usernameController,
                  hintText: 'Username',
                  obscureText: false,
                  prefixIcon: Icons.person_outline,
                ),

                const SizedBox(height: 16),

                // ===== 4. Поле “Password” =====
                _buildTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                ),

                const SizedBox(height: 8),

                // ===== 5. Ссылка “Forgot Password?” по правому краю =====
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      // TODO: сюда логику восстановления пароля
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 14,
                        color: _textDark,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ===== 6. Кнопка “Sign In” =====
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      final username = _usernameController.text.trim();
                      final password = _passwordController.text.trim();

                      final prefs = await SharedPreferences.getInstance();
                      final users = prefs.getStringList('users') ?? [];

                      //print users
                      print('Users: $users');
                      final userExists = users.any((entry) {
                        final parts = entry.split('|');
                        return parts.length == 2 && parts[0] == username && parts[1] == password;
                      });

                      if (userExists) {
                        AccountManager().username = username;
                        await prefs.setBool('is_logged_in', true);
                        await prefs.setString('username', username);

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => MainPage()),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Ошибка'),
                            content: const Text('Неверный логин или пароль'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('ОК'),
                              ),
                            ],
                          ),
                        );
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: _buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _textLight,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ===== 7. Разделитель “Or continue with” =====
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: _textDark.withOpacity(0.4),
                        thickness: 1,
                        indent: 0,
                        endIndent: 8,
                      ),
                    ),
                    Text(
                      'Or continue with',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _textDark.withOpacity(0.6),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: _textDark.withOpacity(0.4),
                        thickness: 1,
                        indent: 8,
                        endIndent: 0,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ===== 8. Кнопки “Google” и “Apple” =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialButton(
                      icon: Image.asset(
                        'assets/img/google.png',
                        width: 32,
                        height: 32,
                      ),
                      onTap: () {
                        // TODO: логика входа через Google
                      },
                    ),
                    _buildSocialButton(
                      icon: Image.asset(
                        'assets/img/apple.png',
                        width: 32,
                        height: 32,
                      ),
                      onTap: () {
                        // TODO: логика входа через Apple
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ===== 9. “Not a member? Register now” =====
                RichText(
                  text: TextSpan(
                    text: 'Not a member? ',
                    style: TextStyle(
                      fontSize: 16,
                      color: _textDark.withOpacity(0.7),
                    ),
                    children: [
                      TextSpan(
                        text: 'Register now',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _textDark,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            );
                          },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Универсальный метод для создания кастомного TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required IconData prefixIcon,
  }) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 16, color: _textDark),
        decoration: InputDecoration(
          filled: true,
          fillColor: _inputBgColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 16,
            color: _textLight.withOpacity(0.8),
          ),
          prefixIcon: Icon(prefixIcon, color: _textLight.withOpacity(0.8)),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// Универсальный метод для круглой кнопки с иконкой (Google, Apple и т.п.)
  Widget _buildSocialButton({
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: _inputBgColor,
        ),
        child: Center(child: icon),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
