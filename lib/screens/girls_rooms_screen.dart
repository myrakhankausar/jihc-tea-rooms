// lib/screens/girls_rooms_screen.dart
import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../services/booking_service.dart';
import '../utils/app_constants.dart';
import '../widgets/shared_widgets.dart';
import 'room_details_screen.dart';

class GirlsRoomsScreen extends StatelessWidget {
  final UserModel userModel;

  const GirlsRoomsScreen({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    const rooms = AppConstants.girlsRooms;
    return Scaffold(
      appBar: AppBar(title: const Text("Girls' Tea Rooms")),
      body: StreamBuilder<Map<String, BookingModel>>(
        stream: BookingService().getRoomAvailabilityByRoomNames(rooms),
        builder: (context, snapshot) {
          final availability =
              snapshot.data ?? const <String, BookingModel>{};
          final allRoomsBooked =
              rooms.isNotEmpty && availability.length >= rooms.length;
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppConstants.accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppConstants.lightBlue),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppConstants.accentColor),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tap a room to view details and book a time slot.',
                        style:
                            TextStyle(color: AppConstants.darkBlue, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              if (allRoomsBooked)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: EmptyState(
                    title: 'No rooms available',
                    description: 'Please try another date or time.',
                    icon: Icons.meeting_room_outlined,
                  ),
                ),
              ...rooms.map(
                (room) {
                  final booking = availability[room];
                  return RoomCard(
                    roomName: room,
                    ownerName: booking?.userName,
                    ownerPhotoUrl: booking?.userPhotoUrl ?? '',
                    isBooked: booking != null,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RoomDetailsScreen(
                          roomName: room,
                          userModel: userModel,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
