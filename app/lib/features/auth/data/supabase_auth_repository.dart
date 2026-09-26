import 'package:supabase_flutter/supabase_flutter.dart' hide ErrorCode;

import '../../../core/errors/app_exception.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this.client, this.logger);
  final SupabaseClient client;
  final AppLogger logger;

  @override
  Stream<StoreUser?> watchUser() => client.auth.onAuthStateChange.map((state) {
    final user = state.session?.user;
    return user == null
        ? null
        : StoreUser(id: user.id, email: user.email ?? '');
  });

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } catch (_) {
      logger.error(
        LogModule.auth,
        LogOperation.signIn,
        ErrorCode.authentication,
      );
      throw const AppException(ErrorCode.authentication);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await client.auth.signOut(scope: SignOutScope.local);
    } catch (_) {
      logger.error(
        LogModule.auth,
        LogOperation.signOut,
        ErrorCode.authentication,
      );
      throw const AppException(ErrorCode.authentication);
    }
  }
}

class UnconfiguredAuthRepository implements AuthRepository {
  @override
  Stream<StoreUser?> watchUser() => Stream.value(null);
  @override
  Future<void> signIn(String email, String password) async =>
      throw const AppException(ErrorCode.authentication);
  @override
  Future<void> signOut() async {}
}
