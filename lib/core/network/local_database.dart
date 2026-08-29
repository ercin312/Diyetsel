import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';

/// Collections that stay on-device only (never pushed to / pulled from Firestore).
const Set<String> kLocalOnlyCollections = {
  FirestorePaths.credentials,
  'settings',
};

class LocalDatabase {
  LocalDatabase(this._box);

  final Box<String> _box;
  final _controller = StreamController<String>.broadcast();
  bool _applyingRemote = false;

  Stream<String> get changes => _controller.stream;

  Stream<String> watch(String collection) =>
      _controller.stream.where((event) => event == collection || event == '*');

  String _key(String collection, String id) => '$collection/$id';

  Map<String, dynamic>? get(String collection, String id) {
    final raw = _box.get(_key(collection, id));
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> put(
    String collection,
    String id,
    Map<String, dynamic> data, {
    bool syncCloud = true,
  }) async {
    final payload = {...data, 'id': id};
    final encoded = jsonEncode(payload);
    final previous = _box.get(_key(collection, id));
    if (previous == encoded) return;

    await _box.put(_key(collection, id), encoded);
    _controller.add(collection);
    if (syncCloud && !_applyingRemote && !kLocalOnlyCollections.contains(collection)) {
      unawaited(_syncCloud(collection, id, payload));
    }
  }

  /// Apply a remote Firestore document into Hive without echoing back to the cloud.
  Future<void> applyRemote(String collection, String id, Map<String, dynamic>? data) async {
    if (kLocalOnlyCollections.contains(collection)) return;
    _applyingRemote = true;
    try {
      if (data == null) {
        final key = _key(collection, id);
        if (_box.containsKey(key)) {
          await _box.delete(key);
          _controller.add(collection);
        }
        return;
      }
      final sanitized = _sanitizeForLocal(data);
      await put(collection, id, sanitized, syncCloud: false);
    } finally {
      _applyingRemote = false;
    }
  }

  Future<void> delete(String collection, String id, {bool syncCloud = true}) async {
    final key = _key(collection, id);
    if (!_box.containsKey(key)) return;
    await _box.delete(key);
    _controller.add(collection);
    if (syncCloud &&
        !_applyingRemote &&
        !kLocalOnlyCollections.contains(collection) &&
        Firebase.apps.isNotEmpty) {
      unawaited(() async {
        try {
          await FirebaseFirestore.instance.collection(collection).doc(id).delete();
        } catch (_) {}
      }());
    }
  }

  List<Map<String, dynamic>> list(String collection) {
    final prefix = '$collection/';
    return _box.keys
        .where((k) => k.toString().startsWith(prefix))
        .map((k) => jsonDecode(_box.get(k)!) as Map<String, dynamic>)
        .toList();
  }

  Map<String, dynamic> _sanitizeForLocal(Map<String, dynamic> data) {
    dynamic walk(dynamic value) {
      if (value is Timestamp) return value.toDate().toIso8601String();
      if (value is Map) {
        return value.map((k, v) => MapEntry('$k', walk(v)));
      }
      if (value is List) return value.map(walk).toList();
      return value;
    }

    return Map<String, dynamic>.from(walk(data) as Map);
  }

  Future<void> _syncCloud(String collection, String id, Map<String, dynamic> data) async {
    if (Firebase.apps.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection(collection).doc(id).set(data, SetOptions(merge: true));
    } catch (_) {}
  }
}

final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  throw StateError('LocalDatabase not initialized');
});

Future<LocalDatabase> openLocalDatabase() async {
  await Hive.initFlutter();
  final box = await Hive.openBox<String>('diyetsel_store');
  return LocalDatabase(box);
}
