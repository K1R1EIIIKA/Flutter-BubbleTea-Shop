import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/shop_icon_button.dart';
import '../../../core/shop_theme.dart';
import '../auth_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    final auth = context.read<AuthCubit>();
    if (auth.state is! AuthLoading && _formKey.currentState!.validate()) {
      auth.login(_username.text.trim(), _password.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final supportsGoogle =
        kIsWeb ||
        const {
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        }.contains(defaultTargetPlatform);

    return Scaffold(
      appBar: AppBar(
        leading: const ShopBackButton(),
        title: const Text('Вход'),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated &&
              ModalRoute.of(context)?.isCurrent == true) {
            Navigator.of(context).popUntil(
              (route) => route.settings.name == '/profile' || route.isFirst,
            );
          } else if (state is AuthError) {
            setState(() => _error = state.message);
          } else if (state is AuthLoading) {
            setState(() => _error = null);
          }
        },
        builder: (context, state) {
          final busy = state is AuthLoading;
          return SafeArea(
            top: false,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: AutofillGroup(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Image.asset(
                            'assets/img/biba_and_boba.png',
                            height: 120,
                            excludeFromSemantics: true,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _username,
                            enabled: !busy,
                            autofillHints: const [AutofillHints.username],
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Логин',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Введите логин'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _password,
                            enabled: !busy,
                            obscureText: _obscure,
                            autofillHints: const [AutofillHints.password],
                            onFieldSubmitted: (_) => _login(),
                            decoration: InputDecoration(
                              labelText: 'Пароль',
                              border: const OutlineInputBorder(),
                              suffixIcon: ShopIconButton(
                                label: _obscure
                                    ? 'Показать пароль'
                                    : 'Скрыть пароль',
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Введите пароль'
                                : null,
                          ),
                          if (_error case final error?)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Semantics(
                                liveRegion: true,
                                child: Text(
                                  error,
                                  style: const TextStyle(color: shopInk),
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: busy ? null : _login,
                            child: Text(busy ? 'Входим…' : 'Войти'),
                          ),
                          if (supportsGoogle)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: OutlinedButton.icon(
                                onPressed: busy
                                    ? null
                                    : context.read<AuthCubit>().loginWithGoogle,
                                icon: Image.asset(
                                  'assets/img/google.png',
                                  height: 20,
                                  width: 20,
                                  excludeFromSemantics: true,
                                ),
                                label: const Text(
                                  'Войти через Google',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          TextButton(
                            onPressed: busy
                                ? null
                                : () =>
                                      Navigator.pushNamed(context, '/register'),
                            child: const Text(
                              'Создать аккаунт',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
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
