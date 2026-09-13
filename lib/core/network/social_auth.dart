import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../firebase_options.dart';

class SocialAuthCanceled implements Exception {
  const SocialAuthCanceled();
}

class SocialAuth {
  SocialAuth._();

  static bool _googleReady = false;
  static String? lastAppleDisplayName;

  static bool get googleAvailable {
    if (kIsWeb) return true;
    try {
      return !Platform.isWindows && !Platform.isLinux;
    } catch (_) {
      return false;
    }
  }

  static bool get appleAvailable {
    if (kIsWeb) return false;
    try {
      return Platform.isIOS || Platform.isMacOS;
    } catch (_) {
      return false;
    }
  }

  static Future<void> ensureInitialized() async {
    if (!googleAvailable || Firebase.apps.isEmpty) return;
    if (_googleReady) return;
    await GoogleSignIn.instance.initialize(
      clientId: defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS
          ? DefaultFirebaseOptions.ios.iosClientId
          : null,
      serverClientId: DefaultFirebaseOptions.googleWebClientId,
    );
    _googleReady = true;
  }

  static Future<UserCredential> signInWithGoogle() async {
    if (Firebase.apps.isEmpty) {
      throw StateError('Firebase bağlantısı yok');
    }
    await ensureInitialized();
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw StateError('Google ile giriş bu cihazda desteklenmiyor');
    }
    try {
      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile'],
      );
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw StateError('Google kimliği alınamadı');
      }
      return FirebaseAuth.instance.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const SocialAuthCanceled();
      }
      throw StateError(_googleMessage(e));
    } on FirebaseAuthException catch (e) {
      throw StateError(_firebaseMessage(e));
    }
  }

  static Future<UserCredential> signInWithApple() async {
    if (Firebase.apps.isEmpty) {
      throw StateError('Firebase bağlantısı yok');
    }
    if (!appleAvailable) {
      throw StateError('Apple ile giriş bu cihazda desteklenmiyor');
    }
    final rawNonce = _nonce();
    final hashed = sha256.convert(utf8.encode(rawNonce)).toString();
    try {
      final apple = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashed,
      );
      final given = apple.givenName?.trim() ?? '';
      final family = apple.familyName?.trim() ?? '';
      lastAppleDisplayName = [given, family].where((p) => p.isNotEmpty).join(' ');
      if (lastAppleDisplayName!.isEmpty) lastAppleDisplayName = null;

      final idToken = apple.identityToken;
      if (idToken == null || idToken.isEmpty) {
        throw StateError('Apple kimliği alınamadı');
      }
      return FirebaseAuth.instance.signInWithCredential(
        OAuthProvider('apple.com').credential(
          idToken: idToken,
          rawNonce: rawNonce,
        ),
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const SocialAuthCanceled();
      }
      throw StateError('Apple girişi başarısız: ${e.message}');
    } on FirebaseAuthException catch (e) {
      throw StateError(_firebaseMessage(e));
    }
  }

  static Future<void> signOut() async {
    try {
      if (_googleReady) await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }

  static String _nonce([int length = 32]) {
    const chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }

  static String _googleMessage(GoogleSignInException e) {
    switch (e.code) {
      case GoogleSignInExceptionCode.interrupted:
        return 'Google girişi yarıda kesildi';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'Google giriş ekranı açılamadı';
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'Google girişi yapılandırılmamış';
      default:
        return e.description ?? 'Google ile giriş başarısız';
    }
  }

  static String _firebaseMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'operation-not-allowed':
        return 'Bu giriş yöntemi Firebase’de henüz açık değil';
      case 'account-exists-with-different-credential':
        return 'Bu e-posta başka bir giriş yöntemiyle kayıtlı';
      case 'network-request-failed':
        return 'Ağ bağlantısı yok';
      case 'invalid-credential':
        return 'Kimlik doğrulama başarısız';
      case 'canceled':
      case 'web-context-cancelled':
        throw const SocialAuthCanceled();
      default:
        return e.message ?? 'Giriş başarısız';
    }
  }
}
