# Releasing

How a build gets from this repository to the phone, and what to check each time.

## Before tagging

1. `flutter analyze` is clean and `flutter test` is green (the CI run on the branch shows both, plus a debug Android build).
2. `node test.js` inside `reference/` still prints "all passed" (the prototype's rules, which `lib/domain/ranking.dart` is ported from).
3. The version is bumped in **both** places: `version:` in `pubspec.yaml` (`0.12.0+15`: the part after `+` is the build number and must go up every build, or Android refuses to install over the old one) and `appVersion` in `lib/app_config.dart` (a test keeps them equal).
4. Anything that changes the database bumps `currentSchemaVersion` in `lib/data/database.dart`, adds an upgrade step (never edit old ones), and extends `test/safe_open_test.dart`.
5. Anything that changes the backup file adds optional fields only, bumps `backupMinor` in `lib/app_config.dart`, and gets a new sample file in `test/fixtures` (`dart run tool/make_fixtures.dart`). Old fixtures are never edited or deleted.

## Making the release

The signing key never leaves GitHub: the workflow reads these repository secrets: `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`. **Keep a backup of `lately-release.jks` somewhere safe.** A build signed with a different key cannot update the installed app, and the only fix is to uninstall, which erases the data.

1. On GitHub: Releases, Draft a new release, choose a new tag (for example `v0.11.0`; the name is only a label), set the target to the branch you built, Publish.
2. The "Release APK" workflow signs and attaches `lately-<tag>.apk` to the release (a few minutes).
3. If a build fails, read the failed step on the Actions tab. Do not reuse a tag: make a new one.

## Installing on the phone

1. **Export a backup first** (Settings, Export backup) and save it somewhere that is not the phone, whenever the database or backup format changed.
2. Download the APK from the release page in the browser and open it. Install **over** the old build. Never uninstall first (that erases the data).
3. Open the app. If the screen says it could not upgrade the data, nothing was lost: it puts the data back exactly as it was and says so. Reinstall the previous version and send the message.
4. Run through the checklist in `docs/EDGE_CASES.md`.

## Things that are pinned on purpose

- **Flutter 3.47.9** in `.github/workflows` (an unpinned "stable" once moved overnight and failed the build). Upgrading is its own change: new version, migrate (the analyzer asks for `package:material_ui`), run everything, install on the phone.
- The generated files are committed: `lib/data/database.g.dart` (`dart run build_runner build` after any table change), `lib/domain/countries.dart` and `zone_countries.dart` (`dart run tool/make_countries.dart /usr/share/zoneinfo`), the launcher icons (`python3 tool/make_icon.py`), and the backup fixtures.

## iPhone, later

Needs a macOS build runner, an Apple Developer account and signing, and a test iPhone. Platform-specific code already sits behind small interfaces: `lib/data/device_sources.dart` (contacts, timezone), `lib/data/backup_platform.dart` (share sheet, file picker), `lib/data/phone_launcher.dart` (opening apps), `lib/app_orientation.dart`. The camera island is handled by the same safe-area mechanism as Android's cutouts (`test/safe_area_test.dart`).
