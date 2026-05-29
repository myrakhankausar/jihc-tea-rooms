import '../state/app_settings_controller.dart';

class AppText {
  static String settings(AppLanguage language) =>
      language == AppLanguage.kazakh ? 'Баптаулар' : 'Settings';

  static String preferences(AppLanguage language) =>
      language == AppLanguage.kazakh ? 'Баптаулар' : 'Preferences';

  static String notifications(AppLanguage language) =>
      language == AppLanguage.kazakh ? 'Хабарламалар' : 'Notifications';

  static String notificationSubtitle(AppLanguage language) =>
      language == AppLanguage.kazakh
          ? 'Жаңа броньдар туралы хабарлама алу'
          : 'Get alerts for new bookings';

  static String darkMode(AppLanguage language) =>
      language == AppLanguage.kazakh ? 'Қараңғы режим' : 'Dark Mode';

  static String darkModeSubtitle(AppLanguage language) =>
      language == AppLanguage.kazakh
          ? 'Қараңғы тақырыпқа ауысу'
          : 'Switch to dark theme';

  static String kazakhLanguage(AppLanguage language) =>
      language == AppLanguage.kazakh ? 'Қазақ тілі' : 'Kazakh Language';

  static String appInfo(AppLanguage language) =>
      language == AppLanguage.kazakh ? 'Қосымша туралы' : 'App Info';

  static String version(AppLanguage language) =>
      language == AppLanguage.kazakh ? 'Нұсқа' : 'Version';

  static String helpFaq(AppLanguage language) =>
      language == AppLanguage.kazakh ? 'Көмек және сұрақтар' : 'Help & FAQ';
}
