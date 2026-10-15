import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.label = 'Continue with Google',
    this.isLoading = false,
  });

  final VoidCallback onPressed;
  final String label;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.border, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation(AppColors.blue),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _GoogleIcon(),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      child: CustomPaint(
        size: const Size(22, 22),
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Red
    final redPaint = Paint()..color = const Color(0xFFEA4335);
    // Yellow
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    // Green
    final greenPaint = Paint()..color = const Color(0xFF34A853);
    // Blue
    final bluePaint = Paint()..color = const Color(0xFF4285F4);

    final center = Offset(w / 2, h / 2);
    final rect = Rect.fromCircle(center: center, radius: w / 2);

    // Draw multi-colored Google 'G' arcs
    final strokeWidth = w * 0.22;
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Red arc (top)
    arcPaint.color = redPaint.color;
    canvas.drawArc(rect.deflate(strokeWidth / 2), -2.6, 1.4, false, arcPaint);

    // Yellow arc (left)
    arcPaint.color = yellowPaint.color;
    canvas.drawArc(rect.deflate(strokeWidth / 2), -1.2, 1.5, false, arcPaint);

    // Green arc (bottom)
    arcPaint.color = greenPaint.color;
    canvas.drawArc(rect.deflate(strokeWidth / 2), 0.3, 1.5, false, arcPaint);

    // Blue arc (right & bar)
    arcPaint.color = bluePaint.color;
    canvas.drawArc(rect.deflate(strokeWidth / 2), 1.8, 1.2, false, arcPaint);

    // Center horizontal bar for 'G'
    final barPaint = Paint()
      ..color = bluePaint.color
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTRB(w * 0.45, h * 0.40, w * 0.95, h * 0.60),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
