import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/google_sign_in_button.dart';
import 'main_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingGoogle = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _register() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final password = _password.text;
    final confirm = _confirm.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage('Silakan lengkapi semua kolom.');
      return;
    }
    if (password.length < 6) {
      _showMessage('Password minimal harus 6 karakter.');
      return;
    }
    if (password != confirm) {
      _showMessage('Konfirmasi password tidak cocok.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final hasActiveSession = await AuthService.signUpWithEmail(
        name: name,
        email: email,
        password: password,
      );
      if (!mounted) return;

      if (hasActiveSession) {
        _showMessage('Akun berhasil dibuat!');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShell()),
          (route) => false,
        );
      } else {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Verifikasi Email Diperlukan'),
            content: const Text(
              'Pendaftaran akun di Supabase berhasil!\n\n'
              'Link verifikasi telah dikirimkan ke email Anda. Silakan buka kotak masuk email untuk memverifikasi akun sebelum login.\n\n'
              '💡 Tips: Anda juga dapat mematikan opsi "Confirm email" di Supabase Dashboard (Auth > Providers > Email) jika ingin login tanpa verifikasi.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK, Kembali ke Login'),
              ),
            ],
          ),
        );
        if (!mounted) return;
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('Gagal mendaftar: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _isLoadingGoogle = true);
    try {
      await AuthService.signInWithGoogle();
      if (!mounted) return;
      _showMessage('Berhasil masuk dengan Google!');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage('Gagal mendaftar dengan Google: $e');
    } finally {
      if (mounted) setState(() => _isLoadingGoogle = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Account',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Start tracking your skin health with AI',
                style: TextStyle(fontSize: 14.5, color: AppColors.grey),
              ),
              const SizedBox(height: 24),
              GoogleSignInButton(
                label: 'Sign up with Google',
                isLoading: _isLoadingGoogle,
                onPressed: _signUpWithGoogle,
              ),
              const SizedBox(height: 22),
              _buildOrDivider(),
              const SizedBox(height: 22),
              AppTextField(
                controller: _name,
                label: 'Full Name',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _email,
                label: 'Email',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _password,
                label: 'Password',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _confirm,
                label: 'Confirm Password',
                icon: Icons.lock_reset_rounded,
                isPassword: true,
              ),
              const SizedBox(height: 28),
              AppButton(
                label: _isLoading ? 'Creating Account...' : 'Create Account',
                onPressed: _isLoading ? null : _register,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'OR',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.grey,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      ],
    );
  }
}
