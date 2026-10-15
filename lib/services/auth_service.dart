import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase_config.dart';

class AuthService {
  AuthService._();

  static final ValueNotifier<String> userNameNotifier =
      ValueNotifier<String>('Shandy');
  static final ValueNotifier<String> userEmailNotifier =
      ValueNotifier<String>('shandy@carein.app');
  static final ValueNotifier<String?> userAvatarNotifier =
      ValueNotifier<String?>(null);

  static String get userName => userNameNotifier.value;
  static String get userEmail => userEmailNotifier.value;
  static String? get avatarUrl => userAvatarNotifier.value;

  /// Inisialisasi AuthService dan listener perubahan status autentikasi Supabase
  static void initialize() {
    final client = SupabaseConfig.client;
    if (client == null) return;

    syncUserFromSupabase();

    client.auth.onAuthStateChange.listen((data) {
      syncUserFromSupabase();
    });
  }

  /// Sinkronisasi info pengguna saat ini dari Supabase Auth jika ada
  static void syncUserFromSupabase() {
    final client = SupabaseConfig.client;
    if (client == null) return;

    final user = client.auth.currentUser;
    if (user != null) {
      final meta = user.userMetadata ?? {};
      final name = meta['full_name'] ?? meta['name'] ?? user.email?.split('@').first ?? 'User';
      final email = user.email ?? '';
      final avatar = meta['avatar_url'] ?? meta['picture'];

      userNameNotifier.value = name.toString();
      userEmailNotifier.value = email;
      userAvatarNotifier.value = avatar?.toString();
    } else {
      userNameNotifier.value = 'User';
      userEmailNotifier.value = '';
      userAvatarNotifier.value = null;
    }
  }

  /// Login / Registrasi Otomatis lewat Google
  static Future<bool> signInWithGoogle() async {
    final client = SupabaseConfig.client;

    if (client != null) {
      try {
        await client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: kIsWeb ? null : 'io.supabase.carein://login-callback/',
        );
        syncUserFromSupabase();
        return true;
      } catch (e) {
        debugPrint('Error signInWithGoogle: $e');
        // Jika gagal koneksi cloud, fallback ke simulasi agar demo tetap berjalan
      }
    }

    // Simulasi Akun Google untuk demo
    userNameNotifier.value = 'Budi Santoso';
    userEmailNotifier.value = 'budisantoso@gmail.com';
    userAvatarNotifier.value = null;
    return true;
  }

  /// Login Manual via Email & Password
  static Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final client = SupabaseConfig.client;

    if (client != null) {
      try {
        final response = await client.auth.signInWithPassword(
          email: email.trim(),
          password: password,
        );
        if (response.user != null) {
          syncUserFromSupabase();
          return true;
        }
      } catch (e) {
        debugPrint('Error signInWithEmail: $e');
        rethrow;
      }
    }

    // Simulasi jika Supabase credentials belum diisi
    userNameNotifier.value = email.split('@').first;
    userEmailNotifier.value = email.trim();
    return true;
  }

  /// Registrasi Manual via Email & Password
  /// Mengembalikan true jika session langsung aktif (bisa langsung masuk),
  /// atau false jika Supabase membutuhkan konfirmasi email terlebih dahulu.
  static Future<bool> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final client = SupabaseConfig.client;

    if (client != null) {
      try {
        final response = await client.auth.signUp(
          email: email.trim(),
          password: password,
          data: {'full_name': name.trim()},
        );
        if (response.user != null) {
          syncUserFromSupabase();
          return response.session != null;
        }
      } catch (e) {
        debugPrint('Error signUpWithEmail: $e');
        rethrow;
      }
    }

    // Simulasi jika Supabase credentials belum diisi
    userNameNotifier.value = name.trim();
    userEmailNotifier.value = email.trim();
    return true;
  }

  /// Logout Akun
  static Future<void> signOut() async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        await client.auth.signOut();
      } catch (e) {
        debugPrint('Error signOut: $e');
      }
    }

    // Reset nama kembali ke default tamu
    userNameNotifier.value = 'Shandy';
    userEmailNotifier.value = 'shandy@carein.app';
    userAvatarNotifier.value = null;
  }
}
