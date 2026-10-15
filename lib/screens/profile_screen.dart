import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.onOpenHistory});

  final VoidCallback onOpenHistory;

  void _soon(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name is not available in this prototype yet.')),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will return to the login screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Log out', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await AuthService.signOut();
    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const Center(
            child: Text('Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder<String>(
            valueListenable: AuthService.userNameNotifier,
            builder: (context, name, _) {
              final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
              return Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.brandGradient,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          ValueListenableBuilder<String>(
            valueListenable: AuthService.userNameNotifier,
            builder: (context, name, _) => Center(
              child: Text(
                name,
                style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 4),
          ValueListenableBuilder<String>(
            valueListenable: AuthService.userEmailNotifier,
            builder: (context, email, _) => Center(
              child: Text(
                email,
                style: const TextStyle(fontSize: 13.5, color: AppColors.grey),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            decoration: AppTheme.card(),
            child: Column(
              children: [
                _MenuItem(
                  icon: Icons.person_outline_rounded,
                  title: 'Personal Information',
                  onTap: () => _soon(context, 'Personal Information'),
                ),
                _MenuItem(
                  icon: Icons.history_rounded,
                  title: 'Analysis History',
                  onTap: onOpenHistory,
                ),
                _MenuItem(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notification',
                  onTap: () => _soon(context, 'Notification'),
                ),
                _MenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () => _soon(context, 'Settings'),
                ),
                _MenuItem(
                  icon: Icons.info_outline_rounded,
                  title: 'About Carein',
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'Carein',
                    applicationVersion: '1.0.0',
                    children: const [
                      Text('AI Skin Analysis & Skincare Recommendation'),
                    ],
                  ),
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: AppTheme.card(),
            child: _MenuItem(
              icon: Icons.logout_rounded,
              title: 'Logout',
              color: AppColors.danger,
              showChevron: false,
              isLast: true,
              onTap: () => _logout(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color = AppColors.navy,
    this.showChevron = true,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;
  final bool showChevron;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color == AppColors.navy
                  ? AppColors.lightBlue
                  : color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon,
                size: 20, color: color == AppColors.navy ? AppColors.blue : color),
          ),
          title: Text(title,
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: color)),
          trailing: showChevron
              ? const Icon(Icons.chevron_right_rounded, color: AppColors.grey)
              : null,
        ),
        if (!isLast)
          const Divider(height: 1, indent: 70, endIndent: 18, color: AppColors.border),
      ],
    );
  }
}
