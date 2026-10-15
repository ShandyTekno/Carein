import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/dummy_models.dart';

/// Konfigurasi URL backend Carein.
/// - Web / Windows Desktop → http://127.0.0.1:8000 (menghindari IPv6 ::1 issue pada Chrome)
/// - Android Emulator      → http://10.0.2.2:8000
/// - Device Fisik Android  → IP LAN PC (mis. http://192.168.18.17:8000)
class ApiConfig {
  static String? customBaseUrl;
  static const int _port = 8000;
  static String? _resolvedUrl;

  /// Daftar kandidat URL backend yang akan dicoba secara otomatis
  static List<String> get candidateUrls {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return [customBaseUrl!];
    }
    if (kIsWeb) {
      return [
        'http://127.0.0.1:$_port',
        'http://localhost:$_port',
      ];
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return [
        'http://127.0.0.1:$_port',     // USB ADB Reverse (prioritas utama HP fisik)
        'http://localhost:$_port',     // USB ADB Reverse localhost
        'http://10.0.2.2:$_port',      // Android Emulator
        'http://192.168.18.17:$_port', // Wi-Fi LAN IP PC
      ];
    }
    return [
      'http://127.0.0.1:$_port',
      'http://localhost:$_port',
    ];
  }

  static String get baseUrl => _resolvedUrl ?? candidateUrls.first;

  /// Cari URL backend yang aktif dengan ping PARALEL cepat (< 1.5 detik)
  static Future<String?> resolveActiveUrl() async {
    if (_resolvedUrl != null) {
      try {
        final res = await http
            .get(Uri.parse('$_resolvedUrl/health'))
            .timeout(const Duration(milliseconds: 1200));
        if (res.statusCode == 200) return _resolvedUrl;
      } catch (_) {
        _resolvedUrl = null;
      }
    }

    // Ping semua kandidat URL secara paralel agar respons didapat instan
    final futures = candidateUrls.map((url) async {
      try {
        final res = await http
            .get(Uri.parse('$url/health'))
            .timeout(const Duration(milliseconds: 1800));
        if (res.statusCode == 200) return url;
      } catch (_) {}
      return null;
    });

    final results = await Future.wait(futures);
    for (final url in results) {
      if (url != null) {
        _resolvedUrl = url;
        debugPrint('[ApiConfig] ✅ Terhubung ke backend aktif: $url');
        return url;
      }
    }
    return null;
  }
}

/// Model hasil analisis yang dikembalikan API.
class ApiAnalysisResult {
  const ApiAnalysisResult({
    required this.score,
    required this.skinType,
    required this.metrics,
    required this.insight,
  });

  final int score;
  final String skinType;
  final List<SkinMetric> metrics;
  final String insight;

  /// Parse dari JSON response /analyze
  factory ApiAnalysisResult.fromJson(Map<String, dynamic> json) {
    final analysis = json['analysis'] as Map<String, dynamic>;

    final rawMetrics = analysis['metrics'] as List<dynamic>;
    final metrics = rawMetrics.map((m) {
      final label = m['label'] as String;
      final value = (m['value'] as num).toDouble();
      final level = m['level'] as String;
      return SkinMetric(
        label: label,
        level: level,
        value: value / 100.0, // API mengembalikan 0–100, widget butuh 0–1
        icon: _iconFor(label),
      );
    }).toList();

    return ApiAnalysisResult(
      score: (analysis['score'] as num).toInt(),
      skinType: analysis['skin_type'] as String,
      metrics: metrics,
      insight: analysis['insight'] as String,
    );
  }

  /// Konversi ke [AnalysisResult] yang digunakan widget
  AnalysisResult toAnalysisResult() {
    final now = DateTime.now();
    final date = '${now.day} ${_monthName(now.month)} ${now.year}';
    return AnalysisResult(
      date: date,
      score: score,
      skinType: skinType,
      metrics: metrics,
      insight: insight,
    );
  }

  static String _monthName(int m) => const [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ][m];
}

/// Service utama untuk memanggil Carein API.
class SkinApiService {
  SkinApiService._();

  /// Kirim foto ke `/analyze` dan kembalikan [ApiAnalysisResult].
  /// Lempar [SkinApiException] jika terjadi error.
  static Future<ApiAnalysisResult> analyze({
    required Uint8List imageBytes,
    required String filename,
  }) async {
    // 1. Cek dulu apakah ada backend yang aktif (maksimal 2.5 detik)
    final activeUrl = await ApiConfig.resolveActiveUrl();
    if (activeUrl == null) {
      throw SkinApiException(
        'Server backend AI belum dapat dijangkau.\n\n'
        '• Jika menggunakan HP via kabel USB: jalankan "adb reverse tcp:8000 tcp:8000"\n'
        '• Atau klik tombol "Mode Demo" di bawah untuk melihat hasil analisis foto secara instan.',
      );
    }

    final uri = Uri.parse('$activeUrl/analyze');

    try {
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: filename,
        ),
      );

      // Timeout cepat 12 detik (bukan 30 detik lagi)
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 12),
        onTimeout: () => throw SkinApiException(
          'Server memproses terlalu lama (timeout 12 detik).\n'
          'Gunakan foto dengan ukuran lebih ringan atau coba lagi.',
        ),
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiAnalysisResult.fromJson(json);
      } else {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final detail = body['detail'] ?? 'Terjadi kesalahan pada server backend.';
        throw SkinApiException('HTTP ${response.statusCode}: $detail');
      }
    } on SkinApiException {
      rethrow;
    } catch (e) {
      debugPrint('[SkinApiService] Error: $e');
      throw SkinApiException(
        'Gagal mengirim foto ke backend ($activeUrl).\n'
        'Pesan error: $e',
      );
    }
  }

  /// Cek apakah backend dapat dijangkau
  static Future<bool> isReachable() async {
    final active = await ApiConfig.resolveActiveUrl();
    return active != null;
  }
}

class SkinApiException implements Exception {
  SkinApiException(this.message);
  final String message;

  @override
  String toString() => 'SkinApiException: $message';
}

/// Mapping nama metrik ke icon
IconData _iconFor(String label) {
  switch (label) {
    case 'Acne':
      return Icons.bubble_chart_rounded;
    case 'Oiliness':
      return Icons.water_drop_outlined;
    case 'Dryness':
      return Icons.air_rounded;
    case 'Spots':
      return Icons.blur_on_rounded;
    case 'Texture':
      return Icons.grain_rounded;
    default:
      return Icons.circle_outlined;
  }
}
