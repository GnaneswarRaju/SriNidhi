import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/branch_membership.dart';

class WorkspaceState {
  const WorkspaceState(this.memberships, this.selected, {this.saving = false});
  final List<BranchMembership> memberships;
  final BranchMembership? selected;
  final bool saving;
}

final workspaceControllerProvider =
    AsyncNotifierProvider<WorkspaceController, WorkspaceState>(
      WorkspaceController.new,
      // Permission/network failures must reach the retry UI immediately.
      retry: (_, _) => null,
    );

class WorkspaceController extends AsyncNotifier<WorkspaceState> {
  @override
  Future<WorkspaceState> build() async {
    final user = ref.watch(sessionProvider).asData?.value;
    if (user == null) return const WorkspaceState([], null);
    final repository = ref.watch(workspaceRepositoryProvider);
    final database = ref.watch(databaseProvider);
    final branches = await repository.memberships();
    final cached = await database.selectedBranch(user.id);
    final selected =
        branches.where((b) => b.branchId == cached).firstOrNull ??
        branches.firstOrNull;
    return WorkspaceState(branches, selected);
  }

  Future<void> selectBranch(String branchId) async {
    final current = state.asData?.value;
    final userId = ref.read(sessionProvider).asData?.value?.id;
    if (current == null || current.saving || userId == null) return;
    final branch = current.memberships
        .where((b) => b.branchId == branchId)
        .firstOrNull;
    if (branch == null) throw const AppException(ErrorCode.authorization);
    state = AsyncData(
      WorkspaceState(current.memberships, current.selected, saving: true),
    );
    try {
      // Recheck active membership at the server before changing branch context.
      final fresh = await ref.read(workspaceRepositoryProvider).memberships();
      final valid = fresh.where((b) => b.branchId == branchId).firstOrNull;
      if (valid == null) {
        if (ref.mounted) ref.invalidateSelf();
        return;
      }
      await ref.read(databaseProvider).saveSelectedBranch(userId, branchId);
      if (!ref.mounted ||
          ref.read(sessionProvider).asData?.value?.id != userId) {
        return;
      }
      state = AsyncData(WorkspaceState(fresh, valid));
    } catch (error, stack) {
      if (!ref.mounted ||
          ref.read(sessionProvider).asData?.value?.id != userId) {
        return;
      }
      ref
          .read(loggerProvider)
          .error(
            LogModule.storage,
            LogOperation.savePreference,
            ErrorCode.database,
          );
      state = AsyncError(
        error is AppException ? error : const AppException(ErrorCode.database),
        stack,
      );
    }
  }
}
