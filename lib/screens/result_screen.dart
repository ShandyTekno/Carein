import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/dummy_models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/metric_tile.dart';
import '../widgets/score_card.dart';
import 'recommendation_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.result,
    this.imageBytes,
    this.fromHistory = false,
  });

  final AnalysisResult result;
  final Uint8List? imageBytes;
  final bool fromHistory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Skin Analysis')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _photo(),
            const SizedBox(height: 18),
            _scoreSection(),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
              decoration: AppTheme.card(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Analysis',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  for (final m in result.metrics) MetricTile(metric: m),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _insight(),
            const SizedBox(height: 24),
            AppButton(
              label: 'View Recommendations',
              icon: Icons.spa_outlined,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RecommendationScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        height: 260,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageBytes != null)
              Image.memory(imageBytes!, fit: BoxFit.cover)
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.softBlue, AppColors.softPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.face_retouching_natural,
                    size: 110, color: Colors.white),
              ),
            Positioned(
              left: 14,
              top: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, size: 14, color: AppColors.purple),
                    const SizedBox(width: 6),
                    Text(result.date,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.card(),
      child: Row(
        children: [
          ScoreRing(score: result.score, size: 108, strokeWidth: 10, fontSize: 32),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Skin Score',
                    style: TextStyle(fontSize: 13, color: AppColors.grey)),
                const SizedBox(height: 2),
                Text('${result.score} / 100',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Skin Type: ${result.skinType}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _insight() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.softPurple,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: AppColors.purple),
              SizedBox(width: 8),
              Text('AI Insight',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.purple,
                  )),
            ],
          ),
          const SizedBox(height: 10),
          Text(result.insight,
              style: const TextStyle(fontSize: 13.5, height: 1.5)),
        ],
      ),
    );
  }
}
