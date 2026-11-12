import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'backup/backup_service.dart';
import 'backup_platform.dart';
import 'database.dart';
import 'device_sources.dart';
import 'phone_launcher.dart';
import 'repository.dart';

/// Set in main() after the database has been opened safely (see safe_open.dart).
/// Tests override it with an in-memory database.
final databaseProvider = Provider<LatelyDatabase>(
    (ref) => throw UnimplementedError('databaseProvider must be overridden'));

/// Where automatic snapshots (before imports) are kept.
final snapshotDirProvider = Provider<Directory>(
    (ref) => throw UnimplementedError('snapshotDirProvider must be overridden'));

final backupPlatformProvider =
    Provider<BackupPlatform>((ref) => DeviceBackupPlatform());

final repositoryProvider =
    Provider<Repository>((ref) => Repository(ref.watch(databaseProvider)));

final backupServiceProvider = Provider<BackupService>((ref) => BackupService(
    ref.watch(databaseProvider),
    snapshotDir: ref.watch(snapshotDirProvider)));

/// Step 2 proof-of-life: group count read from the real database.
final groupCountProvider = FutureProvider<int>((ref) async =>
    (await ref.watch(repositoryProvider).listGroups()).length);

final contactsSourceProvider =
    Provider<ContactsSource>((ref) => DeviceContactsSource());

final deviceTimezoneProvider =
    Provider<DeviceTimezone>((ref) => FlutterDeviceTimezone());

/// The current time; tests override it for stable clocks.
final nowProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final setupCompleteProvider = FutureProvider<bool>(
    (ref) => ref.watch(repositoryProvider).isSetupComplete());

final phoneLauncherProvider =
    Provider<PhoneLauncher>((ref) => DevicePhoneLauncher());

final peopleProvider = StreamProvider<List<PersonRow>>(
    (ref) => ref.watch(repositoryProvider).watchPeople());

final archivedPeopleProvider = StreamProvider<List<PersonRow>>(
    (ref) => ref.watch(repositoryProvider).watchArchivedPeople());

final groupsProvider = StreamProvider<List<GroupRow>>(
    (ref) => ref.watch(repositoryProvider).watchGroups());

final personProvider = StreamProvider.family<PersonRow?, String>(
    (ref, id) => ref.watch(repositoryProvider).watchPerson(id));

final linesProvider = StreamProvider.family<List<LineRow>, String>(
    (ref, id) => ref.watch(repositoryProvider).watchLines(id));

final relationshipsProvider =
    StreamProvider.family<List<RelationshipRow>, String>(
        (ref, id) => ref.watch(repositoryProvider).watchRelationships(id));

final chatsProvider = StreamProvider.family<List<ChatRow>, String>(
    (ref, id) => ref.watch(repositoryProvider).watchChats(id));

final customBlocksProvider = StreamProvider<List<CustomBlockRow>>(
    (ref) => ref.watch(repositoryProvider).watchCustomBlocks());

final settingsProvider = StreamProvider<AppSettings>(
    (ref) => ref.watch(repositoryProvider).watchSettings());

final allChatsProvider = StreamProvider<List<ChatRow>>(
    (ref) => ref.watch(repositoryProvider).watchAllChats());

final allRelationshipsProvider = StreamProvider<List<RelationshipRow>>(
    (ref) => ref.watch(repositoryProvider).watchAllRelationships());

final allImportantDatesProvider = StreamProvider<List<ImportantDateRow>>(
    (ref) => ref.watch(repositoryProvider).watchAllImportantDates());

/// This phone's timezone: "today" and "midnight" are measured in it.
final userZoneProvider =
    FutureProvider<String>((ref) => ref.watch(deviceTimezoneProvider).current());

/// The person Home is showing right now (set by Home). The log popup starts on
/// them when nobody else was chosen.
class SuggestedPersonNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? id) => state = id;
}

final suggestedPersonProvider =
    NotifierProvider<SuggestedPersonNotifier, String?>(SuggestedPersonNotifier.new);

/// Which tab is showing: 0 Home, 1 People, 2 Dates.
class TabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void set(int i) => state = i;
}

final tabIndexProvider = NotifierProvider<TabIndexNotifier, int>(TabIndexNotifier.new);
