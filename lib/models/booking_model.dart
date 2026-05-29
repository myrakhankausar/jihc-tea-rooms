// lib/models/booking_model.dart
// Data model for a tea room booking

import '../utils/booking_utils.dart';

enum BookingStatus {
  active,
  completed,
  cancelled,
}

class BookingModel {
  final String bookingId;
  final String userId;
  final String roomId;
  final String userName;
  final String userPhotoUrl;
  final String gender;
  final String roomName;
  final String date; // ISO date key: "2026-05-28"
  final String timeSlot;
  final String startTime;
  final String endTime;
  final int startMinutes;
  final int endMinutes;
  final String purpose;
  final String status; // 'active' or 'cancelled'
  final DateTime? cancelledAt;
  final String cancelledByUserId;
  final String cancelledByUserName;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookingModel({
    required this.bookingId,
    required this.userId,
    required this.roomId,
    required this.userName,
    this.userPhotoUrl = '',
    required this.gender,
    required this.roomName,
    required this.date,
    required this.timeSlot,
    required this.startTime,
    required this.endTime,
    required this.startMinutes,
    required this.endMinutes,
    required this.purpose,
    this.status = 'active',
    this.cancelledAt,
    this.cancelledByUserId = '',
    this.cancelledByUserName = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingModel.create({
    required String bookingId,
    required String userId,
    required String userName,
    required String userPhotoUrl,
    required String gender,
    String? roomId,
    required String roomName,
    required DateTime bookingDate,
    required String timeSlot,
    required String purpose,
  }) {
    final range = BookingUtils.parseTimeSlot(timeSlot);
    final now = DateTime.now();
    return BookingModel(
      bookingId: bookingId,
      userId: userId,
      roomId: roomId ?? _roomIdFromName(roomName),
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      gender: gender,
      roomName: roomName,
      date: BookingUtils.dateKeyFromDate(bookingDate),
      timeSlot: BookingUtils.slotFromTimes(range.startTime, range.endTime),
      startTime: range.startTime,
      endTime: range.endTime,
      startMinutes: range.startMinutes,
      endMinutes: range.endMinutes,
      purpose: purpose,
      createdAt: now,
      updatedAt: now,
    );
  }

  DateTime get bookingDate => BookingUtils.parseDateKey(date);

  DateTime get startDateTime =>
      BookingUtils.combineDateAndMinutes(bookingDate, startMinutes);

  DateTime get endDateTime =>
      BookingUtils.combineDateAndMinutes(bookingDate, endMinutes);

  BookingStatus get displayStatus {
    if (status == 'cancelled') {
      return BookingStatus.cancelled;
    }
    if (endDateTime.isBefore(DateTime.now())) {
      return BookingStatus.completed;
    }
    return BookingStatus.active;
  }

  bool get isUpcoming => displayStatus == BookingStatus.active;

  bool get isPast =>
      displayStatus == BookingStatus.completed ||
      displayStatus == BookingStatus.cancelled;

  String get timelineTimeLabel => '$startTime - $endTime';

  String get dateLabel => BookingUtils.formatFullDate(bookingDate);

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'roomId': roomId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'gender': gender,
      'roomName': roomName,
      'bookingDate': date,
      'date': date,
      'timeSlot': timeSlot,
      'startTime': startTime,
      'endTime': endTime,
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
      'purpose': purpose,
      'status': status,
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancelledByUserId': cancelledByUserId,
      'cancelledByUserName': cancelledByUserName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from Firestore map
  factory BookingModel.fromMap(Map<String, dynamic> map) {
    final rawTimeSlot = map['timeSlot'] ?? '19:00–20:00';
    final range = BookingUtils.parseTimeSlot(rawTimeSlot);
    return BookingModel(
      bookingId: map['bookingId'] ?? '',
      userId: map['userId'] ?? '',
      roomId: map['roomId'] ?? _roomIdFromName(map['roomName'] ?? ''),
      userName: map['userName'] ?? '',
      userPhotoUrl: map['userPhotoUrl'] ?? '',
      gender: map['gender'] ?? '',
      roomName: map['roomName'] ?? '',
      date: map['date'] ?? map['bookingDate'] ?? '',
      timeSlot: map['timeSlot'] ?? rawTimeSlot,
      startTime: map['startTime'] ?? range.startTime,
      endTime: map['endTime'] ?? range.endTime,
      startMinutes: map['startMinutes'] ?? range.startMinutes,
      endMinutes: map['endMinutes'] ?? range.endMinutes,
      purpose: map['purpose'] ?? '',
      status: _normalizeStatus(map['status']),
      cancelledAt: map['cancelledAt'] != null
          ? DateTime.tryParse(map['cancelledAt'])
          : null,
      cancelledByUserId: map['cancelledByUserId'] ?? '',
      cancelledByUserName: map['cancelledByUserName'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }

  // Copy with changes for edit
  BookingModel copyWith({
    String? userName,
    String? userPhotoUrl,
    String? roomName,
    String? date,
    String? timeSlot,
    String? startTime,
    String? endTime,
    int? startMinutes,
    int? endMinutes,
    String? purpose,
    String? status,
    DateTime? cancelledAt,
    String? cancelledByUserId,
    String? cancelledByUserName,
  }) {
    final nextTimeSlot = timeSlot ?? this.timeSlot;
    final parsed = BookingUtils.parseTimeSlot(nextTimeSlot);
    return BookingModel(
      bookingId: bookingId,
      userId: userId,
      roomId: roomId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      gender: gender,
      roomName: roomName ?? this.roomName,
      date: date ?? this.date,
      timeSlot: nextTimeSlot,
      startTime: startTime ?? parsed.startTime,
      endTime: endTime ?? parsed.endTime,
      startMinutes: startMinutes ?? parsed.startMinutes,
      endMinutes: endMinutes ?? parsed.endMinutes,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelledByUserId: cancelledByUserId ?? this.cancelledByUserId,
      cancelledByUserName: cancelledByUserName ?? this.cancelledByUserName,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  static String _normalizeStatus(dynamic rawStatus) {
    switch (rawStatus) {
      case 'cancelled':
        return 'cancelled';
      case 'booked':
      case 'active':
      default:
        return 'active';
    }
  }

  static String _roomIdFromName(String roomName) {
    final normalized = roomName.trim().toLowerCase();
    if (normalized.isEmpty) {
      return '';
    }
    return normalized.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  }
}
