import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hardware_store/app/providers.dart';
import 'package:hardware_store/app/store_app.dart';
import 'package:hardware_store/core/config/app_config.dart';
import 'package:hardware_store/core/database/app_database.dart';

import 'support/fakes.dart';

void main() {
  testWidgets('compact layout remains usable with 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 1000);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final auth = FakeAuthRepository(user: testUser);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async {
      await db.close();
      await auth.close();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          configProvider.overrideWithValue(
            const AppConfig(
              supabaseUrl: 'https://test.supabase.co',
              supabaseKey: 'sb_publishable_example_only',
            ),
          ),
          authRepositoryProvider.overrideWithValue(auth),
          databaseProvider.overrideWithValue(db),
          workspaceRepositoryProvider.overrideWithValue(
            FakeWorkspaceRepository(),
          ),
        ],
        child: const StoreApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
