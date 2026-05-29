// lib/screens/notifications_screen.dart
// Shows recent booking activity notifications

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import '../models/user_model.dart';
import '../services/alert_service.dart';
import '../utils/app_constants.dart';
import '../widgets/shared_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  final UserModel userModel;

  const NotificationsScreen({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    final alertService = AlertService();
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Хабарламалар'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<AlertModel>>(
        stream: alertService.getUserAlertsStream(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorState(message: 'Қате: ${snapshot.error}');
          }

          final alerts = (snapshot.data ?? []).take(20).toList();

          if (alerts.isEmpty) {
            return const EmptyState(
              title: 'No notifications yet',
              description:
                  'New booking updates and alerts will appear here.',
              icon: Icons.notifications_none,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: alerts.length,
            itemBuilder: (ctx, i) {
              final alert = alerts[i];
              final isOwn = alert.userId == userModel.uid;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isOwn
                      ? AppConstants.accentColor.withValues(alpha: 0.06)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isOwn
                        ? AppConstants.accentColor.withValues(alpha: 0.3)
                        : AppConstants.lightBlue,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppConstants.accentColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_cafe,
                          color: AppConstants.accentColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppConstants.darkBlue),
                          ),
                          Text(
                            alert.message,
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            alert.createdAt.toLocal().toString(),
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (isOwn)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppConstants.accentColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Сіз',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
