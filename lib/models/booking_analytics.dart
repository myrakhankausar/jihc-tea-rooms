import 'booking_model.dart';

class BookingAnalytics {
  final int totalBookings;
  final String mostBookedRoom;
  final String busiestDay;
  final int upcomingCount;
  final int pastCount;

  const BookingAnalytics({
    required this.totalBookings,
    required this.mostBookedRoom,
    required this.busiestDay,
    required this.upcomingCount,
    required this.pastCount,
  });

  factory BookingAnalytics.fromBookings(List<BookingModel> bookings) {
    final activeBookings = bookings
        .where((booking) => booking.displayStatus != BookingStatus.cancelled)
        .toList();

    final roomCounts = <String, int>{};
    final dayCounts = <String, int>{};
    var upcoming = 0;
    var past = 0;

    for (final booking in activeBookings) {
      roomCounts.update(booking.roomName, (count) => count + 1,
          ifAbsent: () => 1);
      dayCounts.update(booking.dateLabel, (count) => count + 1,
          ifAbsent: () => 1);
      if (booking.isUpcoming) {
        upcoming++;
      } else {
        past++;
      }
    }

    String pickLeader(Map<String, int> counts, String fallback) {
      if (counts.isEmpty) {
        return fallback;
      }

      final sorted = counts.entries.toList()
        ..sort((a, b) {
          final compareCount = b.value.compareTo(a.value);
          if (compareCount != 0) {
            return compareCount;
          }
          return a.key.compareTo(b.key);
        });
      return sorted.first.key;
    }

    return BookingAnalytics(
      totalBookings: activeBookings.length,
      mostBookedRoom: pickLeader(roomCounts, 'No data yet'),
      busiestDay: pickLeader(dayCounts, 'No data yet'),
      upcomingCount: upcoming,
      pastCount: past,
    );
  }
}
