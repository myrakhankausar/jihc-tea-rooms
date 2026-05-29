// lib/screens/room_details_screen.dart
// Shows all bookings for a room in real-time and lets user create a new booking

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../services/booking_service.dart';
import '../utils/app_constants.dart';
import '../widgets/shared_widgets.dart';
import 'create_booking_screen.dart';
import 'room_booking_history_screen.dart';

class RoomDetailsScreen extends StatelessWidget {
  final String roomName;
  final UserModel userModel;

  const RoomDetailsScreen({
    super.key,
    required this.roomName,
    required this.userModel,
  });

  @override
  Widget build(BuildContext context) {
    final bookingService = BookingService();

    return Scaffold(
      appBar: AppBar(
        title: Text(roomName),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Room history',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RoomBookingHistoryScreen(
                  roomName: roomName,
                  userModel: userModel,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Book this room',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreateBookingScreen(
                  roomName: roomName,
                  userModel: userModel,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Room header card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppConstants.accentColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_cafe,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          roomName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Calendar history, live timeline, and room analytics are available here.',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SectionHeader(
            title: 'Current Bookings',
            subtitle: 'Live room availability updates across devices.',
            action: TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoomBookingHistoryScreen(
                    roomName: roomName,
                    userModel: userModel,
                  ),
                ),
              ),
              icon: const Icon(Icons.calendar_month_outlined),
              label: const Text('History'),
            ),
          ),

          // Real-time bookings list
          Expanded(
            child: StreamBuilder<List<BookingModel>>(
              stream: bookingService.getRoomBookingsStream(roomName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingState(
                      message: 'Loading room bookings...');
                }
                if (snapshot.hasError) {
                  return ErrorState(message: 'Error: ${snapshot.error}');
                }
                final bookings = snapshot.data ?? [];
                if (bookings.isEmpty) {
                  return const EmptyState(
                    title: 'No bookings yet',
                    description: 'You have not booked any tea rooms yet.',
                    icon: Icons.local_cafe_outlined,
                  );
                }
                return ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, i) {
                    final b = bookings[i];
                    final isOwner =
                        b.userId == FirebaseAuth.instance.currentUser!.uid;
                    return BookingCard(
                      roomName: b.roomName,
                      date: b.dateLabel,
                      timeSlot: b.timelineTimeLabel,
                      purpose: b.purpose,
                      userName: b.userName,
                      userPhotoUrl: b.userPhotoUrl,
                      status: b.displayStatus,
                      isOwner: isOwner,
                      onTap: null,
                      onDelete: isOwner
                          ? () => _confirmCancel(context, bookingService, b)
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CreateBookingScreen(
              roomName: roomName,
              userModel: userModel,
            ),
          ),
        ),
        backgroundColor: AppConstants.accentColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Book Room', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _confirmCancel(
    BuildContext context,
    BookingService bookingService,
    BookingModel booking,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text(
          'Cancel your booking for ${booking.timelineTimeLabel}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await bookingService.cancelBooking(
                bookingId: booking.bookingId,
                actor: userModel,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking cancelled')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.bookedColor,
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }
}
