import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/app_store.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/models.dart';
import '../../../core/network/cloud_sync_service.dart';
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
  @override
  AuthState build() {
    final store = ref.watch(appStoreProvider);
    final id = store.settings().sessionUserId;
    // Resume cloud sync if a session is already restored.
    if (id != null && store.user(id) != null) {
      Future.microtask(() => _startSync());
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

  Future<void> updateProfile(UserProfile user) async {
    await ref.read(appStoreProvider).saveUser(user);
    await _setSession(user);
  }

  Future<void> _setSession(UserProfile user) async {
    final store = ref.read(appStoreProvider);
    await store.saveSettings(store.settings().copyWith(sessionUserId: user.id));
    state = AuthState(user: user);
    await SmartNotificationService.instance.sync(store, user);
    await _startSync();
  }

  Future<void> _startSync() async {
    final sync = ref.read(cloudSyncServiceProvider);
    try {
      await sync.start();
    } catch (e) {
      debugPrint('Cloud sync start failed: $e');
    }
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthRefresh extends ChangeNotifier {
  AuthRefresh(Ref ref) {
    ref.listen(authControllerProvider, (previous, next) => notifyListeners());
  }
}
