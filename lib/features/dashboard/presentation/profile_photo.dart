import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../auth/presentation/auth_controller.dart';
import '../../../core/l10n/ui_string.dart';

/// Lets the signed-in user replace their profile photo.
Future<void> pickProfilePhoto(BuildContext context, WidgetRef ref) async {
  final user = ref.read(authControllerProvider).user;
  if (user == null) return;

  final picked = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    imageQuality: 82,
    maxWidth: 960,
  );
  if (picked == null) return;

  try {
    final photoUrl = await _storePhoto(picked, user.id);
    await ref.read(authControllerProvider.notifier).updateProfile(
          user.copyWith(photoUrl: photoUrl),
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(('Profil fotoğrafı güncellendi.').ui)),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(('Fotoğraf yüklenemedi: $e').ui)),
      );
    }
  }
}

Future<String> _storePhoto(XFile picked, String userId) async {
  final bytes = await picked.readAsBytes();
  if (bytes.isEmpty) {
    throw StateError('Seçilen dosya boş');
  }
  if (Firebase.apps.isNotEmpty) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        final storageRef = FirebaseStorage.instance.ref('users/$uid/avatar.jpg');
        await storageRef
            .putData(
              bytes,
              SettableMetadata(contentType: 'image/jpeg'),
            )
            .timeout(const Duration(seconds: 12));
        return await storageRef.getDownloadURL().timeout(const Duration(seconds: 8));
      } catch (e) {
        debugPrint('Profil fotoğrafı buluta yazılamadı: $e');
      }
    }
  }
  if (bytes.length <= 450000) {
    return 'data:image/jpeg;base64,${base64Encode(bytes)}';
  }
  final dir = await getApplicationDocumentsDirectory();
  final dest = File('${dir.path}/avatar_$userId.jpg');
  await dest.writeAsBytes(bytes, flush: true);
  return dest.path;
}
