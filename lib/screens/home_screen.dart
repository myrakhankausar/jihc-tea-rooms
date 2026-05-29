// lib/screens/home_screen.dart
// Dashboard – shows rooms based on gender and recent bookings

import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../services/booking_service.dart';
import '../utils/app_constants.dart';
import '../widgets/shared_widgets.dart';
import 'girls_rooms_screen.dart';
import 'boys_rooms_screen.dart';
import 'room_details_screen.dart';

class HomeScreen extends StatelessWidget {
  final UserModel userModel;

  const HomeScreen({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    final isGirl = userModel.gender == 'Female';
    final rooms = isGirl ? AppConstants.girlsRooms : AppConstants.boysRooms;
    final bookingService = BookingService();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            JihcLogo(size: 30),
            SizedBox(width: 10),
            Text('JIHC Шай бөлмесі'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 18,
              backgroundImage: avatarImageProvider(userModel.photoUrl),
              child: userModel.photoUrl.isEmpty
                  ? Text(
                      userModel.fullName.isNotEmpty
                          ? userModel.fullName[0].toUpperCase()
                          : 'S',
                      style: const TextStyle(
                          color: AppConstants.accentColor,
                          fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Welcome banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[AppConstants.accentColor, Color(0xFF4040FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Сәлем, ${userModel.fullName.split(' ').first}! 👋',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  isGirl
                      ? 'Кешке арналған қыздар шай бөлмесін брондаңыз.'
                      : 'Кешке арналған шай бөлмесін брондаңыз.',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => isGirl
                          ? GirlsRoomsScreen(userModel: userModel)
                          : BoysRoomsScreen(userModel: userModel),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppConstants.accentColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Бөлмелерді қарау'),
                ),
              ],
            ),
          ),

          // Tea Rooms section
          SectionHeader(
              title: isGirl ? 'Қыздар шай бөлмелері 🍵' : 'Ұлдар шай бөлмелері 🍵'),
          StreamBuilder<Map<String, BookingModel>>(
            stream: bookingService.getRoomAvailabilityByRoomNames(rooms),
            builder: (context, snapshot) {
              final availability =
                  snapshot.data ?? const <String, BookingModel>{};
              final allRoomsBooked =
                  rooms.isNotEmpty && availability.length >= rooms.length;
              return Column(
                children: [
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
                ],
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
