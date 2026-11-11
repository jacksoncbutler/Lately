# Lately — Product Spec

Nov 8, 2026 · @Jackson

## Vision

Lately helps you keep the people you love in your life by nudging you to talk to them, and by remembering what matters to them so every conversation starts warm. It exists because a year and a half of travel let many close relationships go quiet for months, and because remembering details about people is hard. The goal is to speak to each person within roughly a month of last contact, or whatever interval fits that relationship.

**Design principles**

- Open it when you have free time, not because it pinged you. No notifications for now.
- Remove decisions: the home screen shows one person to talk to, not a list to choose from.
- Logging a chat must take seconds. Anything optional stays optional.
- Information is stored as short lines, never text dumps, so it stays organized.
- Warm, not guilt-inducing: no red counters, no streaks.
- Data lives on the device, and a backup file keeps it portable across versions.

## Decisions made

These are settled unless marked otherwise; anything unsettled is under Open questions.

**Reminders and priority**

- Each person has a contact interval, default set by their group (parents, siblings, friends, plus custom groups). Group defaults are set during first setup and can be overridden per person.
- Priority is how overdue someone is relative to their interval. Exact weighting will be tuned through use.
- "Contact" means a real conversation. A like, a heart, or a quick one or two message exchange does not reset the clock. These can still be added as floating notes not tied to a chat.
- Skipping someone on the home screen does not drop them; they come back. Snoozing is available. (Gut decision, to be revisited after real use.)
- Timezone awareness is a must-have: the app avoids suggesting people who are likely asleep.
- The app learns when people are usually reachable from the timing of logged chats. Manual availability entry is optional and not in the first version.

**Person profile**

- Fixed top zone: name, contact actions, birthday, interval, last in person, last call or text, preferred channel, timezone. An expanded view holds less-used details such as hometown and socials.
- Below it, a scrollable grid of blocks, two columns where content is short. Next time is always full width and first.
- Blocks planned: Next time, Their people, Interests and hobbies, About, plus room for custom blocks. Each block shows its most recent few lines with an expand option.
- Empty blocks keep the normal size, with faint ruled lines as blank rows and the usual small plus. Block order has a default chosen during setup.
- Everything in a block is one short line added with a plus button. Tap a line to edit it; swipe it left to delete, with an Undo bar instead of a confirmation. In Next time, the checkbox ticks the item and tapping the text edits it.
- Their people holds the people in this person's life, family or not. Each is a tile; tapping one opens a small card with name, how they are connected, birthday, and a full-width notes block of short lines with a plus. They have no interval and are never ranked.
- Next time items are checkboxes. Checked items are kept so the log screen can offer to add them to the conversation entry.

**Logging a conversation**

- Required: type (in person, call, text) and depth (shallow, varied, deep). How long is a slider from 1 to 60+ minutes, preset to 30; quick (up to 20 minutes), catch-up (up to 45) and long are worked out from it.
- Optional: when it happened (just now, yesterday, or another day by date only), a short note on what the chat was about, how they were feeling (multi-select), and anything learned, added straight to their profile blocks.

**Home screen and navigation**

- Three tabs: Home, People, Dates. Settings and defaults sit behind an icon on Home.
- Home leads with one person: next time items, a Contact button (begin a conversation), a Log button (record one you already had; the two stack full width, with Not today and Snooze as small text links beneath), and a short why line (for example, "3 weeks overdue, usually a 20 minute catch-up").
- An optional time slider with four stops (Any, 15, 30, 60+) are a soft preference: they nudge the ranking toward people whose chats fit the time, but a very overdue person can still appear (A quick hello still counts). Anyone you already talked to today (calendar day, your timezone) is never suggested, nor anyone below a due floor of 0.6 of their interval; when nobody qualifies Home says You're caught up.
- A slim dates strip under the card shows upcoming birthdays and important dates.

**Onboarding**

- First, set group defaults. Then add people with only the minimum: name, group, contact method, timezone.
- Bulk add from phone contacts, with one group assigned to a whole batch.
- Ask roughly when you last talked, to seed the ranking.
- After creating a profile: view it, or add another. Birthdays and the rest fill in over time.
- Timezone is chosen by city search with a map fallback, confirmed by showing the current local time there.

**Platform and storage**

- Mobile app for Android and iPhone from one codebase (recommended framework in the technical document).
- No cloud for now: data stays on the device. An import and export backup file is part of version 1.
- Test device: Pixel 7a on GrapheneOS, Android 17, with sandboxed Google Play.

**Name, icon, and logging**

- The app is called Lately.
- The icon is the orbit concept: a white ring with a dot orbiting a center point, on a teal rounded square.
- Logging starts from a floating circular button (a speech bubble with a plus) at the bottom center, which opens a popup sheet. A button docked in the tab bar, with Settings as its own tab, was considered and set aside for now.
- The popup defaults to the person currently suggested on Home, or to the person whose Log button you tapped. After you tap Contact and come back, it defaults to that person for a few hours. Change opens a searchable list grouped like the People tab.
- If the app is open and the suggested person stops being a good time to reach, Home updates to the next best person.

## Version 1 scope

Version 1 is the smallest app that does the core loop: add people, see who to talk to, log the chat, remember what matters. Items marked (proposed) were suggested here and need your confirmation.

**1. First-run setup**

- Set default groups and intervals (parents, siblings, friends, plus custom groups).
- Choose the default block order for profiles.

**2. Add people**

- Single add: name, group (default interval shown, editable), contact method, timezone, and roughly when you last talked (a week, two weeks, a month, a few months, six months, a year or more).
- Bulk add from phone contacts: pick many, assign one group to the batch, fill in timezones afterward.
- After creating: open the profile, or add another.
- Timezone: offline city search that shows the current local time there to confirm. The map picker comes later.

**3. Home**

- One hero card: the most overdue person who is likely awake, was not talked to today, and is past the due floor; their next time items, Contact and Log buttons, and a why line. When nobody qualifies: You're caught up.
- Live refresh: while the app is open, the card changes to the next best person if the person shown leaves their awake window or is skipped or snoozed.
- Skip (they come back) and snooze.
- Time slider: Any, 15, 30, 60+, as a soft preference that re-weights the ranking by how well each person's expected chat length fits. Expected length = average of recent chats, scaled up by the gap since you last talked (more weight on the gap when history is thin), 30 minutes with no history.
- Dates strip: the next birthdays and important dates.

**4. Person profile**

- Top zone with Contact and Log actions, key facts, and details that expand. An Edit button opens every detail (name, group, how you reach them, timezone, birthday, contact interval, hometown, socials). Archive and Delete forever sit at the bottom of that sheet: archived people are hidden from Home and People but kept, and Delete forever is offered only for archived people and asks for confirmation.
- Blocks: Next time (checkboxes), Their people, Interests, About. Add a short line with the plus, tap a line to edit it, swipe left to delete it (with an Undo bar).
- Empty blocks keep the normal size with ruled blank rows; long blocks show the latest few lines and expand.
- Their people tiles open a small card with name, relation, birthday, and their own notes.
- Chat history at the bottom, collapsed to recent entries. Tapping an entry shows its details, its note, and what was new from that chat: Next time items covered, new people, and new lines in Interests, About and other blocks.

**5. Log a conversation**

- Opened by a floating circle button at the bottom center of Home and People, as a popup over the current screen. On a profile it logs for that person.
- Default person: the person currently suggested on Home, or whoever's Log button you tapped. Change opens a searchable list grouped like the People tab. Home and profiles carry two buttons: Contact (begin a conversation; choose call or message) and Log (record a chat you already had). After you tap Contact and return, Home asks Did you get to talk to them? with Log it and Not yet.
- Required: type (in person, call, text) and depth (shallow, varied, deep). How long is a slider from 1 to 60+ minutes, preset to 30.
- Optional: when it happened (just now, yesterday, or another day by date only), a short note on what the chat was about, how they were feeling (multiple choice), checked Next time items to add to the entry, and anything learned. The bottom of the popup shows the person's profile blocks with full add, edit and delete; lines added there are linked to the chat. The Their people block opens the same add sheet as the profile and offers people already listed first, to avoid duplicates.
- Saving the log resets the contact clock for that person.

**6. People and Dates tabs**

- People: searchable list grouped by group, showing days since last contact. Archived people sit in a collapsed Archived section at the bottom.
- Dates: a simple upcoming list of birthdays and important dates. (proposed: no full calendar view in version 1.)

**7. Settings and backup**

- Edit groups, intervals, and block order.
- Export everything to one backup file, and import it back. Format described in the technical document.

**Availability in version 1**

People are assumed awake between 8am and 10pm in their local time. (proposed: a single global default, adjustable in settings.) Learning real availability from logged chat times comes later.

## Later

Good ideas that wait until version 1 has been used for a while.

- Learn each person's reachable times from the timestamps of logged chats.
- Optional per-person availability: presets (morning person, mid-day, night owl) or a 7-day good, bad, empty entry.
- Map picker for choosing a person's location.
- Suggestions by mood or depth, such as "someone for a deeper conversation."
- Expected depth of a conversation based on past chats.
- Full calendar view on the Dates tab.
- Promote someone from Their people to a full profile with their own interval.
- Floating notes prompt: offer recent notes when logging the next chat.
- Gift ideas, how we met, and other optional blocks.
- Notifications, once there is a reason for them.
- Cloud storage and sync across devices.
- Encrypted backup file.

* Call detection (Android only, optional call log permission): after a call with someone who has a saved number, offer one-tap logging with type, time, and length filled in. Never automatic, since a missed call or a short voicemail is not a conversation. iPhone does not allow this.

## Open questions

- [x] Framework: confirm one cross-platform codebase for Android and iPhone (recommendation in the technical document), or Android first.
- [ ] iPhone distribution: needs a paid Apple developer account and a Mac build step. Start iOS later or in parallel?
- [ ] Priority weighting: how much does time since last chat count against group importance? Tune after real use.
- [ ] Skip behavior: does a skipped person return tomorrow, or after a set number of days?
- [ ] Time chips: now a soft preference, not a filter. Tune the miss weight (0.6) and the length guess after real use.
- [ ] "Last in person" and "last call or text": should an in-person visit count differently toward the interval?
- [x] Awake window default: is 8am to 10pm local the right global assumption?
- [ ] Important dates beyond birthdays: which kinds (anniversaries, trips, events)?
- [ ] Final icon artwork: refine the orbit concept for app store sizes.
