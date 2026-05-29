import 'package:flutter/material.dart';

class AppConstants {
  static const String authorName = 'Kausar';
  static const String studentId = '090708650972';
  static const String appName = 'JIHC Шай бөлмесі';
  static const String appFullName = 'JIHC Шай бөлмесін брондау';

  static const Color accentColor = Color(0xFF185ADB);
  static const Color accentDark = Color(0xFF0D47A1);
  static const Color backgroundColor = Color(0xFFF4F7FB);
  static const Color darkBlue = Color(0xFF0F2744);
  static const Color lightBlue = Color(0xFFB7C9F7);
  static const Color availableColor = Color(0xFF1F9D6B);
  static const Color bookedColor = Color(0xFFE45454);
  static const Color warningColor = Color(0xFFF2A93B);
  static const Color cardBorderColor = Color(0xFFD7E0F1);

  static const List<String> girlsRooms = [
    'Reading',
    'Activity',
    'Mezun',
    'Logman',
    'Kazakh',
  ];

  static const List<String> boysRooms = [
    'Чай ода 1',
    'Чай ода 2',
    'Чай ода 3',
    'Чай ода 4',
    'Чай ода 5',
  ];

  static const List<String> timeSlots = [
    '19:00–20:00',
    '20:00–21:00',
    '21:00–22:00',
    '22:00–23:00',
  ];
}

ThemeData appTheme() {
  final base = ColorScheme.fromSeed(
    seedColor: AppConstants.accentColor,
    brightness: Brightness.light,
  );

  return ThemeData(
    colorScheme: base.copyWith(
      primary: AppConstants.accentColor,
      secondary: const Color(0xFF3EB6A6),
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: AppConstants.backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppConstants.darkBlue,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppConstants.cardBorderColor),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.accentColor,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        side: const BorderSide(color: AppConstants.cardBorderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppConstants.cardBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppConstants.cardBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppConstants.accentColor, width: 2),
      ),
      labelStyle: const TextStyle(color: AppConstants.darkBlue),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      side: const BorderSide(color: AppConstants.cardBorderColor),
      selectedColor: AppConstants.accentColor,
      backgroundColor: Colors.white,
      labelStyle: const TextStyle(color: AppConstants.darkBlue),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
    ),
    useMaterial3: true,
  );
}

ThemeData appDarkTheme() {
  final base = ColorScheme.fromSeed(
    seedColor: AppConstants.accentColor,
    brightness: Brightness.dark,
  );

  return ThemeData(
    colorScheme: base.copyWith(
      primary: const Color(0xFF7BA7FF),
      secondary: const Color(0xFF55D7C2),
      surface: const Color(0xFF162033),
    ),
    scaffoldBackgroundColor: const Color(0xFF09111F),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF162033),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFF22304C)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7BA7FF),
        foregroundColor: const Color(0xFF04101F),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        side: const BorderSide(color: Color(0xFF22304C)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF162033),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF22304C)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF22304C)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF7BA7FF), width: 2),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      side: const BorderSide(color: Color(0xFF22304C)),
      selectedColor: const Color(0xFF7BA7FF),
      backgroundColor: const Color(0xFF162033),
      labelStyle: const TextStyle(color: Colors.white),
      secondaryLabelStyle: const TextStyle(color: Color(0xFF04101F)),
    ),
    useMaterial3: true,
  );
}
