import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hardware_store/app/providers.dart';
import 'package:hardware_store/core/database/app_database.dart';
import 'package:hardware_store/core/errors/app_exception.dart';
import 'package:hardware_store/features/workspace/presentation/workspace_controller.dart';

import 'support/fakes.dart';

void main() {
  test('cached selection cannot restore a revoked or foreign branch', () async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.saveSelectedBranch(testUser.id, 'foreign-branch');
    final auth = FakeAuthRepository(user: testUser);
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        authRepositoryProvider.overrideWithValue(auth),
        workspaceRepositoryProvider.overrideWithValue(
          FakeWorkspaceRepository(),
        ),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
      await auth.close();
    });
    container.listen(sessionProvider, (_, _) {});
    await container.read(sessionProvider.future);
    container.listen(workspaceControllerProvider, (_, _) {});
    final state = await container.read(workspaceControllerProvider.future);
    expect(state.selected?.branchId, branchA.branchId);
    await expectLater(
      container
          .read(workspaceControllerProvider.notifier)
          .selectBranch('foreign-branch'),
      throwsA(isA<AppException>()),
    );
    await container
        .read(workspaceControllerProvider.notifier)
        .selectBranch(branchB.branchId);
    expect(await db.selectedBranch(testUser.id), branchB.branchId);
  });
  test('server failure cannot produce an authorized workspace', () async {
    final auth = FakeAuthRepository(user: testUser);
    final repo = FakeWorkspaceRepository()..fail = true;
    final db = AppDatabase(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        workspaceRepositoryProvider.overrideWithValue(repo),
        databaseProvider.overrideWithValue(db),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
      await auth.close();
    });
    container.listen(sessionProvider, (_, _) {});
    await container.read(sessionProvider.future);
    container.listen(workspaceControllerProvider, (_, _) {});
    await expectLater(
      container.read(workspaceControllerProvider.future),
      throwsA(isA<AppException>()),
    );
  });
}
