import 'package:flutter/material.dart';

import '../core/supabase_config.dart';
import '../models/dummy_models.dart';

/// Service untuk menyimpan dan memuat riwayat analisis kulit dari Supabase.
///
/// Jika Supabase tidak dikonfigurasi atau tidak ada koneksi,
/// semua operasi akan fallback ke data lokal (in-memory / dummy).
class AnalysisService {
  AnalysisService._();

  /// Cache lokal hasil analisis selama sesi berlangsung.
  /// Digunakan sebagai fallback jika Supabase tidak tersedia.
  static final List<AnalysisResult> _localHistory = List.from(DummyData.history);

  // ── Simpan ─────────────────────────────────────────────────────────────────

  /// Menyimpan [result] ke Supabase.
  /// Kembalikan `true` jika berhasil, `false` jika gagal (tetap disimpan lokal).
  static Future<bool> saveAnalysis(AnalysisResult result) async {
    // Selalu tambah ke cache lokal dulu
    _localHistory.insert(0, result);

    final client = SupabaseConfig.client;
    if (client == null) {
      debugPrint('[AnalysisService] Supabase tidak terkonfigurasi, hanya simpan lokal.');
      return false;
    }

    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      debugPrint('[AnalysisService] User belum login, skip simpan ke Supabase.');
      return false;
    }

    double metricValue(String label) {
      try {
        return result.metrics
                .firstWhere(
                    (m) => m.label.toLowerCase() == label.toLowerCase())
                .value *
            100; // konversi dari 0–1 ke 0–100
      } catch (_) {
        return 0;
      }
    }

    try {
      await client.from('skin_analysis').insert({
        'user_id': userId,
        'score': result.score,
        'skin_type': result.skinType,
        'insight': result.insight,
        'acne': metricValue('Acne'),
        'oiliness': metricValue('Oiliness'),
        'dullness': metricValue('Dryness'),
        'dark_spot': metricValue('Spots'),
        'texture': metricValue('Texture'),
        'redness': 0.0,
      });
      debugPrint('[AnalysisService] ✅ Analisis berhasil disimpan ke Supabase.');
      return true;
    } catch (e) {
      debugPrint('[AnalysisService] ⚠️ Gagal simpan ke Supabase: $e');
      return false;
    }
  }

  // ── Baca ───────────────────────────────────────────────────────────────────

  /// Memuat riwayat analisis dari Supabase.
  /// Jika gagal atau Supabase tidak tersedia, kembalikan data lokal.
  static Future<List<AnalysisResult>> fetchHistory() async {
    final client = SupabaseConfig.client;
    if (client == null) {
      debugPrint('[AnalysisService] Supabase tidak terkonfigurasi, pakai data lokal.');
      return List.from(_localHistory);
    }

    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      return List.from(_localHistory);
    }

    try {
      final rows = await client
          .from('skin_analysis')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(30);

      if (rows.isEmpty) return List.from(_localHistory);

      final results = rows.map<AnalysisResult>((row) => _fromRow(row)).toList();
      // Sinkronisasi juga ke local cache
      _localHistory
        ..clear()
        ..addAll(results);
      return results;
    } catch (e) {
      debugPrint('[AnalysisService] ⚠️ Gagal fetch dari Supabase: $e');
      return List.from(_localHistory);
    }
  }

  /// Hapus semua riwayat milik user saat ini dari Supabase.
  static Future<bool> clearHistory() async {
    final client = SupabaseConfig.client;
    final userId = client?.auth.currentUser?.id;

    if (client == null || userId == null) {
      _localHistory
        ..clear()
        ..addAll(DummyData.history);
      return false;
    }

    try {
      await client.from('skin_analysis').delete().eq('user_id', userId);
      _localHistory.clear();
      return true;
    } catch (e) {
      debugPrint('[AnalysisService] ⚠️ Gagal hapus dari Supabase: $e');
      return false;
    }
  }

  // ── Konversi ────────────────────────────────────────────────────────────────

  /// Parse baris dari Supabase menjadi [AnalysisResult]
  static AnalysisResult _fromRow(Map<String, dynamic> row) {
    final createdAt =
        DateTime.tryParse(row['created_at'] as String? ?? '')?.toLocal() ??
            DateTime.now();

    final date =
        '${createdAt.day} ${_monthName(createdAt.month)} ${createdAt.year}';

    final acne = (row['acne'] as num?)?.toDouble() ?? 0.0;
    final oiliness = (row['oiliness'] as num?)?.toDouble() ?? 0.0;
    final dullness = (row['dullness'] as num?)?.toDouble() ?? 0.0;
    final darkSpot = (row['dark_spot'] as num?)?.toDouble() ?? 0.0;
    final texture = (row['texture'] as num?)?.toDouble() ?? 0.0;

    return AnalysisResult(
      date: date,
      score: (row['score'] as num?)?.toInt() ?? 0,
      skinType: row['skin_type'] as String? ?? 'Unknown',
      insight: row['insight'] as String? ?? '',
      metrics: [
        SkinMetric(
          label: 'Acne',
          level: _level(acne),
          value: acne / 100,
          icon: Icons.bubble_chart_rounded,
        ),
        SkinMetric(
          label: 'Oiliness',
          level: _level(oiliness),
          value: oiliness / 100,
          icon: Icons.water_drop_outlined,
        ),
        SkinMetric(
          label: 'Dryness',
          level: _level(dullness),
          value: dullness / 100,
          icon: Icons.air_rounded,
        ),
        SkinMetric(
          label: 'Spots',
          level: _level(darkSpot),
          value: darkSpot / 100,
          icon: Icons.blur_on_rounded,
        ),
        SkinMetric(
          label: 'Texture',
          level: _level(texture),
          value: texture / 100,
          icon: Icons.grain_rounded,
        ),
      ],
    );
  }

  static String _level(double v) {
    if (v < 35) return 'Low';
    if (v < 65) return 'Moderate';
    return 'High';
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
