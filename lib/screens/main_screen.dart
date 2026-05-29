// lib/screens/main_screen.dart
// Main shell with bottom navigation bar

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/app_constants.dart';
import 'home_screen.dart';
import 'my_bookings_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  final UserModel userModel;

  const MainScreen({super.key, required this.userModel});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late UserModel _userModel;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _userModel = widget.userModel;
  }

  void _updateUser(UserModel updated) {
    setState(() => _userModel = updated);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel>(
      stream: _authService.watchCurrentUserDocument(fallbackUser: _userModel),
      builder: (context, snapshot) {
        final currentUserModel = snapshot.data ?? _userModel;
        final screens = [
          HomeScreen(userModel: currentUserModel),
          MyBookingsScreen(userModel: currentUserModel),
          NotificationsScreen(userModel: currentUserModel),
          ProfileScreen(
            userModel: currentUserModel,
            onProfileUpdated: _updateUser,
          ),
        ];

        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            backgroundColor: Colors.white,
            indicatorColor: AppConstants.accentColor.withValues(alpha: 0.12),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: AppConstants.accentColor),
                label: 'Басты бет',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_outline),
                selectedIcon:
                    Icon(Icons.bookmark, color: AppConstants.accentColor),
                label: 'Менің брондарым',
              ),
              NavigationDestination(
                icon: Icon(Icons.notifications_outlined),
                selectedIcon:
                    Icon(Icons.notifications, color: AppConstants.accentColor),
                label: 'Хабарламалар',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon:
                    Icon(Icons.person, color: AppConstants.accentColor),
                label: 'Профиль',
              ),
            ],
          ),
        );
      },
    );
  }
}
