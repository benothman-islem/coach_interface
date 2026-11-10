import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF0E110C);
  static const card = Color(0xFF161A14);
  static const border = Color(0xFF2A2F27);
  static const lime = Color(0xFFB8F23C);
  static const text = Color(0xFFF7F8F5);
  static const muted = Color(0xFF8A9186);
  static const darkGreen = Color(0xFF243014);
  static const purple = Color(0xFFA78BFA);
  static const purpleDark = Color(0xFF7C5CE0);
  static const purpleTint = Color(0xFF2A213F);
  static const orange = Color(0xFFE78A72);
  static const sessionSalmon = Color(0xFFF4A07A);
  static const selectedDay = Color(0xFF1B2410);
  static const memberSalmon = Color(0xFFE8906A);
  static const memberBlue = Color(0xFF6FA3D8);
  static const specialtyChip = Color(0xFF1F241C);
  static const destructive = Color(0xFFF4866A);
  static const sheetField = Color(0xFF1F241C);
  static const selectedChip = Color(0xFF1B2410);
  static const closeButton = Color(0xFF232821);
  static const sheet = Color(0xFF161A14);
}

abstract final class AppText {
  static const eyebrow = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
  );
  static const screenTitle = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.2,
  );
  static const coachName = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
  );
  static const bodySmall = TextStyle(fontSize: 12);
  static const sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  static const trailingLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );
  static const statNumber = TextStyle(
    fontSize: 38,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.2,
    height: 40 / 38,
  );
  static const statLabel = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
  static const caption = TextStyle(fontSize: 11, fontWeight: FontWeight.w500);
  static const dateDay = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
  );
  static const dateNumber = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    height: 32 / 30,
  );
  static const sessionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );
  static const avatarInitials = TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w700,
  );
  static const avatarSmall = TextStyle(
    fontSize: 8,
    fontWeight: FontWeight.w700,
  );
  static const button = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  static const navLabel = TextStyle(fontSize: 10, fontWeight: FontWeight.w500);
}

ThemeData buildAppTheme() {
  const text = AppColors.text;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.lime,
      onPrimary: AppColors.background,
      secondary: AppColors.purple,
      surface: AppColors.card,
      onSurface: text,
      outline: AppColors.border,
    ),
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16, height: 24 / 16),
      bodyMedium: TextStyle(fontSize: 14),
      bodySmall: TextStyle(fontSize: 12),
    ),
    splashFactory: NoSplash.splashFactory,
  );
}
