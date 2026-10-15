import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/dummy_models.dart';

import 'package:flutter/foundation.dart';

/// Konfigurasi URL backend AISKIN.
/// - Android Emulator → otomatis 10.0.2.2:8000 (menghubungkan ke localhost PC)
/// - Web / Windows Desktop → otomatis localhost:8000
/// - Device Fisik Android → set customBaseUrl ke IP LAN PC (mis. http://192.168.1.10:8000)
class ApiConfig {
  static String? customBaseUrl;
  static const int _port = 8000;

  static String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:$_port';
    }
    return 'http://localhost:$_port';
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

/// Service utama untuk memanggil AISKIN API.
class SkinApiService {
  SkinApiService._();

  /// Kirim foto ke `/analyze` dan kembalikan [ApiAnalysisResult].
  /// Lempar [SkinApiException] jika terjadi error.
  static Future<ApiAnalysisResult> analyze({
    required Uint8List imageBytes,
    required String filename,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/analyze');

    try {
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: filename,
        ),
      );

      // Timeout 30 detik
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw SkinApiException(
          'Server tidak merespons dalam 30 detik. '
          'Pastikan backend sudah berjalan.',
        ),
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiAnalysisResult.fromJson(json);
      } else {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final detail = body['detail'] ?? 'Terjadi kesalahan tidak dikenal';
        throw SkinApiException('HTTP ${response.statusCode}: $detail');
      }
    } on SkinApiException {
      rethrow;
    } catch (e) {
      debugPrint('[SkinApiService] Error: $e');
      throw SkinApiException(
        'Tidak dapat terhubung ke server analisis.\n'
        'Pastikan backend sudah dijalankan di ${ApiConfig.baseUrl}',
      );
    }
  }

  /// Cek apakah backend dapat dijangkau
  static Future<bool> isReachable() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
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
