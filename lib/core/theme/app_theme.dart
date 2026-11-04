import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Extra tokens that do not fit in ColorScheme.
@immutable
class TemaniColors extends ThemeExtension<TemaniColors> {
  const TemaniColors({required this.jarWarm, required this.jarPale});
  final Color jarWarm;
  final Color jarPale;

  @override
  TemaniColors copyWith({Color? jarWarm, Color? jarPale}) =>
      TemaniColors(jarWarm: jarWarm ?? this.jarWarm, jarPale: jarPale ?? this.jarPale);

  @override
  TemaniColors lerp(TemaniColors? other, double t) => TemaniColors(
        jarWarm: Color.lerp(jarWarm, other?.jarWarm, t)!,
        jarPale: Color.lerp(jarPale, other?.jarPale, t)!,
      );
}

ThemeData buildTemaniTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
    primary: AppColors.primary,
    onPrimary: AppColors.ink,
    secondary: AppColors.yellow600,
    onSecondary: AppColors.ink,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.inkSoft,
    error: AppColors.error,
    primaryContainer: AppColors.yellow100,
    onPrimaryContainer: AppColors.ink,
  );
  // google_fonts 9 uses material_ui's TextTheme, a different type from
  // flutter/material.dart, so only the font family name is taken from it.
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: GoogleFonts.nunito().fontFamily,
  );
  final text = base.textTheme.apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.yellow50,
    textTheme: text,
    extensions: const [
      TemaniColors(jarWarm: Color(0xFFFFC727), jarPale: Color(0xFFFFF3C4)),
    ],
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.yellow50,
      foregroundColor: AppColors.ink,
      elevation: 0,
      titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.yellow600),
      ),
    ),
  );
}
