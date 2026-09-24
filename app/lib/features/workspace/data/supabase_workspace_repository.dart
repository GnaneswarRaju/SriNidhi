import 'package:supabase_flutter/supabase_flutter.dart' hide ErrorCode;

import '../../../core/errors/app_exception.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/branch_membership.dart';

class SupabaseWorkspaceRepository implements WorkspaceRepository {
  SupabaseWorkspaceRepository(this.client, this.logger);
  final SupabaseClient client;
  final AppLogger logger;
  @override
  Future<List<BranchMembership>> memberships() async {
    try {
      final rows = await client.rpc('my_branch_memberships');
      return List.unmodifiable(
        (rows as List).map(
          (row) =>
              BranchMembership.fromJson(Map<String, dynamic>.from(row as Map)),
        ),
      );
    } catch (_) {
      logger.error(
        LogModule.workspace,
        LogOperation.loadMemberships,
        ErrorCode.authorization,
      );
      throw const AppException(ErrorCode.authorization);
    }
  }
}
