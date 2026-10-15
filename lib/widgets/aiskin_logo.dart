import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AiskinLogo extends StatelessWidget {
  const AiskinLogo({super.key, this.size = 88});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.30),
            blurRadius: size * 0.35,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.face_retouching_natural, color: Colors.white, size: size * 0.52),
          Positioned(
            top: size * 0.16,
            right: size * 0.16,
            child: Icon(Icons.auto_awesome, color: Colors.white, size: size * 0.2),
          ),
        ],
      ),
    );
  }
}

/// Alias nama baru CareinLogo
typedef CareinLogo = AiskinLogo;
