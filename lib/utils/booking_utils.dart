import 'package:intl/intl.dart';

class BookingTimeRange {
  final String startTime;
  final String endTime;
  final int startMinutes;
  final int endMinutes;

  const BookingTimeRange({
    required this.startTime,
    required this.endTime,
    required this.startMinutes,
    required this.endMinutes,
  });
}

class BookingUtils {
  static final DateFormat dateKeyFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat shortDateFormat = DateFormat('MMM d');
  static final DateFormat fullDateFormat = DateFormat('EEEE, MMM d, yyyy');
  static final DateFormat dayLabelFormat = DateFormat('EEE');
  static final DateFormat timeFormat = DateFormat('HH:mm');

  static BookingTimeRange parseTimeSlot(String timeSlot) {
    final normalized = timeSlot.replaceAll('–', '-');
    final parts = normalized.split('-');
    if (parts.length != 2) {
      return const BookingTimeRange(
        startTime: '19:00',
        endTime: '20:00',
        startMinutes: 19 * 60,
        endMinutes: 20 * 60,
      );
    }

    final startTime = parts[0].trim();
    final endTime = parts[1].trim();
    return BookingTimeRange(
      startTime: startTime,
      endTime: endTime,
      startMinutes: minutesFromTime(startTime),
      endMinutes: minutesFromTime(endTime),
    );
  }

  static int minutesFromTime(String time) {
    final parts = time.split(':');
    if (parts.length != 2) {
      return 0;
    }
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return hour * 60 + minute;
  }

  static String slotFromTimes(String startTime, String endTime) {
    return '$startTime–$endTime';
  }

  static DateTime parseDateKey(String dateKey) {
    return DateTime.tryParse(dateKey) ?? DateTime.now();
  }

  static String dateKeyFromDate(DateTime date) {
    return dateKeyFormat.format(date);
  }

  static DateTime combineDateAndMinutes(DateTime date, int minutes) {
    return DateTime(date.year, date.month, date.day)
        .add(Duration(minutes: minutes));
  }

  static String formatFullDate(DateTime date) {
    return fullDateFormat.format(date);
  }

  static String formatShortDate(DateTime date) {
    return shortDateFormat.format(date);
  }

  static String formatDayLabel(DateTime date) {
    return dayLabelFormat.format(date);
  }

  static String formatClock(DateTime dateTime) {
    return timeFormat.format(dateTime);
  }

  static bool overlaps({
    required int startMinutes,
    required int endMinutes,
    required int otherStartMinutes,
    required int otherEndMinutes,
  }) {
    return startMinutes < otherEndMinutes && endMinutes > otherStartMinutes;
  }
}
