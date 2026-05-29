// lib/services/storage_service.dart
// Firebase Storage: upload/download profile images

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload profile image and return download URL
  Future<String> uploadProfileImage(
    String userId,
    Uint8List imageBytes, {
    String contentType = 'image/jpeg',
  }) async {
    final extension = _fileExtensionForContentType(contentType);
    final ref = _storage
        .ref()
        .child('profile_images')
        .child(userId)
        .child('avatar_${DateTime.now().millisecondsSinceEpoch}.$extension');

    final uploadTask = await ref.putData(
      imageBytes,
      SettableMetadata(contentType: contentType),
    );

    final downloadUrl = await uploadTask.ref.getDownloadURL();
    debugPrint('storage upload success');
    return downloadUrl;
  }

  // Delete profile image
  Future<void> deleteProfileImage(String userId) async {
    try {
      final ref = _storage
          .ref()
          .child('profile_images')
          .child(userId)
          .child('profile.jpg');
      await ref.delete();
    } catch (_) {
      // Ignore if doesn't exist
    }
  }

  String imageBytesToDataUrl(
    Uint8List imageBytes, {
    String contentType = 'image/jpeg',
  }) {
    final encoded = base64Encode(imageBytes);
    return 'data:$contentType;base64,$encoded';
  }

  String _fileExtensionForContentType(String contentType) {
    switch (contentType) {
      case 'image/png':
        return 'png';
      case 'image/webp':
        return 'webp';
      case 'image/gif':
        return 'gif';
      default:
        return 'jpg';
    }
  }
}
