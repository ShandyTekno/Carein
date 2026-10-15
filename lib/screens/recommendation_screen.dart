import 'package:flutter/material.dart';

import '../models/dummy_models.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  int _selectedFilter = 0; // 0: All, 1: Morning, 2: Night

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recommended For You')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            const Center(
              child: Text(
                'Personalized routine based on your AI skin analysis',
                style: TextStyle(fontSize: 13.5, color: AppColors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 18),
            _filterChips(),
            const SizedBox(height: 20),
            if (_selectedFilter == 0 || _selectedFilter == 1) ...[
              ..._routine(
                title: 'Morning Routine',
                subtitle: 'Protection & lightweight hydration',
                icon: Icons.wb_sunny_rounded,
                color: AppColors.warning,
                products: DummyData.morning,
              ),
              const SizedBox(height: 16),
            ],
            if (_selectedFilter == 0 || _selectedFilter == 2) ...[
              ..._routine(
                title: 'Night Routine',
                subtitle: 'Deep repair & clarifying active treatment',
                icon: Icons.nightlight_round,
                color: AppColors.purple,
                products: DummyData.night,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _filterChips() {
    final filters = ['All Routines', '☀️ Morning', '🌙 Night'];
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

  List<Widget> _routine({
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.grey),
              ),
            ],
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
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.lightBlue,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                products[i].category,
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
        const SizedBox(height: 16),
      ],
    ];
  }
}
