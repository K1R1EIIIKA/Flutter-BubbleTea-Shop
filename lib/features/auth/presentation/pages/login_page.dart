import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labs/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:labs/features/auth/presentation/pages/register_page.dart';

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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      context.read<AuthCubit>().login(_username.trim(), _password.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вход')),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacementNamed('/'); // на главную страницу
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Логин'),
                      onSaved: (v) => _username = v ?? '',
                      validator: (v) =>
                      (v == null || v.isEmpty) ? 'Введите логин' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Пароль',
                        suffixIcon: IconButton(
                          icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _isObscure = !_isObscure),
                        ),
                      ),
                      obscureText: _isObscure,
                      onSaved: (v) => _password = v ?? '',
                      validator: (v) =>
                      (v == null || v.isEmpty) ? 'Введите пароль' : null,
                    ),
                    const SizedBox(height: 24),
                    (state is AuthLoading)
                        ? const CircularProgressIndicator()
                        : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Войти'),
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: Image.asset('assets/img/google.png', height: 24), // добавьте логотип в assets
                      label: const Text('Войти через Google'),
                      onPressed: () {
                        context.read<AuthCubit>().loginWithGoogle();
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RegisterPage()),
                        );
                      },
                      child: const Text('Нет аккаунта? Зарегистрироваться'),
                    ),

                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
