import 'package:flutter/material.dart';

import '../models/booking_analytics.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../services/booking_service.dart';
import '../utils/app_constants.dart';
import '../utils/booking_utils.dart';
import '../widgets/shared_widgets.dart';

class RoomBookingHistoryScreen extends StatefulWidget {
  final String roomName;
  final UserModel userModel;

  const RoomBookingHistoryScreen({
    super.key,
    required this.roomName,
    required this.userModel,
  });

  @override
  State<RoomBookingHistoryScreen> createState() =>
      _RoomBookingHistoryScreenState();
}

class _RoomBookingHistoryScreenState extends State<RoomBookingHistoryScreen> {
  bool _showUpcoming = true;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final service = BookingService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Room History'),
      ),
      body: ResponsiveContent(
        child: StreamBuilder<List<BookingModel>>(
          stream: service.getRoomBookingsStream(widget.roomName),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingState(message: 'Loading room history...');
            }
            if (snapshot.hasError) {
              return ErrorState(
                  message: 'Error loading bookings: ${snapshot.error}');
            }

            final bookings = snapshot.data ?? [];
            final analytics = BookingAnalytics.fromBookings(bookings);
            final selectedDate = _selectedDate;
            final filtered = bookings.where((booking) {
              final matchesTimeline =
                  _showUpcoming ? booking.isUpcoming : booking.isPast;
              final matchesDate = selectedDate == null ||
                  BookingUtils.dateKeyFromDate(booking.bookingDate) ==
                      BookingUtils.dateKeyFromDate(selectedDate);
              return matchesTimeline && matchesDate;
            }).toList();

            final availableDates = bookings
                .map((booking) => DateTime(
                      booking.bookingDate.year,
                      booking.bookingDate.month,
                      booking.bookingDate.day,
                    ))
                .toSet()
                .toList()
              ..sort((a, b) => a.compareTo(b));

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _HistoryHeader(
                    roomName: widget.roomName,
                    analytics: analytics,
                    isAdmin: widget.userModel.isAdmin,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _CalendarStrip(
                    dates: availableDates,
                    selectedDate: _selectedDate,
                    onSelected: (date) => setState(() {
                      if (_selectedDate != null &&
                          BookingUtils.dateKeyFromDate(_selectedDate!) ==
                              BookingUtils.dateKeyFromDate(date)) {
                        _selectedDate = null;
                      } else {
                        _selectedDate = date;
                      }
                    }),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment<bool>(
                          value: true,
                          icon: Icon(Icons.schedule),
                          label: Text('Upcoming'),
                        ),
                        ButtonSegment<bool>(
                          value: false,
                          icon: Icon(Icons.history),
                          label: Text('Past'),
                        ),
                      ],
                      selected: {_showUpcoming},
                      onSelectionChanged: (selection) {
                        setState(() => _showUpcoming = selection.first);
                      },
                    ),
                  ),
                ),
                if (filtered.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      title: 'No booking history',
                      description:
                          'Your completed and cancelled bookings will appear here.',
                      icon: Icons.event_busy_outlined,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final booking = filtered[index];
                        return BookingTimelineCard(
                          booking: booking,
                          showRoomName: false,
                          canCancel: false,
                          onTap: null,
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

}

class _HistoryHeader extends StatelessWidget {
  final String roomName;
  final BookingAnalytics analytics;
  final bool isAdmin;

  const _HistoryHeader({
    required this.roomName,
    required this.analytics,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child:
                          const Icon(Icons.calendar_month, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            roomName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isAdmin
                                ? 'Admin mode: live room history and controls.'
                                : 'Live booking history with upcoming and past activity.',
                            style: const TextStyle(
                                color: Colors.white70, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    BookingStatusChip(
                      status: BookingStatus.active,
                      customLabel: '${analytics.upcomingCount} upcoming',
                    ),
                    BookingStatusChip(
                      status: BookingStatus.completed,
                      customLabel: '${analytics.pastCount} past',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 1,
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
                icon: Icons.emoji_events_outlined,
              ),
              AnalyticsCard(
                label: 'Busiest day',
                value: analytics.busiestDay,
                icon: Icons.insights_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalendarStrip extends StatelessWidget {
  final List<DateTime> dates;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onSelected;

  const _CalendarStrip({
    required this.dates,
    required this.selectedDate,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (dates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Calendar View',
            subtitle: 'Tap a date to focus the timeline.',
          ),
          SizedBox(
            height: 96,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final date = dates[index];
                final isSelected = selectedDate != null &&
                    BookingUtils.dateKeyFromDate(selectedDate!) ==
                        BookingUtils.dateKeyFromDate(date);
                return InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => onSelected(date),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 74,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).cardColor,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : AppConstants.cardBorderColor,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          BookingUtils.formatDayLabel(date),
                          style: TextStyle(
                            color:
                                isSelected ? Colors.white70 : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          BookingUtils.formatShortDate(date),
                          style: TextStyle(
                            color:
                                isSelected ? Colors.white70 : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
