import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hardware_store/app/providers.dart';
import 'package:hardware_store/app/store_app.dart';
import 'package:hardware_store/core/config/app_config.dart';
import 'package:hardware_store/core/database/app_database.dart';

import 'support/fakes.dart';

const configured = AppConfig(
  supabaseUrl: 'https://test.supabase.co',
  supabaseKey: 'sb_publishable_example_only',
);

void main() {
  testWidgets('unconfigured installation shows setup without simulated data', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: StoreApp()));
    await tester.pumpAndSettle();
    expect(find.text('Connect your store'), findsOneWidget);
    expect(find.text('Your store workspace'), findsNothing);
  });
  for (final width in [320.0, 390.0, 834.0, 1440.0]) {
    testWidgets('sign-in and overview at width $width, including sign-out', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final auth = FakeAuthRepository();
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(() async {
        await db.close();
        await auth.close();
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            configProvider.overrideWithValue(configured),
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
      expect(find.text('Welcome back'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'test-password');
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Your store workspace'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(
        find.byType(NavigationBar),
        width < 600 ? findsOneWidget : findsNothing,
      );
      expect(
        find.byType(NavigationRail),
        width >= 600 ? findsOneWidget : findsNothing,
      );
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Main branch · MAIN'), findsNothing);
    });
  }
  testWidgets('signed-in user without roles gets an access empty state', (
    tester,
  ) async {
    final auth = FakeAuthRepository(user: testUser);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async {
      await db.close();
      await auth.close();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          configProvider.overrideWithValue(configured),
          authRepositoryProvider.overrideWithValue(auth),
          databaseProvider.overrideWithValue(db),
          workspaceRepositoryProvider.overrideWithValue(
            FakeWorkspaceRepository()..branches = [],
          ),
        ],
        child: const StoreApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No branch access yet'), findsOneWidget);
    expect(find.text('Your workspace is ready'), findsNothing);
  });
}
