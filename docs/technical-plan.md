# Lately — Technical Plan

Nov 8, 2026 · @Jackson

## Stack

Recommendation: build one Flutter app for Android and iPhone, storing data in a local SQLite database. Flutter draws its own interface, so the swipe gestures, two-column block grid, and collapsing tiles in the spec look and behave the same on both platforms. The cost of choosing cross-platform now is small, because the Android build and install flow (GitHub Actions builds an APK, you install it) is the same as for a native app. The real extra cost is iPhone distribution, covered under Build and release.

| Choice | Pick | Why |
| --- | --- | --- |
| Framework | Flutter (Dart) | One codebase, custom UI and gestures, strong offline and local-database support, builds an APK on a Linux runner |
| Alternative | React Native with Expo (TypeScript) | Larger ecosystem, but custom swipe and grid UI takes more work and native modules add upgrade risk |
| Alternative | Native Kotlin plus Swift | Best platform feel, but two codebases to build and keep in sync |
| Local database | SQLite through the Drift library | Typed queries, migrations, works fully offline |
| State management | Riverpod | Keeps screens thin and logic testable |
| Notifications | None in version 1 | Matches the spec; add local notifications later without a server |
| Contacts import | Flutter contacts plugin | Reads the Android and iOS address book once, with permission |
| Timezone data | Bundled city list mapped to IANA timezone names | Works offline; avoids map and Google services |

Keep the data and logic layers free of any interface code. If cross-platform ever proves wrong, that separation keeps the rewrite small.

## Architecture

&#91;embedded content: app layers · 4 layers, calls go down only\]

Each layer only calls the one below it. The rules layer knows nothing about screens or storage, so the ranking and timing logic can be tested without a phone.

## Data model

Eight entities cover version 1, and every piece of profile information is a short "line" attached to a person, which keeps adding and exporting simple. Every record has a permanent unique id (a UUID), a created time and an updated time, so records can be matched across backups and app versions.

| Entity | Required | Optional | Notes |
| --- | --- | --- | --- |
| Settings (one record) | awake window start and end, block order, schema version | skip policy, theme, recent contact (person and time) | Global defaults for the app |
| Group | name, default interval in days | sort order, color | Seeded with parents, siblings, friends; users can add more |
| Person | display name, group, timezone (IANA name), preferred contact method | full name, middle name, birthday, interval override, phone, socials, hometown, last-talked estimate, timezone confirmed, snoozed until, archived | Last contact is computed from chats; the estimate only seeds a new person |
| Relationship (Their people) | person, name | relation (free text), birthday, added-in chat | Tiles on the profile. Each has its own notes as Lines linked to the relationship. No interval, never ranked; birthdays feed Dates |
| Line | person, block key, text | done flag, done time, chat link, relationship link (a note on someone in Their people), added-in chat (set when added from the log popup), sort order | One short entry in Next time, Interests, About, or a custom block |
| Chat | person, date and time, type, depth, duration in minutes (1 to 60, where 60 means 60 or more), length (derived: up to 20 quick, up to 45 catch-up, longer long) | feelings (list), note (what the chat was about), source (manual now; call log later), call id (later, prevents duplicates) | The time is when the chat happened (the When field, default now), not when it was saved. For another day only the date is asked: store 12:00 local time and mark the time as approximate, so later availability learning ignores it. Saving resets that person's clock |
| Important date | person, label, date | repeats yearly | Birthdays come from the person; this holds the rest |
| Custom block | key, name | sort order | Lets users add their own profile sections |

Rules that keep the model consistent:

- Last contact for a person is the newest chat date, or the last-talked estimate if there are no chats.
- Next time lines marked done stay stored so the log screen can offer them for the next chat entry; once added to a chat they gain a chat link.
- Deleting a person archives them first, and a permanent delete removes their lines, chats, their people, and dates together.
- Interval for a person is their override if present, otherwise their group's default.

## Screen flow

&#91;embedded content: screen flow · 9 screens\]

After setup you land on Home. Home, People, and Dates all open a person's profile, and the profile is where you log a conversation. Settings sits behind an icon on Home. A floating button on Home and People also opens the log popup, with the person defaulting to the last one you messaged or called.

## Interaction rules

These were settled while testing the prototype. Keep them identical on every screen.

- **Lines:** tap a line to edit it in place. Swipe left to delete, with an Undo bar and no confirmation. While editing, a trash icon also deletes. Swiping right does nothing. The Next time checkbox ticks the item without opening the editor; tapping the text edits it. Their people tiles open their card on tap, and the card's notes follow the same rules.
- **Log popup:** type and depth are the only required taps. How long is a slider from 1 to 60+ minutes, preset to 30. When is just now, yesterday (current time minus one day) or another day (date only, never in the future, stored as 12:00 local and marked approximate). The what-was-it-about note sits below feelings and the covered Next time items, above Their profile. The bottom of the popup holds the person's real profile blocks with full add, edit and delete, saved immediately. Lines and relationships added there are collected and stamped with the new chat's id when the chat is saved.
- **Chat detail:** tapping a chat in Recent chats shows type, length, depth, duration, feelings and note, then what was new from it: lines with that chat as covered-in (Next time items ticked off), lines and relationships with it as added-in. Old chats with nothing linked say nothing was recorded.
- **Edit person:** the Edit button opens one sheet with every detail. Archive is a button at its bottom. An archived person shows in a collapsed Archived list at the bottom of People, with a banner and Restore on their profile. Delete forever is offered only when archived, needs a confirmation, and removes their lines, relationships and chats.
- **Home:** Contact and Log stack full width, with Not today and Snooze as small text links under them. Contact opens a call or message chooser. After Contact and a return to the app, Home asks whether you talked, with Log it and Not yet; the log popup then defaults to that person for three hours.
- **Reference files:** reference/logic.js holds the ranking, expected length, chip scoring and why-line rules as plain functions, with reference/test.js. Port them first and keep the tests. reference/prototype/lately-prototype.html is the clickable prototype that shows every screen.

## Backup format

One JSON file holds the whole app, and any version of the app can read a file written by an older version. The file has a small envelope (format name, version, export time) and one list per entity from the data model. Compatibility comes from a few fixed rules rather than from the exact fields, so the fields can change during development without breaking old backups.

```json
{
  "format": "lately-backup",
  "formatVersion": "1.0",
  "appVersion": "0.3.2",
  "exportedAt": "2026-11-08T07:15:00Z",
  "checksum": "sha256:<hash of the data object>",
  "data": {
    "settings": { "awakeStart": "08:00", "awakeEnd": "22:00", "blockOrder": ["next_time", "family", "interests", "about"] },
    "groups": [
      { "id": "g-001", "name": "Friends", "defaultIntervalDays": 30, "createdAt": "2026-11-08T05:00:00Z", "updatedAt": "2026-11-08T05:00:00Z" }
    ],
    "people": [
      { "id": "p-001", "displayName": "Sam", "groupId": "g-001", "timezone": "Europe/Lisbon",
        "contactMethod": { "type": "text", "value": "+351000000000" },
        "birthday": "--03-14", "createdAt": "2026-11-08T05:10:00Z", "updatedAt": "2026-11-08T05:10:00Z" }
    ],
    "chats": [
      { "id": "c-001", "personId": "p-001", "occurredAt": "2026-10-30T18:00:00Z",
        "type": "call", "length": "catchup", "depth": "varied", "createdAt": "2026-10-30T18:40:00Z", "updatedAt": "2026-10-30T18:40:00Z" }
    ],
    "lines": [
      { "id": "l-001", "personId": "p-001", "block": "next_time", "text": "Ask about the new job", "done": false, "createdAt": "2026-11-01T09:00:00Z", "updatedAt": "2026-11-01T09:00:00Z" }
    ],
    "familyMembers": [],
    "importantDates": [],
    "customBlocks": []
  }
}
```

**Compatibility rules**

1. The format version has a major and minor number. Within a major version, changes only add optional fields. A required field is never removed or renamed; if one must change, add the new field and keep reading the old.
2. An app reads any file with its own major version or lower. A lower major version is upgraded step by step (1 to 2, 2 to 3, and so on) by migration functions kept in the code forever.
3. A file with a higher major version than the app understands is refused with a clear message, and nothing is changed.
4. A higher minor version is accepted. Fields the app doesn't recognize are kept and written back out on the next export, so nothing is lost by opening a newer backup in an older app.
5. Every record has a permanent id. Import can replace everything (restore) or merge by id, with the newest updated time winning.
6. Deleted records carry an optional deleted time instead of disappearing, so a merge does not bring back something you removed.
7. Instants are ISO 8601 in UTC. Birthdays and other calendar dates are plain dates, with `--MM-DD` when the year is unknown. Timezones are IANA names. Enumerated values are lowercase text, and an unknown value is kept as is.
8. Import checks everything first (required fields, valid references between records, checksum) and writes in a single transaction. If anything fails, the database is left untouched.
9. The repository keeps a sample backup file for every format version, and an automated test imports each one into the current code.

The file is plain text and contains personal details about other people, so export shows a short warning. An encrypted option is listed under Later in the product spec.

## Build and release

Android works end to end with a GitHub repository and one GitHub Actions workflow, and iPhone can be added later without changing how the code is organized.

**Android (version 1)**

1. Code lives in a GitHub repository and is developed with Claude Code on branches.
2. Every push runs the analyzer and the automated tests, including the backup import tests.
3. A release workflow runs on a Linux runner, builds a signed release APK, and attaches it to a GitHub Release.
4. On the Pixel, download the APK from the release page in a browser and install it. GrapheneOS asks you to allow installs from that browser once.
5. Sign every build with the same keystore, stored as a GitHub secret and backed up somewhere safe. A build signed with a different key cannot update the installed app, and uninstalling to replace it would erase the local data. Export a backup before any risky install.

**iPhone (later)**

- Building needs a macOS runner (GitHub provides them, billed at a higher rate than Linux).
- Installing on a real iPhone beyond short-lived test builds needs the Apple Developer Program, about 99 dollars a year, and signing certificates managed by a tool such as fastlane.
- You need an iPhone to test on, and the first iOS build usually surfaces a few platform-specific fixes.
- Keep platform-specific code behind small interfaces (contacts, file picking, share sheet) so those fixes stay local.

**Suggested repository layout**

- `lib/data`: database, migrations, backup import and export
- `lib/domain`: entities and rules such as priority ranking and awake-window checks
- `lib/features`: one folder per screen group (home, people, profile, log, dates, settings, onboarding)
- `lib/ui`: shared widgets such as the swipe line, block tile, and chips
- `test/fixtures`: one sample backup file per format version

## Defaults and formulas

These are starting values for version 1. Every number lives in one constants file so it can be tuned after real use, and none of it is shown to the user as a formula.

**Group defaults**

| Group | Default interval |
| --- | --- |
| Parents | 14 days |
| Siblings | 21 days |
| Friends | 30 days |

Any group can be edited or added in settings, and a person can override their group's interval.

**Chat length and last-talked estimate**

| Chat length | Minutes counted |
| --- | --- |
| Quick | 15 |
| Catch-up | 30 |
| Long | 60 |

When a person has no chats, 30 minutes is counted. The last-talked answer at onboarding sets a starting date:

| Last-talked answer | Days ago assumed |
| --- | --- |
| A week | 7 |
| Two weeks | 14 |
| A month | 30 |
| A few months | 90 |
| Six months | 180 |
| A year or more | 360 |

**Priority ranking**

1. Eligible people: not archived, not snoozed, not skipped today, not talked to today (same calendar day in the user's timezone, not a rolling 24 hours), at or above the due floor of 0.6 of their interval, and currently inside their awake window (08:00 to 22:00 in their local time, one global setting).
2. Days since last contact: the newest chat date, or the last-talked estimate if there are no chats.
3. Overdue ratio: days since last contact divided by the person's interval in days.
4. Score: overdue ratio multiplied by the group weight, which is 1.0 for every group in version 1.
5. The highest score is the hero card. Ties go to the person contacted longest ago, then alphabetical. If nobody is eligible, Home shows You're caught up (or who wakes next).

**Expected length and time chips**

- Base length: the average minutes of that person's last five chats, using the exact duration when one was entered and the table above otherwise; 30 if they have none.
- Gap scaling: no change at or under their interval, rising smoothly to double the base at four times the interval, capped at 120 minutes and rounded to 5. With five or more chats, only 40% of that rise applies, so strong history wins; with no history all of it applies. Tunable: gap boost 2, gap ratio 4, history trust 5 chats, damping 0.6, cap 120.
- The why line says "usually" when there are three or more chats and the gap barely moved the guess, otherwise "probably".
- The time control is a four-stop slider (Any, 15, 30, 60+) and is a soft preference, never a filter. 15 fits people with expected length of 20 or less, 30 fits 20 or more, 60+ fits 50 or more.
- With a chip on, a person who does not fit has their overdue ratio multiplied by the chip penalty (0.6). The highest adjusted score wins, so a very overdue person can still appear; the note then reads A quick hello still counts (15 min) or Not a perfect fit for that, but they are the most due.

**Skip and snooze**

- Skip hides that person until midnight local time, then they return at the same rank.
- Snooze hides them for 7 days by default, and the user can pick another date.

**Why line**

- Shown on the hero card as overdue time, then expected length: for example "Overdue by 3 weeks · usually a 30 minute catch-up."
- Overdue under 14 days is shown in days, otherwise in weeks. Not yet due reads "Due in 5 days."
- With no chat history the second half is dropped.

**Live refresh and log default**

- While the app is in the foreground, the hero card is re-evaluated every minute and whenever the app returns to the foreground. If the person shown is no longer eligible (left their awake window, skipped, or snoozed), the card changes to the next best person. (proposed: one-minute interval.)
- Home and profiles carry two buttons: Contact (opens a call or message chooser, then the phone app) and Log (records a chat already had). When Contact is tapped, the person and time are saved as the recent contact. On returning to the app, Home shows Did you get to talk to them? with Log it and Not yet; for three hours the log popup defaults to that person. Otherwise it defaults to the hero card's person, or to the person whose Log button was tapped. The popup has a When field (just now, yesterday, or another day) and a searchable person list grouped like People. Saving a chat for that person clears the recent contact.

**Call detection (later, Android only)**

- Optional permission to read the call log, off by default. The app still has no internet permission, so nothing leaves the phone.
- After a call ends, match the number to a saved person (normalized numbers). Show a suggestion on Home, such as Call with Maria, 23 min, 2:10 pm: Log it? One tap opens the log popup with type call, the real time, and length chosen from the duration.
- Never logged automatically, since a missed call or a short voicemail is not a conversation. Calls made through WhatsApp, Signal, or other apps do not appear in the call log, so those stay manual.
- Chat already stores source and call id, so no data migration is needed when this arrives. iPhone does not allow call log access.

## Edge cases and privacy

**Empty and unusual states**

- No people yet: Home shows a short welcome with the bulk add button and a single add button.
- Nobody eligible (all asleep, snoozed, or skipped): Home shows whoever wakes soonest, with how long until them, and a link to the People tab.
- Everyone overdue after a long time away: Home still shows one person. There are no overdue totals, red badges, or counters anywhere.
- A person with no chats: the header shows "No chats yet" for last in person and last call or text, and the why line uses the last-talked estimate.
- No contact details: the contact button is disabled with a prompt to add a number or handle.
- Bulk add: timezone is not known, so the person gets the device's timezone and an "unconfirmed" mark. The profile shows a "Set timezone" prompt until confirmed.
- Deleting a chat recomputes that person's last contact from the remaining chats.
- Daylight saving changes are handled by the IANA timezone database at runtime, never by stored offsets.

**Derived values** (computed, never stored)

- Last in person: the newest chat of type in person. Last call or text: the newest of type call or text.
- Days since last contact, overdue ratio, expected length, and the why line.
- Dates strip: birthdays and important dates in the next 14 days. Dates tab: the next 12 months, with birthdays of unknown year shown without an age.

**Privacy**

- All data stays in the app's private storage. Version 1 requests no internet permission, so nothing can leave the device except an export file the user chooses to save or share.
- The contacts permission is requested only when the user starts a bulk add, and is not needed afterward.
- Cloud auto-backup of app data is turned off, so personal details about other people do not end up in a phone backup unintentionally. The export file is the only backup.
- The database relies on the phone's own storage encryption in version 1. App lock with biometrics and an encrypted export file are listed under Later in the product spec.

## Build order

Build in nine steps, each ending with something you can install and check on the Pixel. The data and backup steps come first because every later screen depends on them and the backup protects your test data as the schema changes.

| Step | Delivers | Done when |
| --- | --- | --- |
| 1. Skeleton and CI | Flutter project, folder layout, analyzer and tests on every push, signed release APK attached to a GitHub Release | The APK installs on the Pixel and opens to an empty screen; the same keystore signs every build |
| 2. Data layer | Database tables for every entity, migrations, constants file, seeded groups | Automated tests create, read, update, and archive each entity |
| 3. Backup | Export and import in format 1.0 with validation, replace and merge modes, and a sample file in test fixtures | Export then import on a fresh install restores everything; malformed and newer-major files are refused without changes |
| 4. Setup and add people | Group defaults screen, single add, offline city search for timezone, last-talked estimate, bulk add from contacts | Five people added, including a batch from contacts, with correct local times shown |
| 5. Profile | Header with contact actions, blocks, swipe lines, Next time checkboxes, family tiles, peek and expand | Every block type adds, edits, and deletes lines; empty blocks collapse |
| 6. Log a conversation | Floating log button and popup, three required taps, optional feelings and lines, offer of checked Next time items, history list | Saving a chat resets the clock and updates last in person and last call or text |
| 7. Rules and Home | Ranking, awake window, hero card with live refresh, why line, skip, snooze, time chips, dates strip | Tests pass for: higher overdue ratio beats group importance, asleep people excluded, skipped excluded until midnight, each chip filters correctly |
| 8. People, Dates, Settings | Searchable people list, upcoming dates list, settings for groups, block order, and awake window | Changing a group interval changes the ranking on Home |
| 9. Polish | Empty states, edge cases, performance with 200 people, export warning, name and icon | Every state in Edge cases and privacy is reachable and looks intentional |

Working rules for the builder:

- Finish and install each step before starting the next.
- Export a backup before installing any build that changes the database.
- Never change an existing required field; follow the compatibility rules under Backup format.
- iPhone support is a separate step after step 9: macOS build runner, signing, and TestFlight.
