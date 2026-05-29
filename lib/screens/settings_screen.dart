import 'package:flutter/material.dart';

import '../state/app_settings_controller.dart';
import '../utils/app_constants.dart';
import '../utils/app_text.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettings>(
      valueListenable: AppSettingsController.instance,
      builder: (context, settings, _) {
        final language = settings.language;
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(
            title: Text(AppText.settings(language)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionTitle(title: AppText.preferences(language)),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(AppText.notifications(language)),
                      subtitle: Text(AppText.notificationSubtitle(language)),
                      value: _notifications,
                      onChanged: (value) {
                        setState(() => _notifications = value);
                      },
                      activeThumbColor: colorScheme.primary,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: Text(AppText.darkMode(language)),
                      subtitle: Text(AppText.darkModeSubtitle(language)),
                      value: settings.isDarkMode,
                      onChanged: (value) {
                        AppSettingsController.instance.setDarkMode(value);
                      },
                      activeThumbColor: colorScheme.primary,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: Text(AppText.kazakhLanguage(language)),
                      subtitle: const Text('Қазақ тілі'),
                      value: settings.language == AppLanguage.kazakh,
                      onChanged: (value) {
                        AppSettingsController.instance.setLanguage(
                          value ? AppLanguage.kazakh : AppLanguage.english,
                        );
                      },
                      activeThumbColor: colorScheme.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionTitle(title: AppText.appInfo(language)),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.info_outline,
                        color: colorScheme.primary,
                      ),
                      title: Text(AppText.version(language)),
                      trailing: Text(
                        '1.0.0',
                        style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.help_outline,
                        color: colorScheme.primary,
                      ),
                      title: Text(AppText.helpFaq(language)),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HelpScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          fontSize: 13,
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.accentColor.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset('assets/jihc_logo.png', height: 100),
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.appFullName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppConstants.darkBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
            ),
            const SizedBox(height: 20),
            _infoCard(
              context,
              'Description',
              'JIHC Tea Room Booking is a mobile application for JIHC college dormitory students. It allows students to easily book tea rooms in advance, avoiding conflicts and ensuring a fair scheduling system.',
            ),
            const SizedBox(height: 12),
            _infoCard(context, 'Developer Info', '''
Author: ${AppConstants.authorName}
Student ID: ${AppConstants.studentId}
Accent Color: #0000FF
College: JIHC (Жас Іскер Халықаралық Колледжі)
            '''),
            const SizedBox(height: 12),
            _infoCard(context, 'Features', '''
• Firebase Authentication (Email + Google)
• Real-time Firestore bookings
• Separate rooms for girls and boys
• Create, Edit, Delete bookings
• Profile photo upload
• Availability checking
• Booking history
            '''),
            const SizedBox(height: 12),
            _infoCard(
              context,
              'Contact',
              'For support or feedback, contact your JIHC dormitory administration.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(BuildContext context, String title, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppConstants.lightBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppConstants.darkBlue,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content.trim(),
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _HelpItem(
            q: 'How do I book a tea room?',
            a: 'Go to Home → tap on a room → tap the + button or "Book Room" → fill in the date, time slot, and purpose → confirm.',
          ),
          _HelpItem(
            q: 'Can I see rooms from the other gender?',
            a: 'No. The app only shows rooms for your gender as selected during setup.',
          ),
          _HelpItem(
            q: 'How do I edit a booking?',
            a: 'Go to My Bookings → tap Edit on your booking → change details → Save.',
          ),
          _HelpItem(
            q: 'Can I delete someone else\'s booking?',
            a: 'No. You can only edit or delete your own bookings.',
          ),
          _HelpItem(
            q: 'What does "Бос емес" mean?',
            a: '"Бос емес" means "Not available" in Kazakh. The selected time slot is already booked.',
          ),
          _HelpItem(
            q: 'How do I update my profile photo?',
            a: 'Go to Profile → tap your avatar or "Upload Photo" → choose Camera or Gallery.',
          ),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final String q;
  final String a;

  const _HelpItem({required this.q, required this.a});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ExpansionTile(
      title: Text(
        q,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : AppConstants.darkBlue,
        ),
      ),
      iconColor: AppConstants.accentColor,
      collapsedIconColor: AppConstants.accentColor,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            a,
            style: TextStyle(
              height: 1.5,
              color: isDark ? Colors.white70 : null,
            ),
          ),
        ),
      ],
    );
  }
}

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _HelpItem(
            q: 'Is this app official?',
            a: 'This app was developed by a JIHC student (Kausar, ID: 090708650972) as a project for managing tea room bookings in the JIHC dormitory.',
          ),
          _HelpItem(
            q: 'Is my data secure?',
            a: 'Yes. The app uses Firebase with security rules. You can only modify your own bookings and profile.',
          ),
          _HelpItem(
            q: 'What time slots are available?',
            a: 'Time slots: 19:00–20:00, 20:00–21:00, 21:00–22:00, 22:00–23:00.',
          ),
          _HelpItem(
            q: 'How far in advance can I book?',
            a: 'You can book up to 30 days in advance.',
          ),
          _HelpItem(
            q: 'What happens if I forget my password?',
            a: 'Use the "Forgot Password" option on the login screen to reset via email. Or sign in with Google.',
          ),
        ],
      ),
    );
  }
}
