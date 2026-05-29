import 'package:flutter/material.dart';

import '../models/booking_analytics.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../services/booking_service.dart';
import '../widgets/shared_widgets.dart';
import 'booking_details_screen.dart';

class AdminBookingsScreen extends StatefulWidget {
  final UserModel userModel;

  const AdminBookingsScreen({
    super.key,
    required this.userModel,
  });

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Bookings')),
      body: ResponsiveContent(
        child: StreamBuilder<List<BookingModel>>(
          stream: BookingService().getAllBookingsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingState(message: 'Loading admin dashboard...');
            }
            if (snapshot.hasError) {
              return ErrorState(
                  message: 'Error loading admin bookings: ${snapshot.error}');
            }

            final bookings = snapshot.data ?? [];
            final analytics = BookingAnalytics.fromBookings(bookings);
            final filtered = bookings.where((booking) {
              if (_statusFilter == 'all') {
                return true;
              }
              return booking.displayStatus.name == _statusFilter;
            }).toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SectionHeader(
                  title: 'Admin Mode',
                  subtitle: 'Live view of every room booking in Firestore.',
                ),
                GridView.count(
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 800 ? 3 : 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.3,
                  children: [
                    AnalyticsCard(
                      label: 'Total bookings',
                      value: analytics.totalBookings.toString(),
                      icon: Icons.receipt_long_outlined,
                    ),
                    AnalyticsCard(
                      label: 'Most booked room',
                      value: analytics.mostBookedRoom,
                      icon: Icons.local_fire_department_outlined,
                    ),
                    AnalyticsCard(
                      label: 'Busiest day',
                      value: analytics.busiestDay,
                      icon: Icons.calendar_view_week_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _statusFilter == 'all',
                      onSelected: (_) => setState(() => _statusFilter = 'all'),
                    ),
                    FilterChip(
                      label: const Text('Active'),
                      selected: _statusFilter == 'active',
                      onSelected: (_) =>
                          setState(() => _statusFilter = 'active'),
                    ),
                    FilterChip(
                      label: const Text('Completed'),
                      selected: _statusFilter == 'completed',
                      onSelected: (_) =>
                          setState(() => _statusFilter = 'completed'),
                    ),
                    FilterChip(
                      label: const Text('Cancelled'),
                      selected: _statusFilter == 'cancelled',
                      onSelected: (_) =>
                          setState(() => _statusFilter = 'cancelled'),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (filtered.isEmpty)
                  const SizedBox(
                    height: 400,
                    child: EmptyState(
                      title: 'No bookings yet',
                      description:
                          'You have not booked any tea rooms yet.',
                      icon: Icons.admin_panel_settings_outlined,
                    ),
                  )
                else
                  ...filtered.map(
                    (booking) => BookingTimelineCard(
                      booking: booking,
                      canCancel: booking.displayStatus == BookingStatus.active,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingDetailsScreen(
                            booking: booking,
                            userModel: widget.userModel,
                          ),
                        ),
                      ),
                      onCancel: booking.displayStatus == BookingStatus.active
                          ? () => _cancelBooking(context, booking)
                          : null,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _cancelBooking(
      BuildContext context, BookingModel booking) async {
    await BookingService().cancelBooking(
      bookingId: booking.bookingId,
      actor: widget.userModel,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${booking.roomName} booking cancelled')),
      );
    }
  }
}
