# Lately: build instructions

Lately is a personal, offline, device-only mobile app that ranks who to talk to next and stores a short profile and chat log per person. Owner: Jackson (programmer). Android APK first (GitHub Actions), iPhone later. Planned stack: Flutter, Drift (SQLite), Riverpod.

## Read first, in this order
1. `docs/product-spec.md`: what the app does and every settled decision.
2. `docs/technical-plan.md`: stack, data model, backup format, formulas, build order, interaction rules.
3. `docs/screens/`: how each screen looks.
4. `reference/`: `logic.js` + `test.js` (ranking rules, ported first, keep the tests), `prototype/lately-prototype.html` (open in a browser; behaviour of record for anything the docs leave open). Run the logic tests with `node test.js` inside `reference/` (prints "all passed").

## Working method
- Follow the nine steps in "Build order" in the technical plan, one at a time. Each step ends with something Jackson can install on his Pixel 7a (GrapheneOS) and check. Do not start the next step before that.
- Keep data and logic layers free of UI code. Port `reference/logic.js` to Dart as pure functions with the same tests; all tunable numbers live in one constants file (dueFloor 0.6, chipPenalty 0.6, gapBoost 2, gapRatio 4, trustChats 5, historyDamp 0.6, expCap 90, chip15Max 20, chip30Min 20, chipLongMin 50).
- If the docs and prototype disagree, the prototype wins on behaviour, the technical plan on data and formats; tell Jackson about the mismatch.

## Never break
- Backup compatibility: format `lately-backup`; never remove or rename a required field; old files must always import (see "Backup format" rules). Every release gets a migration test with a sample file per format version.
- Privacy: data stays on the device. No INTERNET permission, no analytics, cloud auto-backup off. Contacts permission only when a bulk add starts. Call-log reading is a Later item, optional, Android only.
- Same release keystore for every build, or installs cannot update and data is lost.
- Tone: no notifications, no red badges, no overdue counters, no streaks. Home shows exactly one person.
- Interaction rules (technical plan, "Interaction rules") are identical on every screen: tap a line to edit, swipe left to delete with an Undo bar (no confirm), swipe right does nothing, trash icon while editing, Next time checkbox ticks without opening the editor. Delete forever exists only for archived people and needs confirmation.
- Other-day logs are date-only: store 12:00 local, mark approximate, never in the future. No time-of-day choice.

## Open questions (ask Jackson, do not guess)
- Skip behaviour: returns tomorrow, or after N days? (current default: midnight local)
- Should in-person contact count differently toward the interval?
- Important dates beyond birthdays: which kinds?
- Final icon artwork (orbit concept) for store sizes.
- Priority weights per group are all 1.0 in version 1; tune after real use.
- App name availability (store, domain, trademark) has not been checked.

## Done means
Analyzer clean, tests green (including backup import fixtures), APK installs over the previous build without losing data.
