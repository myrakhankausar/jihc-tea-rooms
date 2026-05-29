// lib/models/alert_model.dart
// Data model for Firestore alerts

class AlertModel {
  final String alertId;
  final String userId;
  final String title;
  final String message;
  final String bookingId;
  final String type;
  final DateTime createdAt;
  final bool isRead;

  AlertModel({
    required this.alertId,
    required this.userId,
    required this.title,
    required this.message,
    required this.bookingId,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'alertId': alertId,
      'userId': userId,
      'title': title,
      'message': message,
      'bookingId': bookingId,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory AlertModel.fromMap(Map<String, dynamic> map) {
    return AlertModel(
      alertId: map['alertId'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      bookingId: map['bookingId'] ?? '',
      type: map['type'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }

  AlertModel copyWith({
    String? title,
    String? message,
    String? type,
    bool? isRead,
  }) {
    return AlertModel(
      alertId: alertId,
      userId: userId,
      title: title ?? this.title,
      message: message ?? this.message,
      bookingId: bookingId,
      type: type ?? this.type,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
