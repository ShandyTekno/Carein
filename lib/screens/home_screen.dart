import 'package:flutter/material.dart';

import '../services/analysis_service.dart';
import '../services/auth_service.dart';
import '../services/recommendation_service.dart';
import '../theme/app_theme.dart';
import '../widgets/analysis_card.dart';
import '../widgets/product_card.dart';
import '../widgets/score_card.dart';
import '../widgets/section_title.dart';
import 'product_detail_screen.dart';
import 'recommendation_screen.dart';
import 'result_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onAnalyze});

  final VoidCallback onAnalyze;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<String>(
                  valueListenable: AuthService.userNameNotifier,
                  builder: (context, name, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hello, $name 👋',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      const Text("Let's check your skin today",
                          style: TextStyle(fontSize: 14, color: AppColors.grey)),
                    ],
                  ),
                ),
              ),
              Container(
                width: 46,
                height: 46,
                decoration: AppTheme.card(radius: 16),
                child: const Icon(Icons.notifications_none_rounded, color: AppColors.navy),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AnalysisCard(onPressed: onAnalyze),
          const SizedBox(height: 28),
          const SectionTitle('Analisis Terkini'),
          const SizedBox(height: 14),
          Builder(
            builder: (context) {
              final latest = AnalysisService.latestResult;
              return ScoreCard(
                result: latest,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ResultScreen(result: latest, fromHistory: true),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          Builder(
            builder: (context) {
              final latest = AnalysisService.latestResult;
              final routine = RecommendationService.getPersonalizedRoutine(latest);
              final recommendedProducts = [
                ...routine.morningProducts.take(2),
                ...routine.nightProducts.take(2),
              ];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(
                    'Rekomendasi Untuk Anda',
                    actionLabel: 'Lihat semua',
                    onAction: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RecommendationScreen(analysisResult: latest),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 215,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      itemCount: recommendedProducts.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 14),
                      itemBuilder: (context, i) => MiniProductCard(
                        product: recommendedProducts[i],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(
                              product: recommendedProducts[i],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

