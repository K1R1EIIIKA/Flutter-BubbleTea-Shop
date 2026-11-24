import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/shop_icon_button.dart';
import '../../../core/shop_theme.dart';
import '../auth_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AuthCubit>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    final user = auth is AuthAuthenticated ? auth.user : null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const ShopBackButton(),
        title: const Text('Профиль'),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              children: [
                const Align(
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: shopSurface,
                    foregroundColor: shopInk,
                    child: Icon(Icons.person_outline, size: 32),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.username ?? 'Гость',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                if (user != null && user.email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: shopMuted),
                  ),
                ],
                const SizedBox(height: 26),
                Material(
                  color: shopSurface,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: const Text('Мои заказы'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pushNamed(context, '/orders'),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: user == null
                      ? () => Navigator.pushNamed(context, '/login')
                      : () => _logout(context),
                  child: Text(
                    user == null ? 'Войти в аккаунт' : 'Выйти из аккаунта',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
