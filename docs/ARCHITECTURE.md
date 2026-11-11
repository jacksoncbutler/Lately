# Architecture

Maps the repository to `docs/technical-plan.md`. Calls only go downward.

| Folder | Layer | Contents |
| --- | --- | --- |
| `lib/ui` | Shared widgets | Swipe line, block tile, chips |
| `lib/features/<name>` | Screens | home, people, profile, log, dates, settings, onboarding |
| `lib/domain` | Rules | Pure Dart ranking, expected length, why line, awake window; `constants.dart` holds every tunable number. No Flutter or storage imports |
| `lib/data` | Storage | Drift database, migrations, backup export/import, pre-migration snapshot |
| `test/` | Tests | Domain tests ported from `reference/test.js`; `test/fixtures/` holds one sample backup per format version |
| `android/` | Platform | Release signing via `key.properties` (gitignored), no INTERNET in release, cloud backup off |
| `reference/` | Behaviour of record | Prototype and `logic.js` / `test.js`; do not edit |

Temporary identity (name, icon, package id `net.butler.lately`) is in `lib/app_config.dart` and the Android manifest. Platform-specific features (contacts, file picking, share sheet) go behind small interfaces in `lib/data` so iOS can be added later.
