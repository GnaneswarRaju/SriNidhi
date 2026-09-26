// Manual visual QA: flutter test tool/render_screens_test.dart
// --dart-define=FLUTTER_SDK_PATH=<absolute SDK path>
// Uses explicitly synthetic test fixtures; never shipped as an app entry point.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hardware_store/app/providers.dart';
import 'package:hardware_store/app/store_app.dart';
import 'package:hardware_store/core/config/app_config.dart';
import 'package:hardware_store/core/database/app_database.dart';

import '../test/support/fakes.dart';

void main() {
  const sdk = String.fromEnvironment('FLUTTER_SDK_PATH');
  for (final width in [390.0, 834.0, 1440.0]) {
    testWidgets('export sign-in and workspace at $width', (tester) async {
      await tester.runAsync(() async {
        final loader = FontLoader('Roboto');
        loader.addFont(
          File('$sdk/bin/cache/artifacts/material_fonts/roboto-regular.ttf')
              .readAsBytes()
              .then((b) => ByteData.sublistView(b)),
        );
        await loader.load();
        final icons = FontLoader('MaterialIcons');
        icons.addFont(
          File(
            '$sdk/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
          ).readAsBytes().then((b) => ByteData.sublistView(b)),
        );
        await icons.load();
      });
      tester.view.physicalSize = Size(
        width,
        width < 600 ? 844 : (width < 1024 ? 1112 : 900),
      );
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final key = GlobalKey();
      final auth = FakeAuthRepository();
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(() async {
        await database.close();
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
            databaseProvider.overrideWithValue(database),
            workspaceRepositoryProvider.overrideWithValue(
              FakeWorkspaceRepository(),
            ),
          ],
          child: RepaintBoundary(key: key, child: const StoreApp()),
        ),
      );
      await tester.pumpAndSettle();
      Future<void> capture(String name) async {
        expect(tester.takeException(), isNull);
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final picture = await boundary.toImage();
          final data = await picture.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            '../docs/design/screenshots/$name-${width.toInt()}.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(data!.buffer.asUint8List());
          picture.dispose();
        });
      }

      await capture('sign-in');
      await auth.signIn('test@example.com', 'fixture');
      await tester.pumpAndSettle();
      await capture('overview');
    });
  }
}
