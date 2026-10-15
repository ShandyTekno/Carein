import 'package:flutter/material.dart';

import '../models/dummy_models.dart';
import '../theme/app_theme.dart';

class ScoreRing extends StatelessWidget {
  const ScoreRing({
    super.key,
    required this.score,
    this.size = 72,
    this.strokeWidth = 7,
    this.fontSize = 20,
  });

  final int score;
  final double size;
  final double strokeWidth;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: score / 100),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: strokeWidth,
                  strokeCap: StrokeCap.round,
                  backgroundColor: AppColors.softBlue,
                  valueColor: const AlwaysStoppedAnimation(AppColors.purple),
                ),
              ),
              Text(
                '$score',
                style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Compact summary of an analysis, used on Home.
class ScoreCard extends StatelessWidget {
  const ScoreCard({super.key, required this.result, this.onTap});

  final AnalysisResult result;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: AppTheme.card(),
        child: Row(
          children: [
            ScoreRing(score: result.score),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skin Score: ${result.score}/100',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Skin Type: ${result.skinType}',
                    style: const TextStyle(fontSize: 13, color: AppColors.grey),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Last Analysis: ${result.date}',
                    style: const TextStyle(fontSize: 13, color: AppColors.grey),
                  ),
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
