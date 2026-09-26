import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/app_store.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/models.dart';
import '../../../core/network/cloud_sync_service.dart';
import '../../../core/network/social_auth.dart';
import '../../../core/utils/smart_notification_service.dart';

class AuthState {
  const AuthState({this.user, this.loading = false, this.error});

  final UserProfile? user;
  final bool loading;
  final String? error;

  bool get isLoggedIn => user != null;
  bool get isAdmin => user?.isAdmin ?? false;
}

class AuthController extends Notifier<AuthState> {
  bool _pushBound = false;

  @override
  AuthState build() {
    final store = ref.watch(appStoreProvider);
    final id = store.settings().sessionUserId;
    // Resume cloud sync if a session is already restored.
    if (id != null && store.user(id) != null) {
      Future.microtask(() async {
        await _startSync();
        final current = store.user(id);
        if (current != null) {
          state = AuthState(user: current);
          await _bindPushToken(current);
        }
      });
    }
    return AuthState(user: id == null ? null : store.user(id));
  }

  Future<void> login(String email, String password) async {
    state = AuthState(user: state.user, loading: true);
    try {
      final user = await ref.read(appStoreProvider).login(email.trim(), password);
      await _setSession(user);
    } catch (e) {
      state = AuthState(error: e.toString().replaceAll('Bad state: ', ''));
    }
  }

  Future<void> loginWithGoogle() =>
      _social(() => ref.read(appStoreProvider).loginWithGoogle());

  Future<void> loginWithApple() =>
      _social(() => ref.read(appStoreProvider).loginWithApple());

  Future<void> _social(Future<UserProfile> Function() run) async {
    state = AuthState(user: state.user, loading: true);
    try {
      final user = await run();
      await _setSession(user);
    } on SocialAuthCanceled {
      state = AuthState(user: state.user);
    } catch (e) {
      state = AuthState(error: e.toString().replaceAll('Bad state: ', ''));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required bool asAdmin,
  }) async {
    state = const AuthState(loading: true);
    try {
      final store = ref.read(appStoreProvider);
      final role = asAdmin && !store.hasAdmin ? UserRole.admin : UserRole.client;
      final user = await store.register(
        email: email.trim(),
        password: password,
        displayName: name.trim(),
        role: role,
      );
      await _setSession(user);
    } catch (e) {
      state = AuthState(error: e.toString().replaceAll('Bad state: ', ''));
    }
  }

  Future<void> logout() async {
    final store = ref.read(appStoreProvider);
    await ref.read(cloudSyncServiceProvider).stop();
    await store.logout();
    await store.saveSettings(store.settings().copyWith(clearSession: true));
    state = const AuthState();
  }

  Future<void> deleteAccount({String? password}) async {
    final user = state.user;
    if (user == null) return;
    state = AuthState(user: user, loading: true);
    try {
      final store = ref.read(appStoreProvider);
      await ref.read(cloudSyncServiceProvider).stop();
      await store.deleteAccount(user, passwordForReauth: password);
      await store.saveSettings(store.settings().copyWith(clearSession: true));
      state = const AuthState();
    } catch (e) {
      state = AuthState(
        user: user,
        error: e.toString().replaceAll('Bad state: ', '').replaceAll('StateError: ', ''),
      );
      rethrow;
    }
  }

  Future<void> updateProfile(UserProfile user) async {
    await ref.read(appStoreProvider).saveUser(user);
    await _setSession(user);
  }

  Future<void> _setSession(UserProfile user) async {
    final store = ref.read(appStoreProvider);
    await store.ensureDietitianName();
    final current = store.user(user.id) ?? user;
    await store.saveSettings(store.settings().copyWith(sessionUserId: current.id));
    state = AuthState(user: current);
    await SmartNotificationService.instance.sync(store, current);
    await _startSync();
    final refreshed = store.user(current.id);
    if (refreshed != null) state = AuthState(user: refreshed);
    await _bindPushToken(state.user ?? current);
  }

  Future<void> _startSync() async {
    final sync = ref.read(cloudSyncServiceProvider);
    try {
      await sync.start();
      await ref.read(appStoreProvider).ensureDietitianName();
    } catch (e) {
      debugPrint('Cloud sync start failed: $e');
    }
  }

  Future<void> _bindPushToken(UserProfile user) async {
    if (kIsWeb) return;
    try {
      final messaging = FirebaseMessaging.instance;
      await _storeToken(user, await messaging.getToken());
      if (_pushBound) return;
      _pushBound = true;
      messaging.onTokenRefresh.listen((next) async {
        final current = state.user;
        if (current == null) return;
        await _storeToken(current, next);
      });
    } catch (e) {
      debugPrint('FCM token failed: $e');
    }
  }

  Future<void> _storeToken(UserProfile user, String? token) async {
    if (token == null || token.isEmpty || user.fcmTokens.contains(token)) return;
    final tokens = [...user.fcmTokens, token];
    final trimmed = tokens.length > 8 ? tokens.sublist(tokens.length - 8) : tokens;
    final next = user.copyWith(fcmTokens: trimmed);
    await ref.read(appStoreProvider).saveUser(next);
    if (state.user?.id == next.id) state = AuthState(user: next);
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthRefresh extends ChangeNotifier {
  AuthRefresh(Ref ref) {
    ref.listen(authControllerProvider, (previous, next) => notifyListeners());
  }
}
