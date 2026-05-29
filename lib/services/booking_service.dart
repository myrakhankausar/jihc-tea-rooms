import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/alert_model.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import 'alert_service.dart';
import '../utils/booking_utils.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AlertService _alertService = AlertService();
  final String _collection = 'bookings';
  final String _roomAvailabilityCollection = 'room_availability';

  CollectionReference<Map<String, dynamic>> get _bookingsRef =>
      _firestore.collection(_collection);
  CollectionReference<Map<String, dynamic>> get _roomAvailabilityRef =>
      _firestore.collection(_roomAvailabilityCollection);

  Future<void> createBooking(BookingModel booking) async {
    const collectionName = 'bookings';
    final docPath = 'bookings/${booking.bookingId}';
    try {
      await _ensureNoOverlap(
        roomName: booking.roomName,
        dateKey: booking.date,
        startMinutes: booking.startMinutes,
        endMinutes: booking.endMinutes,
      );

      final batch = _firestore.batch();
      debugPrint('FIRESTORE WRITE PATH: $docPath');
      batch.set(_bookingsRef.doc(booking.bookingId), booking.toMap());
      batch.set(
        _roomAvailabilityRef.doc(booking.bookingId),
        _publicAvailabilityMap(booking),
      );
      await batch.commit();
      debugPrint('BOOKING SAVED TO FIRESTORE');
      _logWriteSuccess(
        collection: collectionName,
        documentId: booking.bookingId,
      );
    } catch (e, st) {
      _logWriteFailure(
        collection: collectionName,
        documentId: booking.bookingId,
        error: e,
        stackTrace: st,
      );
      rethrow;
    }

    final alertId = _alertService.generateAlertId();
    await _alertService.createAlert(
      AlertModel(
        alertId: alertId,
        userId: booking.userId,
        title: 'Booking Confirmed',
        message:
            'Your booking for ${booking.roomName} on ${booking.date} from ${booking.startTime} to ${booking.endTime} was created.',
        bookingId: booking.bookingId,
        type: 'booking_created',
        createdAt: DateTime.now(),
      ),
    );
  }

  Stream<List<BookingModel>> getAllBookingsStream() {
    return _bookingsRef.snapshots().map(_mapAndSortBookings);
  }

  Stream<List<BookingModel>> getRoomBookingsStream(String roomName) {
    return _roomAvailabilityRef
        .where('roomName', isEqualTo: roomName)
        .snapshots()
        .map(_mapAndSortPublicBookings)
        .map((bookings) =>
            bookings.where((booking) => booking.status == 'active').toList());
  }

  Stream<Map<String, BookingModel>> getRoomAvailabilityByRoomNames(
      List<String> roomNames) {
    return _roomAvailabilityRef.snapshots().map((snap) {
      final bookings = snap.docs
          .map((doc) => _mapPublicAvailabilityDoc(doc.data()))
          .where((booking) =>
              booking.status == 'active' && roomNames.contains(booking.roomName))
          .toList();
      final availability = <String, BookingModel>{};
      for (final booking in _sortBookings(bookings)) {
        availability.putIfAbsent(booking.roomName, () => booking);
      }
      return availability;
    });
  }

  Stream<List<BookingModel>> getUserBookingsStream(String userId) {
    return _bookingsRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(_mapAndSortBookings);
  }

  Future<bool> isSlotAvailable({
    required String roomName,
    required String date,
    required String timeSlot,
    String? excludeBookingId,
  }) async {
    final range = BookingUtils.parseTimeSlot(timeSlot);
    final snap = await _roomAvailabilityRef
        .where('roomName', isEqualTo: roomName)
        .where('bookingDate', isEqualTo: date)
        .get();

    for (final doc in snap.docs) {
      final booking = _mapPublicAvailabilityDoc(doc.data());
      if (booking.bookingId == excludeBookingId) {
        continue;
      }
      if (booking.status == 'cancelled') {
        continue;
      }
      if (BookingUtils.overlaps(
        startMinutes: range.startMinutes,
        endMinutes: range.endMinutes,
        otherStartMinutes: booking.startMinutes,
        otherEndMinutes: booking.endMinutes,
      )) {
        return false;
      }
    }

    return true;
  }

  Future<void> updateBooking(BookingModel booking) async {
    const collectionName = 'bookings';
    final docPath = 'bookings/${booking.bookingId}';
    try {
      await _ensureNoOverlap(
        roomName: booking.roomName,
        dateKey: booking.date,
        startMinutes: booking.startMinutes,
        endMinutes: booking.endMinutes,
        excludeBookingId: booking.bookingId,
      );

      final batch = _firestore.batch();
      debugPrint('FIRESTORE WRITE PATH: $docPath');
      batch.update(
        _bookingsRef.doc(booking.bookingId),
        booking.copyWith().toMap(),
      );
      batch.set(
        _roomAvailabilityRef.doc(booking.bookingId),
        _publicAvailabilityMap(booking),
      );
      await batch.commit();
      _logWriteSuccess(
        collection: collectionName,
        documentId: booking.bookingId,
      );
    } catch (e, st) {
      _logWriteFailure(
        collection: collectionName,
        documentId: booking.bookingId,
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> updateBookingFields(
    String bookingId,
    Map<String, dynamic> updates, {
    BookingModel? currentBooking,
  }) async {
    final existing = currentBooking ?? await getBooking(bookingId);
    if (existing == null) {
      return;
    }

    final nextTimeSlot = updates['timeSlot'] ?? existing.timeSlot;
    final nextDate = updates['date'] ?? existing.date;
    final range = BookingUtils.parseTimeSlot(nextTimeSlot);

    final updated = existing.copyWith(
      userName: updates['userName'],
      userPhotoUrl: updates['userPhotoUrl'],
      roomName: updates['roomName'],
      date: nextDate,
      timeSlot: nextTimeSlot,
      startTime: updates['startTime'] ?? range.startTime,
      endTime: updates['endTime'] ?? range.endTime,
      startMinutes: updates['startMinutes'] ?? range.startMinutes,
      endMinutes: updates['endMinutes'] ?? range.endMinutes,
      purpose: updates['purpose'],
      status: updates['status'],
      cancelledByUserId: updates['cancelledByUserId'],
      cancelledByUserName: updates['cancelledByUserName'],
      cancelledAt: updates['cancelledAt'],
    );

    await updateBooking(updated);
  }

  Future<void> cancelBooking({
    required String bookingId,
    required UserModel actor,
  }) async {
    final booking = await getBooking(bookingId);
    if (booking == null) {
      throw Exception('Booking not found.');
    }

    const collectionName = 'bookings';
    final docPath = 'bookings/$bookingId';
    final cancelledAt = DateTime.now();
    try {
      final batch = _firestore.batch();
      debugPrint('FIRESTORE WRITE PATH: $docPath');
      batch.update(_bookingsRef.doc(bookingId), {
        'status': 'cancelled',
        'cancelledAt': cancelledAt.toIso8601String(),
        'cancelledByUserId': actor.uid,
        'cancelledByUserName': actor.fullName,
        'updatedAt': cancelledAt.toIso8601String(),
      });
      batch.delete(_roomAvailabilityRef.doc(bookingId));
      await batch.commit();
      debugPrint('BOOKING SAVED TO FIRESTORE');
      _logWriteSuccess(
        collection: collectionName,
        documentId: bookingId,
      );
    } catch (e, st) {
      _logWriteFailure(
        collection: collectionName,
        documentId: bookingId,
        error: e,
        stackTrace: st,
      );
      rethrow;
    }

    final alertId = _alertService.generateAlertId();
    await _alertService.createAlert(
      AlertModel(
        alertId: alertId,
        userId: booking.userId,
        title: 'Booking Cancelled',
        message:
            'Your booking for ${booking.roomName} on ${booking.date} from ${booking.startTime} to ${booking.endTime} was cancelled.',
        bookingId: booking.bookingId,
        type: 'booking_cancelled',
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> deleteBooking(String bookingId) async {
    final batch = _firestore.batch();
    batch.delete(_bookingsRef.doc(bookingId));
    batch.delete(_roomAvailabilityRef.doc(bookingId));
    await batch.commit();
  }

  void _logWriteSuccess({
    required String collection,
    required String documentId,
  }) {
    debugPrint(
      'SUCCESS:\ncollection name: $collection\ndocument id: $documentId',
    );
    debugPrint('FIRESTORE WRITE SUCCESS');
  }

  void _logWriteFailure({
    required String collection,
    required String documentId,
    required Object error,
    required StackTrace stackTrace,
  }) {
    final message = error is FirebaseException
        ? 'FirebaseException(code: ${error.code}, message: ${error.message}, plugin: ${error.plugin})'
        : error.toString();
    debugPrint(
      'ERROR:\ncollection name: $collection\ndocument id: $documentId\nfull Firebase exception message: $message\nstack trace: $stackTrace',
    );
    debugPrint('FIRESTORE WRITE FAILED: $message');
  }

  Future<BookingModel?> getBooking(String bookingId) async {
    final doc = await _bookingsRef.doc(bookingId).get();
    if (doc.exists) {
      return BookingModel.fromMap(doc.data()!);
    }
    return null;
  }

  String generateBookingId() {
    return _bookingsRef.doc().id;
  }

  List<BookingModel> _mapAndSortBookings(
      QuerySnapshot<Map<String, dynamic>> snap) {
    final bookings =
        snap.docs.map((doc) => BookingModel.fromMap(doc.data())).toList();
    return _sortBookings(bookings);
  }

  List<BookingModel> _mapAndSortPublicBookings(
      QuerySnapshot<Map<String, dynamic>> snap) {
    final bookings =
        snap.docs.map((doc) => _mapPublicAvailabilityDoc(doc.data())).toList();
    return _sortBookings(bookings);
  }

  List<BookingModel> _sortBookings(List<BookingModel> bookings) {
    bookings.sort((a, b) {
      final dateCompare = a.startDateTime.compareTo(b.startDateTime);
      if (dateCompare != 0) {
        return dateCompare;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    return bookings;
  }

  Future<void> _ensureNoOverlap({
    required String roomName,
    required String dateKey,
    required int startMinutes,
    required int endMinutes,
    String? excludeBookingId,
  }) async {
    final query = _roomAvailabilityRef
        .where('roomName', isEqualTo: roomName)
        .where('bookingDate', isEqualTo: dateKey);
    final snap = await query.get();

    for (final doc in snap.docs) {
      final booking = _mapPublicAvailabilityDoc(doc.data());
      if (booking.bookingId == excludeBookingId) {
        continue;
      }
      if (booking.status == 'cancelled') {
        continue;
      }
      if (BookingUtils.overlaps(
        startMinutes: startMinutes,
        endMinutes: endMinutes,
        otherStartMinutes: booking.startMinutes,
        otherEndMinutes: booking.endMinutes,
      )) {
        throw Exception('This room is already booked for that time.');
      }
    }
  }

  Map<String, dynamic> _publicAvailabilityMap(BookingModel booking) {
    return {
      'bookingId': booking.bookingId,
      'ownerId': booking.userId,
      'ownerName': booking.userName,
      'ownerPhotoUrl': booking.userPhotoUrl,
      'roomId': booking.roomId,
      'roomName': booking.roomName,
      'bookingDate': booking.date,
      'timeSlot': booking.timeSlot,
      'startTime': booking.startTime,
      'endTime': booking.endTime,
      'startMinutes': booking.startMinutes,
      'endMinutes': booking.endMinutes,
      'status': booking.status,
      'createdAt': booking.createdAt.toIso8601String(),
      'updatedAt': booking.updatedAt.toIso8601String(),
    };
  }

  BookingModel _mapPublicAvailabilityDoc(Map<String, dynamic> map) {
    final rawTimeSlot = map['timeSlot'] ?? '19:00–20:00';
    final range = BookingUtils.parseTimeSlot(rawTimeSlot);
    final bookingDate = map['bookingDate'] ?? map['date'] ?? '';
    return BookingModel(
      bookingId: map['bookingId'] ?? '',
      userId: map['ownerId'] ?? '',
      roomId: map['roomId'] ?? '',
      userName: map['ownerName'] ?? 'Reserved Slot',
      userPhotoUrl: map['ownerPhotoUrl'] ?? '',
      gender: '',
      roomName: map['roomName'] ?? '',
      date: bookingDate,
      timeSlot: map['timeSlot'] ?? rawTimeSlot,
      startTime: map['startTime'] ?? range.startTime,
      endTime: map['endTime'] ?? range.endTime,
      startMinutes: map['startMinutes'] ?? range.startMinutes,
      endMinutes: map['endMinutes'] ?? range.endMinutes,
      purpose:
          'Booked by ${map['ownerName'] ?? 'another student'} for this time slot.',
      status: (map['status'] ?? 'active').toString(),
      cancelledAt: null,
      cancelledByUserId: '',
      cancelledByUserName: '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }
}
