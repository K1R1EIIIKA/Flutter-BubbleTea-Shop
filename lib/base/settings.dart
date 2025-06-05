import 'package:flutter/material.dart';
import 'package:labs/base/calculator.dart';
import 'package:labs/base/home.dart';
import 'package:labs/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2D8B0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2D8B0),
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5D3A00),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SettingsItem(
            icon: Icons.search,
            title: 'Search',
            description: 'Go to the search page',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchView()),
              );
            },
          ),
          const SizedBox(height: 16),
          _SettingsItem(
            icon: Icons.calculate,
            title: 'Calculator',
            description: 'Open the calculator tool',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalculatorView()),
              );
            },
          ),
          const SizedBox(height: 16),
          _SettingsItem(
            icon: Icons.logout,
            title: 'Logout',
            description: 'Sign out of your account',
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('is_logged_in');
                await prefs.remove('username');

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              }
          ),
        ],
      ),
    );
  }
}


class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF5D3A00), size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5D3A00),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9E7F62),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF5D3A00)),
            ],
          ),
        ),
      ),
    );
  }
}