import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import 'local_database.dart';

/// Shared clinic collections mirrored between devices via Firestore.
const List<String> kSyncedCollections = [
  FirestorePaths.users,
  FirestorePaths.appointments,
  FirestorePaths.availability,
  FirestorePaths.services,
  FirestorePaths.serviceRequests,
  FirestorePaths.dietPlans,
  FirestorePaths.waterLogs,
  FirestorePaths.measurements,
  FirestorePaths.mealLogs,
  FirestorePaths.blogPosts,
  FirestorePaths.blogInteractions,
  FirestorePaths.recipes,
  FirestorePaths.recipeInteractions,
  FirestorePaths.chats,
  FirestorePaths.messages,
  FirestorePaths.documents,
  FirestorePaths.payments,
  FirestorePaths.shoppingLists,
  FirestorePaths.prefs,
  FirestorePaths.streaks,
  FirestorePaths.checkIns,
  FirestorePaths.fasting,
  FirestorePaths.userProgress,
  FirestorePaths.adminBroadcasts,
  'home_theme',
];

class CloudSyncService {
  CloudSyncService(this._db);

  final LocalDatabase _db;
  final List<StreamSubscription<QuerySnapshot<Map<String, dynamic>>>> _subs = [];
  bool _active = false;
  String? _uid;

  bool get isActive => _active;

  Future<void> start() async {
    if (Firebase.apps.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await stop();
      return;
    }
    if (_active && _uid == user.uid) return;

    await stop();
    _uid = user.uid;
    _active = true;

    // Pull remote first so a stale local seed cannot overwrite newer clinic data.
    await _hydrateOnce();

    // First device in an empty project uploads the local seed once.
    if (await _cloudLooksEmpty()) {
      await pushLocalSnapshot();
    }

    final firestore = FirebaseFirestore.instance;
    for (final collection in kSyncedCollections) {
      final sub = firestore.collection(collection).snapshots().listen(
        (snap) => _onSnapshot(collection, snap),
        onError: (Object e, StackTrace st) {
          debugPrint('CloudSync[$collection]: $e');
        },
      );
      _subs.add(sub);
    }
  }

  Future<bool> _cloudLooksEmpty() async {
    try {
      // Auth mirror writes users/{uid} before sync starts; clinic seed lives in services.
      final snap =
          await FirebaseFirestore.instance.collection(FirestorePaths.services).limit(1).get();
      return snap.docs.isEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> stop() async {
    for (final sub in _subs) {
      await sub.cancel();
    }
    _subs.clear();
    _active = false;
    _uid = null;
  }

  /// Push every local synced doc once (after login) so seed/demo data reaches the cloud.
  Future<void> pushLocalSnapshot() async {
    if (Firebase.apps.isEmpty || FirebaseAuth.instance.currentUser == null) return;
    final firestore = FirebaseFirestore.instance;
    for (final collection in kSyncedCollections) {
      for (final doc in _db.list(collection)) {
        final id = doc['id']?.toString();
        if (id == null || id.isEmpty) continue;
        try {
          await firestore.collection(collection).doc(id).set(doc, SetOptions(merge: true));
        } catch (e) {
          debugPrint('CloudSync push[$collection/$id]: $e');
        }
      }
    }
  }

  Future<void> _hydrateOnce() async {
    final firestore = FirebaseFirestore.instance;
    for (final collection in kSyncedCollections) {
      try {
        final snap = await firestore.collection(collection).get();
        for (final doc in snap.docs) {
          await _db.applyRemote(collection, doc.id, doc.data());
        }
      } catch (e) {
        debugPrint('CloudSync hydrate[$collection]: $e');
      }
    }
  }

  Future<void> _onSnapshot(
    String collection,
    QuerySnapshot<Map<String, dynamic>> snap,
  ) async {
    for (final change in snap.docChanges) {
      switch (change.type) {
        case DocumentChangeType.added:
        case DocumentChangeType.modified:
          await _db.applyRemote(collection, change.doc.id, change.doc.data());
        case DocumentChangeType.removed:
          await _db.applyRemote(collection, change.doc.id, null);
      }
    }
  }
}

final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  final db = ref.watch(localDatabaseProvider);
  final service = CloudSyncService(db);
  ref.onDispose(() => unawaited(service.stop()));
  return service;
});
