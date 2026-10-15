import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/aiskin_logo.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/google_sign_in_button.dart';
import 'main_shell.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLoadingEmail = false;
  bool _isLoadingGoogle = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _goToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  Future<void> _loginEmail() async {
    final email = _email.text.trim();
    final password = _password.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan masukkan email dan password.')),
      );
      return;
    }

    setState(() => _isLoadingEmail = true);
    try {
      await AuthService.signInWithEmail(email: email, password: password);
      if (!mounted) return;
      _goToHome();
    } catch (e) {
      if (!mounted) return;
      String message = 'Gagal login: $e';
      final text = e.toString().toLowerCase();
      if (text.contains('email not confirmed')) {
        message = 'Email belum diverifikasi. Silakan periksa inbox email Anda, atau nonaktifkan "Confirm email" di Supabase Dashboard.';
      } else if (text.contains('invalid login credentials') || text.contains('invalid_credentials')) {
        message = 'Email atau password salah. Silakan periksa kembali.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _isLoadingEmail = false);
    }
  }

  Future<void> _loginGoogle() async {
    setState(() => _isLoadingGoogle = true);
    try {
      await AuthService.signInWithGoogle();
      if (!mounted) return;
      _goToHome();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal masuk dengan Google: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoadingGoogle = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: AiskinLogo(size: 84)),
                const SizedBox(height: 28),
                const Text(
                  'Welcome Back',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Analyze your skin condition with AI',
                  style: TextStyle(fontSize: 14.5, color: AppColors.grey),
                ),
                const SizedBox(height: 28),
                GoogleSignInButton(
                  label: 'Continue with Google',
                  isLoading: _isLoadingGoogle,
                  onPressed: _loginGoogle,
                ),
                const SizedBox(height: 22),
                _buildOrDivider(),
                const SizedBox(height: 22),
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
                const SizedBox(height: 24),
                AppButton(
                  label: _isLoadingEmail ? 'Signing in...' : 'Login',
                  onPressed: _isLoadingEmail ? null : _loginEmail,
                ),
                const SizedBox(height: 20),
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: AppColors.grey, fontSize: 13.5),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            color: AppColors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
