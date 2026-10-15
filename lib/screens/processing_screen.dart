import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/dummy_models.dart';
import '../services/analysis_service.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/aiskin_logo.dart';
import 'result_screen.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key, this.imageBytes});

  final Uint8List? imageBytes;

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);

  String _statusText = 'Mendeteksi wajah...';
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _runAnalysis();
  }

  Future<void> _runAnalysis() async {
    // Jika tidak ada foto, gunakan data dummy seperti sebelumnya
    if (widget.imageBytes == null) {
      await Future.delayed(const Duration(milliseconds: 2800));
      if (!mounted) return;
      _navigateToResult(DummyData.latest);
      return;
    }

    // ── Tahap 1: Deteksi wajah ────────────────────────────────────────────
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _statusText = 'Menganalisis jerawat & kondisi kulit...');

    // ── Tahap 2: Kirim ke API ─────────────────────────────────────────────
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _statusText = 'AI sedang memproses...');

    try {
      final apiResult = await SkinApiService.analyze(
        imageBytes: widget.imageBytes!,
        filename: 'face_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      if (!mounted) return;
      setState(() => _statusText = 'Menyimpan ke riwayat...');

      // Auto-save ke Supabase (background, tidak blokir navigasi)
      final analysisResult = apiResult.toAnalysisResult();
      AnalysisService.saveAnalysis(analysisResult).then((saved) {
        debugPrint(saved
            ? '[ProcessingScreen] Hasil disimpan ke Supabase ✅'
            : '[ProcessingScreen] Disimpan lokal (Supabase tidak tersedia)');
      });

      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      _navigateToResult(analysisResult);
    } on SkinApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.message;
        _statusText = 'Analisis gagal';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = 'Terjadi kesalahan tidak terduga: $e';
        _statusText = 'Analisis gagal';
      });
    }
  }

  void _navigateToResult(AnalysisResult result) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          result: result,
          imageBytes: widget.imageBytes,
        ),
      ),
    );
  }

  void _retryAnalysis() {
    setState(() {
      _hasError = false;
      _errorMessage = '';
      _statusText = 'Menghubungkan ke server...';
    });
    _runAnalysis();
  }

  void _retryWithDummy() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          result: DummyData.latest,
          imageBytes: widget.imageBytes,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Widget _buildScanTarget() {
    if (widget.imageBytes != null) {
      return Container(
        width: 170,
        height: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _hasError ? AppColors.danger : AppColors.purple,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (_hasError ? AppColors.danger : AppColors.purple)
                  .withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.memory(widget.imageBytes!, fit: BoxFit.cover),
            ),
            if (!_hasError)
              // Glowing scanner beam
              AnimatedBuilder(
                animation: _anim,
                builder: (context, _) {
                  return Positioned(
                    top: _anim.value * 160,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.purple,
                            Colors.white,
                            AppColors.purple,
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.purple.withValues(alpha: 0.8),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      );
    }

    return const AiskinLogo(size: 100);
  }

  Widget _ring(double phase) {
    final t = (_anim.value + phase) % 1.0;
    final size = 160 + 90 * t;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.purple.withValues(alpha: (1 - t) * 0.35),
          width: 2,
        ),
        color: AppColors.purple.withValues(alpha: (1 - t) * 0.05),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: AnimatedBuilder(
                      animation: _anim,
                      builder: (context, child) => Stack(
                        alignment: Alignment.center,
                        children: [
                          if (!_hasError) _ring(0),
                          if (!_hasError) _ring(0.5),
                          child!,
                        ],
                      ),
                      child: _buildScanTarget(),
                    ),
                  ),
                  const SizedBox(height: 28),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _hasError ? 'Analisis Gagal' : 'Menganalisis kulit Anda...',
                      key: ValueKey(_hasError),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _hasError ? AppColors.danger : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _statusText,
                      key: ValueKey(_statusText),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: AppColors.grey),
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (_hasError) ...[
                    // Tampilkan pesan error dan tombol aksi
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.danger.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.wifi_off_rounded,
                              size: 36, color: AppColors.danger),
                          const SizedBox(height: 10),
                          Text(
                            _errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.danger,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _retryAnalysis,
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Coba Lagi'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _retryWithDummy,
                            icon: const Icon(Icons.auto_awesome, size: 18),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.purple,
                            ),
                            label: const Text('Mode Demo'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Kembali ke Kamera / Galeri'),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: 180,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: const LinearProgressIndicator(
                          minHeight: 5,
                          backgroundColor: AppColors.softBlue,
                          valueColor:
                              AlwaysStoppedAnimation(AppColors.purple),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.imageBytes != null
                          ? 'Sedang mendeteksi jerawat & kondisi kulit...'
                          : 'Menyiapkan demo analisis...',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
