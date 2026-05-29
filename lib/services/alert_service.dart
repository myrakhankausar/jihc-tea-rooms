import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/alert_model.dart';

class AlertService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _alertsRef =>
      _firestore.collection('alerts');

  String generateAlertId() {
    return _alertsRef.doc().id;
  }

  Future<void> createAlert(AlertModel alert) async {
    const collectionName = 'alerts';
    final docPath = 'alerts/${alert.alertId}';
    try {
      debugPrint('FIRESTORE WRITE PATH: $docPath');
      await _alertsRef.doc(alert.alertId).set(alert.toMap());
      debugPrint('ALERT SAVED TO FIRESTORE');
      _logWriteSuccess(
        collection: collectionName,
        documentId: alert.alertId,
      );
    } catch (e, st) {
      _logWriteFailure(
        collection: collectionName,
        documentId: alert.alertId,
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Stream<List<AlertModel>> getUserAlertsStream(String userId) {
    return _alertsRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
      final alerts =
          snap.docs.map((doc) => AlertModel.fromMap(doc.data())).toList();
      alerts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return alerts;
    });
  }

  Future<void> markAlertAsRead(String alertId) async {
    const collectionName = 'alerts';
    final docPath = 'alerts/$alertId';
    try {
      debugPrint('FIRESTORE WRITE PATH: $docPath');
      await _alertsRef.doc(alertId).set({
        'isRead': true,
      }, SetOptions(merge: true));
      debugPrint('ALERT SAVED TO FIRESTORE');
      _logWriteSuccess(
        collection: collectionName,
        documentId: alertId,
      );
    } catch (e, st) {
      _logWriteFailure(
        collection: collectionName,
        documentId: alertId,
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> deleteAlert(String alertId) async {
    await _alertsRef.doc(alertId).delete();
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
}
