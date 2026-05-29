import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/booking_analytics.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../services/booking_service.dart';
import '../widgets/shared_widgets.dart';
import 'admin_bookings_screen.dart';
import 'booking_details_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  final UserModel userModel;

  const MyBookingsScreen({super.key, required this.userModel});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  bool _showUpcoming = true;
  final Set<String> _hiddenBookingIds = {};

  @override
  Widget build(BuildContext context) {
    final bookingService = BookingService();
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Менің брондарым'),
        automaticallyImplyLeading: false,
        actions: [
          if (widget.userModel.isAdmin)
            IconButton(
              tooltip: 'Әкімші режимі',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AdminBookingsScreen(userModel: widget.userModel),
                ),
              ),
              icon: const Icon(Icons.admin_panel_settings_outlined),
            ),
        ],
      ),
      body: ResponsiveContent(
        child: StreamBuilder<List<BookingModel>>(
          stream: bookingService.getUserBookingsStream(uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingState(message: 'Loading your bookings...');
            }
            if (snapshot.hasError) {
              return ErrorState(message: 'Error: ${snapshot.error}');
            }

            final bookings = (snapshot.data ?? [])
                .where((booking) =>
                    booking.displayStatus != BookingStatus.cancelled &&
                    !_hiddenBookingIds.contains(booking.bookingId))
                .toList();
            final analytics = BookingAnalytics.fromBookings(bookings);
            final filtered = bookings
                .where((booking) =>
                    _showUpcoming ? booking.isUpcoming : booking.isPast)
                .toList();

            if (bookings.isEmpty) {
              return const EmptyState(
                title: 'No bookings yet',
                description: 'You have not booked any tea rooms yet.',
                icon: Icons.bookmark_outline_rounded,
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SectionHeader(
                  title: 'Брондар тізбегі',
                  subtitle: widget.userModel.isAdmin
                      ? 'Өз брондарыңыз және жоғарғы панельдегі әкімші кіруі.'
                      : 'Алдағы және өткен брондарды нақты уақытта бақылаңыз.',
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
                      label: 'Барлық брон',
                      value: analytics.totalBookings.toString(),
                      icon: Icons.receipt_long_outlined,
                    ),
                    AnalyticsCard(
                      label: 'Алдағы',
                      value: analytics.upcomingCount.toString(),
                      icon: Icons.upcoming_outlined,
                    ),
                    AnalyticsCard(
                      label: 'Өткен',
                      value: analytics.pastCount.toString(),
                      icon: Icons.history_toggle_off_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(
                      value: true,
                      icon: Icon(Icons.schedule),
                      label: Text('Алдағы'),
                    ),
                    ButtonSegment<bool>(
                      value: false,
                      icon: Icon(Icons.history),
                      label: Text('Өткен'),
                    ),
                  ],
                  selected: {_showUpcoming},
                  onSelectionChanged: (selection) {
                    setState(() => _showUpcoming = selection.first);
                  },
                ),
                const SizedBox(height: 18),
                if (filtered.isEmpty)
                  EmptyState(
                    title: _showUpcoming
                        ? 'No bookings yet'
                        : 'No booking history',
                    description: _showUpcoming
                        ? 'You have not booked any tea rooms yet.'
                        : 'Your completed and cancelled bookings will appear here.',
                    icon: _showUpcoming
                        ? Icons.calendar_month_outlined
                        : Icons.history_outlined,
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
                          ? () => _confirmCancel(context, booking)
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

  Future<void> _confirmCancel(
      BuildContext context, BookingModel booking) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Бұл брон бірден тізімнен жасырылады.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Қалдыру'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Бронды болдырмау'),
          ),
        ],
      ),
    );

    if (shouldCancel == true && context.mounted) {
      setState(() => _hiddenBookingIds.add(booking.bookingId));
      try {
        await BookingService().cancelBooking(
          bookingId: booking.bookingId,
          actor: widget.userModel,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(this.context).showSnackBar(
          const SnackBar(content: Text('Брон күші жойылды')),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _hiddenBookingIds.remove(booking.bookingId));
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(content: Text('Қате: $e')),
        );
      }
    }
  }
}
