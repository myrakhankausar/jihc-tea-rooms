// lib/screens/upload_photo_screen.dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../utils/app_constants.dart';
import '../widgets/shared_widgets.dart';

class UploadPhotoScreen extends StatefulWidget {
  final UserModel userModel;
  final Function(String) onPhotoUploaded;

  const UploadPhotoScreen(
      {super.key, required this.userModel, required this.onPhotoUploaded});

  @override
  State<UploadPhotoScreen> createState() => _UploadPhotoScreenState();
}

class _UploadPhotoScreenState extends State<UploadPhotoScreen> {
  Uint8List? _imageBytes;
  String _selectedContentType = 'image/jpeg';
  bool _isUploading = false;
  bool _isPicking = false;
  final _picker = ImagePicker();

  Future<void> _pick(ImageSource source) async {
    if (_isPicking || _isUploading) return;

    setState(() {
      _isPicking = true;
    });

    try {
      final effectiveSource = kIsWeb ? ImageSource.gallery : source;
      final picked = await _picker.pickImage(
        source: effectiveSource,
        maxWidth: 800,
        imageQuality: 80,
      );

      if (picked == null) {
        debugPrint('image selection cancelled');
        return;
      }

      debugPrint('image selected');

      final bytes = await picked.readAsBytes();
      if (!mounted) return;

      setState(() {
        _imageBytes = bytes;
        _selectedContentType = picked.mimeType ?? 'image/jpeg';
      });

      debugPrint('avatar preview updated');
    } catch (e) {
      debugPrint('image selection failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Қате: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }

  Future<void> _upload() async {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Фото таңдалмады')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      debugPrint('avatar upload started');
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final storageService = StorageService();
      late final String finalPhotoUrl;

      try {
        finalPhotoUrl = await storageService
            .uploadProfileImage(
              uid,
              _imageBytes!,
              contentType: _selectedContentType,
            )
            .timeout(const Duration(seconds: 15));
      } on TimeoutException {
        finalPhotoUrl = storageService.imageBytesToDataUrl(
          _imageBytes!,
          contentType: _selectedContentType,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Firebase Storage timed out. Saved fallback avatar instead.',
              ),
            ),
          );
        }
      } catch (e) {
        debugPrint('avatar upload failed with error: $e');
        finalPhotoUrl = storageService.imageBytesToDataUrl(
          _imageBytes!,
          contentType: _selectedContentType,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Firebase Storage failed. Saved fallback avatar instead: $e',
              ),
            ),
          );
        }
      }

      await AuthService()
          .updateProfilePhoto(uid, finalPhotoUrl)
          .timeout(const Duration(seconds: 15));

      if (mounted) {
        setState(() {
          _isUploading = false;
          _isPicking = false;
        });
      }

      widget.onPhotoUploaded(finalPhotoUrl);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Фото жүктелді'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint('avatar upload failed with error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Avatar upload failed with error: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider<Object>? currentPhotoProvider =
        avatarImageProvider(widget.userModel.photoUrl);

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль фотосын жүктеу')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 80,
              backgroundColor: AppConstants.lightBlue,
              backgroundImage: _imageBytes != null
                  ? MemoryImage(_imageBytes!)
                  : currentPhotoProvider,
              child: _imageBytes == null && currentPhotoProvider == null
                  ? const Icon(
                      Icons.person,
                      size: 80,
                      color: AppConstants.accentColor,
                    )
                  : null,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isPicking || _isUploading
                        ? null
                        : () => _pick(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Камера'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConstants.accentColor,
                      side: const BorderSide(color: AppConstants.accentColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isPicking || _isUploading
                        ? null
                        : () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Галерея'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConstants.accentColor,
                      side: const BorderSide(color: AppConstants.accentColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            if (_isPicking) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              const Text('Файл таңдау терезесі ашылуда...'),
            ],
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Фотоны жүктеу',
              onPressed: _isPicking || _isUploading ? null : _upload,
              isLoading: _isUploading,
            ),
          ],
        ),
      ),
    );
  }
}
