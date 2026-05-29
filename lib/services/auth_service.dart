// lib/services/auth_service.dart
// Handles Firebase Authentication: email/password + Google Sign-In

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  // Get current Firebase user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Email/Password Registration ───────────────────────────────────────────
  Future<UserCredential?> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(fullName);
      await ensureCurrentUserDocument(
        fallbackName: fullName,
        fallbackEmail: email,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ─── Email/Password Login ───────────────────────────────────────────────────
  Future<UserCredential?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await ensureCurrentUserDocument(fallbackEmail: email);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ─── Google Sign-In ─────────────────────────────────────────────────────────
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleProvider = GoogleAuthProvider();
      final credential = await _auth.signInWithPopup(googleProvider);
      await ensureCurrentUserDocument();
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ─── Logout ─────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ─── Save/Get user in Firestore ─────────────────────────────────────────────
  Future<void> saveUserToFirestore(UserModel user) async {
    final firebaseUser = _requireCurrentUser();
    const collectionName = 'users';
    final docPath = 'users/${firebaseUser.uid}';
    final normalizedUser = UserModel(
      uid: firebaseUser.uid,
      fullName: user.fullName,
      email: user.email,
      gender: user.gender,
      photoUrl: user.photoUrl,
      isAdmin: user.isAdmin,
      createdAt: user.createdAt,
    );

    try {
      debugPrint('FIRESTORE WRITE PATH: $docPath');
      await _usersRef.doc(firebaseUser.uid).set(normalizedUser.toMap());
      debugPrint('USER SAVED TO FIRESTORE');
      _logWriteSuccess(
        collection: collectionName,
        documentId: firebaseUser.uid,
      );
    } catch (e, st) {
      _logWriteFailure(
        collection: collectionName,
        documentId: firebaseUser.uid,
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<UserModel?> getUserFromFirestore(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['uid'] ??= uid;
      final user = UserModel.fromMap(data);
      final authPhotoUrl = _auth.currentUser?.photoURL ?? '';
      if (user.photoUrl.isEmpty && authPhotoUrl.isNotEmpty) {
        return user.copyWith(photoUrl: authPhotoUrl);
      }
      return user;
    }
    return null;
  }

  Stream<UserModel> watchCurrentUserDocument({UserModel? fallbackUser}) async* {
    final firebaseUser = _requireCurrentUser();
    await ensureCurrentUserDocument(
      fallbackName: fallbackUser?.fullName,
      fallbackEmail: fallbackUser?.email,
      fallbackPhotoUrl: fallbackUser?.photoUrl,
      fallbackGender: fallbackUser?.gender ?? '',
    );

    yield* _usersRef.doc(firebaseUser.uid).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) {
        return fallbackUser ??
            UserModel(
              uid: firebaseUser.uid,
              fullName: firebaseUser.displayName ?? 'Student',
              email: firebaseUser.email ?? '',
              gender: '',
              photoUrl: firebaseUser.photoURL ?? '',
              createdAt: DateTime.now(),
            );
      }
      data['uid'] ??= firebaseUser.uid;
      final user = UserModel.fromMap(data);
      if (user.photoUrl.isEmpty && firebaseUser.photoURL != null) {
        return user.copyWith(photoUrl: firebaseUser.photoURL);
      }
      return user;
    });
  }

  Future<bool> userExistsInFirestore(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    return doc.exists;
  }

  Future<UserModel> getCurrentUserFromFirestore() async {
    _requireCurrentUser();
    return ensureCurrentUserDocument();
  }

  Future<UserModel> ensureCurrentUserDocument({
    String? fallbackName,
    String? fallbackEmail,
    String? fallbackPhotoUrl,
    String fallbackGender = '',
  }) async {
    final firebaseUser = _requireCurrentUser();
    final uid = firebaseUser.uid;
    final existingUser = await getUserFromFirestore(uid);
    final resolvedName = fallbackName ?? firebaseUser.displayName ?? 'Student';
    final resolvedEmail = fallbackEmail ?? firebaseUser.email ?? '';
    final resolvedPhotoUrl = _preferredPhotoUrl(
      firestorePhotoUrl: existingUser?.photoUrl ?? '',
      authPhotoUrl: firebaseUser.photoURL ?? '',
      overridePhotoUrl: fallbackPhotoUrl ?? '',
    );
    const collectionName = 'users';
    final docPath = 'users/$uid';

    if (existingUser != null) {
      try {
        debugPrint('FIRESTORE WRITE PATH: $docPath');
        await _usersRef.doc(uid).set({
          'uid': uid,
          'name':
              resolvedName.isNotEmpty ? resolvedName : existingUser.fullName,
          'fullName':
              resolvedName.isNotEmpty ? resolvedName : existingUser.fullName,
          'email':
              resolvedEmail.isNotEmpty ? resolvedEmail : existingUser.email,
          'photoUrl': resolvedPhotoUrl.isNotEmpty
              ? resolvedPhotoUrl
              : existingUser.photoUrl,
          'gender': existingUser.gender,
          'createdAt': existingUser.createdAt.toIso8601String(),
        }, SetOptions(merge: true));
        debugPrint('USER SAVED TO FIRESTORE');
        _logWriteSuccess(
          collection: collectionName,
          documentId: uid,
        );
      } catch (e, st) {
        _logWriteFailure(
          collection: collectionName,
          documentId: uid,
          error: e,
          stackTrace: st,
        );
        rethrow;
      }

      return UserModel(
        uid: uid,
        fullName:
            resolvedName.isNotEmpty ? resolvedName : existingUser.fullName,
        email: resolvedEmail.isNotEmpty ? resolvedEmail : existingUser.email,
        gender: existingUser.gender,
        photoUrl: resolvedPhotoUrl,
        isAdmin: existingUser.isAdmin,
        createdAt: existingUser.createdAt,
      );
    }

    final newUser = UserModel(
      uid: uid,
      fullName: resolvedName,
      email: resolvedEmail,
      photoUrl: resolvedPhotoUrl,
      gender: fallbackGender,
      createdAt: DateTime.now(),
    );

    try {
      debugPrint('FIRESTORE WRITE PATH: $docPath');
      await _usersRef.doc(uid).set(newUser.toMap());
      debugPrint('USER SAVED TO FIRESTORE');
      _logWriteSuccess(
        collection: collectionName,
        documentId: uid,
      );
    } catch (e, st) {
      _logWriteFailure(
        collection: collectionName,
        documentId: uid,
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
    return newUser;
  }

  // ─── Update profile ─────────────────────────────────────────────────────────
  Future<void> updateUserProfile(
    String uid,
    Map<String, dynamic> updates,
  ) async {
    final firebaseUser = _requireCurrentUser();
    const collectionName = 'users';
    final docPath = 'users/${firebaseUser.uid}';
    await ensureCurrentUserDocument();
    final normalizedUpdates = Map<String, dynamic>.from(updates);
    final fullName = normalizedUpdates['fullName'] ?? normalizedUpdates['name'];
    if (fullName != null) {
      normalizedUpdates['fullName'] = fullName;
      normalizedUpdates['name'] = fullName;
      await firebaseUser.updateDisplayName(fullName as String);
    }

    normalizedUpdates['uid'] = firebaseUser.uid;
    try {
      debugPrint('FIRESTORE WRITE PATH: $docPath');
      await _usersRef.doc(firebaseUser.uid).set(
        normalizedUpdates,
        SetOptions(merge: true),
      );
      debugPrint('USER SAVED TO FIRESTORE');
      _logWriteSuccess(
        collection: collectionName,
        documentId: firebaseUser.uid,
      );
    } catch (e, st) {
      _logWriteFailure(
        collection: collectionName,
        documentId: firebaseUser.uid,
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> updateProfilePhoto(String uid, String photoUrl) async {
    final firebaseUser = _requireCurrentUser();
    const collectionName = 'users';
    final docPath = 'users/${firebaseUser.uid}';
    try {
      await firebaseUser.updatePhotoURL(photoUrl);
    } catch (e) {
      debugPrint('AUTH PHOTO UPDATE FAILED: $e');
    }

    await ensureCurrentUserDocument(fallbackPhotoUrl: photoUrl);
    try {
      debugPrint('FIRESTORE WRITE PATH: $docPath');
      await _usersRef.doc(firebaseUser.uid).set({
        'uid': firebaseUser.uid,
        'photoUrl': photoUrl,
      }, SetOptions(merge: true));
      debugPrint('firestore photoUrl saved');
      debugPrint('USER SAVED TO FIRESTORE');
      _logWriteSuccess(
        collection: collectionName,
        documentId: firebaseUser.uid,
      );
    } catch (e, st) {
      _logWriteFailure(
        collection: collectionName,
        documentId: firebaseUser.uid,
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
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

  User _requireCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw 'No authenticated user found.';
    }
    return user;
  }

  String _preferredPhotoUrl({
    required String firestorePhotoUrl,
    required String authPhotoUrl,
    required String overridePhotoUrl,
  }) {
    if (overridePhotoUrl.isNotEmpty) {
      return overridePhotoUrl;
    }
    if (firestorePhotoUrl.isNotEmpty) {
      return firestorePhotoUrl;
    }
    return authPhotoUrl;
  }

  // ─── Error handling ─────────────────────────────────────────────────────────
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Authentication error occurred.';
    }
  }
}
