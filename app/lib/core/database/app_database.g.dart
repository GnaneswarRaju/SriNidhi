// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DevicePreferencesTable extends DevicePreferences
    with TableInfo<$DevicePreferencesTable, DevicePreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicePreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _preferenceKeyMeta = const VerificationMeta(
    'preferenceKey',
  );
  @override
  late final GeneratedColumn<String> preferenceKey = GeneratedColumn<String>(
    'preference_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [userId, preferenceKey, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<DevicePreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('preference_key')) {
      context.handle(
        _preferenceKeyMeta,
        preferenceKey.isAcceptableOrUnknown(
          data['preference_key']!,
          _preferenceKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_preferenceKeyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, preferenceKey};
  @override
  DevicePreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DevicePreference(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      preferenceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preference_key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $DevicePreferencesTable createAlias(String alias) {
    return $DevicePreferencesTable(attachedDatabase, alias);
  }
}

class DevicePreference extends DataClass
    implements Insertable<DevicePreference> {
  final String userId;
  final String preferenceKey;
  final String value;
  const DevicePreference({
    required this.userId,
    required this.preferenceKey,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['preference_key'] = Variable<String>(preferenceKey);
    map['value'] = Variable<String>(value);
    return map;
  }

  DevicePreferencesCompanion toCompanion(bool nullToAbsent) {
    return DevicePreferencesCompanion(
      userId: Value(userId),
      preferenceKey: Value(preferenceKey),
      value: Value(value),
    );
  }

  factory DevicePreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DevicePreference(
      userId: serializer.fromJson<String>(json['userId']),
      preferenceKey: serializer.fromJson<String>(json['preferenceKey']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'preferenceKey': serializer.toJson<String>(preferenceKey),
      'value': serializer.toJson<String>(value),
    };
  }

  DevicePreference copyWith({
    String? userId,
    String? preferenceKey,
    String? value,
  }) => DevicePreference(
    userId: userId ?? this.userId,
    preferenceKey: preferenceKey ?? this.preferenceKey,
    value: value ?? this.value,
  );
  DevicePreference copyWithCompanion(DevicePreferencesCompanion data) {
    return DevicePreference(
      userId: data.userId.present ? data.userId.value : this.userId,
      preferenceKey: data.preferenceKey.present
          ? data.preferenceKey.value
          : this.preferenceKey,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DevicePreference(')
          ..write('userId: $userId, ')
          ..write('preferenceKey: $preferenceKey, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, preferenceKey, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DevicePreference &&
          other.userId == this.userId &&
          other.preferenceKey == this.preferenceKey &&
          other.value == this.value);
}

class DevicePreferencesCompanion extends UpdateCompanion<DevicePreference> {
  final Value<String> userId;
  final Value<String> preferenceKey;
  final Value<String> value;
  final Value<int> rowid;
  const DevicePreferencesCompanion({
    this.userId = const Value.absent(),
    this.preferenceKey = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicePreferencesCompanion.insert({
    required String userId,
    required String preferenceKey,
    required String value,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       preferenceKey = Value(preferenceKey),
       value = Value(value);
  static Insertable<DevicePreference> custom({
    Expression<String>? userId,
    Expression<String>? preferenceKey,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (preferenceKey != null) 'preference_key': preferenceKey,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicePreferencesCompanion copyWith({
    Value<String>? userId,
    Value<String>? preferenceKey,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return DevicePreferencesCompanion(
      userId: userId ?? this.userId,
      preferenceKey: preferenceKey ?? this.preferenceKey,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (preferenceKey.present) {
      map['preference_key'] = Variable<String>(preferenceKey.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicePreferencesCompanion(')
          ..write('userId: $userId, ')
          ..write('preferenceKey: $preferenceKey, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DevicePreferencesTable devicePreferences =
      $DevicePreferencesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [devicePreferences];
}

typedef $$DevicePreferencesTableCreateCompanionBuilder =
    DevicePreferencesCompanion Function({
      required String userId,
      required String preferenceKey,
      required String value,
      Value<int> rowid,
    });
typedef $$DevicePreferencesTableUpdateCompanionBuilder =
    DevicePreferencesCompanion Function({
      Value<String> userId,
      Value<String> preferenceKey,
      Value<String> value,
      Value<int> rowid,
    });

class $$DevicePreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $DevicePreferencesTable> {
  $$DevicePreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferenceKey => $composableBuilder(
    column: $table.preferenceKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DevicePreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicePreferencesTable> {
  $$DevicePreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferenceKey => $composableBuilder(
    column: $table.preferenceKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevicePreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicePreferencesTable> {
  $$DevicePreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get preferenceKey => $composableBuilder(
    column: $table.preferenceKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$DevicePreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevicePreferencesTable,
          DevicePreference,
          $$DevicePreferencesTableFilterComposer,
          $$DevicePreferencesTableOrderingComposer,
          $$DevicePreferencesTableAnnotationComposer,
          $$DevicePreferencesTableCreateCompanionBuilder,
          $$DevicePreferencesTableUpdateCompanionBuilder,
          (
            DevicePreference,
            BaseReferences<
              _$AppDatabase,
              $DevicePreferencesTable,
              DevicePreference
            >,
          ),
          DevicePreference,
          PrefetchHooks Function()
        > {
  $$DevicePreferencesTableTableManager(
    _$AppDatabase db,
    $DevicePreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicePreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicePreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicePreferencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> preferenceKey = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicePreferencesCompanion(
                userId: userId,
                preferenceKey: preferenceKey,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String preferenceKey,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => DevicePreferencesCompanion.insert(
                userId: userId,
                preferenceKey: preferenceKey,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DevicePreferencesTable, DevicePreference>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DevicePreferencesTable,
                    DevicePreference
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DevicePreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevicePreferencesTable,
      DevicePreference,
      $$DevicePreferencesTableFilterComposer,
      $$DevicePreferencesTableOrderingComposer,
      $$DevicePreferencesTableAnnotationComposer,
      $$DevicePreferencesTableCreateCompanionBuilder,
      $$DevicePreferencesTableUpdateCompanionBuilder,
      (
        DevicePreference,
        BaseReferences<
          _$AppDatabase,
          $DevicePreferencesTable,
          DevicePreference
        >,
      ),
      DevicePreference,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DevicePreferencesTableTableManager get devicePreferences =>
      $$DevicePreferencesTableTableManager(_db, _db.devicePreferences);
}
