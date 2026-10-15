import 'package:flutter/material.dart';

import 'core/supabase_config.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase (jika kredensial sudah diisi di SupabaseConfig)
  await SupabaseConfig.initialize();

  // Inisialisasi AuthService dan dengarkan perubahan sesi login Supabase
  AuthService.initialize();

  runApp(const CareinApp());
}

class CareinApp extends StatelessWidget {
  const CareinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carein',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
