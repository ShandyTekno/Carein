import 'package:flutter/material.dart';

import '../models/dummy_models.dart';
import '../services/analysis_service.dart';
import '../theme/app_theme.dart';
import '../widgets/score_card.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<AnalysisResult>? _items;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await AnalysisService.fetchHistory();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat riwayat: $e';
        _loading = false;
        _items = [];
      });
    }
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Riwayat'),
        content: const Text(
            'Semua riwayat analisis akan dihapus permanen. Lanjutkan?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await AnalysisService.clearHistory();
    if (mounted) _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadHistory,
        color: AppColors.purple,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Analysis History',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w700)),
                          SizedBox(height: 4),
                          Text('Tap an item to see the full analysis',
                              style: TextStyle(
                                  fontSize: 14, color: AppColors.grey)),
                        ],
                      ),
                    ),
                    if (_items != null && _items!.isNotEmpty)
                      IconButton(
                        tooltip: 'Hapus semua riwayat',
                        onPressed: _clearHistory,
                        icon: const Icon(Icons.delete_sweep_outlined,
                            color: AppColors.danger),
                      ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            if (_loading)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.purple),
                      SizedBox(height: 16),
                      Text('Memuat riwayat dari Supabase...',
                          style: TextStyle(color: AppColors.grey)),
                    ],
                  ),
                ),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_rounded,
                          size: 48, color: AppColors.grey),
                      const SizedBox(height: 12),
                      Text(_error!,
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(color: AppColors.grey, fontSize: 13)),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _loadHistory,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_items == null || _items!.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_rounded,
                          size: 64, color: AppColors.softBlue),
                      SizedBox(height: 16),
                      Text('Belum ada riwayat analisis',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      SizedBox(height: 6),
                      Text('Lakukan analisis wajah pertama Anda!',
                          style:
                              TextStyle(fontSize: 13, color: AppColors.grey)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final item = _items![i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _HistoryItem(
                          result: item,
                          index: i,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ResultScreen(
                                result: item,
                                fromHistory: true,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: _items!.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({
    required this.result,
    required this.index,
    required this.onTap,
  });

  final AnalysisResult result;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Temukan nilai acne untuk tampilkan badge
    final acneMetric = result.metrics
        .where((m) => m.label == 'Acne')
        .firstOrNull;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.card(),
        child: Row(
          children: [
            ScoreRing(score: result.score, size: 60, strokeWidth: 6, fontSize: 18),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result.date,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${result.skinType} Skin',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.grey)),
                  if (acneMetric != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.bubble_chart_rounded,
                            size: 13,
                            color: acneMetric.color.withValues(alpha: 0.9)),
                        const SizedBox(width: 4),
                        Text(
                          'Acne: ${acneMetric.level}',
                          style: TextStyle(
                            fontSize: 12,
                            color: acneMetric.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
          ],
        ),
      ),
    );
  }
}
