import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  /// Kredensial Project Supabase — Project: AISKIN (ShandyTekno)
  /// URL tidak berubah meski project di-rename
  static const String supabaseUrl = 'https://riwqpkxpnrecfrjvovpi.supabase.co';

  /// Publishable key (format baru Supabase)
  static const String supabaseAnonKey =
      'sb_publishable_eIbUbEwYDXPXgeZHsNXiKw_d0Bw8fq1';

  /// Memeriksa apakah kredensial sudah diisi
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      supabaseUrl != 'https://YOUR_PROJECT_ID.supabase.co';

  /// Inisialisasi Supabase Flutter SDK
  static Future<void> initialize() async {
    if (!isConfigured) {
      debugPrint('ℹ️ Supabase credentials belum diisi. Mode demo aktif.');
      return;
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseAnonKey,
      );
      debugPrint('✅ Supabase terhubung: $supabaseUrl');
    } catch (e) {
      debugPrint('⚠️ Gagal inisialisasi Supabase: $e');
    }
  }

  /// Akses SupabaseClient dengan aman
  static SupabaseClient? get client {
    if (!isConfigured) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }
}
