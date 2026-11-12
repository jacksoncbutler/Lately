# Architecture

Maps the repository to `docs/technical-plan.md`. Calls only go downward.

| Folder | Layer | Contents |
| --- | --- | --- |
| `lib/ui` | Shared widgets | Swipe line, block tile, chips |
| `lib/features/<name>` | Screens | home, people, profile, log, dates, settings, onboarding |
| `lib/domain` | Rules | Pure Dart ranking, expected length, why line, awake window; `constants.dart` holds every tunable number. No Flutter or storage imports |
| `lib/data` | Storage | `tables.dart` (schema), `database.dart` (seed, migrations), `repository.dart` (create/read/update/archive/soft-delete), `providers.dart` (Riverpod). `database.g.dart` is generated: after changing tables run `dart run build_runner build` and commit it. `backup/` holds the backup format: `backup_codec.dart` (checksum, validation, version migrations; pure), `backup_service.dart` (export, replace/merge import, undo). `safe_open.dart` copies the database file aside before a schema migration and restores it if the migration fails. `backup_platform.dart` is the only place that touches share sheet and file picker. Sample files for every format version live in `test/fixtures/`, regenerated with `dart run tool/make_fixtures.dart` (add, never edit, old ones) |
| `test/` | Tests | Domain tests ported from `reference/test.js`; `test/fixtures/` holds one sample backup per format version |
| `android/` | Platform | Release signing via `key.properties` (gitignored), no INTERNET in release, cloud backup off |
| `reference/` | Behaviour of record | Prototype and `logic.js` / `test.js`; do not edit |

Temporary identity (name, icon, package id `net.butler.lately`) is in `lib/app_config.dart` and the Android manifest. Platform-specific features (contacts, file picking, share sheet) go behind small interfaces in `lib/data` so iOS can be added later.

## Step 4 notes

- `lib/domain/timezones.dart` wraps the bundled IANA database (`latest_all`, which includes link names such as `Europe/Amsterdam` that phones report). `lib/domain/cities.dart` is the offline city list; search also covers every city in the tz database and country names.
- `lib/data/device_sources.dart` holds the two platform inputs (phone contacts, device timezone) behind interfaces. READ_CONTACTS is declared in the manifest but only requested when a bulk add starts.
- First-run setup completion is device-local (`settings.setupCompletedAt`, not exported). Importing a backup marks setup done.
- Until profiles (step 5) and People (step 8) exist, `people_screen.dart` is a minimal list; tapping a person only sets their timezone.

## Step 5 notes

- `lib/ui/swipe_line.dart` and `lib/ui/block_tile.dart` hold the interaction rules once (tap to edit, swipe left to delete with an Undo bar, trash while editing, Next time checkbox, ruled blank rows, See all). Every screen that shows lines uses them; do not re-implement.
- `lib/ui/theme.dart` carries the prototype's colours (light and dark). The prototype's web fonts are not bundled (no network access); the system font is used until fonts are bundled as assets.
- Profile screens live in `lib/features/profile/`: header and facts, blocks, Their people cards, Edit person (with Manage: archive, restore, delete forever), Reach (Contact), Finish setup.
- Bulk-added people are "unfinished" (`needsFinishing`: timezone not confirmed) until you confirm where they are and roughly when you last talked, per person.
- Widget tests that use drift streams must use the `testApp` helper pattern (unmount and close the database inside the test) or drift's stream timers fail the test.
- Chat detail and the Log button arrive in step 6; Recent chats is read-only until then.

## Step 6 notes

- `lib/domain/chat_rules.dart` (pure): length buckets, when-it-happened rules (other day = date only, 12:00 local, approximate, never future), "ago" text, and who the popup starts on. The fallback "most overdue" is a stand-in until step 7 ports the real ranking; `defaultLogPersonId` should then take the hero's id.
- `Repository.logChat` saves a chat, links covered Next time items, stamps lines and people added in the popup, clears skip and snooze, and clears the recent-contact prompt, all in one transaction.
- `ProfileBlocks` (lib/features/profile) is shared by the profile and the log popup, so the line rules cannot drift between screens. Tests that look inside the popup must scope finders to `LogSheet`, because the profile underneath has the same keys.
- Chat deletion has no UI yet (edge case for step 9); `Repository.deleteChat` exists and last contact recomputes from the remaining chats.

## Flutter version

CI and release builds pin Flutter 3.47.9 (`flutter-version` in `.github/workflows`). An unpinned `stable` moved to 3.50.0 and its analyzer now flags `package:flutter/material.dart` as deprecated in favour of `package:material_ui`, which failed the build with no code change. Upgrading Flutter is a deliberate step: change the pin, migrate, run the tests, and install on the Pixel.

## Step 7 notes

- `lib/domain/ranking.dart` is the port of `reference/logic.js` (rank, status, expected length, chips, hero pick, why line, upcoming dates). Its tests (`test/ranking_test.dart`) include the ported reference tests plus the added rules. Every number comes from `constants.dart`.
- Decisions that differ from the reference: the why line drops its second half when there are no chats (the technical plan says so; the prototype did not); skip returns tomorrow, or sooner only when it is the single skipped person left and everyone else eligible has been talked to today (skip everyone and Home says that's everyone for today); people who have not finished setup are never suggested (their awake window would be a guess), and Home says so quietly instead.
- Home re-evaluates every minute and on return to the foreground, like the prototype: it does not keep a person "sticky". When the person shown stops being eligible, or someone more overdue becomes available, it moves on and says why (not when you caused the change yourself).
- "Today" and "midnight" use this phone's timezone; the awake window uses each person's own timezone and the global window in settings.
- `suggestedPersonProvider` carries the person Home shows to the log popup (default person and the "Suggested" tag).
