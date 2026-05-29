// lib/screens/loading_screen.dart
import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../widgets/shared_widgets.dart';

class LoadingScreen extends StatelessWidget {
  final String message;
  const LoadingScreen({super.key, this.message = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const JihcLogo(size: 70),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: AppConstants.accentColor),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(color: AppConstants.darkBlue)),
          ],
        ),
      ),
    );
  }
}

// lib/screens/empty_state_screen.dart
class EmptyStateScreen extends StatelessWidget {
  const EmptyStateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nothing Here')),
      body: const EmptyState(
        title: 'No notifications yet',
        description: 'New booking updates and alerts will appear here.',
        icon: Icons.inbox_outlined,
      ),
    );
  }
}

// lib/screens/error_state_screen.dart
class ErrorStateScreen extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateScreen(
      {super.key, this.message = 'Something went wrong.', this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: ErrorState(message: message, onRetry: onRetry),
    );
  }
}
