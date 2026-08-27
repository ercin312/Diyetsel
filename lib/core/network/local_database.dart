import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalDatabase {
  LocalDatabase(this._box);

  final Box<String> _box;
  final _controller = StreamController<String>.broadcast();

  Stream<String> get changes => _controller.stream;

  Stream<String> watch(String collection) =>
      _controller.stream.where((event) => event == collection || event == '*');

  String _key(String collection, String id) => '$collection/$id';

  Map<String, dynamic>? get(String collection, String id) {
    final raw = _box.get(_key(collection, id));
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> put(String collection, String id, Map<String, dynamic> data) async {
    final payload = {...data, 'id': id};
    await _box.put(_key(collection, id), jsonEncode(payload));
    _controller.add(collection);
    unawaited(_syncCloud(collection, id, payload));
  }

  Future<void> delete(String collection, String id) async {
    await _box.delete(_key(collection, id));
    _controller.add(collection);
    if (Firebase.apps.isNotEmpty) {
      unawaited(FirebaseFirestore.instance.collection(collection).doc(id).delete());
    }
  }

  List<Map<String, dynamic>> list(String collection) {
    final prefix = '$collection/';
    return _box.keys
        .where((k) => k.toString().startsWith(prefix))
        .map((k) => jsonDecode(_box.get(k)!) as Map<String, dynamic>)
        .toList();
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
