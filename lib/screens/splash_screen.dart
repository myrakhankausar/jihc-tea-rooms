// lib/screens/splash_screen.dart
// Displayed on app launch, checks auth state and routes accordingly

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../utils/app_constants.dart';
import '../widgets/shared_widgets.dart';
import 'login_screen.dart';
import 'main_screen.dart';
import 'gender_select_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Fade-in animation
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
    // Navigate after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), _checkAuthState);
  }

  Future<void> _checkAuthState() async {
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Not logged in → Onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen1()),
      );
    } else {
      // Logged in → check gender set
      final userData = await _authService.getCurrentUserFromFirestore();
      if (!mounted) return;
      if (userData.gender.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GenderSelectScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScreen(userModel: userData)),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.accentColor,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // JIHC official logo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const JihcLogo(size: 100),
              ),
              const SizedBox(height: 28),
              const Text(
                AppConstants.appFullName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Жатақхана Студенттері Үшін',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Onboarding screens ──────────────────────────────────────────────────────

class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return _OnboardingPage(
      index: 1,
      icon: Icons.local_cafe,
      title: 'Welcome to JIHC Tea Room',
      subtitle: 'Book tea rooms in the JIHC dormitory easily and quickly.',
      onNext: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen2()),
      ),
    );
  }
}

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return _OnboardingPage(
      index: 2,
      icon: Icons.calendar_month,
      title: 'Plan Your Evening',
      subtitle:
          'Choose a date, time slot, and room. No more arguments — just book!',
      onNext: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen3()),
      ),
    );
  }
}

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return _OnboardingPage(
      index: 3,
      icon: Icons.people,
      title: 'Separate Rooms for All',
      subtitle:
          'Girls and boys have dedicated tea rooms. Fair and organized for everyone.',
      onNext: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      ),
      isLast: true,
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final int index;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onNext;
  final bool isLast;

  const _OnboardingPage({
    required this.index,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onNext,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              // Page indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i + 1 == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i + 1 == index
                          ? AppConstants.accentColor
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppConstants.accentColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 80, color: AppConstants.accentColor),
              ),
              const SizedBox(height: 40),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.darkBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                subtitle,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              PrimaryButton(
                label: isLast ? 'Get Started' : 'Next',
                onPressed: onNext,
              ),
              if (!isLast) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: const Text('Skip',
                      style: TextStyle(color: AppConstants.accentColor)),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
