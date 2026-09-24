import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/app_config.dart';
import '../core/database/app_database.dart';
import '../core/logging/app_logger.dart';
import '../features/auth/data/supabase_auth_repository.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/workspace/data/supabase_workspace_repository.dart';
import '../features/workspace/domain/branch_membership.dart';

final configProvider = Provider<AppConfig>((ref) => const AppConfig());
final loggerProvider = Provider<AppLogger>((ref) {
  final config = ref.watch(configProvider);
  return AppLogger(version: config.version, commit: config.gitSha);
});
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => ref.watch(configProvider).ready
      ? SupabaseAuthRepository(
          Supabase.instance.client,
          ref.watch(loggerProvider),
        )
      : UnconfiguredAuthRepository(),
);
final sessionProvider = StreamProvider<StoreUser?>(
  (ref) => ref.watch(authRepositoryProvider).watchUser(),
  retry: (_, _) => null,
);
final workspaceRepositoryProvider = Provider<WorkspaceRepository>(
  (ref) => SupabaseWorkspaceRepository(
    Supabase.instance.client,
    ref.watch(loggerProvider),
  ),
);
