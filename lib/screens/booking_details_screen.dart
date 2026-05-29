import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../services/booking_service.dart';
import '../utils/app_constants.dart';
import '../widgets/shared_widgets.dart';
import 'edit_booking_screen.dart';

class BookingDetailsScreen extends StatelessWidget {
  final BookingModel booking;
  final UserModel userModel;

  const BookingDetailsScreen({
    super.key,
    required this.booking,
    required this.userModel,
  });

  @override
  Widget build(BuildContext context) {
    final isOwner =
        booking.userId == FirebaseAuth.instance.currentUser!.uid;
    final canCancel = isOwner || userModel.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        actions: [
          if (isOwner && booking.displayStatus == BookingStatus.active)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditBookingScreen(
                    booking: booking,
                    userModel: userModel,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: ResponsiveContent(
        maxWidth: 760,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ProfileAvatar(
                          name: booking.userName,
                          photoUrl: booking.userPhotoUrl,
                          radius: 28,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.userName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              Text(
                                booking.roomName,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        BookingStatusChip(status: booking.displayStatus),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _DetailPill(
                          icon: Icons.calendar_today_outlined,
                          label: 'Date',
                          value: booking.dateLabel,
                        ),
                        _DetailPill(
                          icon: Icons.access_time,
                          label: 'Time',
                          value: booking.timelineTimeLabel,
                        ),
                        _DetailPill(
                          icon: Icons.people_alt_outlined,
                          label: 'Group',
                          value: booking.gender,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _InfoBlock(label: 'Purpose', value: booking.purpose),
                    const SizedBox(height: 12),
                    _InfoBlock(
                      label: 'Created',
                      value: booking.createdAt.toLocal().toString(),
                    ),
                    if (booking.cancelledAt != null) ...[
                      const SizedBox(height: 12),
                      _InfoBlock(
                        label: 'Cancelled',
                        value:
                            '${booking.cancelledByUserName} on ${booking.cancelledAt!.toLocal()}',
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (canCancel && booking.displayStatus == BookingStatus.active) ...[
              const SizedBox(height: 18),
              Row(
                children: [
                  if (isOwner) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditBookingScreen(
                              booking: booking,
                              userModel: userModel,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit Booking'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmCancel(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.bookedColor,
                      ),
                      icon: const Icon(Icons.cancel_outlined),
                      label: Text(userModel.isAdmin && !isOwner
                          ? 'Admin Cancel'
                          : 'Cancel Booking'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('This booking will stay in history as cancelled.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep booking'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.bookedColor),
            child: const Text('Cancel booking'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await BookingService().cancelBooking(
        bookingId: booking.bookingId,
        actor: userModel,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking cancelled')),
        );
        Navigator.pop(context);
      }
    }
  }
}

class _DetailPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String label;
  final String value;

  const _InfoBlock({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(height: 1.5)),
      ],
    );
  }
}
