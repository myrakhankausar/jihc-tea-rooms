// lib/models/user_model.dart
// Data model for a JIHC app user

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String gender; // 'Female' or 'Male'
  final String photoUrl;
  final bool isAdmin;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.gender,
    this.photoUrl = '',
    this.isAdmin = false,
    required this.createdAt,
  });

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': fullName,
      'fullName': fullName,
      'email': email,
      'gender': gender,
      'photoUrl': photoUrl,
      'isAdmin': isAdmin,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Firestore map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? map['name'] ?? '',
      email: map['email'] ?? '',
      gender: map['gender'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  // Copy with changes
  UserModel copyWith({
    String? fullName,
    String? email,
    String? gender,
    String? photoUrl,
    bool? isAdmin,
  }) {
    return UserModel(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt,
    );
  }
}
