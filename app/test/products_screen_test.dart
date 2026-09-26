import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hardware_store/app/providers.dart';
import 'package:hardware_store/app/store_app.dart';
import 'package:hardware_store/core/database/app_database.dart';
import 'package:hardware_store/features/products/presentation/product_providers.dart';

import 'app_test.dart' show configured;
import 'support/fakes.dart';
import 'support/product_fake.dart';

Future<FakeProductRepository> openCatalogue(
  WidgetTester tester, {
  bool cashier = false,
  FakeProductRepository? repository,
}) async {
  final auth = FakeAuthRepository(user: testUser);
  final db = AppDatabase(NativeDatabase.memory());
  final products = repository ?? FakeProductRepository();
  addTearDown(() async {
    await auth.close();
    await db.close();
  });
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        configProvider.overrideWithValue(configured),
        authRepositoryProvider.overrideWithValue(auth),
        databaseProvider.overrideWithValue(db),
        workspaceRepositoryProvider.overrideWithValue(
          FakeWorkspaceRepository()..branches = [cashier ? branchA : branchB],
        ),
        productRepositoryProvider.overrideWithValue(products),
      ],
      child: const StoreApp(),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Products').last);
  await tester.pumpAndSettle();
  return products;
}

Future<void> tapSave(WidgetTester tester) async {
  await tester.pumpAndSettle();
  final save = find.widgetWithText(FilledButton, 'Save product');
  await tester.ensureVisible(save);
  await tester.pumpAndSettle();
  await tester.tap(save);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('product form supports 200 percent text at 320 pixels', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 1000);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await openCatalogue(tester);
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Add product'),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Add product'));
    await tester.pumpAndSettle();
    await tapSave(tester);
    expect(tester.takeException(), isNull);
  });
  for (final width in [320.0, 390.0, 834.0, 1440.0]) {
    testWidgets('catalogue and form fit width $width', (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await openCatalogue(tester);
      expect(find.text('Your catalogue starts here'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Add product'));
      await tester.pumpAndSettle();
      await tapSave(tester);
      expect(find.text('Enter a value.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('cashier can view details but cannot add or edit', (
    tester,
  ) async {
    await openCatalogue(
      tester,
      cashier: true,
      repository: FakeProductRepository()..products = [sampleProduct],
    );
    expect(find.text('Add product'), findsNothing);
    expect(find.text('Edit'), findsNothing);
    await tester.ensureVisible(find.text('View details'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View details'));
    await tester.pumpAndSettle();
    expect(find.text('Product details'), findsOneWidget);
    expect(find.text('Save product'), findsNothing);
    expect(
      tester
          .widget<TextField>(
            find.descendant(
              of: find.byKey(const ValueKey('product-sale_price')),
              matching: find.byType(TextField),
            ),
          )
          .readOnly,
      isTrue,
    );
  });
  testWidgets(
    'failed create retries stable id and exact strings, then refreshes list',
    (tester) async {
      final products = await openCatalogue(tester);
      products.fail = true;
      await tester.tap(find.widgetWithText(FilledButton, 'Add product'));
      await tester.pumpAndSettle();
      for (final entry in {
        'name': 'Test bolt',
        'sku': 'BOLT-1',
        'sale_price': '0.10',
      }.entries) {
        final field = find.byKey(ValueKey('product-${entry.key}'));
        await tester.ensureVisible(field);
        await tester.enterText(field, entry.value);
      }
      await tapSave(tester);
      expect(
        find.textContaining('Saving could not be confirmed'),
        findsOneWidget,
      );
      products.fail = false;
      await tapSave(tester);
      expect(products.savedIds, hasLength(2));
      expect(products.savedIds.toSet(), hasLength(1));
      expect(products.savedData!['sale_price'], '0.10');
      expect(find.text('Test bolt'), findsOneWidget);
    },
  );
  testWidgets('pagination carries composite cursor and search resets it', (
    tester,
  ) async {
    final products = await openCatalogue(
      tester,
      repository: FakeProductRepository()
        ..products = [sampleProduct]
        ..paginated = true,
    );
    await tester.ensureVisible(find.text('Next'));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(products.queries.last.afterId, sampleProduct.id);
    expect(products.queries.last.afterName, sampleProduct.nameKey);
    await tester.ensureVisible(find.byType(TextField).first);
    await tester.enterText(find.byType(TextField).first, 'br-');
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(products.queries.last.afterId, isNull);
    expect(products.queries.last.search, 'br-');
  });
  testWidgets('load failure offers retry and restores catalogue', (
    tester,
  ) async {
    final products = await openCatalogue(
      tester,
      repository: FakeProductRepository()..failLoad = true,
    );
    expect(find.textContaining('We could not load products'), findsOneWidget);
    products.failLoad = false;
    await tester.ensureVisible(find.text('Try again'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Your catalogue starts here'), findsOneWidget);
  });
}
