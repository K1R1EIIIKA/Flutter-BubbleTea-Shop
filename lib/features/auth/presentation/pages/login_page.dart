import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labs/features/auth/presentation/bloc/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _isObscure = true;

  void _login() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      context.read<AuthCubit>().login(_username.trim(), _password.trim());
    }
  }

  void _loginWithGoogle() {
    context.read<AuthCubit>().loginWithGoogle();
  }

  void _goToRegister() {
    Navigator.of(context).pushNamed('/register'); // или свой Route
  }

  void _forgotPassword() {
    // Навигация на экран восстановления пароля
    Navigator.of(context).pushNamed('/recover_password');
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFFCE5CC);
    final brown = const Color(0xFF7A4F23);

    return Scaffold(
      backgroundColor: bgColor,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacementNamed('/');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/img/biba_and_boba.png', height: 170),
                      const SizedBox(height: 32),
                      const Text(
                        'Biba & Boba',
                        style: TextStyle(
                          color: Color(0xFF7A4F23),
                          fontWeight: FontWeight.w900,
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFDCC3A4),
                          hintText: 'Username',
                          hintStyle: const TextStyle(color: Color(0xFFBCA47C)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Введите логин' : null,
                        onSaved: (v) => _username = v ?? '',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        obscureText: _isObscure,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFDCC3A4),
                          hintText: 'Password',
                          hintStyle: const TextStyle(color: Color(0xFFBCA47C)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                          suffixIcon: IconButton(
                            icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _isObscure = !_isObscure),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Введите пароль' : null,
                        onSaved: (v) => _password = v ?? '',
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _forgotPassword,
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Color(0xFFBCA47C)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state is AuthLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brown,
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: state is AuthLoading
                              ? const SizedBox(
                              height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(thickness: 1, color: Color(0xFFDDC7AA)),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Or continue with',
                            style: TextStyle(color: Color(0xFFBCA47C)),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Divider(thickness: 1, color: Color(0xFFDDC7AA)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      GestureDetector(
                        onTap: state is AuthLoading ? null : _loginWithGoogle,
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.white,
                          child: Image.asset('assets/img/google.png', height: 36),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Not a member? ',
                            style: TextStyle(color: Color(0xFFBCA47C)),
                          ),
                          GestureDetector(
                            onTap: _goToRegister,
                            child: const Text(
                              'Register now',
                              style: TextStyle(
                                color: Color(0xFF7A4F23),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
