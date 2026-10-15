import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Hero card on Home that invites the user to start a skin analysis.
class AnalysisCard extends StatelessWidget {
  const AnalysisCard({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -6,
            top: -6,
            child: Icon(
              Icons.face_retouching_natural,
              size: 96,
              color: Colors.white.withValues(alpha: 0.22),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                    SizedBox(width: 6),
                    Text('AI powered', style: TextStyle(color: Colors.white, fontSize: 11.5)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'AI Skin Analysis',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const SizedBox(
                width: 230,
                child: Text(
                  'Get a quick analysis of your skin condition',
                  style: TextStyle(color: Colors.white, fontSize: 13.5, height: 1.4),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.purple,
                  minimumSize: const Size(150, 46),
                ),
                child: const Text('Analyze Now'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
