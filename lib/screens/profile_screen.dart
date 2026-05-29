// lib/screens/profile_screen.dart
// User profile with photo, details, and logout

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/app_constants.dart';
import '../widgets/shared_widgets.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'upload_photo_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel userModel;
  final Function(UserModel) onProfileUpdated;

  const ProfileScreen({
    super.key,
    required this.userModel,
    required this.onProfileUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _overrideProfile;

  void _applyProfileUpdate(UserModel updated) {
    widget.onProfileUpdated(updated);
    setState(() {
      _overrideProfile = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userModel = _overrideProfile ?? widget.userModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
              Container(
                color: AppConstants.accentColor,
                padding: const EdgeInsets.only(bottom: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UploadPhotoScreen(
                            userModel: userModel,
                            onPhotoUploaded: (url) {
                              _applyProfileUpdate(
                                userModel.copyWith(photoUrl: url),
                              );
                            },
                          ),
                        ),
                      ),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 54,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                avatarImageProvider(userModel.photoUrl),
                            child: userModel.photoUrl.isEmpty
                                ? Text(
                                    userModel.fullName.isNotEmpty
                                        ? userModel.fullName[0].toUpperCase()
                                        : 'S',
                                    style: const TextStyle(
                                      fontSize: 40,
                                      color: AppConstants.accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: AppConstants.accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      userModel.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userModel.email,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        userModel.gender == 'Female' ? '👩 Әйел' : '👨 Ер',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF14253D) : AppConstants.darkBlue,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF7BA7FF)
                        : AppConstants.lightBlue,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.18 : 0.08,
                      ),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Әзірлеуші туралы',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _row(
                      Icons.person,
                      'Автор',
                      AppConstants.authorName,
                      iconColor: const Color(0xFF9CC0FF),
                      labelColor: Colors.white70,
                      valueColor: Colors.white,
                    ),
                    _row(
                      Icons.badge,
                      'Студент ID',
                      AppConstants.studentId,
                      iconColor: const Color(0xFF9CC0FF),
                      labelColor: Colors.white70,
                      valueColor: Colors.white,
                    ),
                    _row(
                      Icons.color_lens,
                      'Акцент түсі',
                      '#0000FF',
                      iconColor: const Color(0xFF9CC0FF),
                      labelColor: Colors.white70,
                      valueColor: Colors.white,
                    ),
                  ],
                ),
              ),
              _menuItem(
                context,
                Icons.edit,
                'Профильді өзгерту',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(
                      userModel: userModel,
                      onUpdated: _applyProfileUpdate,
                    ),
                  ),
                ),
              ),
              _menuItem(
                context,
                Icons.photo_camera,
                'Фото жүктеу',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UploadPhotoScreen(
                      userModel: userModel,
                      onPhotoUploaded: (url) {
                        _applyProfileUpdate(userModel.copyWith(photoUrl: url));
                      },
                    ),
                  ),
                ),
              ),
              _menuItem(
                context,
                Icons.settings,
                'Баптаулар',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
              _menuItem(
                context,
                Icons.info_outline,
                'Қосымша туралы',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                ),
              ),
              const Divider(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Шығу',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _row(
    IconData icon,
    String label,
    String value, {
    Color iconColor = AppConstants.accentColor,
    Color labelColor = Colors.grey,
    Color valueColor = AppConstants.darkBlue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: labelColor, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.accentColor),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Шығу'),
        content: const Text('Шынымен аккаунттан шыққыңыз келе ме?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Бас тарту'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Шығу'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await AuthService().logout();
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }
}
