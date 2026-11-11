// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, AppSettings> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extraMeta = const VerificationMeta('extra');
  @override
  late final GeneratedColumn<String> extra = GeneratedColumn<String>(
    'extra',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _awakeStartMeta = const VerificationMeta(
    'awakeStart',
  );
  @override
  late final GeneratedColumn<String> awakeStart = GeneratedColumn<String>(
    'awake_start',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('08:00'),
  );
  static const VerificationMeta _awakeEndMeta = const VerificationMeta(
    'awakeEnd',
  );
  @override
  late final GeneratedColumn<String> awakeEnd = GeneratedColumn<String>(
    'awake_end',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('22:00'),
  );
  static const VerificationMeta _blockOrderMeta = const VerificationMeta(
    'blockOrder',
  );
  @override
  late final GeneratedColumn<String> blockOrder = GeneratedColumn<String>(
    'block_order',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skipPolicyMeta = const VerificationMeta(
    'skipPolicy',
  );
  @override
  late final GeneratedColumn<String> skipPolicy = GeneratedColumn<String>(
    'skip_policy',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _themeMeta = const VerificationMeta('theme');
  @override
  late final GeneratedColumn<String> theme = GeneratedColumn<String>(
    'theme',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recentContactPersonIdMeta =
      const VerificationMeta('recentContactPersonId');
  @override
  late final GeneratedColumn<String> recentContactPersonId =
      GeneratedColumn<String>(
        'recent_contact_person_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recentContactAtMeta = const VerificationMeta(
    'recentContactAt',
  );
  @override
  late final GeneratedColumn<DateTime> recentContactAt =
      GeneratedColumn<DateTime>(
        'recent_contact_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastExportAtMeta = const VerificationMeta(
    'lastExportAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastExportAt = GeneratedColumn<DateTime>(
    'last_export_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    extra,
    awakeStart,
    awakeEnd,
    blockOrder,
    schemaVersion,
    skipPolicy,
    theme,
    recentContactPersonId,
    recentContactAt,
    lastExportAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettings> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('extra')) {
      context.handle(
        _extraMeta,
        extra.isAcceptableOrUnknown(data['extra']!, _extraMeta),
      );
    }
    if (data.containsKey('awake_start')) {
      context.handle(
        _awakeStartMeta,
        awakeStart.isAcceptableOrUnknown(data['awake_start']!, _awakeStartMeta),
      );
    }
    if (data.containsKey('awake_end')) {
      context.handle(
        _awakeEndMeta,
        awakeEnd.isAcceptableOrUnknown(data['awake_end']!, _awakeEndMeta),
      );
    }
    if (data.containsKey('block_order')) {
      context.handle(
        _blockOrderMeta,
        blockOrder.isAcceptableOrUnknown(data['block_order']!, _blockOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_blockOrderMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('skip_policy')) {
      context.handle(
        _skipPolicyMeta,
        skipPolicy.isAcceptableOrUnknown(data['skip_policy']!, _skipPolicyMeta),
      );
    }
    if (data.containsKey('theme')) {
      context.handle(
        _themeMeta,
        theme.isAcceptableOrUnknown(data['theme']!, _themeMeta),
      );
    }
    if (data.containsKey('recent_contact_person_id')) {
      context.handle(
        _recentContactPersonIdMeta,
        recentContactPersonId.isAcceptableOrUnknown(
          data['recent_contact_person_id']!,
          _recentContactPersonIdMeta,
        ),
      );
    }
    if (data.containsKey('recent_contact_at')) {
      context.handle(
        _recentContactAtMeta,
        recentContactAt.isAcceptableOrUnknown(
          data['recent_contact_at']!,
          _recentContactAtMeta,
        ),
      );
    }
    if (data.containsKey('last_export_at')) {
      context.handle(
        _lastExportAtMeta,
        lastExportAt.isAcceptableOrUnknown(
          data['last_export_at']!,
          _lastExportAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettings map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettings(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      extra: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extra'],
      ),
      awakeStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}awake_start'],
      )!,
      awakeEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}awake_end'],
      )!,
      blockOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}block_order'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      skipPolicy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skip_policy'],
      ),
      theme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme'],
      ),
      recentContactPersonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recent_contact_person_id'],
      ),
      recentContactAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recent_contact_at'],
      ),
      lastExportAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_export_at'],
      ),
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class AppSettings extends DataClass implements Insertable<AppSettings> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? extra;
  final String awakeStart;
  final String awakeEnd;

  /// JSON list of block keys.
  final String blockOrder;
  final int schemaVersion;
  final String? skipPolicy;
  final String? theme;
  final String? recentContactPersonId;
  final DateTime? recentContactAt;

  /// Device-local: when a backup was last exported. Not written to backups.
  final DateTime? lastExportAt;
  const AppSettings({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.extra,
    required this.awakeStart,
    required this.awakeEnd,
    required this.blockOrder,
    required this.schemaVersion,
    this.skipPolicy,
    this.theme,
    this.recentContactPersonId,
    this.recentContactAt,
    this.lastExportAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || extra != null) {
      map['extra'] = Variable<String>(extra);
    }
    map['awake_start'] = Variable<String>(awakeStart);
    map['awake_end'] = Variable<String>(awakeEnd);
    map['block_order'] = Variable<String>(blockOrder);
    map['schema_version'] = Variable<int>(schemaVersion);
    if (!nullToAbsent || skipPolicy != null) {
      map['skip_policy'] = Variable<String>(skipPolicy);
    }
    if (!nullToAbsent || theme != null) {
      map['theme'] = Variable<String>(theme);
    }
    if (!nullToAbsent || recentContactPersonId != null) {
      map['recent_contact_person_id'] = Variable<String>(recentContactPersonId);
    }
    if (!nullToAbsent || recentContactAt != null) {
      map['recent_contact_at'] = Variable<DateTime>(recentContactAt);
    }
    if (!nullToAbsent || lastExportAt != null) {
      map['last_export_at'] = Variable<DateTime>(lastExportAt);
    }
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      extra: extra == null && nullToAbsent
          ? const Value.absent()
          : Value(extra),
      awakeStart: Value(awakeStart),
      awakeEnd: Value(awakeEnd),
      blockOrder: Value(blockOrder),
      schemaVersion: Value(schemaVersion),
      skipPolicy: skipPolicy == null && nullToAbsent
          ? const Value.absent()
          : Value(skipPolicy),
      theme: theme == null && nullToAbsent
          ? const Value.absent()
          : Value(theme),
      recentContactPersonId: recentContactPersonId == null && nullToAbsent
          ? const Value.absent()
          : Value(recentContactPersonId),
      recentContactAt: recentContactAt == null && nullToAbsent
          ? const Value.absent()
          : Value(recentContactAt),
      lastExportAt: lastExportAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastExportAt),
    );
  }

  factory AppSettings.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettings(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      extra: serializer.fromJson<String?>(json['extra']),
      awakeStart: serializer.fromJson<String>(json['awakeStart']),
      awakeEnd: serializer.fromJson<String>(json['awakeEnd']),
      blockOrder: serializer.fromJson<String>(json['blockOrder']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      skipPolicy: serializer.fromJson<String?>(json['skipPolicy']),
      theme: serializer.fromJson<String?>(json['theme']),
      recentContactPersonId: serializer.fromJson<String?>(
        json['recentContactPersonId'],
      ),
      recentContactAt: serializer.fromJson<DateTime?>(json['recentContactAt']),
      lastExportAt: serializer.fromJson<DateTime?>(json['lastExportAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'extra': serializer.toJson<String?>(extra),
      'awakeStart': serializer.toJson<String>(awakeStart),
      'awakeEnd': serializer.toJson<String>(awakeEnd),
      'blockOrder': serializer.toJson<String>(blockOrder),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'skipPolicy': serializer.toJson<String?>(skipPolicy),
      'theme': serializer.toJson<String?>(theme),
      'recentContactPersonId': serializer.toJson<String?>(
        recentContactPersonId,
      ),
      'recentContactAt': serializer.toJson<DateTime?>(recentContactAt),
      'lastExportAt': serializer.toJson<DateTime?>(lastExportAt),
    };
  }

  AppSettings copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> extra = const Value.absent(),
    String? awakeStart,
    String? awakeEnd,
    String? blockOrder,
    int? schemaVersion,
    Value<String?> skipPolicy = const Value.absent(),
    Value<String?> theme = const Value.absent(),
    Value<String?> recentContactPersonId = const Value.absent(),
    Value<DateTime?> recentContactAt = const Value.absent(),
    Value<DateTime?> lastExportAt = const Value.absent(),
  }) => AppSettings(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    extra: extra.present ? extra.value : this.extra,
    awakeStart: awakeStart ?? this.awakeStart,
    awakeEnd: awakeEnd ?? this.awakeEnd,
    blockOrder: blockOrder ?? this.blockOrder,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    skipPolicy: skipPolicy.present ? skipPolicy.value : this.skipPolicy,
    theme: theme.present ? theme.value : this.theme,
    recentContactPersonId: recentContactPersonId.present
        ? recentContactPersonId.value
        : this.recentContactPersonId,
    recentContactAt: recentContactAt.present
        ? recentContactAt.value
        : this.recentContactAt,
    lastExportAt: lastExportAt.present ? lastExportAt.value : this.lastExportAt,
  );
  AppSettings copyWithCompanion(SettingsCompanion data) {
    return AppSettings(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      extra: data.extra.present ? data.extra.value : this.extra,
      awakeStart: data.awakeStart.present
          ? data.awakeStart.value
          : this.awakeStart,
      awakeEnd: data.awakeEnd.present ? data.awakeEnd.value : this.awakeEnd,
      blockOrder: data.blockOrder.present
          ? data.blockOrder.value
          : this.blockOrder,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      skipPolicy: data.skipPolicy.present
          ? data.skipPolicy.value
          : this.skipPolicy,
      theme: data.theme.present ? data.theme.value : this.theme,
      recentContactPersonId: data.recentContactPersonId.present
          ? data.recentContactPersonId.value
          : this.recentContactPersonId,
      recentContactAt: data.recentContactAt.present
          ? data.recentContactAt.value
          : this.recentContactAt,
      lastExportAt: data.lastExportAt.present
          ? data.lastExportAt.value
          : this.lastExportAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettings(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('extra: $extra, ')
          ..write('awakeStart: $awakeStart, ')
          ..write('awakeEnd: $awakeEnd, ')
          ..write('blockOrder: $blockOrder, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('skipPolicy: $skipPolicy, ')
          ..write('theme: $theme, ')
          ..write('recentContactPersonId: $recentContactPersonId, ')
          ..write('recentContactAt: $recentContactAt, ')
          ..write('lastExportAt: $lastExportAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    extra,
    awakeStart,
    awakeEnd,
    blockOrder,
    schemaVersion,
    skipPolicy,
    theme,
    recentContactPersonId,
    recentContactAt,
    lastExportAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettings &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.extra == this.extra &&
          other.awakeStart == this.awakeStart &&
          other.awakeEnd == this.awakeEnd &&
          other.blockOrder == this.blockOrder &&
          other.schemaVersion == this.schemaVersion &&
          other.skipPolicy == this.skipPolicy &&
          other.theme == this.theme &&
          other.recentContactPersonId == this.recentContactPersonId &&
          other.recentContactAt == this.recentContactAt &&
          other.lastExportAt == this.lastExportAt);
}

class SettingsCompanion extends UpdateCompanion<AppSettings> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> extra;
  final Value<String> awakeStart;
  final Value<String> awakeEnd;
  final Value<String> blockOrder;
  final Value<int> schemaVersion;
  final Value<String?> skipPolicy;
  final Value<String?> theme;
  final Value<String?> recentContactPersonId;
  final Value<DateTime?> recentContactAt;
  final Value<DateTime?> lastExportAt;
  final Value<int> rowid;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.extra = const Value.absent(),
    this.awakeStart = const Value.absent(),
    this.awakeEnd = const Value.absent(),
    this.blockOrder = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.skipPolicy = const Value.absent(),
    this.theme = const Value.absent(),
    this.recentContactPersonId = const Value.absent(),
    this.recentContactAt = const Value.absent(),
    this.lastExportAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.extra = const Value.absent(),
    this.awakeStart = const Value.absent(),
    this.awakeEnd = const Value.absent(),
    required String blockOrder,
    required int schemaVersion,
    this.skipPolicy = const Value.absent(),
    this.theme = const Value.absent(),
    this.recentContactPersonId = const Value.absent(),
    this.recentContactAt = const Value.absent(),
    this.lastExportAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       blockOrder = Value(blockOrder),
       schemaVersion = Value(schemaVersion);
  static Insertable<AppSettings> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? extra,
    Expression<String>? awakeStart,
    Expression<String>? awakeEnd,
    Expression<String>? blockOrder,
    Expression<int>? schemaVersion,
    Expression<String>? skipPolicy,
    Expression<String>? theme,
    Expression<String>? recentContactPersonId,
    Expression<DateTime>? recentContactAt,
    Expression<DateTime>? lastExportAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (extra != null) 'extra': extra,
      if (awakeStart != null) 'awake_start': awakeStart,
      if (awakeEnd != null) 'awake_end': awakeEnd,
      if (blockOrder != null) 'block_order': blockOrder,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (skipPolicy != null) 'skip_policy': skipPolicy,
      if (theme != null) 'theme': theme,
      if (recentContactPersonId != null)
        'recent_contact_person_id': recentContactPersonId,
      if (recentContactAt != null) 'recent_contact_at': recentContactAt,
      if (lastExportAt != null) 'last_export_at': lastExportAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? extra,
    Value<String>? awakeStart,
    Value<String>? awakeEnd,
    Value<String>? blockOrder,
    Value<int>? schemaVersion,
    Value<String?>? skipPolicy,
    Value<String?>? theme,
    Value<String?>? recentContactPersonId,
    Value<DateTime?>? recentContactAt,
    Value<DateTime?>? lastExportAt,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      extra: extra ?? this.extra,
      awakeStart: awakeStart ?? this.awakeStart,
      awakeEnd: awakeEnd ?? this.awakeEnd,
      blockOrder: blockOrder ?? this.blockOrder,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      skipPolicy: skipPolicy ?? this.skipPolicy,
      theme: theme ?? this.theme,
      recentContactPersonId:
          recentContactPersonId ?? this.recentContactPersonId,
      recentContactAt: recentContactAt ?? this.recentContactAt,
      lastExportAt: lastExportAt ?? this.lastExportAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (extra.present) {
      map['extra'] = Variable<String>(extra.value);
    }
    if (awakeStart.present) {
      map['awake_start'] = Variable<String>(awakeStart.value);
    }
    if (awakeEnd.present) {
      map['awake_end'] = Variable<String>(awakeEnd.value);
    }
    if (blockOrder.present) {
      map['block_order'] = Variable<String>(blockOrder.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (skipPolicy.present) {
      map['skip_policy'] = Variable<String>(skipPolicy.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(theme.value);
    }
    if (recentContactPersonId.present) {
      map['recent_contact_person_id'] = Variable<String>(
        recentContactPersonId.value,
      );
    }
    if (recentContactAt.present) {
      map['recent_contact_at'] = Variable<DateTime>(recentContactAt.value);
    }
    if (lastExportAt.present) {
      map['last_export_at'] = Variable<DateTime>(lastExportAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('extra: $extra, ')
          ..write('awakeStart: $awakeStart, ')
          ..write('awakeEnd: $awakeEnd, ')
          ..write('blockOrder: $blockOrder, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('skipPolicy: $skipPolicy, ')
          ..write('theme: $theme, ')
          ..write('recentContactPersonId: $recentContactPersonId, ')
          ..write('recentContactAt: $recentContactAt, ')
          ..write('lastExportAt: $lastExportAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupsTable extends Groups with TableInfo<$GroupsTable, GroupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extraMeta = const VerificationMeta('extra');
  @override
  late final GeneratedColumn<String> extra = GeneratedColumn<String>(
    'extra',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultIntervalDaysMeta =
      const VerificationMeta('defaultIntervalDays');
  @override
  late final GeneratedColumn<int> defaultIntervalDays = GeneratedColumn<int>(
    'default_interval_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    extra,
    name,
    defaultIntervalDays,
    sortOrder,
    color,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('extra')) {
      context.handle(
        _extraMeta,
        extra.isAcceptableOrUnknown(data['extra']!, _extraMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('default_interval_days')) {
      context.handle(
        _defaultIntervalDaysMeta,
        defaultIntervalDays.isAcceptableOrUnknown(
          data['default_interval_days']!,
          _defaultIntervalDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultIntervalDaysMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GroupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      extra: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extra'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      defaultIntervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_interval_days'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
    );
  }

  @override
  $GroupsTable createAlias(String alias) {
    return $GroupsTable(attachedDatabase, alias);
  }
}

class GroupRow extends DataClass implements Insertable<GroupRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? extra;
  final String name;
  final int defaultIntervalDays;
  final int sortOrder;
  final String? color;
  const GroupRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.extra,
    required this.name,
    required this.defaultIntervalDays,
    required this.sortOrder,
    this.color,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || extra != null) {
      map['extra'] = Variable<String>(extra);
    }
    map['name'] = Variable<String>(name);
    map['default_interval_days'] = Variable<int>(defaultIntervalDays);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    return map;
  }

  GroupsCompanion toCompanion(bool nullToAbsent) {
    return GroupsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      extra: extra == null && nullToAbsent
          ? const Value.absent()
          : Value(extra),
      name: Value(name),
      defaultIntervalDays: Value(defaultIntervalDays),
      sortOrder: Value(sortOrder),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
    );
  }

  factory GroupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      extra: serializer.fromJson<String?>(json['extra']),
      name: serializer.fromJson<String>(json['name']),
      defaultIntervalDays: serializer.fromJson<int>(
        json['defaultIntervalDays'],
      ),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      color: serializer.fromJson<String?>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'extra': serializer.toJson<String?>(extra),
      'name': serializer.toJson<String>(name),
      'defaultIntervalDays': serializer.toJson<int>(defaultIntervalDays),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'color': serializer.toJson<String?>(color),
    };
  }

  GroupRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> extra = const Value.absent(),
    String? name,
    int? defaultIntervalDays,
    int? sortOrder,
    Value<String?> color = const Value.absent(),
  }) => GroupRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    extra: extra.present ? extra.value : this.extra,
    name: name ?? this.name,
    defaultIntervalDays: defaultIntervalDays ?? this.defaultIntervalDays,
    sortOrder: sortOrder ?? this.sortOrder,
    color: color.present ? color.value : this.color,
  );
  GroupRow copyWithCompanion(GroupsCompanion data) {
    return GroupRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      extra: data.extra.present ? data.extra.value : this.extra,
      name: data.name.present ? data.name.value : this.name,
      defaultIntervalDays: data.defaultIntervalDays.present
          ? data.defaultIntervalDays.value
          : this.defaultIntervalDays,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('extra: $extra, ')
          ..write('name: $name, ')
          ..write('defaultIntervalDays: $defaultIntervalDays, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    extra,
    name,
    defaultIntervalDays,
    sortOrder,
    color,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.extra == this.extra &&
          other.name == this.name &&
          other.defaultIntervalDays == this.defaultIntervalDays &&
          other.sortOrder == this.sortOrder &&
          other.color == this.color);
}

class GroupsCompanion extends UpdateCompanion<GroupRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> extra;
  final Value<String> name;
  final Value<int> defaultIntervalDays;
  final Value<int> sortOrder;
  final Value<String?> color;
  final Value<int> rowid;
  const GroupsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.extra = const Value.absent(),
    this.name = const Value.absent(),
    this.defaultIntervalDays = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.extra = const Value.absent(),
    required String name,
    required int defaultIntervalDays,
    this.sortOrder = const Value.absent(),
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       defaultIntervalDays = Value(defaultIntervalDays);
  static Insertable<GroupRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? extra,
    Expression<String>? name,
    Expression<int>? defaultIntervalDays,
    Expression<int>? sortOrder,
    Expression<String>? color,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (extra != null) 'extra': extra,
      if (name != null) 'name': name,
      if (defaultIntervalDays != null)
        'default_interval_days': defaultIntervalDays,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (color != null) 'color': color,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? extra,
    Value<String>? name,
    Value<int>? defaultIntervalDays,
    Value<int>? sortOrder,
    Value<String?>? color,
    Value<int>? rowid,
  }) {
    return GroupsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      extra: extra ?? this.extra,
      name: name ?? this.name,
      defaultIntervalDays: defaultIntervalDays ?? this.defaultIntervalDays,
      sortOrder: sortOrder ?? this.sortOrder,
      color: color ?? this.color,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (extra.present) {
      map['extra'] = Variable<String>(extra.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (defaultIntervalDays.present) {
      map['default_interval_days'] = Variable<int>(defaultIntervalDays.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('extra: $extra, ')
          ..write('name: $name, ')
          ..write('defaultIntervalDays: $defaultIntervalDays, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('color: $color, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PeopleTable extends People with TableInfo<$PeopleTable, PersonRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeopleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extraMeta = const VerificationMeta('extra');
  @override
  late final GeneratedColumn<String> extra = GeneratedColumn<String>(
    'extra',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES "groups" (id)',
    ),
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timezoneConfirmedMeta = const VerificationMeta(
    'timezoneConfirmed',
  );
  @override
  late final GeneratedColumn<bool> timezoneConfirmed = GeneratedColumn<bool>(
    'timezone_confirmed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("timezone_confirmed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _contactMethodTypeMeta = const VerificationMeta(
    'contactMethodType',
  );
  @override
  late final GeneratedColumn<String> contactMethodType =
      GeneratedColumn<String>(
        'contact_method_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _contactMethodValueMeta =
      const VerificationMeta('contactMethodValue');
  @override
  late final GeneratedColumn<String> contactMethodValue =
      GeneratedColumn<String>(
        'contact_method_value',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _middleNameMeta = const VerificationMeta(
    'middleName',
  );
  @override
  late final GeneratedColumn<String> middleName = GeneratedColumn<String>(
    'middle_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthdayMeta = const VerificationMeta(
    'birthday',
  );
  @override
  late final GeneratedColumn<String> birthday = GeneratedColumn<String>(
    'birthday',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intervalOverrideDaysMeta =
      const VerificationMeta('intervalOverrideDays');
  @override
  late final GeneratedColumn<int> intervalOverrideDays = GeneratedColumn<int>(
    'interval_override_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _socialsMeta = const VerificationMeta(
    'socials',
  );
  @override
  late final GeneratedColumn<String> socials = GeneratedColumn<String>(
    'socials',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hometownMeta = const VerificationMeta(
    'hometown',
  );
  @override
  late final GeneratedColumn<String> hometown = GeneratedColumn<String>(
    'hometown',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastTalkedEstimateMeta =
      const VerificationMeta('lastTalkedEstimate');
  @override
  late final GeneratedColumn<DateTime> lastTalkedEstimate =
      GeneratedColumn<DateTime>(
        'last_talked_estimate',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _snoozedUntilMeta = const VerificationMeta(
    'snoozedUntil',
  );
  @override
  late final GeneratedColumn<DateTime> snoozedUntil = GeneratedColumn<DateTime>(
    'snoozed_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skippedUntilMeta = const VerificationMeta(
    'skippedUntil',
  );
  @override
  late final GeneratedColumn<DateTime> skippedUntil = GeneratedColumn<DateTime>(
    'skipped_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    extra,
    displayName,
    groupId,
    timezone,
    timezoneConfirmed,
    contactMethodType,
    contactMethodValue,
    fullName,
    middleName,
    birthday,
    intervalOverrideDays,
    phone,
    socials,
    hometown,
    lastTalkedEstimate,
    snoozedUntil,
    skippedUntil,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'people';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('extra')) {
      context.handle(
        _extraMeta,
        extra.isAcceptableOrUnknown(data['extra']!, _extraMeta),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    } else if (isInserting) {
      context.missing(_timezoneMeta);
    }
    if (data.containsKey('timezone_confirmed')) {
      context.handle(
        _timezoneConfirmedMeta,
        timezoneConfirmed.isAcceptableOrUnknown(
          data['timezone_confirmed']!,
          _timezoneConfirmedMeta,
        ),
      );
    }
    if (data.containsKey('contact_method_type')) {
      context.handle(
        _contactMethodTypeMeta,
        contactMethodType.isAcceptableOrUnknown(
          data['contact_method_type']!,
          _contactMethodTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contactMethodTypeMeta);
    }
    if (data.containsKey('contact_method_value')) {
      context.handle(
        _contactMethodValueMeta,
        contactMethodValue.isAcceptableOrUnknown(
          data['contact_method_value']!,
          _contactMethodValueMeta,
        ),
      );
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    }
    if (data.containsKey('middle_name')) {
      context.handle(
        _middleNameMeta,
        middleName.isAcceptableOrUnknown(data['middle_name']!, _middleNameMeta),
      );
    }
    if (data.containsKey('birthday')) {
      context.handle(
        _birthdayMeta,
        birthday.isAcceptableOrUnknown(data['birthday']!, _birthdayMeta),
      );
    }
    if (data.containsKey('interval_override_days')) {
      context.handle(
        _intervalOverrideDaysMeta,
        intervalOverrideDays.isAcceptableOrUnknown(
          data['interval_override_days']!,
          _intervalOverrideDaysMeta,
        ),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('socials')) {
      context.handle(
        _socialsMeta,
        socials.isAcceptableOrUnknown(data['socials']!, _socialsMeta),
      );
    }
    if (data.containsKey('hometown')) {
      context.handle(
        _hometownMeta,
        hometown.isAcceptableOrUnknown(data['hometown']!, _hometownMeta),
      );
    }
    if (data.containsKey('last_talked_estimate')) {
      context.handle(
        _lastTalkedEstimateMeta,
        lastTalkedEstimate.isAcceptableOrUnknown(
          data['last_talked_estimate']!,
          _lastTalkedEstimateMeta,
        ),
      );
    }
    if (data.containsKey('snoozed_until')) {
      context.handle(
        _snoozedUntilMeta,
        snoozedUntil.isAcceptableOrUnknown(
          data['snoozed_until']!,
          _snoozedUntilMeta,
        ),
      );
    }
    if (data.containsKey('skipped_until')) {
      context.handle(
        _skippedUntilMeta,
        skippedUntil.isAcceptableOrUnknown(
          data['skipped_until']!,
          _skippedUntilMeta,
        ),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      extra: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extra'],
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      timezoneConfirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}timezone_confirmed'],
      )!,
      contactMethodType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_method_type'],
      )!,
      contactMethodValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_method_value'],
      ),
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      ),
      middleName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}middle_name'],
      ),
      birthday: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birthday'],
      ),
      intervalOverrideDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_override_days'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      socials: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}socials'],
      ),
      hometown: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hometown'],
      ),
      lastTalkedEstimate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_talked_estimate'],
      ),
      snoozedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}snoozed_until'],
      ),
      skippedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}skipped_until'],
      ),
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $PeopleTable createAlias(String alias) {
    return $PeopleTable(attachedDatabase, alias);
  }
}

class PersonRow extends DataClass implements Insertable<PersonRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? extra;
  final String displayName;
  final String groupId;

  /// IANA name, e.g. Europe/Lisbon.
  final String timezone;
  final bool timezoneConfirmed;

  /// text | call | ... (lowercase), plus the number or handle.
  final String contactMethodType;
  final String? contactMethodValue;
  final String? fullName;
  final String? middleName;

  /// 'YYYY-MM-DD', or '--MM-DD' when the year is unknown.
  final String? birthday;
  final int? intervalOverrideDays;
  final String? phone;

  /// JSON list of handles.
  final String? socials;
  final String? hometown;

  /// Seeds a new person's last contact; real chats win once they exist.
  final DateTime? lastTalkedEstimate;
  final DateTime? snoozedUntil;

  /// Skip hides a person until this instant (next local midnight).
  final DateTime? skippedUntil;
  final DateTime? archivedAt;
  const PersonRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.extra,
    required this.displayName,
    required this.groupId,
    required this.timezone,
    required this.timezoneConfirmed,
    required this.contactMethodType,
    this.contactMethodValue,
    this.fullName,
    this.middleName,
    this.birthday,
    this.intervalOverrideDays,
    this.phone,
    this.socials,
    this.hometown,
    this.lastTalkedEstimate,
    this.snoozedUntil,
    this.skippedUntil,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || extra != null) {
      map['extra'] = Variable<String>(extra);
    }
    map['display_name'] = Variable<String>(displayName);
    map['group_id'] = Variable<String>(groupId);
    map['timezone'] = Variable<String>(timezone);
    map['timezone_confirmed'] = Variable<bool>(timezoneConfirmed);
    map['contact_method_type'] = Variable<String>(contactMethodType);
    if (!nullToAbsent || contactMethodValue != null) {
      map['contact_method_value'] = Variable<String>(contactMethodValue);
    }
    if (!nullToAbsent || fullName != null) {
      map['full_name'] = Variable<String>(fullName);
    }
    if (!nullToAbsent || middleName != null) {
      map['middle_name'] = Variable<String>(middleName);
    }
    if (!nullToAbsent || birthday != null) {
      map['birthday'] = Variable<String>(birthday);
    }
    if (!nullToAbsent || intervalOverrideDays != null) {
      map['interval_override_days'] = Variable<int>(intervalOverrideDays);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || socials != null) {
      map['socials'] = Variable<String>(socials);
    }
    if (!nullToAbsent || hometown != null) {
      map['hometown'] = Variable<String>(hometown);
    }
    if (!nullToAbsent || lastTalkedEstimate != null) {
      map['last_talked_estimate'] = Variable<DateTime>(lastTalkedEstimate);
    }
    if (!nullToAbsent || snoozedUntil != null) {
      map['snoozed_until'] = Variable<DateTime>(snoozedUntil);
    }
    if (!nullToAbsent || skippedUntil != null) {
      map['skipped_until'] = Variable<DateTime>(skippedUntil);
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  PeopleCompanion toCompanion(bool nullToAbsent) {
    return PeopleCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      extra: extra == null && nullToAbsent
          ? const Value.absent()
          : Value(extra),
      displayName: Value(displayName),
      groupId: Value(groupId),
      timezone: Value(timezone),
      timezoneConfirmed: Value(timezoneConfirmed),
      contactMethodType: Value(contactMethodType),
      contactMethodValue: contactMethodValue == null && nullToAbsent
          ? const Value.absent()
          : Value(contactMethodValue),
      fullName: fullName == null && nullToAbsent
          ? const Value.absent()
          : Value(fullName),
      middleName: middleName == null && nullToAbsent
          ? const Value.absent()
          : Value(middleName),
      birthday: birthday == null && nullToAbsent
          ? const Value.absent()
          : Value(birthday),
      intervalOverrideDays: intervalOverrideDays == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalOverrideDays),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      socials: socials == null && nullToAbsent
          ? const Value.absent()
          : Value(socials),
      hometown: hometown == null && nullToAbsent
          ? const Value.absent()
          : Value(hometown),
      lastTalkedEstimate: lastTalkedEstimate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastTalkedEstimate),
      snoozedUntil: snoozedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozedUntil),
      skippedUntil: skippedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(skippedUntil),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory PersonRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      extra: serializer.fromJson<String?>(json['extra']),
      displayName: serializer.fromJson<String>(json['displayName']),
      groupId: serializer.fromJson<String>(json['groupId']),
      timezone: serializer.fromJson<String>(json['timezone']),
      timezoneConfirmed: serializer.fromJson<bool>(json['timezoneConfirmed']),
      contactMethodType: serializer.fromJson<String>(json['contactMethodType']),
      contactMethodValue: serializer.fromJson<String?>(
        json['contactMethodValue'],
      ),
      fullName: serializer.fromJson<String?>(json['fullName']),
      middleName: serializer.fromJson<String?>(json['middleName']),
      birthday: serializer.fromJson<String?>(json['birthday']),
      intervalOverrideDays: serializer.fromJson<int?>(
        json['intervalOverrideDays'],
      ),
      phone: serializer.fromJson<String?>(json['phone']),
      socials: serializer.fromJson<String?>(json['socials']),
      hometown: serializer.fromJson<String?>(json['hometown']),
      lastTalkedEstimate: serializer.fromJson<DateTime?>(
        json['lastTalkedEstimate'],
      ),
      snoozedUntil: serializer.fromJson<DateTime?>(json['snoozedUntil']),
      skippedUntil: serializer.fromJson<DateTime?>(json['skippedUntil']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'extra': serializer.toJson<String?>(extra),
      'displayName': serializer.toJson<String>(displayName),
      'groupId': serializer.toJson<String>(groupId),
      'timezone': serializer.toJson<String>(timezone),
      'timezoneConfirmed': serializer.toJson<bool>(timezoneConfirmed),
      'contactMethodType': serializer.toJson<String>(contactMethodType),
      'contactMethodValue': serializer.toJson<String?>(contactMethodValue),
      'fullName': serializer.toJson<String?>(fullName),
      'middleName': serializer.toJson<String?>(middleName),
      'birthday': serializer.toJson<String?>(birthday),
      'intervalOverrideDays': serializer.toJson<int?>(intervalOverrideDays),
      'phone': serializer.toJson<String?>(phone),
      'socials': serializer.toJson<String?>(socials),
      'hometown': serializer.toJson<String?>(hometown),
      'lastTalkedEstimate': serializer.toJson<DateTime?>(lastTalkedEstimate),
      'snoozedUntil': serializer.toJson<DateTime?>(snoozedUntil),
      'skippedUntil': serializer.toJson<DateTime?>(skippedUntil),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  PersonRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> extra = const Value.absent(),
    String? displayName,
    String? groupId,
    String? timezone,
    bool? timezoneConfirmed,
    String? contactMethodType,
    Value<String?> contactMethodValue = const Value.absent(),
    Value<String?> fullName = const Value.absent(),
    Value<String?> middleName = const Value.absent(),
    Value<String?> birthday = const Value.absent(),
    Value<int?> intervalOverrideDays = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> socials = const Value.absent(),
    Value<String?> hometown = const Value.absent(),
    Value<DateTime?> lastTalkedEstimate = const Value.absent(),
    Value<DateTime?> snoozedUntil = const Value.absent(),
    Value<DateTime?> skippedUntil = const Value.absent(),
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => PersonRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    extra: extra.present ? extra.value : this.extra,
    displayName: displayName ?? this.displayName,
    groupId: groupId ?? this.groupId,
    timezone: timezone ?? this.timezone,
    timezoneConfirmed: timezoneConfirmed ?? this.timezoneConfirmed,
    contactMethodType: contactMethodType ?? this.contactMethodType,
    contactMethodValue: contactMethodValue.present
        ? contactMethodValue.value
        : this.contactMethodValue,
    fullName: fullName.present ? fullName.value : this.fullName,
    middleName: middleName.present ? middleName.value : this.middleName,
    birthday: birthday.present ? birthday.value : this.birthday,
    intervalOverrideDays: intervalOverrideDays.present
        ? intervalOverrideDays.value
        : this.intervalOverrideDays,
    phone: phone.present ? phone.value : this.phone,
    socials: socials.present ? socials.value : this.socials,
    hometown: hometown.present ? hometown.value : this.hometown,
    lastTalkedEstimate: lastTalkedEstimate.present
        ? lastTalkedEstimate.value
        : this.lastTalkedEstimate,
    snoozedUntil: snoozedUntil.present ? snoozedUntil.value : this.snoozedUntil,
    skippedUntil: skippedUntil.present ? skippedUntil.value : this.skippedUntil,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  PersonRow copyWithCompanion(PeopleCompanion data) {
    return PersonRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      extra: data.extra.present ? data.extra.value : this.extra,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      timezoneConfirmed: data.timezoneConfirmed.present
          ? data.timezoneConfirmed.value
          : this.timezoneConfirmed,
      contactMethodType: data.contactMethodType.present
          ? data.contactMethodType.value
          : this.contactMethodType,
      contactMethodValue: data.contactMethodValue.present
          ? data.contactMethodValue.value
          : this.contactMethodValue,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      middleName: data.middleName.present
          ? data.middleName.value
          : this.middleName,
      birthday: data.birthday.present ? data.birthday.value : this.birthday,
      intervalOverrideDays: data.intervalOverrideDays.present
          ? data.intervalOverrideDays.value
          : this.intervalOverrideDays,
      phone: data.phone.present ? data.phone.value : this.phone,
      socials: data.socials.present ? data.socials.value : this.socials,
      hometown: data.hometown.present ? data.hometown.value : this.hometown,
      lastTalkedEstimate: data.lastTalkedEstimate.present
          ? data.lastTalkedEstimate.value
          : this.lastTalkedEstimate,
      snoozedUntil: data.snoozedUntil.present
          ? data.snoozedUntil.value
          : this.snoozedUntil,
      skippedUntil: data.skippedUntil.present
          ? data.skippedUntil.value
          : this.skippedUntil,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('extra: $extra, ')
          ..write('displayName: $displayName, ')
          ..write('groupId: $groupId, ')
          ..write('timezone: $timezone, ')
          ..write('timezoneConfirmed: $timezoneConfirmed, ')
          ..write('contactMethodType: $contactMethodType, ')
          ..write('contactMethodValue: $contactMethodValue, ')
          ..write('fullName: $fullName, ')
          ..write('middleName: $middleName, ')
          ..write('birthday: $birthday, ')
          ..write('intervalOverrideDays: $intervalOverrideDays, ')
          ..write('phone: $phone, ')
          ..write('socials: $socials, ')
          ..write('hometown: $hometown, ')
          ..write('lastTalkedEstimate: $lastTalkedEstimate, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('skippedUntil: $skippedUntil, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    createdAt,
    updatedAt,
    deletedAt,
    extra,
    displayName,
    groupId,
    timezone,
    timezoneConfirmed,
    contactMethodType,
    contactMethodValue,
    fullName,
    middleName,
    birthday,
    intervalOverrideDays,
    phone,
    socials,
    hometown,
    lastTalkedEstimate,
    snoozedUntil,
    skippedUntil,
    archivedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.extra == this.extra &&
          other.displayName == this.displayName &&
          other.groupId == this.groupId &&
          other.timezone == this.timezone &&
          other.timezoneConfirmed == this.timezoneConfirmed &&
          other.contactMethodType == this.contactMethodType &&
          other.contactMethodValue == this.contactMethodValue &&
          other.fullName == this.fullName &&
          other.middleName == this.middleName &&
          other.birthday == this.birthday &&
          other.intervalOverrideDays == this.intervalOverrideDays &&
          other.phone == this.phone &&
          other.socials == this.socials &&
          other.hometown == this.hometown &&
          other.lastTalkedEstimate == this.lastTalkedEstimate &&
          other.snoozedUntil == this.snoozedUntil &&
          other.skippedUntil == this.skippedUntil &&
          other.archivedAt == this.archivedAt);
}

class PeopleCompanion extends UpdateCompanion<PersonRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> extra;
  final Value<String> displayName;
  final Value<String> groupId;
  final Value<String> timezone;
  final Value<bool> timezoneConfirmed;
  final Value<String> contactMethodType;
  final Value<String?> contactMethodValue;
  final Value<String?> fullName;
  final Value<String?> middleName;
  final Value<String?> birthday;
  final Value<int?> intervalOverrideDays;
  final Value<String?> phone;
  final Value<String?> socials;
  final Value<String?> hometown;
  final Value<DateTime?> lastTalkedEstimate;
  final Value<DateTime?> snoozedUntil;
  final Value<DateTime?> skippedUntil;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const PeopleCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.extra = const Value.absent(),
    this.displayName = const Value.absent(),
    this.groupId = const Value.absent(),
    this.timezone = const Value.absent(),
    this.timezoneConfirmed = const Value.absent(),
    this.contactMethodType = const Value.absent(),
    this.contactMethodValue = const Value.absent(),
    this.fullName = const Value.absent(),
    this.middleName = const Value.absent(),
    this.birthday = const Value.absent(),
    this.intervalOverrideDays = const Value.absent(),
    this.phone = const Value.absent(),
    this.socials = const Value.absent(),
    this.hometown = const Value.absent(),
    this.lastTalkedEstimate = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.skippedUntil = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PeopleCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.extra = const Value.absent(),
    required String displayName,
    required String groupId,
    required String timezone,
    this.timezoneConfirmed = const Value.absent(),
    required String contactMethodType,
    this.contactMethodValue = const Value.absent(),
    this.fullName = const Value.absent(),
    this.middleName = const Value.absent(),
    this.birthday = const Value.absent(),
    this.intervalOverrideDays = const Value.absent(),
    this.phone = const Value.absent(),
    this.socials = const Value.absent(),
    this.hometown = const Value.absent(),
    this.lastTalkedEstimate = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.skippedUntil = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       displayName = Value(displayName),
       groupId = Value(groupId),
       timezone = Value(timezone),
       contactMethodType = Value(contactMethodType);
  static Insertable<PersonRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? extra,
    Expression<String>? displayName,
    Expression<String>? groupId,
    Expression<String>? timezone,
    Expression<bool>? timezoneConfirmed,
    Expression<String>? contactMethodType,
    Expression<String>? contactMethodValue,
    Expression<String>? fullName,
    Expression<String>? middleName,
    Expression<String>? birthday,
    Expression<int>? intervalOverrideDays,
    Expression<String>? phone,
    Expression<String>? socials,
    Expression<String>? hometown,
    Expression<DateTime>? lastTalkedEstimate,
    Expression<DateTime>? snoozedUntil,
    Expression<DateTime>? skippedUntil,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (extra != null) 'extra': extra,
      if (displayName != null) 'display_name': displayName,
      if (groupId != null) 'group_id': groupId,
      if (timezone != null) 'timezone': timezone,
      if (timezoneConfirmed != null) 'timezone_confirmed': timezoneConfirmed,
      if (contactMethodType != null) 'contact_method_type': contactMethodType,
      if (contactMethodValue != null)
        'contact_method_value': contactMethodValue,
      if (fullName != null) 'full_name': fullName,
      if (middleName != null) 'middle_name': middleName,
      if (birthday != null) 'birthday': birthday,
      if (intervalOverrideDays != null)
        'interval_override_days': intervalOverrideDays,
      if (phone != null) 'phone': phone,
      if (socials != null) 'socials': socials,
      if (hometown != null) 'hometown': hometown,
      if (lastTalkedEstimate != null)
        'last_talked_estimate': lastTalkedEstimate,
      if (snoozedUntil != null) 'snoozed_until': snoozedUntil,
      if (skippedUntil != null) 'skipped_until': skippedUntil,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PeopleCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? extra,
    Value<String>? displayName,
    Value<String>? groupId,
    Value<String>? timezone,
    Value<bool>? timezoneConfirmed,
    Value<String>? contactMethodType,
    Value<String?>? contactMethodValue,
    Value<String?>? fullName,
    Value<String?>? middleName,
    Value<String?>? birthday,
    Value<int?>? intervalOverrideDays,
    Value<String?>? phone,
    Value<String?>? socials,
    Value<String?>? hometown,
    Value<DateTime?>? lastTalkedEstimate,
    Value<DateTime?>? snoozedUntil,
    Value<DateTime?>? skippedUntil,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return PeopleCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      extra: extra ?? this.extra,
      displayName: displayName ?? this.displayName,
      groupId: groupId ?? this.groupId,
      timezone: timezone ?? this.timezone,
      timezoneConfirmed: timezoneConfirmed ?? this.timezoneConfirmed,
      contactMethodType: contactMethodType ?? this.contactMethodType,
      contactMethodValue: contactMethodValue ?? this.contactMethodValue,
      fullName: fullName ?? this.fullName,
      middleName: middleName ?? this.middleName,
      birthday: birthday ?? this.birthday,
      intervalOverrideDays: intervalOverrideDays ?? this.intervalOverrideDays,
      phone: phone ?? this.phone,
      socials: socials ?? this.socials,
      hometown: hometown ?? this.hometown,
      lastTalkedEstimate: lastTalkedEstimate ?? this.lastTalkedEstimate,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      skippedUntil: skippedUntil ?? this.skippedUntil,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (extra.present) {
      map['extra'] = Variable<String>(extra.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (timezoneConfirmed.present) {
      map['timezone_confirmed'] = Variable<bool>(timezoneConfirmed.value);
    }
    if (contactMethodType.present) {
      map['contact_method_type'] = Variable<String>(contactMethodType.value);
    }
    if (contactMethodValue.present) {
      map['contact_method_value'] = Variable<String>(contactMethodValue.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (middleName.present) {
      map['middle_name'] = Variable<String>(middleName.value);
    }
    if (birthday.present) {
      map['birthday'] = Variable<String>(birthday.value);
    }
    if (intervalOverrideDays.present) {
      map['interval_override_days'] = Variable<int>(intervalOverrideDays.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (socials.present) {
      map['socials'] = Variable<String>(socials.value);
    }
    if (hometown.present) {
      map['hometown'] = Variable<String>(hometown.value);
    }
    if (lastTalkedEstimate.present) {
      map['last_talked_estimate'] = Variable<DateTime>(
        lastTalkedEstimate.value,
      );
    }
    if (snoozedUntil.present) {
      map['snoozed_until'] = Variable<DateTime>(snoozedUntil.value);
    }
    if (skippedUntil.present) {
      map['skipped_until'] = Variable<DateTime>(skippedUntil.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeopleCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('extra: $extra, ')
          ..write('displayName: $displayName, ')
          ..write('groupId: $groupId, ')
          ..write('timezone: $timezone, ')
          ..write('timezoneConfirmed: $timezoneConfirmed, ')
          ..write('contactMethodType: $contactMethodType, ')
          ..write('contactMethodValue: $contactMethodValue, ')
          ..write('fullName: $fullName, ')
          ..write('middleName: $middleName, ')
          ..write('birthday: $birthday, ')
          ..write('intervalOverrideDays: $intervalOverrideDays, ')
          ..write('phone: $phone, ')
          ..write('socials: $socials, ')
          ..write('hometown: $hometown, ')
          ..write('lastTalkedEstimate: $lastTalkedEstimate, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('skippedUntil: $skippedUntil, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RelationshipsTable extends Relationships
    with TableInfo<$RelationshipsTable, RelationshipRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RelationshipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extraMeta = const VerificationMeta('extra');
  @override
  late final GeneratedColumn<String> extra = GeneratedColumn<String>(
    'extra',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES people (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relationMeta = const VerificationMeta(
    'relation',
  );
  @override
  late final GeneratedColumn<String> relation = GeneratedColumn<String>(
    'relation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthdayMeta = const VerificationMeta(
    'birthday',
  );
  @override
  late final GeneratedColumn<String> birthday = GeneratedColumn<String>(
    'birthday',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedInChatIdMeta = const VerificationMeta(
    'addedInChatId',
  );
  @override
  late final GeneratedColumn<String> addedInChatId = GeneratedColumn<String>(
    'added_in_chat_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    extra,
    personId,
    name,
    relation,
    birthday,
    addedInChatId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'relationships';
  @override
  VerificationContext validateIntegrity(
    Insertable<RelationshipRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('extra')) {
      context.handle(
        _extraMeta,
        extra.isAcceptableOrUnknown(data['extra']!, _extraMeta),
      );
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('relation')) {
      context.handle(
        _relationMeta,
        relation.isAcceptableOrUnknown(data['relation']!, _relationMeta),
      );
    }
    if (data.containsKey('birthday')) {
      context.handle(
        _birthdayMeta,
        birthday.isAcceptableOrUnknown(data['birthday']!, _birthdayMeta),
      );
    }
    if (data.containsKey('added_in_chat_id')) {
      context.handle(
        _addedInChatIdMeta,
        addedInChatId.isAcceptableOrUnknown(
          data['added_in_chat_id']!,
          _addedInChatIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RelationshipRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RelationshipRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      extra: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extra'],
      ),
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      relation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relation'],
      ),
      birthday: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birthday'],
      ),
      addedInChatId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}added_in_chat_id'],
      ),
    );
  }

  @override
  $RelationshipsTable createAlias(String alias) {
    return $RelationshipsTable(attachedDatabase, alias);
  }
}

class RelationshipRow extends DataClass implements Insertable<RelationshipRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? extra;
  final String personId;
  final String name;
  final String? relation;
  final String? birthday;
  final String? addedInChatId;
  const RelationshipRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.extra,
    required this.personId,
    required this.name,
    this.relation,
    this.birthday,
    this.addedInChatId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || extra != null) {
      map['extra'] = Variable<String>(extra);
    }
    map['person_id'] = Variable<String>(personId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || relation != null) {
      map['relation'] = Variable<String>(relation);
    }
    if (!nullToAbsent || birthday != null) {
      map['birthday'] = Variable<String>(birthday);
    }
    if (!nullToAbsent || addedInChatId != null) {
      map['added_in_chat_id'] = Variable<String>(addedInChatId);
    }
    return map;
  }

  RelationshipsCompanion toCompanion(bool nullToAbsent) {
    return RelationshipsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      extra: extra == null && nullToAbsent
          ? const Value.absent()
          : Value(extra),
      personId: Value(personId),
      name: Value(name),
      relation: relation == null && nullToAbsent
          ? const Value.absent()
          : Value(relation),
      birthday: birthday == null && nullToAbsent
          ? const Value.absent()
          : Value(birthday),
      addedInChatId: addedInChatId == null && nullToAbsent
          ? const Value.absent()
          : Value(addedInChatId),
    );
  }

  factory RelationshipRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RelationshipRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      extra: serializer.fromJson<String?>(json['extra']),
      personId: serializer.fromJson<String>(json['personId']),
      name: serializer.fromJson<String>(json['name']),
      relation: serializer.fromJson<String?>(json['relation']),
      birthday: serializer.fromJson<String?>(json['birthday']),
      addedInChatId: serializer.fromJson<String?>(json['addedInChatId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'extra': serializer.toJson<String?>(extra),
      'personId': serializer.toJson<String>(personId),
      'name': serializer.toJson<String>(name),
      'relation': serializer.toJson<String?>(relation),
      'birthday': serializer.toJson<String?>(birthday),
      'addedInChatId': serializer.toJson<String?>(addedInChatId),
    };
  }

  RelationshipRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> extra = const Value.absent(),
    String? personId,
    String? name,
    Value<String?> relation = const Value.absent(),
    Value<String?> birthday = const Value.absent(),
    Value<String?> addedInChatId = const Value.absent(),
  }) => RelationshipRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    extra: extra.present ? extra.value : this.extra,
    personId: personId ?? this.personId,
    name: name ?? this.name,
    relation: relation.present ? relation.value : this.relation,
    birthday: birthday.present ? birthday.value : this.birthday,
    addedInChatId: addedInChatId.present
        ? addedInChatId.value
        : this.addedInChatId,
  );
  RelationshipRow copyWithCompanion(RelationshipsCompanion data) {
    return RelationshipRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      extra: data.extra.present ? data.extra.value : this.extra,
      personId: data.personId.present ? data.personId.value : this.personId,
      name: data.name.present ? data.name.value : this.name,
      relation: data.relation.present ? data.relation.value : this.relation,
      birthday: data.birthday.present ? data.birthday.value : this.birthday,
      addedInChatId: data.addedInChatId.present
          ? data.addedInChatId.value
          : this.addedInChatId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RelationshipRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('extra: $extra, ')
          ..write('personId: $personId, ')
          ..write('name: $name, ')
          ..write('relation: $relation, ')
          ..write('birthday: $birthday, ')
          ..write('addedInChatId: $addedInChatId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    extra,
    personId,
    name,
    relation,
    birthday,
    addedInChatId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RelationshipRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.extra == this.extra &&
          other.personId == this.personId &&
          other.name == this.name &&
          other.relation == this.relation &&
          other.birthday == this.birthday &&
          other.addedInChatId == this.addedInChatId);
}

class RelationshipsCompanion extends UpdateCompanion<RelationshipRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> extra;
  final Value<String> personId;
  final Value<String> name;
  final Value<String?> relation;
  final Value<String?> birthday;
  final Value<String?> addedInChatId;
  final Value<int> rowid;
  const RelationshipsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.extra = const Value.absent(),
    this.personId = const Value.absent(),
    this.name = const Value.absent(),
    this.relation = const Value.absent(),
    this.birthday = const Value.absent(),
    this.addedInChatId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RelationshipsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.extra = const Value.absent(),
    required String personId,
    required String name,
    this.relation = const Value.absent(),
    this.birthday = const Value.absent(),
    this.addedInChatId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       personId = Value(personId),
       name = Value(name);
  static Insertable<RelationshipRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? extra,
    Expression<String>? personId,
    Expression<String>? name,
    Expression<String>? relation,
    Expression<String>? birthday,
    Expression<String>? addedInChatId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (extra != null) 'extra': extra,
      if (personId != null) 'person_id': personId,
      if (name != null) 'name': name,
      if (relation != null) 'relation': relation,
      if (birthday != null) 'birthday': birthday,
      if (addedInChatId != null) 'added_in_chat_id': addedInChatId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RelationshipsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? extra,
    Value<String>? personId,
    Value<String>? name,
    Value<String?>? relation,
    Value<String?>? birthday,
    Value<String?>? addedInChatId,
    Value<int>? rowid,
  }) {
    return RelationshipsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      extra: extra ?? this.extra,
      personId: personId ?? this.personId,
      name: name ?? this.name,
      relation: relation ?? this.relation,
      birthday: birthday ?? this.birthday,
      addedInChatId: addedInChatId ?? this.addedInChatId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (extra.present) {
      map['extra'] = Variable<String>(extra.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (relation.present) {
      map['relation'] = Variable<String>(relation.value);
    }
    if (birthday.present) {
      map['birthday'] = Variable<String>(birthday.value);
    }
    if (addedInChatId.present) {
      map['added_in_chat_id'] = Variable<String>(addedInChatId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RelationshipsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('extra: $extra, ')
          ..write('personId: $personId, ')
          ..write('name: $name, ')
          ..write('relation: $relation, ')
          ..write('birthday: $birthday, ')
          ..write('addedInChatId: $addedInChatId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatsTable extends Chats with TableInfo<$ChatsTable, ChatRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extraMeta = const VerificationMeta('extra');
  @override
  late final GeneratedColumn<String> extra = GeneratedColumn<String>(
    'extra',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES people (id)',
    ),
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeApproximateMeta = const VerificationMeta(
    'timeApproximate',
  );
  @override
  late final GeneratedColumn<bool> timeApproximate = GeneratedColumn<bool>(
    'time_approximate',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("time_approximate" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _depthMeta = const VerificationMeta('depth');
  @override
  late final GeneratedColumn<String> depth = GeneratedColumn<String>(
    'depth',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lengthMeta = const VerificationMeta('length');
  @override
  late final GeneratedColumn<String> length = GeneratedColumn<String>(
    'length',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feelingsMeta = const VerificationMeta(
    'feelings',
  );
  @override
  late final GeneratedColumn<String> feelings = GeneratedColumn<String>(
    'feelings',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _callIdMeta = const VerificationMeta('callId');
  @override
  late final GeneratedColumn<String> callId = GeneratedColumn<String>(
    'call_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    extra,
    personId,
    occurredAt,
    timeApproximate,
    type,
    depth,
    durationMinutes,
    length,
    feelings,
    note,
    source,
    callId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chats';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('extra')) {
      context.handle(
        _extraMeta,
        extra.isAcceptableOrUnknown(data['extra']!, _extraMeta),
      );
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('time_approximate')) {
      context.handle(
        _timeApproximateMeta,
        timeApproximate.isAcceptableOrUnknown(
          data['time_approximate']!,
          _timeApproximateMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('depth')) {
      context.handle(
        _depthMeta,
        depth.isAcceptableOrUnknown(data['depth']!, _depthMeta),
      );
    } else if (isInserting) {
      context.missing(_depthMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('length')) {
      context.handle(
        _lengthMeta,
        length.isAcceptableOrUnknown(data['length']!, _lengthMeta),
      );
    } else if (isInserting) {
      context.missing(_lengthMeta);
    }
    if (data.containsKey('feelings')) {
      context.handle(
        _feelingsMeta,
        feelings.isAcceptableOrUnknown(data['feelings']!, _feelingsMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('call_id')) {
      context.handle(
        _callIdMeta,
        callId.isAcceptableOrUnknown(data['call_id']!, _callIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      extra: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extra'],
      ),
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      timeApproximate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}time_approximate'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      depth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}depth'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      ),
      length: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}length'],
      )!,
      feelings: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feelings'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      callId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}call_id'],
      ),
    );
  }

  @override
  $ChatsTable createAlias(String alias) {
    return $ChatsTable(attachedDatabase, alias);
  }
}

class ChatRow extends DataClass implements Insertable<ChatRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? extra;
  final String personId;
  final DateTime occurredAt;

  /// True for other-day logs (stored as 12:00 local); availability learning
  /// ignores the time of such chats.
  final bool timeApproximate;

  /// person | call | text
  final String type;

  /// shallow | varied | deep
  final String depth;

  /// 1 to 60, where 60 means 60 or more.
  final int? durationMinutes;

  /// quick | catchup | long (derived from duration but stored for old chats).
  final String length;

  /// JSON list.
  final String? feelings;
  final String? note;
  final String source;
  final String? callId;
  const ChatRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.extra,
    required this.personId,
    required this.occurredAt,
    required this.timeApproximate,
    required this.type,
    required this.depth,
    this.durationMinutes,
    required this.length,
    this.feelings,
    this.note,
    required this.source,
    this.callId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || extra != null) {
      map['extra'] = Variable<String>(extra);
    }
    map['person_id'] = Variable<String>(personId);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['time_approximate'] = Variable<bool>(timeApproximate);
    map['type'] = Variable<String>(type);
    map['depth'] = Variable<String>(depth);
    if (!nullToAbsent || durationMinutes != null) {
      map['duration_minutes'] = Variable<int>(durationMinutes);
    }
    map['length'] = Variable<String>(length);
    if (!nullToAbsent || feelings != null) {
      map['feelings'] = Variable<String>(feelings);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || callId != null) {
      map['call_id'] = Variable<String>(callId);
    }
    return map;
  }

  ChatsCompanion toCompanion(bool nullToAbsent) {
    return ChatsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      extra: extra == null && nullToAbsent
          ? const Value.absent()
          : Value(extra),
      personId: Value(personId),
      occurredAt: Value(occurredAt),
      timeApproximate: Value(timeApproximate),
      type: Value(type),
      depth: Value(depth),
      durationMinutes: durationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMinutes),
      length: Value(length),
      feelings: feelings == null && nullToAbsent
          ? const Value.absent()
          : Value(feelings),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      source: Value(source),
      callId: callId == null && nullToAbsent
          ? const Value.absent()
          : Value(callId),
    );
  }

  factory ChatRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      extra: serializer.fromJson<String?>(json['extra']),
      personId: serializer.fromJson<String>(json['personId']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      timeApproximate: serializer.fromJson<bool>(json['timeApproximate']),
      type: serializer.fromJson<String>(json['type']),
      depth: serializer.fromJson<String>(json['depth']),
      durationMinutes: serializer.fromJson<int?>(json['durationMinutes']),
      length: serializer.fromJson<String>(json['length']),
      feelings: serializer.fromJson<String?>(json['feelings']),
      note: serializer.fromJson<String?>(json['note']),
      source: serializer.fromJson<String>(json['source']),
      callId: serializer.fromJson<String?>(json['callId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'extra': serializer.toJson<String?>(extra),
      'personId': serializer.toJson<String>(personId),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'timeApproximate': serializer.toJson<bool>(timeApproximate),
      'type': serializer.toJson<String>(type),
      'depth': serializer.toJson<String>(depth),
      'durationMinutes': serializer.toJson<int?>(durationMinutes),
      'length': serializer.toJson<String>(length),
      'feelings': serializer.toJson<String?>(feelings),
      'note': serializer.toJson<String?>(note),
      'source': serializer.toJson<String>(source),
      'callId': serializer.toJson<String?>(callId),
    };
  }

  ChatRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> extra = const Value.absent(),
    String? personId,
    DateTime? occurredAt,
    bool? timeApproximate,
    String? type,
    String? depth,
    Value<int?> durationMinutes = const Value.absent(),
    String? length,
    Value<String?> feelings = const Value.absent(),
    Value<String?> note = const Value.absent(),
    String? source,
    Value<String?> callId = const Value.absent(),
  }) => ChatRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    extra: extra.present ? extra.value : this.extra,
    personId: personId ?? this.personId,
    occurredAt: occurredAt ?? this.occurredAt,
    timeApproximate: timeApproximate ?? this.timeApproximate,
    type: type ?? this.type,
    depth: depth ?? this.depth,
    durationMinutes: durationMinutes.present
        ? durationMinutes.value
        : this.durationMinutes,
    length: length ?? this.length,
    feelings: feelings.present ? feelings.value : this.feelings,
    note: note.present ? note.value : this.note,
    source: source ?? this.source,
    callId: callId.present ? callId.value : this.callId,
  );
  ChatRow copyWithCompanion(ChatsCompanion data) {
    return ChatRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      extra: data.extra.present ? data.extra.value : this.extra,
      personId: data.personId.present ? data.personId.value : this.personId,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      timeApproximate: data.timeApproximate.present
          ? data.timeApproximate.value
          : this.timeApproximate,
      type: data.type.present ? data.type.value : this.type,
      depth: data.depth.present ? data.depth.value : this.depth,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      length: data.length.present ? data.length.value : this.length,
      feelings: data.feelings.present ? data.feelings.value : this.feelings,
      note: data.note.present ? data.note.value : this.note,
      source: data.source.present ? data.source.value : this.source,
      callId: data.callId.present ? data.callId.value : this.callId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('extra: $extra, ')
          ..write('personId: $personId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('timeApproximate: $timeApproximate, ')
          ..write('type: $type, ')
          ..write('depth: $depth, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('length: $length, ')
          ..write('feelings: $feelings, ')
          ..write('note: $note, ')
          ..write('source: $source, ')
          ..write('callId: $callId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    extra,
    personId,
    occurredAt,
    timeApproximate,
    type,
    depth,
    durationMinutes,
    length,
    feelings,
    note,
    source,
    callId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.extra == this.extra &&
          other.personId == this.personId &&
          other.occurredAt == this.occurredAt &&
          other.timeApproximate == this.timeApproximate &&
          other.type == this.type &&
          other.depth == this.depth &&
          other.durationMinutes == this.durationMinutes &&
          other.length == this.length &&
          other.feelings == this.feelings &&
          other.note == this.note &&
          other.source == this.source &&
          other.callId == this.callId);
}

class ChatsCompanion extends UpdateCompanion<ChatRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> extra;
  final Value<String> personId;
  final Value<DateTime> occurredAt;
  final Value<bool> timeApproximate;
  final Value<String> type;
  final Value<String> depth;
  final Value<int?> durationMinutes;
  final Value<String> length;
  final Value<String?> feelings;
  final Value<String?> note;
  final Value<String> source;
  final Value<String?> callId;
  final Value<int> rowid;
  const ChatsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.extra = const Value.absent(),
    this.personId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.timeApproximate = const Value.absent(),
    this.type = const Value.absent(),
    this.depth = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.length = const Value.absent(),
    this.feelings = const Value.absent(),
    this.note = const Value.absent(),
    this.source = const Value.absent(),
    this.callId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.extra = const Value.absent(),
    required String personId,
    required DateTime occurredAt,
    this.timeApproximate = const Value.absent(),
    required String type,
    required String depth,
    this.durationMinutes = const Value.absent(),
    required String length,
    this.feelings = const Value.absent(),
    this.note = const Value.absent(),
    this.source = const Value.absent(),
    this.callId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       personId = Value(personId),
       occurredAt = Value(occurredAt),
       type = Value(type),
       depth = Value(depth),
       length = Value(length);
  static Insertable<ChatRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? extra,
    Expression<String>? personId,
    Expression<DateTime>? occurredAt,
    Expression<bool>? timeApproximate,
    Expression<String>? type,
    Expression<String>? depth,
    Expression<int>? durationMinutes,
    Expression<String>? length,
    Expression<String>? feelings,
    Expression<String>? note,
    Expression<String>? source,
    Expression<String>? callId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (extra != null) 'extra': extra,
      if (personId != null) 'person_id': personId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (timeApproximate != null) 'time_approximate': timeApproximate,
      if (type != null) 'type': type,
      if (depth != null) 'depth': depth,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (length != null) 'length': length,
      if (feelings != null) 'feelings': feelings,
      if (note != null) 'note': note,
      if (source != null) 'source': source,
      if (callId != null) 'call_id': callId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? extra,
    Value<String>? personId,
    Value<DateTime>? occurredAt,
    Value<bool>? timeApproximate,
    Value<String>? type,
    Value<String>? depth,
    Value<int?>? durationMinutes,
    Value<String>? length,
    Value<String?>? feelings,
    Value<String?>? note,
    Value<String>? source,
    Value<String?>? callId,
    Value<int>? rowid,
  }) {
    return ChatsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      extra: extra ?? this.extra,
      personId: personId ?? this.personId,
      occurredAt: occurredAt ?? this.occurredAt,
      timeApproximate: timeApproximate ?? this.timeApproximate,
      type: type ?? this.type,
      depth: depth ?? this.depth,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      length: length ?? this.length,
      feelings: feelings ?? this.feelings,
      note: note ?? this.note,
      source: source ?? this.source,
      callId: callId ?? this.callId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (extra.present) {
      map['extra'] = Variable<String>(extra.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (timeApproximate.present) {
      map['time_approximate'] = Variable<bool>(timeApproximate.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (depth.present) {
      map['depth'] = Variable<String>(depth.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (length.present) {
      map['length'] = Variable<String>(length.value);
    }
    if (feelings.present) {
      map['feelings'] = Variable<String>(feelings.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (callId.present) {
      map['call_id'] = Variable<String>(callId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('extra: $extra, ')
          ..write('personId: $personId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('timeApproximate: $timeApproximate, ')
          ..write('type: $type, ')
          ..write('depth: $depth, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('length: $length, ')
          ..write('feelings: $feelings, ')
          ..write('note: $note, ')
          ..write('source: $source, ')
          ..write('callId: $callId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LinesTable extends Lines with TableInfo<$LinesTable, LineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extraMeta = const VerificationMeta('extra');
  @override
  late final GeneratedColumn<String> extra = GeneratedColumn<String>(
    'extra',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES people (id)',
    ),
  );
  static const VerificationMeta _blockMeta = const VerificationMeta('block');
  @override
  late final GeneratedColumn<String> block = GeneratedColumn<String>(
    'block',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineTextMeta = const VerificationMeta(
    'lineText',
  );
  @override
  late final GeneratedColumn<String> lineText = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _doneAtMeta = const VerificationMeta('doneAt');
  @override
  late final GeneratedColumn<DateTime> doneAt = GeneratedColumn<DateTime>(
    'done_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<String> chatId = GeneratedColumn<String>(
    'chat_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relationshipIdMeta = const VerificationMeta(
    'relationshipId',
  );
  @override
  late final GeneratedColumn<String> relationshipId = GeneratedColumn<String>(
    'relationship_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedInChatIdMeta = const VerificationMeta(
    'addedInChatId',
  );
  @override
  late final GeneratedColumn<String> addedInChatId = GeneratedColumn<String>(
    'added_in_chat_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    extra,
    personId,
    block,
    lineText,
    done,
    doneAt,
    chatId,
    relationshipId,
    addedInChatId,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<LineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('extra')) {
      context.handle(
        _extraMeta,
        extra.isAcceptableOrUnknown(data['extra']!, _extraMeta),
      );
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('block')) {
      context.handle(
        _blockMeta,
        block.isAcceptableOrUnknown(data['block']!, _blockMeta),
      );
    } else if (isInserting) {
      context.missing(_blockMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _lineTextMeta,
        lineText.isAcceptableOrUnknown(data['text']!, _lineTextMeta),
      );
    } else if (isInserting) {
      context.missing(_lineTextMeta);
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    if (data.containsKey('done_at')) {
      context.handle(
        _doneAtMeta,
        doneAt.isAcceptableOrUnknown(data['done_at']!, _doneAtMeta),
      );
    }
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    }
    if (data.containsKey('relationship_id')) {
      context.handle(
        _relationshipIdMeta,
        relationshipId.isAcceptableOrUnknown(
          data['relationship_id']!,
          _relationshipIdMeta,
        ),
      );
    }
    if (data.containsKey('added_in_chat_id')) {
      context.handle(
        _addedInChatIdMeta,
        addedInChatId.isAcceptableOrUnknown(
          data['added_in_chat_id']!,
          _addedInChatIdMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LineRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      extra: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extra'],
      ),
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      )!,
      block: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}block'],
      )!,
      lineText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
      doneAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}done_at'],
      ),
      chatId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chat_id'],
      ),
      relationshipId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relationship_id'],
      ),
      addedInChatId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}added_in_chat_id'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $LinesTable createAlias(String alias) {
    return $LinesTable(attachedDatabase, alias);
  }
}

class LineRow extends DataClass implements Insertable<LineRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? extra;
  final String personId;

  /// next_time | interests | about | family | custom block key
  final String block;
  final String lineText;
  final bool done;
  final DateTime? doneAt;

  /// Chat this Next time item was covered in.
  final String? chatId;
  final String? relationshipId;

  /// Chat popup that added this line.
  final String? addedInChatId;
  final int sortOrder;
  const LineRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.extra,
    required this.personId,
    required this.block,
    required this.lineText,
    required this.done,
    this.doneAt,
    this.chatId,
    this.relationshipId,
    this.addedInChatId,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || extra != null) {
      map['extra'] = Variable<String>(extra);
    }
    map['person_id'] = Variable<String>(personId);
    map['block'] = Variable<String>(block);
    map['text'] = Variable<String>(lineText);
    map['done'] = Variable<bool>(done);
    if (!nullToAbsent || doneAt != null) {
      map['done_at'] = Variable<DateTime>(doneAt);
    }
    if (!nullToAbsent || chatId != null) {
      map['chat_id'] = Variable<String>(chatId);
    }
    if (!nullToAbsent || relationshipId != null) {
      map['relationship_id'] = Variable<String>(relationshipId);
    }
    if (!nullToAbsent || addedInChatId != null) {
      map['added_in_chat_id'] = Variable<String>(addedInChatId);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  LinesCompanion toCompanion(bool nullToAbsent) {
    return LinesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      extra: extra == null && nullToAbsent
          ? const Value.absent()
          : Value(extra),
      personId: Value(personId),
      block: Value(block),
      lineText: Value(lineText),
      done: Value(done),
      doneAt: doneAt == null && nullToAbsent
          ? const Value.absent()
          : Value(doneAt),
      chatId: chatId == null && nullToAbsent
          ? const Value.absent()
          : Value(chatId),
      relationshipId: relationshipId == null && nullToAbsent
          ? const Value.absent()
          : Value(relationshipId),
      addedInChatId: addedInChatId == null && nullToAbsent
          ? const Value.absent()
          : Value(addedInChatId),
      sortOrder: Value(sortOrder),
    );
  }

  factory LineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LineRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      extra: serializer.fromJson<String?>(json['extra']),
      personId: serializer.fromJson<String>(json['personId']),
      block: serializer.fromJson<String>(json['block']),
      lineText: serializer.fromJson<String>(json['lineText']),
      done: serializer.fromJson<bool>(json['done']),
      doneAt: serializer.fromJson<DateTime?>(json['doneAt']),
      chatId: serializer.fromJson<String?>(json['chatId']),
      relationshipId: serializer.fromJson<String?>(json['relationshipId']),
      addedInChatId: serializer.fromJson<String?>(json['addedInChatId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'extra': serializer.toJson<String?>(extra),
      'personId': serializer.toJson<String>(personId),
      'block': serializer.toJson<String>(block),
      'lineText': serializer.toJson<String>(lineText),
      'done': serializer.toJson<bool>(done),
      'doneAt': serializer.toJson<DateTime?>(doneAt),
      'chatId': serializer.toJson<String?>(chatId),
      'relationshipId': serializer.toJson<String?>(relationshipId),
      'addedInChatId': serializer.toJson<String?>(addedInChatId),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  LineRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> extra = const Value.absent(),
    String? personId,
    String? block,
    String? lineText,
    bool? done,
    Value<DateTime?> doneAt = const Value.absent(),
    Value<String?> chatId = const Value.absent(),
    Value<String?> relationshipId = const Value.absent(),
    Value<String?> addedInChatId = const Value.absent(),
    int? sortOrder,
  }) => LineRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    extra: extra.present ? extra.value : this.extra,
    personId: personId ?? this.personId,
    block: block ?? this.block,
    lineText: lineText ?? this.lineText,
    done: done ?? this.done,
    doneAt: doneAt.present ? doneAt.value : this.doneAt,
    chatId: chatId.present ? chatId.value : this.chatId,
    relationshipId: relationshipId.present
        ? relationshipId.value
        : this.relationshipId,
    addedInChatId: addedInChatId.present
        ? addedInChatId.value
        : this.addedInChatId,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  LineRow copyWithCompanion(LinesCompanion data) {
    return LineRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      extra: data.extra.present ? data.extra.value : this.extra,
      personId: data.personId.present ? data.personId.value : this.personId,
      block: data.block.present ? data.block.value : this.block,
      lineText: data.lineText.present ? data.lineText.value : this.lineText,
      done: data.done.present ? data.done.value : this.done,
      doneAt: data.doneAt.present ? data.doneAt.value : this.doneAt,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      relationshipId: data.relationshipId.present
          ? data.relationshipId.value
          : this.relationshipId,
      addedInChatId: data.addedInChatId.present
          ? data.addedInChatId.value
          : this.addedInChatId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LineRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('extra: $extra, ')
          ..write('personId: $personId, ')
          ..write('block: $block, ')
          ..write('lineText: $lineText, ')
          ..write('done: $done, ')
          ..write('doneAt: $doneAt, ')
          ..write('chatId: $chatId, ')
          ..write('relationshipId: $relationshipId, ')
          ..write('addedInChatId: $addedInChatId, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    extra,
    personId,
    block,
    lineText,
    done,
    doneAt,
    chatId,
    relationshipId,
    addedInChatId,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LineRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.extra == this.extra &&
          other.personId == this.personId &&
          other.block == this.block &&
          other.lineText == this.lineText &&
          other.done == this.done &&
          other.doneAt == this.doneAt &&
          other.chatId == this.chatId &&
          other.relationshipId == this.relationshipId &&
          other.addedInChatId == this.addedInChatId &&
          other.sortOrder == this.sortOrder);
}

class LinesCompanion extends UpdateCompanion<LineRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> extra;
  final Value<String> personId;
  final Value<String> block;
  final Value<String> lineText;
  final Value<bool> done;
  final Value<DateTime?> doneAt;
  final Value<String?> chatId;
  final Value<String?> relationshipId;
  final Value<String?> addedInChatId;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const LinesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.extra = const Value.absent(),
    this.personId = const Value.absent(),
    this.block = const Value.absent(),
    this.lineText = const Value.absent(),
    this.done = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.chatId = const Value.absent(),
    this.relationshipId = const Value.absent(),
    this.addedInChatId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LinesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.extra = const Value.absent(),
    required String personId,
    required String block,
    required String lineText,
    this.done = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.chatId = const Value.absent(),
    this.relationshipId = const Value.absent(),
    this.addedInChatId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       personId = Value(personId),
       block = Value(block),
       lineText = Value(lineText);
  static Insertable<LineRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? extra,
    Expression<String>? personId,
    Expression<String>? block,
    Expression<String>? lineText,
    Expression<bool>? done,
    Expression<DateTime>? doneAt,
    Expression<String>? chatId,
    Expression<String>? relationshipId,
    Expression<String>? addedInChatId,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (extra != null) 'extra': extra,
      if (personId != null) 'person_id': personId,
      if (block != null) 'block': block,
      if (lineText != null) 'text': lineText,
      if (done != null) 'done': done,
      if (doneAt != null) 'done_at': doneAt,
      if (chatId != null) 'chat_id': chatId,
      if (relationshipId != null) 'relationship_id': relationshipId,
      if (addedInChatId != null) 'added_in_chat_id': addedInChatId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LinesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? extra,
    Value<String>? personId,
    Value<String>? block,
    Value<String>? lineText,
    Value<bool>? done,
    Value<DateTime?>? doneAt,
    Value<String?>? chatId,
    Value<String?>? relationshipId,
    Value<String?>? addedInChatId,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return LinesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      extra: extra ?? this.extra,
      personId: personId ?? this.personId,
      block: block ?? this.block,
      lineText: lineText ?? this.lineText,
      done: done ?? this.done,
      doneAt: doneAt ?? this.doneAt,
      chatId: chatId ?? this.chatId,
      relationshipId: relationshipId ?? this.relationshipId,
      addedInChatId: addedInChatId ?? this.addedInChatId,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (extra.present) {
      map['extra'] = Variable<String>(extra.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (block.present) {
      map['block'] = Variable<String>(block.value);
    }
    if (lineText.present) {
      map['text'] = Variable<String>(lineText.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (doneAt.present) {
      map['done_at'] = Variable<DateTime>(doneAt.value);
    }
    if (chatId.present) {
      map['chat_id'] = Variable<String>(chatId.value);
    }
    if (relationshipId.present) {
      map['relationship_id'] = Variable<String>(relationshipId.value);
    }
    if (addedInChatId.present) {
      map['added_in_chat_id'] = Variable<String>(addedInChatId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LinesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('extra: $extra, ')
          ..write('personId: $personId, ')
          ..write('block: $block, ')
          ..write('lineText: $lineText, ')
          ..write('done: $done, ')
          ..write('doneAt: $doneAt, ')
          ..write('chatId: $chatId, ')
          ..write('relationshipId: $relationshipId, ')
          ..write('addedInChatId: $addedInChatId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImportantDatesTable extends ImportantDates
    with TableInfo<$ImportantDatesTable, ImportantDateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportantDatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extraMeta = const VerificationMeta('extra');
  @override
  late final GeneratedColumn<String> extra = GeneratedColumn<String>(
    'extra',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES people (id)',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repeatsYearlyMeta = const VerificationMeta(
    'repeatsYearly',
  );
  @override
  late final GeneratedColumn<bool> repeatsYearly = GeneratedColumn<bool>(
    'repeats_yearly',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("repeats_yearly" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    extra,
    personId,
    label,
    date,
    repeatsYearly,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'important_dates';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportantDateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('extra')) {
      context.handle(
        _extraMeta,
        extra.isAcceptableOrUnknown(data['extra']!, _extraMeta),
      );
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('repeats_yearly')) {
      context.handle(
        _repeatsYearlyMeta,
        repeatsYearly.isAcceptableOrUnknown(
          data['repeats_yearly']!,
          _repeatsYearlyMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportantDateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportantDateRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      extra: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extra'],
      ),
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      repeatsYearly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}repeats_yearly'],
      )!,
    );
  }

  @override
  $ImportantDatesTable createAlias(String alias) {
    return $ImportantDatesTable(attachedDatabase, alias);
  }
}

class ImportantDateRow extends DataClass
    implements Insertable<ImportantDateRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? extra;
  final String personId;
  final String label;
  final String date;
  final bool repeatsYearly;
  const ImportantDateRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.extra,
    required this.personId,
    required this.label,
    required this.date,
    required this.repeatsYearly,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || extra != null) {
      map['extra'] = Variable<String>(extra);
    }
    map['person_id'] = Variable<String>(personId);
    map['label'] = Variable<String>(label);
    map['date'] = Variable<String>(date);
    map['repeats_yearly'] = Variable<bool>(repeatsYearly);
    return map;
  }

  ImportantDatesCompanion toCompanion(bool nullToAbsent) {
    return ImportantDatesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      extra: extra == null && nullToAbsent
          ? const Value.absent()
          : Value(extra),
      personId: Value(personId),
      label: Value(label),
      date: Value(date),
      repeatsYearly: Value(repeatsYearly),
    );
  }

  factory ImportantDateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportantDateRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      extra: serializer.fromJson<String?>(json['extra']),
      personId: serializer.fromJson<String>(json['personId']),
      label: serializer.fromJson<String>(json['label']),
      date: serializer.fromJson<String>(json['date']),
      repeatsYearly: serializer.fromJson<bool>(json['repeatsYearly']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'extra': serializer.toJson<String?>(extra),
      'personId': serializer.toJson<String>(personId),
      'label': serializer.toJson<String>(label),
      'date': serializer.toJson<String>(date),
      'repeatsYearly': serializer.toJson<bool>(repeatsYearly),
    };
  }

  ImportantDateRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> extra = const Value.absent(),
    String? personId,
    String? label,
    String? date,
    bool? repeatsYearly,
  }) => ImportantDateRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    extra: extra.present ? extra.value : this.extra,
    personId: personId ?? this.personId,
    label: label ?? this.label,
    date: date ?? this.date,
    repeatsYearly: repeatsYearly ?? this.repeatsYearly,
  );
  ImportantDateRow copyWithCompanion(ImportantDatesCompanion data) {
    return ImportantDateRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      extra: data.extra.present ? data.extra.value : this.extra,
      personId: data.personId.present ? data.personId.value : this.personId,
      label: data.label.present ? data.label.value : this.label,
      date: data.date.present ? data.date.value : this.date,
      repeatsYearly: data.repeatsYearly.present
          ? data.repeatsYearly.value
          : this.repeatsYearly,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportantDateRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('extra: $extra, ')
          ..write('personId: $personId, ')
          ..write('label: $label, ')
          ..write('date: $date, ')
          ..write('repeatsYearly: $repeatsYearly')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    extra,
    personId,
    label,
    date,
    repeatsYearly,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportantDateRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.extra == this.extra &&
          other.personId == this.personId &&
          other.label == this.label &&
          other.date == this.date &&
          other.repeatsYearly == this.repeatsYearly);
}

class ImportantDatesCompanion extends UpdateCompanion<ImportantDateRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> extra;
  final Value<String> personId;
  final Value<String> label;
  final Value<String> date;
  final Value<bool> repeatsYearly;
  final Value<int> rowid;
  const ImportantDatesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.extra = const Value.absent(),
    this.personId = const Value.absent(),
    this.label = const Value.absent(),
    this.date = const Value.absent(),
    this.repeatsYearly = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportantDatesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.extra = const Value.absent(),
    required String personId,
    required String label,
    required String date,
    this.repeatsYearly = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       personId = Value(personId),
       label = Value(label),
       date = Value(date);
  static Insertable<ImportantDateRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? extra,
    Expression<String>? personId,
    Expression<String>? label,
    Expression<String>? date,
    Expression<bool>? repeatsYearly,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (extra != null) 'extra': extra,
      if (personId != null) 'person_id': personId,
      if (label != null) 'label': label,
      if (date != null) 'date': date,
      if (repeatsYearly != null) 'repeats_yearly': repeatsYearly,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportantDatesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? extra,
    Value<String>? personId,
    Value<String>? label,
    Value<String>? date,
    Value<bool>? repeatsYearly,
    Value<int>? rowid,
  }) {
    return ImportantDatesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      extra: extra ?? this.extra,
      personId: personId ?? this.personId,
      label: label ?? this.label,
      date: date ?? this.date,
      repeatsYearly: repeatsYearly ?? this.repeatsYearly,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (extra.present) {
      map['extra'] = Variable<String>(extra.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (repeatsYearly.present) {
      map['repeats_yearly'] = Variable<bool>(repeatsYearly.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportantDatesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('extra: $extra, ')
          ..write('personId: $personId, ')
          ..write('label: $label, ')
          ..write('date: $date, ')
          ..write('repeatsYearly: $repeatsYearly, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomBlocksTable extends CustomBlocks
    with TableInfo<$CustomBlocksTable, CustomBlockRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomBlocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extraMeta = const VerificationMeta('extra');
  @override
  late final GeneratedColumn<String> extra = GeneratedColumn<String>(
    'extra',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    extra,
    key,
    name,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_blocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomBlockRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('extra')) {
      context.handle(
        _extraMeta,
        extra.isAcceptableOrUnknown(data['extra']!, _extraMeta),
      );
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomBlockRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomBlockRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      extra: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extra'],
      ),
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CustomBlocksTable createAlias(String alias) {
    return $CustomBlocksTable(attachedDatabase, alias);
  }
}

class CustomBlockRow extends DataClass implements Insertable<CustomBlockRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? extra;
  final String key;
  final String name;
  final int sortOrder;
  const CustomBlockRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.extra,
    required this.key,
    required this.name,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || extra != null) {
      map['extra'] = Variable<String>(extra);
    }
    map['key'] = Variable<String>(key);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CustomBlocksCompanion toCompanion(bool nullToAbsent) {
    return CustomBlocksCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      extra: extra == null && nullToAbsent
          ? const Value.absent()
          : Value(extra),
      key: Value(key),
      name: Value(name),
      sortOrder: Value(sortOrder),
    );
  }

  factory CustomBlockRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomBlockRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      extra: serializer.fromJson<String?>(json['extra']),
      key: serializer.fromJson<String>(json['key']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'extra': serializer.toJson<String?>(extra),
      'key': serializer.toJson<String>(key),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CustomBlockRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> extra = const Value.absent(),
    String? key,
    String? name,
    int? sortOrder,
  }) => CustomBlockRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    extra: extra.present ? extra.value : this.extra,
    key: key ?? this.key,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  CustomBlockRow copyWithCompanion(CustomBlocksCompanion data) {
    return CustomBlockRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      extra: data.extra.present ? data.extra.value : this.extra,
      key: data.key.present ? data.key.value : this.key,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomBlockRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('extra: $extra, ')
          ..write('key: $key, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    extra,
    key,
    name,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomBlockRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.extra == this.extra &&
          other.key == this.key &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder);
}

class CustomBlocksCompanion extends UpdateCompanion<CustomBlockRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> extra;
  final Value<String> key;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CustomBlocksCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.extra = const Value.absent(),
    this.key = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomBlocksCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.extra = const Value.absent(),
    required String key,
    required String name,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       key = Value(key),
       name = Value(name);
  static Insertable<CustomBlockRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? extra,
    Expression<String>? key,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (extra != null) 'extra': extra,
      if (key != null) 'key': key,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomBlocksCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? extra,
    Value<String>? key,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return CustomBlocksCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      extra: extra ?? this.extra,
      key: key ?? this.key,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (extra.present) {
      map['extra'] = Variable<String>(extra.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomBlocksCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('extra: $extra, ')
          ..write('key: $key, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LatelyDatabase extends GeneratedDatabase {
  _$LatelyDatabase(QueryExecutor e) : super(e);
  $LatelyDatabaseManager get managers => $LatelyDatabaseManager(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $GroupsTable groups = $GroupsTable(this);
  late final $PeopleTable people = $PeopleTable(this);
  late final $RelationshipsTable relationships = $RelationshipsTable(this);
  late final $ChatsTable chats = $ChatsTable(this);
  late final $LinesTable lines = $LinesTable(this);
  late final $ImportantDatesTable importantDates = $ImportantDatesTable(this);
  late final $CustomBlocksTable customBlocks = $CustomBlocksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    settings,
    groups,
    people,
    relationships,
    chats,
    lines,
    importantDates,
    customBlocks,
  ];
}

typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> extra,
  Value<String> awakeStart,
  Value<String> awakeEnd,
  required String blockOrder,
  required int schemaVersion,
  Value<String?> skipPolicy,
  Value<String?> theme,
  Value<String?> recentContactPersonId,
  Value<DateTime?> recentContactAt,
  Value<DateTime?> lastExportAt,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> extra,
  Value<String> awakeStart,
  Value<String> awakeEnd,
  Value<String> blockOrder,
  Value<int> schemaVersion,
  Value<String?> skipPolicy,
  Value<String?> theme,
  Value<String?> recentContactPersonId,
  Value<DateTime?> recentContactAt,
  Value<DateTime?> lastExportAt,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$LatelyDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get awakeStart => $composableBuilder(
    column: $table.awakeStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get awakeEnd => $composableBuilder(
    column: $table.awakeEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get blockOrder => $composableBuilder(
    column: $table.blockOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get skipPolicy => $composableBuilder(
    column: $table.skipPolicy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recentContactPersonId => $composableBuilder(
    column: $table.recentContactPersonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recentContactAt => $composableBuilder(
    column: $table.recentContactAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastExportAt => $composableBuilder(
    column: $table.lastExportAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$LatelyDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get awakeStart => $composableBuilder(
    column: $table.awakeStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get awakeEnd => $composableBuilder(
    column: $table.awakeEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get blockOrder => $composableBuilder(
    column: $table.blockOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get skipPolicy => $composableBuilder(
    column: $table.skipPolicy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recentContactPersonId => $composableBuilder(
    column: $table.recentContactPersonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recentContactAt => $composableBuilder(
    column: $table.recentContactAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastExportAt => $composableBuilder(
    column: $table.lastExportAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$LatelyDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get extra =>
      $composableBuilder(column: $table.extra, builder: (column) => column);

  GeneratedColumn<String> get awakeStart => $composableBuilder(
    column: $table.awakeStart,
    builder: (column) => column,
  );

  GeneratedColumn<String> get awakeEnd =>
      $composableBuilder(column: $table.awakeEnd, builder: (column) => column);

  GeneratedColumn<String> get blockOrder => $composableBuilder(
    column: $table.blockOrder,
    builder: (column) => column,
  );

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get skipPolicy => $composableBuilder(
    column: $table.skipPolicy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<String> get recentContactPersonId => $composableBuilder(
    column: $table.recentContactPersonId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recentContactAt => $composableBuilder(
    column: $table.recentContactAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastExportAt => $composableBuilder(
    column: $table.lastExportAt,
    builder: (column) => column,
  );
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$LatelyDatabase,
          $SettingsTable,
          AppSettings,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            AppSettings,
            BaseReferences<_$LatelyDatabase, $SettingsTable, AppSettings>,
          ),
          AppSettings,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$LatelyDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> extra = const Value.absent(),
                Value<String> awakeStart = const Value.absent(),
                Value<String> awakeEnd = const Value.absent(),
                Value<String> blockOrder = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<String?> skipPolicy = const Value.absent(),
                Value<String?> theme = const Value.absent(),
                Value<String?> recentContactPersonId = const Value.absent(),
                Value<DateTime?> recentContactAt = const Value.absent(),
                Value<DateTime?> lastExportAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                extra: extra,
                awakeStart: awakeStart,
                awakeEnd: awakeEnd,
                blockOrder: blockOrder,
                schemaVersion: schemaVersion,
                skipPolicy: skipPolicy,
                theme: theme,
                recentContactPersonId: recentContactPersonId,
                recentContactAt: recentContactAt,
                lastExportAt: lastExportAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> extra = const Value.absent(),
                Value<String> awakeStart = const Value.absent(),
                Value<String> awakeEnd = const Value.absent(),
                required String blockOrder,
                required int schemaVersion,
                Value<String?> skipPolicy = const Value.absent(),
                Value<String?> theme = const Value.absent(),
                Value<String?> recentContactPersonId = const Value.absent(),
                Value<DateTime?> recentContactAt = const Value.absent(),
                Value<DateTime?> lastExportAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                extra: extra,
                awakeStart: awakeStart,
                awakeEnd: awakeEnd,
                blockOrder: blockOrder,
                schemaVersion: schemaVersion,
                skipPolicy: skipPolicy,
                theme: theme,
                recentContactPersonId: recentContactPersonId,
                recentContactAt: recentContactAt,
                lastExportAt: lastExportAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, AppSettings>(table),
                  BaseReferences<_$LatelyDatabase, $SettingsTable, AppSettings>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$LatelyDatabase,
      $SettingsTable,
      AppSettings,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (
        AppSettings,
        BaseReferences<_$LatelyDatabase, $SettingsTable, AppSettings>,
      ),
      AppSettings,
      PrefetchHooks Function()
    >;
typedef $$GroupsTableCreateCompanionBuilder = GroupsCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> extra,
  required String name,
  required int defaultIntervalDays,
  Value<int> sortOrder,
  Value<String?> color,
  Value<int> rowid,
});
typedef $$GroupsTableUpdateCompanionBuilder = GroupsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> extra,
  Value<String> name,
  Value<int> defaultIntervalDays,
  Value<int> sortOrder,
  Value<String?> color,
  Value<int> rowid,
});

final class $$GroupsTableReferences
    extends BaseReferences<_$LatelyDatabase, $GroupsTable, GroupRow> {
  $$GroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PeopleTable, List<PersonRow>> _peopleRefsTable(
    _$LatelyDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.people,
    aliasName: 'groups__id__people__group_id',
  );

  $$PeopleTableProcessedTableManager get peopleRefs {
    final manager = $$PeopleTableTableManager(
      $_db,
      $_db.people,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_peopleRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GroupsTableFilterComposer
    extends Composer<_$LatelyDatabase, $GroupsTable> {
  $$GroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultIntervalDays => $composableBuilder(
    column: $table.defaultIntervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> peopleRefs(
    Expression<bool> Function($$PeopleTableFilterComposer f) f,
  ) {
    final $$PeopleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableFilterComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroupsTableOrderingComposer
    extends Composer<_$LatelyDatabase, $GroupsTable> {
  $$GroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultIntervalDays => $composableBuilder(
    column: $table.defaultIntervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GroupsTableAnnotationComposer
    extends Composer<_$LatelyDatabase, $GroupsTable> {
  $$GroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get extra =>
      $composableBuilder(column: $table.extra, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get defaultIntervalDays => $composableBuilder(
    column: $table.defaultIntervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  Expression<T> peopleRefs<T extends Object>(
    Expression<T> Function($$PeopleTableAnnotationComposer a) f,
  ) {
    final $$PeopleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableAnnotationComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroupsTableTableManager
    extends
        RootTableManager<
          _$LatelyDatabase,
          $GroupsTable,
          GroupRow,
          $$GroupsTableFilterComposer,
          $$GroupsTableOrderingComposer,
          $$GroupsTableAnnotationComposer,
          $$GroupsTableCreateCompanionBuilder,
          $$GroupsTableUpdateCompanionBuilder,
          (GroupRow, $$GroupsTableReferences),
          GroupRow,
          PrefetchHooks Function({bool peopleRefs})
        > {
  $$GroupsTableTableManager(_$LatelyDatabase db, $GroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> extra = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> defaultIntervalDays = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                extra: extra,
                name: name,
                defaultIntervalDays: defaultIntervalDays,
                sortOrder: sortOrder,
                color: color,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> extra = const Value.absent(),
                required String name,
                required int defaultIntervalDays,
                Value<int> sortOrder = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                extra: extra,
                name: name,
                defaultIntervalDays: defaultIntervalDays,
                sortOrder: sortOrder,
                color: color,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GroupsTable, GroupRow>(table),
                  $$GroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({peopleRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (peopleRefs) db.people],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (peopleRefs)
                    await $_getPrefetchedDataByColumns<
                      GroupRow,
                      $GroupsTable,
                      PersonRow,
                      $PeopleTable
                    >(
                      currentTable: table,
                      referencedTable: $$GroupsTableReferences._peopleRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$GroupsTableReferences(db, table, p0).peopleRefs,
                      currentColumn: 'id',
                      referencedColumn: 'group_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$LatelyDatabase,
      $GroupsTable,
      GroupRow,
      $$GroupsTableFilterComposer,
      $$GroupsTableOrderingComposer,
      $$GroupsTableAnnotationComposer,
      $$GroupsTableCreateCompanionBuilder,
      $$GroupsTableUpdateCompanionBuilder,
      (GroupRow, $$GroupsTableReferences),
      GroupRow,
      PrefetchHooks Function({bool peopleRefs})
    >;
typedef $$PeopleTableCreateCompanionBuilder = PeopleCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> extra,
  required String displayName,
  required String groupId,
  required String timezone,
  Value<bool> timezoneConfirmed,
  required String contactMethodType,
  Value<String?> contactMethodValue,
  Value<String?> fullName,
  Value<String?> middleName,
  Value<String?> birthday,
  Value<int?> intervalOverrideDays,
  Value<String?> phone,
  Value<String?> socials,
  Value<String?> hometown,
  Value<DateTime?> lastTalkedEstimate,
  Value<DateTime?> snoozedUntil,
  Value<DateTime?> skippedUntil,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});
typedef $$PeopleTableUpdateCompanionBuilder = PeopleCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> extra,
  Value<String> displayName,
  Value<String> groupId,
  Value<String> timezone,
  Value<bool> timezoneConfirmed,
  Value<String> contactMethodType,
  Value<String?> contactMethodValue,
  Value<String?> fullName,
  Value<String?> middleName,
  Value<String?> birthday,
  Value<int?> intervalOverrideDays,
  Value<String?> phone,
  Value<String?> socials,
  Value<String?> hometown,
  Value<DateTime?> lastTalkedEstimate,
  Value<DateTime?> snoozedUntil,
  Value<DateTime?> skippedUntil,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});

final class $$PeopleTableReferences
    extends BaseReferences<_$LatelyDatabase, $PeopleTable, PersonRow> {
  $$PeopleTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GroupsTable _groupIdTable(_$LatelyDatabase db) =>
      db.groups.createAlias('people__group_id__groups__id');

  $$GroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<String>('group_id')!;

    final manager = $$GroupsTableTableManager(
      $_db,
      $_db.groups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RelationshipsTable, List<RelationshipRow>>
  _relationshipsRefsTable(_$LatelyDatabase db) => MultiTypedResultKey.fromTable(
    db.relationships,
    aliasName: 'people__id__relationships__person_id',
  );

  $$RelationshipsTableProcessedTableManager get relationshipsRefs {
    final manager = $$RelationshipsTableTableManager(
      $_db,
      $_db.relationships,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_relationshipsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChatsTable, List<ChatRow>> _chatsRefsTable(
    _$LatelyDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.chats,
    aliasName: 'people__id__chats__person_id',
  );

  $$ChatsTableProcessedTableManager get chatsRefs {
    final manager = $$ChatsTableTableManager(
      $_db,
      $_db.chats,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_chatsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LinesTable, List<LineRow>> _linesRefsTable(
    _$LatelyDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.lines,
    aliasName: 'people__id__lines__person_id',
  );

  $$LinesTableProcessedTableManager get linesRefs {
    final manager = $$LinesTableTableManager(
      $_db,
      $_db.lines,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_linesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ImportantDatesTable, List<ImportantDateRow>>
  _importantDatesRefsTable(_$LatelyDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.importantDates,
        aliasName: 'people__id__important_dates__person_id',
      );

  $$ImportantDatesTableProcessedTableManager get importantDatesRefs {
    final manager = $$ImportantDatesTableTableManager(
      $_db,
      $_db.importantDates,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_importantDatesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PeopleTableFilterComposer
    extends Composer<_$LatelyDatabase, $PeopleTable> {
  $$PeopleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get timezoneConfirmed => $composableBuilder(
    column: $table.timezoneConfirmed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactMethodType => $composableBuilder(
    column: $table.contactMethodType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactMethodValue => $composableBuilder(
    column: $table.contactMethodValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get middleName => $composableBuilder(
    column: $table.middleName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthday => $composableBuilder(
    column: $table.birthday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalOverrideDays => $composableBuilder(
    column: $table.intervalOverrideDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get socials => $composableBuilder(
    column: $table.socials,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hometown => $composableBuilder(
    column: $table.hometown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastTalkedEstimate => $composableBuilder(
    column: $table.lastTalkedEstimate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get skippedUntil => $composableBuilder(
    column: $table.skippedUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableFilterComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> relationshipsRefs(
    Expression<bool> Function($$RelationshipsTableFilterComposer f) f,
  ) {
    final $$RelationshipsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.relationships,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RelationshipsTableFilterComposer(
            $db: $db,
            $table: $db.relationships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> chatsRefs(
    Expression<bool> Function($$ChatsTableFilterComposer f) f,
  ) {
    final $$ChatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chats,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatsTableFilterComposer(
            $db: $db,
            $table: $db.chats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> linesRefs(
    Expression<bool> Function($$LinesTableFilterComposer f) f,
  ) {
    final $$LinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lines,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LinesTableFilterComposer(
            $db: $db,
            $table: $db.lines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> importantDatesRefs(
    Expression<bool> Function($$ImportantDatesTableFilterComposer f) f,
  ) {
    final $$ImportantDatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importantDates,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportantDatesTableFilterComposer(
            $db: $db,
            $table: $db.importantDates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PeopleTableOrderingComposer
    extends Composer<_$LatelyDatabase, $PeopleTable> {
  $$PeopleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get timezoneConfirmed => $composableBuilder(
    column: $table.timezoneConfirmed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactMethodType => $composableBuilder(
    column: $table.contactMethodType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactMethodValue => $composableBuilder(
    column: $table.contactMethodValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get middleName => $composableBuilder(
    column: $table.middleName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthday => $composableBuilder(
    column: $table.birthday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalOverrideDays => $composableBuilder(
    column: $table.intervalOverrideDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get socials => $composableBuilder(
    column: $table.socials,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hometown => $composableBuilder(
    column: $table.hometown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastTalkedEstimate => $composableBuilder(
    column: $table.lastTalkedEstimate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get skippedUntil => $composableBuilder(
    column: $table.skippedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableOrderingComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PeopleTableAnnotationComposer
    extends Composer<_$LatelyDatabase, $PeopleTable> {
  $$PeopleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get extra =>
      $composableBuilder(column: $table.extra, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<bool> get timezoneConfirmed => $composableBuilder(
    column: $table.timezoneConfirmed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contactMethodType => $composableBuilder(
    column: $table.contactMethodType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contactMethodValue => $composableBuilder(
    column: $table.contactMethodValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get middleName => $composableBuilder(
    column: $table.middleName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get birthday =>
      $composableBuilder(column: $table.birthday, builder: (column) => column);

  GeneratedColumn<int> get intervalOverrideDays => $composableBuilder(
    column: $table.intervalOverrideDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get socials =>
      $composableBuilder(column: $table.socials, builder: (column) => column);

  GeneratedColumn<String> get hometown =>
      $composableBuilder(column: $table.hometown, builder: (column) => column);

  GeneratedColumn<DateTime> get lastTalkedEstimate => $composableBuilder(
    column: $table.lastTalkedEstimate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get skippedUntil => $composableBuilder(
    column: $table.skippedUntil,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> relationshipsRefs<T extends Object>(
    Expression<T> Function($$RelationshipsTableAnnotationComposer a) f,
  ) {
    final $$RelationshipsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.relationships,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RelationshipsTableAnnotationComposer(
            $db: $db,
            $table: $db.relationships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> chatsRefs<T extends Object>(
    Expression<T> Function($$ChatsTableAnnotationComposer a) f,
  ) {
    final $$ChatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chats,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatsTableAnnotationComposer(
            $db: $db,
            $table: $db.chats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> linesRefs<T extends Object>(
    Expression<T> Function($$LinesTableAnnotationComposer a) f,
  ) {
    final $$LinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lines,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LinesTableAnnotationComposer(
            $db: $db,
            $table: $db.lines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> importantDatesRefs<T extends Object>(
    Expression<T> Function($$ImportantDatesTableAnnotationComposer a) f,
  ) {
    final $$ImportantDatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importantDates,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportantDatesTableAnnotationComposer(
            $db: $db,
            $table: $db.importantDates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PeopleTableTableManager
    extends
        RootTableManager<
          _$LatelyDatabase,
          $PeopleTable,
          PersonRow,
          $$PeopleTableFilterComposer,
          $$PeopleTableOrderingComposer,
          $$PeopleTableAnnotationComposer,
          $$PeopleTableCreateCompanionBuilder,
          $$PeopleTableUpdateCompanionBuilder,
          (PersonRow, $$PeopleTableReferences),
          PersonRow,
          PrefetchHooks Function({
            bool groupId,
            bool relationshipsRefs,
            bool chatsRefs,
            bool linesRefs,
            bool importantDatesRefs,
          })
        > {
  $$PeopleTableTableManager(_$LatelyDatabase db, $PeopleTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeopleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeopleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeopleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> extra = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<bool> timezoneConfirmed = const Value.absent(),
                Value<String> contactMethodType = const Value.absent(),
                Value<String?> contactMethodValue = const Value.absent(),
                Value<String?> fullName = const Value.absent(),
                Value<String?> middleName = const Value.absent(),
                Value<String?> birthday = const Value.absent(),
                Value<int?> intervalOverrideDays = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> socials = const Value.absent(),
                Value<String?> hometown = const Value.absent(),
                Value<DateTime?> lastTalkedEstimate = const Value.absent(),
                Value<DateTime?> snoozedUntil = const Value.absent(),
                Value<DateTime?> skippedUntil = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PeopleCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                extra: extra,
                displayName: displayName,
                groupId: groupId,
                timezone: timezone,
                timezoneConfirmed: timezoneConfirmed,
                contactMethodType: contactMethodType,
                contactMethodValue: contactMethodValue,
                fullName: fullName,
                middleName: middleName,
                birthday: birthday,
                intervalOverrideDays: intervalOverrideDays,
                phone: phone,
                socials: socials,
                hometown: hometown,
                lastTalkedEstimate: lastTalkedEstimate,
                snoozedUntil: snoozedUntil,
                skippedUntil: skippedUntil,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> extra = const Value.absent(),
                required String displayName,
                required String groupId,
                required String timezone,
                Value<bool> timezoneConfirmed = const Value.absent(),
                required String contactMethodType,
                Value<String?> contactMethodValue = const Value.absent(),
                Value<String?> fullName = const Value.absent(),
                Value<String?> middleName = const Value.absent(),
                Value<String?> birthday = const Value.absent(),
                Value<int?> intervalOverrideDays = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> socials = const Value.absent(),
                Value<String?> hometown = const Value.absent(),
                Value<DateTime?> lastTalkedEstimate = const Value.absent(),
                Value<DateTime?> snoozedUntil = const Value.absent(),
                Value<DateTime?> skippedUntil = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PeopleCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                extra: extra,
                displayName: displayName,
                groupId: groupId,
                timezone: timezone,
                timezoneConfirmed: timezoneConfirmed,
                contactMethodType: contactMethodType,
                contactMethodValue: contactMethodValue,
                fullName: fullName,
                middleName: middleName,
                birthday: birthday,
                intervalOverrideDays: intervalOverrideDays,
                phone: phone,
                socials: socials,
                hometown: hometown,
                lastTalkedEstimate: lastTalkedEstimate,
                snoozedUntil: snoozedUntil,
                skippedUntil: skippedUntil,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PeopleTable, PersonRow>(table),
                  $$PeopleTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                groupId = false,
                relationshipsRefs = false,
                chatsRefs = false,
                linesRefs = false,
                importantDatesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (relationshipsRefs) db.relationships,
                    if (chatsRefs) db.chats,
                    if (linesRefs) db.lines,
                    if (importantDatesRefs) db.importantDates,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (groupId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.groupId,
                            referencedTable: $$PeopleTableReferences
                                ._groupIdTable(db),
                            referencedColumn: $$PeopleTableReferences
                                ._groupIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (relationshipsRefs)
                        await $_getPrefetchedDataByColumns<
                          PersonRow,
                          $PeopleTable,
                          RelationshipRow,
                          $RelationshipsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PeopleTableReferences
                              ._relationshipsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PeopleTableReferences(
                                db,
                                table,
                                p0,
                              ).relationshipsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'person_id',
                          typedResults: items,
                        ),
                      if (chatsRefs)
                        await $_getPrefetchedDataByColumns<
                          PersonRow,
                          $PeopleTable,
                          ChatRow,
                          $ChatsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PeopleTableReferences
                              ._chatsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PeopleTableReferences(db, table, p0).chatsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'person_id',
                          typedResults: items,
                        ),
                      if (linesRefs)
                        await $_getPrefetchedDataByColumns<
                          PersonRow,
                          $PeopleTable,
                          LineRow,
                          $LinesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PeopleTableReferences
                              ._linesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PeopleTableReferences(db, table, p0).linesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'person_id',
                          typedResults: items,
                        ),
                      if (importantDatesRefs)
                        await $_getPrefetchedDataByColumns<
                          PersonRow,
                          $PeopleTable,
                          ImportantDateRow,
                          $ImportantDatesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PeopleTableReferences
                              ._importantDatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PeopleTableReferences(
                                db,
                                table,
                                p0,
                              ).importantDatesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'person_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PeopleTableProcessedTableManager =
    ProcessedTableManager<
      _$LatelyDatabase,
      $PeopleTable,
      PersonRow,
      $$PeopleTableFilterComposer,
      $$PeopleTableOrderingComposer,
      $$PeopleTableAnnotationComposer,
      $$PeopleTableCreateCompanionBuilder,
      $$PeopleTableUpdateCompanionBuilder,
      (PersonRow, $$PeopleTableReferences),
      PersonRow,
      PrefetchHooks Function({
        bool groupId,
        bool relationshipsRefs,
        bool chatsRefs,
        bool linesRefs,
        bool importantDatesRefs,
      })
    >;
typedef $$RelationshipsTableCreateCompanionBuilder =
    RelationshipsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> extra,
      required String personId,
      required String name,
      Value<String?> relation,
      Value<String?> birthday,
      Value<String?> addedInChatId,
      Value<int> rowid,
    });
typedef $$RelationshipsTableUpdateCompanionBuilder =
    RelationshipsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> extra,
      Value<String> personId,
      Value<String> name,
      Value<String?> relation,
      Value<String?> birthday,
      Value<String?> addedInChatId,
      Value<int> rowid,
    });

final class $$RelationshipsTableReferences
    extends
        BaseReferences<_$LatelyDatabase, $RelationshipsTable, RelationshipRow> {
  $$RelationshipsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PeopleTable _personIdTable(_$LatelyDatabase db) =>
      db.people.createAlias('relationships__person_id__people__id');

  $$PeopleTableProcessedTableManager get personId {
    final $_column = $_itemColumn<String>('person_id')!;

    final manager = $$PeopleTableTableManager(
      $_db,
      $_db.people,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RelationshipsTableFilterComposer
    extends Composer<_$LatelyDatabase, $RelationshipsTable> {
  $$RelationshipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthday => $composableBuilder(
    column: $table.birthday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addedInChatId => $composableBuilder(
    column: $table.addedInChatId,
    builder: (column) => ColumnFilters(column),
  );

  $$PeopleTableFilterComposer get personId {
    final $$PeopleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableFilterComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RelationshipsTableOrderingComposer
    extends Composer<_$LatelyDatabase, $RelationshipsTable> {
  $$RelationshipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthday => $composableBuilder(
    column: $table.birthday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addedInChatId => $composableBuilder(
    column: $table.addedInChatId,
    builder: (column) => ColumnOrderings(column),
  );

  $$PeopleTableOrderingComposer get personId {
    final $$PeopleTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableOrderingComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RelationshipsTableAnnotationComposer
    extends Composer<_$LatelyDatabase, $RelationshipsTable> {
  $$RelationshipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get extra =>
      $composableBuilder(column: $table.extra, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get relation =>
      $composableBuilder(column: $table.relation, builder: (column) => column);

  GeneratedColumn<String> get birthday =>
      $composableBuilder(column: $table.birthday, builder: (column) => column);

  GeneratedColumn<String> get addedInChatId => $composableBuilder(
    column: $table.addedInChatId,
    builder: (column) => column,
  );

  $$PeopleTableAnnotationComposer get personId {
    final $$PeopleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableAnnotationComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RelationshipsTableTableManager
    extends
        RootTableManager<
          _$LatelyDatabase,
          $RelationshipsTable,
          RelationshipRow,
          $$RelationshipsTableFilterComposer,
          $$RelationshipsTableOrderingComposer,
          $$RelationshipsTableAnnotationComposer,
          $$RelationshipsTableCreateCompanionBuilder,
          $$RelationshipsTableUpdateCompanionBuilder,
          (RelationshipRow, $$RelationshipsTableReferences),
          RelationshipRow,
          PrefetchHooks Function({bool personId})
        > {
  $$RelationshipsTableTableManager(
    _$LatelyDatabase db,
    $RelationshipsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RelationshipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RelationshipsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RelationshipsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> extra = const Value.absent(),
                Value<String> personId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> relation = const Value.absent(),
                Value<String?> birthday = const Value.absent(),
                Value<String?> addedInChatId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RelationshipsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                extra: extra,
                personId: personId,
                name: name,
                relation: relation,
                birthday: birthday,
                addedInChatId: addedInChatId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> extra = const Value.absent(),
                required String personId,
                required String name,
                Value<String?> relation = const Value.absent(),
                Value<String?> birthday = const Value.absent(),
                Value<String?> addedInChatId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RelationshipsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                extra: extra,
                personId: personId,
                name: name,
                relation: relation,
                birthday: birthday,
                addedInChatId: addedInChatId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RelationshipsTable, RelationshipRow>(table),
                  $$RelationshipsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({personId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (personId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.personId,
                        referencedTable: $$RelationshipsTableReferences
                            ._personIdTable(db),
                        referencedColumn: $$RelationshipsTableReferences
                            ._personIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RelationshipsTableProcessedTableManager =
    ProcessedTableManager<
      _$LatelyDatabase,
      $RelationshipsTable,
      RelationshipRow,
      $$RelationshipsTableFilterComposer,
      $$RelationshipsTableOrderingComposer,
      $$RelationshipsTableAnnotationComposer,
      $$RelationshipsTableCreateCompanionBuilder,
      $$RelationshipsTableUpdateCompanionBuilder,
      (RelationshipRow, $$RelationshipsTableReferences),
      RelationshipRow,
      PrefetchHooks Function({bool personId})
    >;
typedef $$ChatsTableCreateCompanionBuilder = ChatsCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> extra,
  required String personId,
  required DateTime occurredAt,
  Value<bool> timeApproximate,
  required String type,
  required String depth,
  Value<int?> durationMinutes,
  required String length,
  Value<String?> feelings,
  Value<String?> note,
  Value<String> source,
  Value<String?> callId,
  Value<int> rowid,
});
typedef $$ChatsTableUpdateCompanionBuilder = ChatsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> extra,
  Value<String> personId,
  Value<DateTime> occurredAt,
  Value<bool> timeApproximate,
  Value<String> type,
  Value<String> depth,
  Value<int?> durationMinutes,
  Value<String> length,
  Value<String?> feelings,
  Value<String?> note,
  Value<String> source,
  Value<String?> callId,
  Value<int> rowid,
});

final class $$ChatsTableReferences
    extends BaseReferences<_$LatelyDatabase, $ChatsTable, ChatRow> {
  $$ChatsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PeopleTable _personIdTable(_$LatelyDatabase db) =>
      db.people.createAlias('chats__person_id__people__id');

  $$PeopleTableProcessedTableManager get personId {
    final $_column = $_itemColumn<String>('person_id')!;

    final manager = $$PeopleTableTableManager(
      $_db,
      $_db.people,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChatsTableFilterComposer
    extends Composer<_$LatelyDatabase, $ChatsTable> {
  $$ChatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get timeApproximate => $composableBuilder(
    column: $table.timeApproximate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get depth => $composableBuilder(
    column: $table.depth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get length => $composableBuilder(
    column: $table.length,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feelings => $composableBuilder(
    column: $table.feelings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get callId => $composableBuilder(
    column: $table.callId,
    builder: (column) => ColumnFilters(column),
  );

  $$PeopleTableFilterComposer get personId {
    final $$PeopleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableFilterComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatsTableOrderingComposer
    extends Composer<_$LatelyDatabase, $ChatsTable> {
  $$ChatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get timeApproximate => $composableBuilder(
    column: $table.timeApproximate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get depth => $composableBuilder(
    column: $table.depth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get length => $composableBuilder(
    column: $table.length,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feelings => $composableBuilder(
    column: $table.feelings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get callId => $composableBuilder(
    column: $table.callId,
    builder: (column) => ColumnOrderings(column),
  );

  $$PeopleTableOrderingComposer get personId {
    final $$PeopleTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableOrderingComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatsTableAnnotationComposer
    extends Composer<_$LatelyDatabase, $ChatsTable> {
  $$ChatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get extra =>
      $composableBuilder(column: $table.extra, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get timeApproximate => $composableBuilder(
    column: $table.timeApproximate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get depth =>
      $composableBuilder(column: $table.depth, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get length =>
      $composableBuilder(column: $table.length, builder: (column) => column);

  GeneratedColumn<String> get feelings =>
      $composableBuilder(column: $table.feelings, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get callId =>
      $composableBuilder(column: $table.callId, builder: (column) => column);

  $$PeopleTableAnnotationComposer get personId {
    final $$PeopleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableAnnotationComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatsTableTableManager
    extends
        RootTableManager<
          _$LatelyDatabase,
          $ChatsTable,
          ChatRow,
          $$ChatsTableFilterComposer,
          $$ChatsTableOrderingComposer,
          $$ChatsTableAnnotationComposer,
          $$ChatsTableCreateCompanionBuilder,
          $$ChatsTableUpdateCompanionBuilder,
          (ChatRow, $$ChatsTableReferences),
          ChatRow,
          PrefetchHooks Function({bool personId})
        > {
  $$ChatsTableTableManager(_$LatelyDatabase db, $ChatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> extra = const Value.absent(),
                Value<String> personId = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<bool> timeApproximate = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> depth = const Value.absent(),
                Value<int?> durationMinutes = const Value.absent(),
                Value<String> length = const Value.absent(),
                Value<String?> feelings = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> callId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                extra: extra,
                personId: personId,
                occurredAt: occurredAt,
                timeApproximate: timeApproximate,
                type: type,
                depth: depth,
                durationMinutes: durationMinutes,
                length: length,
                feelings: feelings,
                note: note,
                source: source,
                callId: callId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> extra = const Value.absent(),
                required String personId,
                required DateTime occurredAt,
                Value<bool> timeApproximate = const Value.absent(),
                required String type,
                required String depth,
                Value<int?> durationMinutes = const Value.absent(),
                required String length,
                Value<String?> feelings = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> callId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                extra: extra,
                personId: personId,
                occurredAt: occurredAt,
                timeApproximate: timeApproximate,
                type: type,
                depth: depth,
                durationMinutes: durationMinutes,
                length: length,
                feelings: feelings,
                note: note,
                source: source,
                callId: callId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChatsTable, ChatRow>(table),
                  $$ChatsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({personId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (personId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.personId,
                        referencedTable: $$ChatsTableReferences._personIdTable(
                          db,
                        ),
                        referencedColumn: $$ChatsTableReferences
                            ._personIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ChatsTableProcessedTableManager =
    ProcessedTableManager<
      _$LatelyDatabase,
      $ChatsTable,
      ChatRow,
      $$ChatsTableFilterComposer,
      $$ChatsTableOrderingComposer,
      $$ChatsTableAnnotationComposer,
      $$ChatsTableCreateCompanionBuilder,
      $$ChatsTableUpdateCompanionBuilder,
      (ChatRow, $$ChatsTableReferences),
      ChatRow,
      PrefetchHooks Function({bool personId})
    >;
typedef $$LinesTableCreateCompanionBuilder = LinesCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> extra,
  required String personId,
  required String block,
  required String lineText,
  Value<bool> done,
  Value<DateTime?> doneAt,
  Value<String?> chatId,
  Value<String?> relationshipId,
  Value<String?> addedInChatId,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$LinesTableUpdateCompanionBuilder = LinesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> extra,
  Value<String> personId,
  Value<String> block,
  Value<String> lineText,
  Value<bool> done,
  Value<DateTime?> doneAt,
  Value<String?> chatId,
  Value<String?> relationshipId,
  Value<String?> addedInChatId,
  Value<int> sortOrder,
  Value<int> rowid,
});

final class $$LinesTableReferences
    extends BaseReferences<_$LatelyDatabase, $LinesTable, LineRow> {
  $$LinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PeopleTable _personIdTable(_$LatelyDatabase db) =>
      db.people.createAlias('lines__person_id__people__id');

  $$PeopleTableProcessedTableManager get personId {
    final $_column = $_itemColumn<String>('person_id')!;

    final manager = $$PeopleTableTableManager(
      $_db,
      $_db.people,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LinesTableFilterComposer
    extends Composer<_$LatelyDatabase, $LinesTable> {
  $$LinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get block => $composableBuilder(
    column: $table.block,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lineText => $composableBuilder(
    column: $table.lineText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relationshipId => $composableBuilder(
    column: $table.relationshipId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addedInChatId => $composableBuilder(
    column: $table.addedInChatId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$PeopleTableFilterComposer get personId {
    final $$PeopleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableFilterComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LinesTableOrderingComposer
    extends Composer<_$LatelyDatabase, $LinesTable> {
  $$LinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get block => $composableBuilder(
    column: $table.block,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lineText => $composableBuilder(
    column: $table.lineText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relationshipId => $composableBuilder(
    column: $table.relationshipId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addedInChatId => $composableBuilder(
    column: $table.addedInChatId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$PeopleTableOrderingComposer get personId {
    final $$PeopleTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableOrderingComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LinesTableAnnotationComposer
    extends Composer<_$LatelyDatabase, $LinesTable> {
  $$LinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get extra =>
      $composableBuilder(column: $table.extra, builder: (column) => column);

  GeneratedColumn<String> get block =>
      $composableBuilder(column: $table.block, builder: (column) => column);

  GeneratedColumn<String> get lineText =>
      $composableBuilder(column: $table.lineText, builder: (column) => column);

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<DateTime> get doneAt =>
      $composableBuilder(column: $table.doneAt, builder: (column) => column);

  GeneratedColumn<String> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => column);

  GeneratedColumn<String> get relationshipId => $composableBuilder(
    column: $table.relationshipId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get addedInChatId => $composableBuilder(
    column: $table.addedInChatId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$PeopleTableAnnotationComposer get personId {
    final $$PeopleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableAnnotationComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LinesTableTableManager
    extends
        RootTableManager<
          _$LatelyDatabase,
          $LinesTable,
          LineRow,
          $$LinesTableFilterComposer,
          $$LinesTableOrderingComposer,
          $$LinesTableAnnotationComposer,
          $$LinesTableCreateCompanionBuilder,
          $$LinesTableUpdateCompanionBuilder,
          (LineRow, $$LinesTableReferences),
          LineRow,
          PrefetchHooks Function({bool personId})
        > {
  $$LinesTableTableManager(_$LatelyDatabase db, $LinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> extra = const Value.absent(),
                Value<String> personId = const Value.absent(),
                Value<String> block = const Value.absent(),
                Value<String> lineText = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<DateTime?> doneAt = const Value.absent(),
                Value<String?> chatId = const Value.absent(),
                Value<String?> relationshipId = const Value.absent(),
                Value<String?> addedInChatId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LinesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                extra: extra,
                personId: personId,
                block: block,
                lineText: lineText,
                done: done,
                doneAt: doneAt,
                chatId: chatId,
                relationshipId: relationshipId,
                addedInChatId: addedInChatId,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> extra = const Value.absent(),
                required String personId,
                required String block,
                required String lineText,
                Value<bool> done = const Value.absent(),
                Value<DateTime?> doneAt = const Value.absent(),
                Value<String?> chatId = const Value.absent(),
                Value<String?> relationshipId = const Value.absent(),
                Value<String?> addedInChatId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LinesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                extra: extra,
                personId: personId,
                block: block,
                lineText: lineText,
                done: done,
                doneAt: doneAt,
                chatId: chatId,
                relationshipId: relationshipId,
                addedInChatId: addedInChatId,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LinesTable, LineRow>(table),
                  $$LinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({personId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (personId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.personId,
                        referencedTable: $$LinesTableReferences._personIdTable(
                          db,
                        ),
                        referencedColumn: $$LinesTableReferences
                            ._personIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LinesTableProcessedTableManager =
    ProcessedTableManager<
      _$LatelyDatabase,
      $LinesTable,
      LineRow,
      $$LinesTableFilterComposer,
      $$LinesTableOrderingComposer,
      $$LinesTableAnnotationComposer,
      $$LinesTableCreateCompanionBuilder,
      $$LinesTableUpdateCompanionBuilder,
      (LineRow, $$LinesTableReferences),
      LineRow,
      PrefetchHooks Function({bool personId})
    >;
typedef $$ImportantDatesTableCreateCompanionBuilder =
    ImportantDatesCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> extra,
      required String personId,
      required String label,
      required String date,
      Value<bool> repeatsYearly,
      Value<int> rowid,
    });
typedef $$ImportantDatesTableUpdateCompanionBuilder =
    ImportantDatesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> extra,
      Value<String> personId,
      Value<String> label,
      Value<String> date,
      Value<bool> repeatsYearly,
      Value<int> rowid,
    });

final class $$ImportantDatesTableReferences
    extends
        BaseReferences<
          _$LatelyDatabase,
          $ImportantDatesTable,
          ImportantDateRow
        > {
  $$ImportantDatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PeopleTable _personIdTable(_$LatelyDatabase db) =>
      db.people.createAlias('important_dates__person_id__people__id');

  $$PeopleTableProcessedTableManager get personId {
    final $_column = $_itemColumn<String>('person_id')!;

    final manager = $$PeopleTableTableManager(
      $_db,
      $_db.people,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImportantDatesTableFilterComposer
    extends Composer<_$LatelyDatabase, $ImportantDatesTable> {
  $$ImportantDatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get repeatsYearly => $composableBuilder(
    column: $table.repeatsYearly,
    builder: (column) => ColumnFilters(column),
  );

  $$PeopleTableFilterComposer get personId {
    final $$PeopleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableFilterComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportantDatesTableOrderingComposer
    extends Composer<_$LatelyDatabase, $ImportantDatesTable> {
  $$ImportantDatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get repeatsYearly => $composableBuilder(
    column: $table.repeatsYearly,
    builder: (column) => ColumnOrderings(column),
  );

  $$PeopleTableOrderingComposer get personId {
    final $$PeopleTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableOrderingComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportantDatesTableAnnotationComposer
    extends Composer<_$LatelyDatabase, $ImportantDatesTable> {
  $$ImportantDatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get extra =>
      $composableBuilder(column: $table.extra, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get repeatsYearly => $composableBuilder(
    column: $table.repeatsYearly,
    builder: (column) => column,
  );

  $$PeopleTableAnnotationComposer get personId {
    final $$PeopleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableAnnotationComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportantDatesTableTableManager
    extends
        RootTableManager<
          _$LatelyDatabase,
          $ImportantDatesTable,
          ImportantDateRow,
          $$ImportantDatesTableFilterComposer,
          $$ImportantDatesTableOrderingComposer,
          $$ImportantDatesTableAnnotationComposer,
          $$ImportantDatesTableCreateCompanionBuilder,
          $$ImportantDatesTableUpdateCompanionBuilder,
          (ImportantDateRow, $$ImportantDatesTableReferences),
          ImportantDateRow,
          PrefetchHooks Function({bool personId})
        > {
  $$ImportantDatesTableTableManager(
    _$LatelyDatabase db,
    $ImportantDatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportantDatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportantDatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportantDatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> extra = const Value.absent(),
                Value<String> personId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<bool> repeatsYearly = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportantDatesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                extra: extra,
                personId: personId,
                label: label,
                date: date,
                repeatsYearly: repeatsYearly,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> extra = const Value.absent(),
                required String personId,
                required String label,
                required String date,
                Value<bool> repeatsYearly = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportantDatesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                extra: extra,
                personId: personId,
                label: label,
                date: date,
                repeatsYearly: repeatsYearly,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ImportantDatesTable, ImportantDateRow>(table),
                  $$ImportantDatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({personId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (personId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.personId,
                        referencedTable: $$ImportantDatesTableReferences
                            ._personIdTable(db),
                        referencedColumn: $$ImportantDatesTableReferences
                            ._personIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ImportantDatesTableProcessedTableManager =
    ProcessedTableManager<
      _$LatelyDatabase,
      $ImportantDatesTable,
      ImportantDateRow,
      $$ImportantDatesTableFilterComposer,
      $$ImportantDatesTableOrderingComposer,
      $$ImportantDatesTableAnnotationComposer,
      $$ImportantDatesTableCreateCompanionBuilder,
      $$ImportantDatesTableUpdateCompanionBuilder,
      (ImportantDateRow, $$ImportantDatesTableReferences),
      ImportantDateRow,
      PrefetchHooks Function({bool personId})
    >;
typedef $$CustomBlocksTableCreateCompanionBuilder =
    CustomBlocksCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> extra,
      required String key,
      required String name,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$CustomBlocksTableUpdateCompanionBuilder =
    CustomBlocksCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> extra,
      Value<String> key,
      Value<String> name,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$CustomBlocksTableFilterComposer
    extends Composer<_$LatelyDatabase, $CustomBlocksTable> {
  $$CustomBlocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomBlocksTableOrderingComposer
    extends Composer<_$LatelyDatabase, $CustomBlocksTable> {
  $$CustomBlocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomBlocksTableAnnotationComposer
    extends Composer<_$LatelyDatabase, $CustomBlocksTable> {
  $$CustomBlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get extra =>
      $composableBuilder(column: $table.extra, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$CustomBlocksTableTableManager
    extends
        RootTableManager<
          _$LatelyDatabase,
          $CustomBlocksTable,
          CustomBlockRow,
          $$CustomBlocksTableFilterComposer,
          $$CustomBlocksTableOrderingComposer,
          $$CustomBlocksTableAnnotationComposer,
          $$CustomBlocksTableCreateCompanionBuilder,
          $$CustomBlocksTableUpdateCompanionBuilder,
          (
            CustomBlockRow,
            BaseReferences<
              _$LatelyDatabase,
              $CustomBlocksTable,
              CustomBlockRow
            >,
          ),
          CustomBlockRow,
          PrefetchHooks Function()
        > {
  $$CustomBlocksTableTableManager(_$LatelyDatabase db, $CustomBlocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomBlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomBlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomBlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> extra = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomBlocksCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                extra: extra,
                key: key,
                name: name,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> extra = const Value.absent(),
                required String key,
                required String name,
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomBlocksCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                extra: extra,
                key: key,
                name: name,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomBlocksTable, CustomBlockRow>(table),
                  BaseReferences<
                    _$LatelyDatabase,
                    $CustomBlocksTable,
                    CustomBlockRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomBlocksTableProcessedTableManager =
    ProcessedTableManager<
      _$LatelyDatabase,
      $CustomBlocksTable,
      CustomBlockRow,
      $$CustomBlocksTableFilterComposer,
      $$CustomBlocksTableOrderingComposer,
      $$CustomBlocksTableAnnotationComposer,
      $$CustomBlocksTableCreateCompanionBuilder,
      $$CustomBlocksTableUpdateCompanionBuilder,
      (
        CustomBlockRow,
        BaseReferences<_$LatelyDatabase, $CustomBlocksTable, CustomBlockRow>,
      ),
      CustomBlockRow,
      PrefetchHooks Function()
    >;

class $LatelyDatabaseManager {
  final _$LatelyDatabase _db;
  $LatelyDatabaseManager(this._db);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db, _db.groups);
  $$PeopleTableTableManager get people =>
      $$PeopleTableTableManager(_db, _db.people);
  $$RelationshipsTableTableManager get relationships =>
      $$RelationshipsTableTableManager(_db, _db.relationships);
  $$ChatsTableTableManager get chats =>
      $$ChatsTableTableManager(_db, _db.chats);
  $$LinesTableTableManager get lines =>
      $$LinesTableTableManager(_db, _db.lines);
  $$ImportantDatesTableTableManager get importantDates =>
      $$ImportantDatesTableTableManager(_db, _db.importantDates);
  $$CustomBlocksTableTableManager get customBlocks =>
      $$CustomBlocksTableTableManager(_db, _db.customBlocks);
}
