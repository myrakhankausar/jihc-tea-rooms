import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'state/app_settings_controller.dart';
import 'utils/app_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('PROJECT ID: ${Firebase.app().options.projectId}');
  await AppSettingsController.instance.load();

  runApp(const JihcTeaRoomApp());
}

class JihcTeaRoomApp extends StatelessWidget {
  const JihcTeaRoomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettings>(
      valueListenable: AppSettingsController.instance,
      builder: (context, settings, _) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: appTheme(),
          darkTheme: appDarkTheme(),
          themeMode: AppSettingsController.instance.themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
