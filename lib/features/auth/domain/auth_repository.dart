import '../../../core/models/enums.dart';
import '../../../core/models/models.dart';

abstract class AuthRepository {
  Future<UserProfile> login(String email, String password);
  Future<UserProfile> register({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  });
  Future<void> logout();
}
