import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const navy = Color(0xFF14213D);
  static const grey = Color(0xFF8A94A6);
  static const blue = Color(0xFF5B9DF9);
  static const softBlue = Color(0xFFD6E8FF);
  static const lightBlue = Color(0xFFEAF3FF);
  static const purple = Color(0xFF8B7CF6);
  static const softPurple = Color(0xFFF1EEFF);
  static const bg = Color(0xFFF7FAFF);
  static const border = Color(0xFFE6EDF7);
  static const success = Color(0xFF3CC8A0);
  static const warning = Color(0xFFF5A75B);
  static const danger = Color(0xFFF17C7C);
}

class AppTheme {
  AppTheme._();

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: AppColors.blue.withValues(alpha: 0.10),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static BoxDecoration card({Color color = Colors.white, double radius = 22}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.border),
      boxShadow: softShadow,
    );
  }

  static const LinearGradient brandGradient = LinearGradient(
    colors: [AppColors.blue, AppColors.purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static OutlineInputBorder _border(Color c, [double w = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: c, width: w),
    );
  }

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.blue,
        primary: AppColors.blue,
        secondary: AppColors.purple,
        surface: Colors.white,
        brightness: Brightness.light,
      ),
    );
    final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.navy, displayColor: AppColors.navy);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.navy,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 17,
          color: AppColors.navy,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: const TextStyle(color: AppColors.grey, fontSize: 14),
        border: _border(AppColors.border),
        enabledBorder: _border(AppColors.border),
        focusedBorder: _border(AppColors.blue, 1.6),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.blue,
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.softBlue, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.lightBlue,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.blue : AppColors.grey,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.blue : AppColors.grey,
            size: 26,
          );
        }),
      ),
    );
  }
}
