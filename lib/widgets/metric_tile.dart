import 'package:flutter/material.dart';

import '../models/dummy_models.dart';
import '../theme/app_theme.dart';

class MetricTile extends StatelessWidget {
  const MetricTile({super.key, required this.metric});

  final SkinMetric metric;

  @override
  Widget build(BuildContext context) {
    final color = metric.color;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(metric.icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(metric.label,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(metric.level,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: metric.value),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: v,
                minHeight: 7,
                backgroundColor: AppColors.lightBlue,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
