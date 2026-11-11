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
