import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labs/features/auth/presentation/bloc/auth_cubit.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _email = '';
  String _password = '';
  bool _isObscure = true;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      context.read<AuthCubit>().register(
        _username.trim(),
        _email.trim(),
        _password.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFFCE5CC);
    final brown = const Color(0xFF7A4F23);
    final accent = const Color(0xFFBCA47C);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF7A4F23)),
        title: const Text(
          'Регистрация',
          style: TextStyle(
            color: Color(0xFF7A4F23),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
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
              child: Container(
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(

                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: brown.withOpacity(0.13),
                      blurRadius: 24,
                      spreadRadius: 4,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Регистрация",
                        style: TextStyle(
                          color: Color(0xFF7A4F23),
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: bgColor,
                          labelText: 'Логин',
                          labelStyle: TextStyle(color: brown),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.person, color: accent),
                        ),
                        onSaved: (v) => _username = v ?? '',
                        validator: (v) =>
                        (v == null || v.isEmpty) ? 'Введите логин' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: bgColor,
                          labelText: 'Email',
                          labelStyle: TextStyle(color: brown),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.email, color: accent),
                        ),
                        onSaved: (v) => _email = v ?? '',
                        validator: (v) =>
                        (v == null || v.isEmpty) ? 'Введите email' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: bgColor,
                          labelText: 'Пароль',
                          labelStyle: TextStyle(color: brown),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.lock, color: accent),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure ? Icons.visibility : Icons.visibility_off,
                              color: accent,
                            ),
                            onPressed: () =>
                                setState(() => _isObscure = !_isObscure),
                          ),
                        ),
                        obscureText: _isObscure,
                        onSaved: (v) => _password = v ?? '',
                        validator: (v) =>
                        (v == null || v.isEmpty) ? 'Введите пароль' : null,
                      ),
                      const SizedBox(height: 26),
                      (state is AuthLoading)
                          ? const CircularProgressIndicator()
                          : SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brown,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: _submit,
                          child: const Text(
                            'Зарегистрироваться',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
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
