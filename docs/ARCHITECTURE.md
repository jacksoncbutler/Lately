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
