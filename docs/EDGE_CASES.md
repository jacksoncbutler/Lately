# Edge cases and privacy: where each is covered

Every state in "Edge cases and privacy" of the technical plan, the automated test that proves it, and what to look at on the phone.

| State | Test | On the phone |
| --- | --- | --- |
| No people yet: a short welcome with Add someone and Add from contacts | `smoke_test.dart` (an empty app invites you to add someone) | Fresh install, finish setup: Home shows the welcome |
| Nobody eligible (asleep, paused, skipped): who wakes soonest, how long, a way to People | `home_test.dart` (caught up and other empty cards) | Pause or skip everyone: "Nobody is free right now" or "That's everyone for today" |
| Everyone overdue after a long time away: still one person, no totals or badges | `edge_cases_test.dart` | Import a backup with old dates: one card only |
| A person with no chats: "None yet", and the why line uses the last-talked estimate | `profile_test.dart` (no chats says None yet), `ranking_test.dart` | A new person's profile |
| No contact details: Contact is disabled and says what to add | `profile_test.dart` (Contact group) | Add someone with no number |
| Bulk add: device timezone, unconfirmed, "Finish setup" until confirmed | `people_flow_test.dart` (bulk add) | Add a few from contacts: they show Finish setup |
| Deleting a chat recomputes last contact (and Undo restores everything) | `profile_test.dart` (deleting a chat), `log_data_test.dart` | Swipe a chat left in Recent chats |
| Daylight saving comes from the timezone database, never stored offsets | `ranking_test.dart`, `timezones_test.dart` | Local times next to people stay right across a clock change |
| Derived values are never stored | `edge_cases_test.dart` | n/a |
| Dates strip (14 days) and Dates tab (12 months, no age when the year is unknown) | `home_test.dart`, `tabs_test.dart` | Add a few birthdays |
| Export shows a warning that the file holds personal details | `smoke_test.dart` | Settings, Export backup |
| Old backups always import; newer major versions are refused untouched | `backup_test.dart` (every fixture) | Import a backup from an earlier build |
| A failed upgrade restores the data | `safe_open_test.dart` | n/a (unlikely; the message appears if it happens) |
| No INTERNET permission, no analytics, cloud backup off, contacts only when a bulk add starts | `privacy_test.dart`, `people_flow_test.dart` | App info shows no network permission |
| Release signed with the one keystore | `privacy_test.dart` | A new build installs over the old one without losing data |
| Camera cutout or island and the gesture bar do not hide anything | `safe_area_test.dart` | Look at the top and bottom of every screen |
| Small phones and big text do not overflow | `small_phone_test.dart` | Settings, Display, larger text, then open each screen |
| 200 people stay quick | `performance_test.dart` | Import a big backup and scroll |
| Portrait only | `orientation_test.dart` | Turn the phone sideways: nothing changes |
| Name and icon | `privacy_test.dart` (icon files), `docs/icon/lately-icon-512.png` | The launcher shows the orbit icon |
