import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hardware_store/core/database/app_database.dart';

void main() {
  test('branch preference survives restart and is isolated by user', () async {
    final dir = await Directory.systemTemp.createTemp('store-test-');
    final file = File('${dir.path}/preferences.sqlite');
    var db = AppDatabase(NativeDatabase(file));
    try {
      await db.saveSelectedBranch('user-a', 'branch-a');
      await db.saveSelectedBranch('user-b', 'branch-b');
      await db.saveSelectedBranch('user-a', 'branch-a2');
      await db.close();
      db = AppDatabase(NativeDatabase(file));
      expect(await db.selectedBranch('user-a'), 'branch-a2');
      expect(await db.selectedBranch('user-b'), 'branch-b');
      expect(await db.selectedBranch('unknown'), isNull);
    } finally {
      await db.close();
      await dir.delete(recursive: true);
    }
  });
}
