import 'package:flutter/material.dart';

import '../models/dummy_models.dart';
import '../services/analysis_service.dart';
import '../services/recommendation_service.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key, this.analysisResult});

  final AnalysisResult? analysisResult;

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  int _selectedFilter = 0; // 0: All, 1: Morning, 2: Night

  @override
  Widget build(BuildContext context) {
    // Gunakan hasil analisis yang dikirimkan, atau ambil analisis terbaru pengguna
    final result = widget.analysisResult ?? AnalysisService.latestResult;
    final routine = RecommendationService.getPersonalizedRoutine(result);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekomendasi Skincare'),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            // ── Kartu Ringkasan Personal AI ─────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.purple.withValues(alpha: 0.12),
                    AppColors.blue.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.purple.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.purple,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome, size: 13, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(
                              'Skin: ${routine.skinType}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'Score: ${routine.score}/100',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    routine.primaryFocus,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    routine.focusDescription,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.grey,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _filterChips(routine),
            const SizedBox(height: 20),

            // ── Rutinitas Pagi ──────────────────────────────────────────────
            if (_selectedFilter == 0 || _selectedFilter == 1) ...[
              ..._routineSection(
                title: 'Rutinitas Pagi (Morning)',
                subtitle: 'Perlindungan harian & hidrasi ringan bebas kilap',
                icon: Icons.wb_sunny_rounded,
                color: AppColors.warning,
                products: routine.morningProducts,
              ),
              const SizedBox(height: 20),
            ],

            // ── Rutinitas Malam ─────────────────────────────────────────────
            if (_selectedFilter == 0 || _selectedFilter == 2) ...[
              ..._routineSection(
                title: 'Rutinitas Malam (Night)',
                subtitle: 'Eksfoliasi mendalam & pemulihan barrier saat tidur',
                icon: Icons.nightlight_round,
                color: AppColors.purple,
                products: routine.nightProducts,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _filterChips(RoutineRecommendation routine) {
    final filters = [
      'Semua (${routine.morningProducts.length + routine.nightProducts.length})',
      '☀️ Pagi (${routine.morningProducts.length})',
      '🌙 Malam (${routine.nightProducts.length})',
    ];

    return Row(
      children: List.generate(filters.length, (index) {
        final isSelected = _selectedFilter == index;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(filters[index]),
            selected: isSelected,
            onSelected: (val) {
              if (val) setState(() => _selectedFilter = index);
            },
            selectedColor: AppColors.blue,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.navy,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? AppColors.blue : AppColors.border,
              ),
            ),
            showCheckmark: false,
          ),
        );
      }),
    );
  }

  List<Widget> _routineSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Product> products,
  }) {
    return [
      Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      for (var i = 0; i < products.length; i++) ...[
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.lightBlue,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Langkah ${i + 1}: ${products[i].category}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
        ),
        ProductCard(product: products[i]),
        const SizedBox(height: 14),
      ],
    ];
  }
}
