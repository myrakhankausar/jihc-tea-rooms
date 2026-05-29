// lib/screens/gender_select_screen.dart
// After login/register, user chooses gender to see the right rooms

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/app_constants.dart';
import '../widgets/shared_widgets.dart';
import 'main_screen.dart';

class GenderSelectScreen extends StatefulWidget {
  const GenderSelectScreen({super.key});

  @override
  State<GenderSelectScreen> createState() => _GenderSelectScreenState();
}

class _GenderSelectScreenState extends State<GenderSelectScreen> {
  String? _selectedGender;
  bool _isLoading = false;
  final _authService = AuthService();

  Future<void> _confirm() async {
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Жынысыңызды таңдаңыз')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      // Update or create user document with gender
      final existingUser = await _authService.getUserFromFirestore(uid);
      final firebaseUser = FirebaseAuth.instance.currentUser!;

      final userModel = existingUser != null
          ? existingUser.copyWith(gender: _selectedGender)
          : UserModel(
              uid: uid,
              fullName: firebaseUser.displayName ?? 'Студент',
              email: firebaseUser.email ?? '',
              gender: _selectedGender!,
              createdAt: DateTime.now(),
            );

      await _authService
          .saveUserToFirestore(userModel.copyWith(gender: _selectedGender));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => MainScreen(
                userModel: userModel.copyWith(gender: _selectedGender))),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Қате: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const JihcLogo(size: 80),
              const SizedBox(height: 24),
              const Text(
                'Жынысыңызды таңдаңыз',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.darkBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Бұл сізге арналған шай бөлмелерін көрсетуге көмектеседі.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Female option
              _GenderOption(
                label: 'Әйел',
                emoji: '👩',
                subtitle: 'Reading, Activity, Mezun, Logman, Kazakh',
                selected: _selectedGender == 'Female',
                onTap: () => setState(() => _selectedGender = 'Female'),
              ),
              const SizedBox(height: 16),

              // Male option
              _GenderOption(
                label: 'Ер',
                emoji: '👨',
                subtitle: 'Чай ода 1 – Чай ода 5',
                selected: _selectedGender == 'Male',
                onTap: () => setState(() => _selectedGender = 'Male'),
              ),
              const Spacer(),

              PrimaryButton(
                label: 'Жалғастыру',
                onPressed: _confirm,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final String emoji;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.emoji,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected
              ? AppConstants.accentColor.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppConstants.accentColor : Colors.grey.shade300,
            width: selected ? 2.5 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: selected
                          ? AppConstants.accentColor
                          : AppConstants.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? AppConstants.accentColor : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
