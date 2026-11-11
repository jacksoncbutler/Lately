import 'package:drift/drift.dart';

/// Columns every record shares (data model: permanent id, created and updated
/// time). [deletedAt] is a soft delete so a backup merge cannot resurrect a
/// removed record. [extra] holds unknown fields from newer backups (JSON) so
/// they are written back out on the next export.
mixin RecordColumns on Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get extra => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One row only (id = 'settings').
@DataClassName('AppSettings')
class Settings extends Table with RecordColumns {
  TextColumn get awakeStart => text().withDefault(const Constant('08:00'))();
  TextColumn get awakeEnd => text().withDefault(const Constant('22:00'))();

  /// JSON list of block keys.
  TextColumn get blockOrder => text()();
  IntColumn get schemaVersion => integer()();
  TextColumn get skipPolicy => text().nullable()();
  TextColumn get theme => text().nullable()();
  TextColumn get recentContactPersonId => text().nullable()();
  DateTimeColumn get recentContactAt => dateTime().nullable()();

  /// Device-local: when a backup was last exported. Not written to backups.
  DateTimeColumn get lastExportAt => dateTime().nullable()();

  /// Device-local: set when first-run setup is finished (or a backup is
  /// imported). Not written to backups.
  DateTimeColumn get setupCompletedAt => dateTime().nullable()();
}

@DataClassName('GroupRow')
class Groups extends Table with RecordColumns {
  TextColumn get name => text()();
  IntColumn get defaultIntervalDays => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get color => text().nullable()();
}

@DataClassName('PersonRow')
class People extends Table with RecordColumns {
  TextColumn get displayName => text()();
  TextColumn get groupId => text().references(Groups, #id)();

  /// IANA name, e.g. Europe/Lisbon.
  TextColumn get timezone => text()();
  BoolColumn get timezoneConfirmed =>
      boolean().withDefault(const Constant(false))();

  /// text | call | ... (lowercase), plus the number or handle.
  TextColumn get contactMethodType => text()();
  TextColumn get contactMethodValue => text().nullable()();
  TextColumn get fullName => text().nullable()();
  TextColumn get middleName => text().nullable()();

  /// 'YYYY-MM-DD', or '--MM-DD' when the year is unknown.
  TextColumn get birthday => text().nullable()();
  IntColumn get intervalOverrideDays => integer().nullable()();
  TextColumn get phone => text().nullable()();

  /// JSON list of handles.
  TextColumn get socials => text().nullable()();
  TextColumn get hometown => text().nullable()();

  /// Seeds a new person's last contact; real chats win once they exist.
  DateTimeColumn get lastTalkedEstimate => dateTime().nullable()();
  DateTimeColumn get snoozedUntil => dateTime().nullable()();

  /// Skip hides a person until this instant (next local midnight).
  DateTimeColumn get skippedUntil => dateTime().nullable()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
}

/// "Their people": tiles on a profile. Never ranked.
@DataClassName('RelationshipRow')
class Relationships extends Table with RecordColumns {
  TextColumn get personId => text().references(People, #id)();
  TextColumn get name => text()();
  TextColumn get relation => text().nullable()();
  TextColumn get birthday => text().nullable()();
  TextColumn get addedInChatId => text().nullable()();
}

@DataClassName('ChatRow')
class Chats extends Table with RecordColumns {
  TextColumn get personId => text().references(People, #id)();
  DateTimeColumn get occurredAt => dateTime()();

  /// True for other-day logs (stored as 12:00 local); availability learning
  /// ignores the time of such chats.
  BoolColumn get timeApproximate =>
      boolean().withDefault(const Constant(false))();

  /// person | call | text
  TextColumn get type => text()();

  /// shallow | varied | deep
  TextColumn get depth => text()();

  /// 1 to 60, where 60 means 60 or more.
  IntColumn get durationMinutes => integer().nullable()();

  /// quick | catchup | long (derived from duration but stored for old chats).
  TextColumn get length => text()();

  /// JSON list.
  TextColumn get feelings => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  TextColumn get callId => text().nullable()();
}

@DataClassName('LineRow')
class Lines extends Table with RecordColumns {
  TextColumn get personId => text().references(People, #id)();

  /// next_time | interests | about | family | custom block key
  TextColumn get block => text()();
  TextColumn get lineText => text().named('text')();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  DateTimeColumn get doneAt => dateTime().nullable()();

  /// Chat this Next time item was covered in.
  TextColumn get chatId => text().nullable()();
  TextColumn get relationshipId => text().nullable()();

  /// Chat popup that added this line.
  TextColumn get addedInChatId => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('ImportantDateRow')
class ImportantDates extends Table with RecordColumns {
  TextColumn get personId => text().references(People, #id)();
  TextColumn get label => text()();
  TextColumn get date => text()();
  BoolColumn get repeatsYearly =>
      boolean().withDefault(const Constant(true))();
}

@DataClassName('CustomBlockRow')
class CustomBlocks extends Table with RecordColumns {
  TextColumn get key => text()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}
