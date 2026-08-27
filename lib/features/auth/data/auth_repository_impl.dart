import '../../../core/data/app_store.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/models.dart';
import '../domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._store);
  final AppStore _store;

  @override
  Future<UserProfile> login(String email, String password) => _store.login(email, password);

  @override
  Future<void> logout() => _store.logout();

  @override
  Future<UserProfile> register({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) =>
      _store.register(email: email, password: password, displayName: displayName, role: role);
}
