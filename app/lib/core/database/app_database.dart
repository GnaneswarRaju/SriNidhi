import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class DevicePreferences extends Table {
  TextColumn get userId => text()();
  TextColumn get preferenceKey => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {userId, preferenceKey};
}

@DriftDatabase(tables: [DevicePreferences])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: 'srinidhi_foundation',
              web: DriftWebOptions(
                sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                driftWorker: Uri.parse('drift_worker.dart.js'),
                onResult: (result) {
                  if (result.chosenImplementation ==
                      WasmStorageImplementation.inMemory) {
                    throw StateError('Persistent storage unavailable');
                  }
                },
              ),
            ),
      );
  @override
  int get schemaVersion => 1;

  Future<String?> selectedBranch(String userId) async {
    final row =
        await (select(devicePreferences)..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.preferenceKey.equals('selected_branch'),
            ))
            .getSingleOrNull();
    return row?.value;
  }

  Future<void> saveSelectedBranch(String userId, String branchId) =>
      into(devicePreferences).insertOnConflictUpdate(
        DevicePreferencesCompanion.insert(
          userId: userId,
          preferenceKey: 'selected_branch',
          value: branchId,
        ),
      );
}
