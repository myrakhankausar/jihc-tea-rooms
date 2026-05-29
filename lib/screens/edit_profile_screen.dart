// lib/screens/edit_profile_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../widgets/shared_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel userModel;
  final Function(UserModel) onUpdated;

  const EditProfileScreen(
      {super.key, required this.userModel, required this.onUpdated});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.userModel.fullName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Аты бос болмауы керек')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await AuthService().updateUserProfile(uid, {
        'fullName': _nameCtrl.text.trim(),
      });
      final updated =
          widget.userModel.copyWith(fullName: _nameCtrl.text.trim());
      widget.onUpdated(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Профиль жаңартылды'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Қате: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профильді өзгерту')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Толық аты',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              initialValue: widget.userModel.email,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Email (өзгертілмейді)',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              initialValue:
                  widget.userModel.gender == 'Male' ? 'Ер' : 'Әйел',
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Жынысы (өзгертілмейді)',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Сақтау',
              onPressed: _save,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
