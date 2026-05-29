import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  english,
  kazakh,
}

@immutable
class AppSettings {
  final bool isDarkMode;
  final AppLanguage language;

  const AppSettings({
    required this.isDarkMode,
    required this.language,
  });

  AppSettings copyWith({
    bool? isDarkMode,
    AppLanguage? language,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
    );
  }
}

class AppSettingsController extends ValueNotifier<AppSettings> {
  AppSettingsController._()
      : super(
          const AppSettings(
            isDarkMode: false,
            language: AppLanguage.english,
          ),
        );

  static final AppSettingsController instance = AppSettingsController._();

  static const String _darkModeKey = 'is_dark_mode';
  static const String _languageKey = 'app_language';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    final languageCode = prefs.getString(_languageKey) ?? 'en';

    value = AppSettings(
      isDarkMode: isDarkMode,
      language: languageCode == 'kk' ? AppLanguage.kazakh : AppLanguage.english,
    );
  }

  Future<void> setDarkMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, enabled);
    value = value.copyWith(isDarkMode: enabled);
  }

  Future<void> setLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _languageKey, language == AppLanguage.kazakh ? 'kk' : 'en');
    value = value.copyWith(language: language);
  }

  ThemeMode get themeMode =>
      value.isDarkMode ? ThemeMode.dark : ThemeMode.light;

  bool get isKazakh => value.language == AppLanguage.kazakh;
}
