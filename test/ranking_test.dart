import 'package:flutter_test/flutter_test.dart';
import 'package:lately/domain/ranking.dart';
import 'package:lately/domain/timezones.dart';

// Ported from reference/test.js, plus the rules added since (skip fallback,
// group weight, awake window edges, dates).

final now = DateTime.utc(2026, 11, 11, 14, 10);
const utc = RankSettings(userZone: 'UTC');

RankChat chat(int daysAgo, {int? minutes, String length = 'catchup', DateTime? from}) =>
    RankChat(at: (from ?? now).subtract(Duration(days: daysAgo)), minutes: minutes, length: length);

RankPerson person(
  String name, {
  String zone = 'UTC',
  int interval = 30,
  List<RankChat> chats = const [],
  DateTime? estimate,
  DateTime? snoozedUntil,
  DateTime? skippedUntil,
  bool archived = false,
  double weight = 1.0,
}) =>
    RankPerson(
      id: name,
      name: name,
      zone: zone,
      intervalDays: interval,
      chats: chats,
      lastTalkedEstimate: estimate,
      snoozedUntil: snoozedUntil,
      skippedUntil: skippedUntil,
      archived: archived,
      weight: weight,
    );

/// The prototype's sample people, with the same intervals and chat history.
List<RankPerson> sample() => [
      person('Sam', zone: 'Europe/Lisbon', chats: [chat(51), chat(70, length: 'quick'), chat(104, minutes: 150, length: 'long')]),
      person('Mom', zone: 'America/Chicago', interval: 14, chats: [chat(9, minutes: 40), chat(24)]),
      person('Dad', zone: 'America/Chicago', interval: 14, chats: [chat(31, length: 'quick'), chat(52, length: 'quick')]),
      person('Kate', zone: 'America/Denver', interval: 21, chats: [chat(40, length: 'quick'), chat(70, minutes: 75, length: 'long')]),
      person('Alex', zone: 'Australia/Sydney', estimate: now.subtract(const Duration(days: 60))),
      person('Priya', zone: 'Asia/Kolkata', chats: [chat(15), chat(40, minutes: 70, length: 'long')]),
      person('Marcus', zone: 'America/New_York', chats: [chat(62, minutes: 90, length: 'long'), chat(120)]),
      person('Noor', zone: 'Asia/Dubai', chats: [chat(33, length: 'quick'), chat(60, length: 'quick'), chat(90, length: 'quick')]),
      person('Jun', zone: 'Asia/Tokyo', estimate: now.subtract(const Duration(days: 30))),
      person('Elena', zone: 'Europe/Berlin', chats: [chat(100, minutes: 180, length: 'long'), chat(130)]),
      person('Lena', zone: 'Europe/London', interval: 21, chats: [chat(0)]),
      person('Ruth', zone: 'Pacific/Auckland', chats: [chat(80, minutes: 120, length: 'long')]),
    ];

RankRow by(List<RankRow> rows, String name) => rows.firstWhere((r) => r.person.name == name);

void main() {
  setUpAll(ensureTimezonesLoaded);

  late List<RankRow> rows;
  setUp(() => rows = rank(sample(), now, utc));

  group('who is eligible', () {
    test('someone you talked to today is excluded (Lena)', () {
      expect(by(rows, 'Lena').status, PersonStatus.today);
    });

    test('below the due floor is not due (Priya, ratio .5)', () {
      final r = by(rows, 'Priya');
      expect(r.ratio, closeTo(0.5, 0.001));
      expect(r.status, PersonStatus.notDue);
    });

    test('Mom sits between the floor and 1 and is eligible', () {
      final r = by(rows, 'Mom');
      expect(r.ratio, greaterThanOrEqualTo(0.6));
      expect(r.ratio, lessThan(1));
      expect(r.status, PersonStatus.ok);
    });

    test('asleep people are excluded, using THEIR local time', () {
      // 14:10 UTC: Denver 7:10, Tokyo 23:10, Sydney 1:10, Auckland 3:10.
      for (final n in ['Kate', 'Jun', 'Alex', 'Ruth']) {
        expect(by(rows, n).status, PersonStatus.asleep, reason: n);
      }
      for (final n in ['Sam', 'Marcus', 'Elena', 'Noor', 'Dad']) {
        expect(by(rows, n).status, PersonStatus.ok, reason: n);
      }
    });

    test('the awake window includes the start and excludes the end', () {
      RankRow at(int h, int m) => rank([person('P', chats: [chat(60)])],
          DateTime.utc(2026, 11, 11, h, m), utc).single;
      expect(at(7, 59).status, PersonStatus.asleep);
      expect(at(8, 0).status, PersonStatus.ok);
      expect(at(21, 59).status, PersonStatus.ok);
      expect(at(22, 0).status, PersonStatus.asleep);
    });

    test('a custom awake window is respected', () {
      const s = RankSettings(userZone: 'UTC', awakeStartMinutes: 9 * 60, awakeEndMinutes: 20 * 60 + 30);
      final p = person('P', chats: [chat(60)]);
      expect(rank([p], DateTime.utc(2026, 11, 11, 8, 59), s).single.status, PersonStatus.asleep);
      expect(rank([p], DateTime.utc(2026, 11, 11, 9, 0), s).single.status, PersonStatus.ok);
      expect(rank([p], DateTime.utc(2026, 11, 11, 20, 30), s).single.status, PersonStatus.asleep);
    });

    test('snoozed until a time in the future is excluded, and returns after it', () {
      final p = person('P', chats: [chat(60)], snoozedUntil: now.add(const Duration(days: 7)));
      expect(rank([p], now, utc).single.status, PersonStatus.snoozed);
      expect(rank([p], now.add(const Duration(days: 7, minutes: 1)), utc).single.status, PersonStatus.ok);
    });

    test('archived people are not ranked at all', () {
      expect(rank([person('P', chats: [chat(60)], archived: true)], now, utc), isEmpty);
    });

    test('a person who is not yet past the interval but past the floor still ranks', () {
      final r = rank([person('P', chats: [chat(20)])], now, utc).single; // ratio .67
      expect(r.status, PersonStatus.ok);
    });
  });

  group('same calendar day, not a rolling 24 hours', () {
    test('a chat before local midnight is not today; one after midnight is', () {
      final tzs = ['UTC', 'America/Los_Angeles', 'Asia/Tokyo'];
      for (final z in tzs) {
        final s = RankSettings(userZone: z);
        final t = calendarDate(z, now);
        // Local midnight at the start of today in z, as an instant.
        final nowMinutes = minutesOfDay(z, now);
        final midnight = now.subtract(Duration(minutes: nowMinutes));
        final before = person('P', zone: z, chats: [RankChat(at: midnight.subtract(const Duration(hours: 1)), length: 'quick')]);
        final after = person('P', zone: z, chats: [RankChat(at: midnight.add(const Duration(seconds: 1)), length: 'quick')]);
        expect(rank([before], now, s).single.status, isNot(PersonStatus.today), reason: '$z before $t');
        expect(rank([after], now, s).single.status, PersonStatus.today, reason: '$z after $t');
      }
    });

    test("'today' is measured in your timezone, not the person's", () {
      // 2026-11-11 23:30 in Los Angeles is 07:30 UTC on the 12th.
      final chatAt = DateTime.utc(2026, 11, 12, 7, 30);
      final later = DateTime.utc(2026, 11, 12, 18, 0); // 10:00 on the 12th in LA
      final p = person('P', zone: 'UTC', chats: [RankChat(at: chatAt, length: 'quick')]);
      expect(rank([p], later, const RankSettings(userZone: 'America/Los_Angeles')).single.status,
          isNot(PersonStatus.today)); // different local day for you
      expect(rank([p], later, const RankSettings(userZone: 'UTC')).single.status, PersonStatus.today);
    });

    test('the same-day rule holds for every chip', () {
      for (final c in TimeChip.values) {
        final h = pickHero(rows, c);
        expect(h.row == null || h.row!.person.name != 'Lena', isTrue, reason: '$c');
      }
    });
  });

  group('order and ties', () {
    test('a higher overdue ratio beats group importance (default weights are equal)', () {
      final friend = person('Friend', interval: 30, chats: [chat(90)]); // ratio 3
      final parent = person('Parent', interval: 14, chats: [chat(20)]); // ratio 1.43
      final r = rank([parent, friend], now, utc);
      expect(r.first.person.name, 'Friend');
    });

    test('ratio, not raw days: 21 days on a 14-day interval beats 40 days on 90', () {
      final a = person('A', interval: 14, chats: [chat(21)]);
      final b = person('B', interval: 90, chats: [chat(60)]);
      expect(rank([b, a], now, utc).first.person.name, 'A');
    });

    test('a group weight can reorder, but only when someone sets it', () {
      final a = person('A', chats: [chat(45)], weight: 1.0); // 1.5
      final b = person('B', chats: [chat(36)], weight: 1.5); // 1.2 * 1.5 = 1.8
      expect(rank([a, b], now, utc).first.person.name, 'B');
      final b1 = person('B', chats: [chat(36)]);
      expect(rank([a, b1], now, utc).first.person.name, 'A');
    });

    test('ties go to the longest since contact, then A to Z', () {
      // Same ratio (2.0), different days.
      final x = person('X', interval: 15, chats: [chat(30)]);
      final y = person('Y', interval: 30, chats: [chat(60)]);
      expect(rank([x, y], now, utc).first.person.name, 'Y');
      final b = person('Bea', chats: [chat(60)]);
      final a = person('abe', chats: [chat(60)]);
      expect(rank([b, a], now, utc).first.person.name, 'abe');
    });

    test('with no chats, the last-talked estimate seeds the ranking', () {
      final p = person('P', estimate: now.subtract(const Duration(days: 90)));
      final r = rank([p], now, utc).single;
      expect(r.days, closeTo(90, 0.01));
      expect(r.ratio, closeTo(3, 0.01));
    });

    test('with no chats and no estimate, six months is assumed', () {
      expect(rank([person('P')], now, utc).single.days, closeTo(180, 0.01));
    });

    test('the newest chat beats the estimate once one exists', () {
      final p = person('P', estimate: now.subtract(const Duration(days: 200)), chats: [chat(10)]);
      expect(rank([p], now, utc).single.days, closeTo(10, 0.01));
    });

    test('eligible people always come before ineligible ones, whatever their ratio', () {
      final asleep = person('Asleep', zone: 'Asia/Tokyo', chats: [chat(300)]); // 23:10 there
      final awake = person('Awake', chats: [chat(35)]);
      final r = rank([asleep, awake], now, utc);
      expect(r.first.person.name, 'Awake');
    });
  });

  group('skip: tomorrow, or sooner when nobody else is left', () {
    test('a skipped person is passed over while someone else is eligible', () {
      final skipped = person('Skipped', chats: [chat(120)], skippedUntil: nextLocalMidnight('UTC', now));
      final other = person('Other', chats: [chat(40)]);
      final r = rank([skipped, other], now, utc);
      expect(by(r, 'Skipped').status, PersonStatus.skipped);
      final h = pickHero(r, TimeChip.any);
      expect(h.row!.person.name, 'Other');
      expect(h.fromSkipped, isFalse);
    });

    test('...but comes back before "caught up" when nobody else could be shown', () {
      final skipped = person('Skipped', chats: [chat(120)], skippedUntil: nextLocalMidnight('UTC', now));
      final done = person('Done', chats: [chat(0)]); // talked today
      final r = rank([skipped, done], now, utc);
      expect(by(r, 'Skipped').skipEligible, isTrue);
      final h = pickHero(r, TimeChip.any);
      expect(h.row!.person.name, 'Skipped');
      expect(h.fromSkipped, isTrue);
    });

    test('with nobody else to talk to, skipping simply hides them for today', () {
      final skipped = person('Only', chats: [chat(120)], skippedUntil: nextLocalMidnight('UTC', now));
      final h = pickHero(rank([skipped], now, utc), TimeChip.any);
      expect(h.row, isNull);
    });

    test('others who are only asleep or not due do not bring them back either', () {
      final until = nextLocalMidnight('UTC', now);
      final skipped = person('Skipped', chats: [chat(120)], skippedUntil: until);
      final asleep = person('Asleep', zone: 'Asia/Tokyo', chats: [chat(120)]);
      final notDue = person('NotDue', chats: [chat(3)]);
      expect(pickHero(rank([skipped, asleep, notDue], now, utc), TimeChip.any).row, isNull);
    });

    test('a skipped person who is asleep, snoozed or not due does not come back early', () {
      final until = nextLocalMidnight('UTC', now);
      final asleep = person('A', zone: 'Asia/Tokyo', chats: [chat(120)], skippedUntil: until);
      final snoozed = person('B', chats: [chat(120)], skippedUntil: until, snoozedUntil: now.add(const Duration(days: 3)));
      final notDue = person('C', chats: [chat(5)], skippedUntil: until);
      for (final p in [asleep, snoozed, notDue]) {
        final done = person('Done', chats: [chat(0)]); // talked today, so the fallback applies
        final h = pickHero(rank([p, done], now, utc), TimeChip.any);
        expect(h.row, isNull, reason: p.name);
      }
    });

    test('skipped is excluded until midnight, then returns at the same rank', () {
      final until = nextLocalMidnight('UTC', now);
      expect(until, DateTime.utc(2026, 11, 12));
      final skipped = person('Skipped', chats: [chat(120)], skippedUntil: until);
      final other = person('Other', chats: [chat(40)]);
      final justBefore = until.subtract(const Duration(minutes: 1));
      expect(by(rank([skipped, other], justBefore, utc), 'Skipped').status, PersonStatus.skipped);
      final after = DateTime.utc(2026, 11, 12, 9); // awake again, after midnight
      final r = rank([skipped, other], after, utc);
      expect(r.first.person.name, 'Skipped'); // back, and ranked first again
      expect(r.first.status, PersonStatus.ok);
    });

    test('next local midnight follows your timezone, including daylight saving', () {
      // New York leaves daylight saving on 2026-11-01: that day is 25 hours long.
      final t = DateTime.utc(2026, 11, 1, 12);
      final m = nextLocalMidnight('America/New_York', t);
      expect(m, DateTime.utc(2026, 11, 2, 5)); // midnight EST is 05:00 UTC
      expect(nextLocalMidnight('Asia/Tokyo', DateTime.utc(2026, 11, 11, 14, 10)), DateTime.utc(2026, 11, 11, 15));
    });
  });

  group('time chips are a soft preference', () {
    test('what each chip fits', () {
      expect(chipFits(TimeChip.any, 5), isTrue);
      expect([chipFits(TimeChip.m15, 20), chipFits(TimeChip.m15, 25)], [true, false]);
      expect([chipFits(TimeChip.m30, 19), chipFits(TimeChip.m30, 20)], [false, true]);
      expect([chipFits(TimeChip.long, 45), chipFits(TimeChip.long, 50)], [false, true]);
    });

    RankRow fake(String n, double ratio, int exp) => RankRow(
          person: person(n),
          days: ratio * 30,
          ratio: ratio,
          score: ratio,
          status: PersonStatus.ok,
          expectedMinutes: exp,
          sure: true,
          hasHistory: true,
          skipEligible: false,
        );

    test('a very overdue person beats a barely due short-chat person under the 15 chip, with a note', () {
      final h = pickHero([fake('A', 3.0, 60), fake('B', 1.2, 15)], TimeChip.m15);
      expect(h.row!.person.name, 'A');
      expect(h.note, 'A quick hello still counts.');
    });

    test('at a similar ratio, the chip fit wins', () {
      expect(pickHero([fake('C', 1.3, 60), fake('B', 1.2, 15)], TimeChip.m15).row!.person.name, 'B');
    });

    test('the long chip prefers long chats, with its own note when nobody fits', () {
      expect(pickHero([fake('A', 1.5, 20), fake('B', 1.4, 60)], TimeChip.long).row!.person.name, 'B');
      final h = pickHero([fake('A', 3.0, 20), fake('B', 1.0, 30)], TimeChip.long);
      expect(h.row!.person.name, 'A');
      expect(h.note, 'Not a perfect fit for that, but they are the most due.');
    });

    test('the chip never excludes anyone: it always returns somebody if anybody is eligible', () {
      for (final c in TimeChip.values) {
        expect(pickHero(rows, c).row, isNotNull, reason: '$c');
      }
    });

    test('Any adds no note', () {
      expect(pickHero(rows, TimeChip.any).note, '');
    });
  });

  group('caught up', () {
    test('everyone talked today: no hero', () {
      final all = [for (final p in sample()) person(p.name, zone: p.zone, chats: [chat(0)])];
      expect(pickHero(rank(all, now, utc), TimeChip.any).row, isNull);
    });

    test('nobody due: no hero', () {
      final all = [for (final p in sample()) person(p.name, zone: p.zone, chats: [chat(2)])];
      expect(pickHero(rank(all, now, utc), TimeChip.any).row, isNull);
    });

    test('no people: no hero', () {
      expect(pickHero(rank(const [], now, utc), TimeChip.any).row, isNull);
    });

    test('who wakes next, and in how long', () {
      final tokyo = person('Jun', zone: 'Asia/Tokyo'); // 23:10 there
      expect(wakeInMinutes(tokyo, now, utc), 8 * 60 + 50); // until 08:00
      final sydney = person('Alex', zone: 'Australia/Sydney'); // 01:10 there
      expect(wakeInMinutes(sydney, now, utc), 6 * 60 + 50);
    });
  });

  group('expected chat length', () {
    RankChat c(int m) => RankChat(at: now.subtract(const Duration(days: 10)), minutes: m, length: 'catchup');

    test('a long gap raises the guess; five short chats mostly hold it', () {
      final five = [c(20), c(20), c(20), c(20), c(20)];
      final a = expectedInfo(five, 0.9).minutes;
      final b = expectedInfo(five, 6).minutes;
      expect(b, greaterThan(a));
      expect(b, lessThanOrEqualTo(30));
    });

    test('thin history lets the gap matter more', () {
      final b = expectedInfo([c(20), c(20), c(20), c(20), c(20)], 6).minutes;
      final e = expectedInfo([c(20)], 6).minutes;
      expect(e, greaterThan(b));
    });

    test('never above the cap, never below 5', () {
      expect(expectedInfo([c(200)], 6).minutes, lessThanOrEqualTo(90));
      expect(expectedInfo([c(1)], 0.1).minutes, 5);
    });

    test('no history and on time: 30', () {
      expect(expectedInfo(const [], 1).minutes, 30);
    });

    test('an entered duration is used; otherwise quick, catch-up and long count 15, 30, 60', () {
      expect(chatMinutes(RankChat(at: now, minutes: 42, length: 'quick')), 42);
      expect(chatMinutes(RankChat(at: now, length: 'quick')), 15);
      expect(chatMinutes(RankChat(at: now, length: 'catchup')), 30);
      expect(chatMinutes(RankChat(at: now, length: 'long')), 60);
      expect(chatMinutes(RankChat(at: now, length: 'mystery')), 30);
    });

    test('only the last five chats count', () {
      final chats = [
        for (var i = 0; i < 5; i++) RankChat(at: now.subtract(Duration(days: i + 1)), minutes: 20, length: 'quick'),
        RankChat(at: now.subtract(const Duration(days: 400)), minutes: 600, length: 'long'),
      ];
      expect(expectedInfo(chats, 1).minutes, 20);
    });

    test('"usually" needs three chats and a guess the gap barely moved', () {
      final three = [c(30), c(30), c(30)];
      expect(expectedInfo(three, 1).sure, isTrue);
      expect(expectedInfo([c(30), c(30)], 1).sure, isFalse);
      expect(expectedInfo(three, 8).sure, isFalse); // big gap moved the guess
    });
  });

  group('the why line', () {
    RankRow row({required double days, int interval = 30, List<RankChat>? chats}) {
      final p = person('P', interval: interval, chats: chats ?? [chat(days.round())]);
      return RankRow(
        person: p,
        days: days,
        ratio: days / interval,
        score: days / interval,
        status: PersonStatus.ok,
        expectedMinutes: 30,
        sure: true,
        hasHistory: chats == null || chats.isNotEmpty,
        skipEligible: false,
      );
    }

    test('days under two weeks overdue, weeks after that, months from about three', () {
      expect(whyLine(row(days: 31)).startsWith('Overdue by 1 day · '), isTrue);
      expect(whyLine(row(days: 35)).startsWith('Overdue by 5 days'), isTrue);
      expect(whyLine(row(days: 44)).startsWith('Overdue by 2 weeks'), isTrue);
      expect(whyLine(row(days: 79)).startsWith('Overdue by 7 weeks'), isTrue);
      expect(whyLine(row(days: 125)).startsWith('Overdue by 3 months'), isTrue);
    });

    test('due today and due soon', () {
      expect(whyLine(row(days: 30)).startsWith('Due today'), isTrue);
      expect(whyLine(row(days: 29.5)).startsWith('Due today'), isTrue);
      expect(whyLine(row(days: 25)).startsWith('Due in 5 days'), isTrue);
      expect(whyLine(row(days: 28.5)).startsWith('Due in 2 days'), isTrue);
      expect(whyLine(row(days: 29.1, interval: 30)).startsWith('Due today'), isTrue);
    });

    test('the second half names the length, usually or probably', () {
      expect(whyLine(row(days: 31)), 'Overdue by 1 day · usually a 30 minute catch-up');
    });

    test('with no chat history the second half is dropped', () {
      expect(whyLine(row(days: 60, chats: [])), 'Overdue by 4 weeks');
    });
  });

  group('dates', () {
    DateSource s(String name, {String? birthday, bool archived = false, List<({String name, String? relation, String? birthday})> rels = const [], List<({String label, String date, bool repeatsYearly})> dates = const []}) =>
        DateSource(personId: name, name: name, birthday: birthday, archived: archived, relationships: rels, importantDates: dates);

    test("their people's birthdays feed the list, with whose person they are", () {
      final u = upcoming([
        s('Sam', rels: [(name: 'Maria', relation: 'mother', birthday: '--11-20')])
      ], now, 'UTC', 365);
      expect(u.single.label, "Maria's birthday");
      expect(u.single.sub, "Sam's mother");
      expect(u.single.days, 9);
    });

    test('soonest first, today counts as 0, and the limit applies', () {
      final u = upcoming([
        s('Mom', birthday: '--11-14'),
        s('Alex', birthday: '--11-11'),
        s('Far', birthday: '--12-30'),
        s('Kate', birthday: '1990-11-17'),
      ], now, 'UTC', 14);
      expect(u.map((e) => e.label), ["Alex's birthday", "Mom's birthday", "Kate's birthday"]);
      expect(u.map((e) => e.days), [0, 3, 6]);
    });

    test('a birthday earlier this year comes round next year', () {
      final u = upcoming([s('P', birthday: '--03-14')], now, 'UTC', 365);
      expect(u.single.days, 123);
      expect(u.single.year, 2027);
    });

    test('year rollover and a birthday on the last day', () {
      final dec = DateTime.utc(2026, 12, 30, 12);
      final u = upcoming([s('P', birthday: '--01-02'), s('Q', birthday: '--12-31')], dec, 'UTC', 14);
      expect(u.map((e) => (e.label, e.days)), [("Q's birthday", 1), ("P's birthday", 3)]);
    });

    test('Feb 29 shows on Feb 28 in years that are not leap years', () {
      final u = upcoming([s('P', birthday: '--02-29')], DateTime.utc(2027, 2, 20), 'UTC', 30);
      expect((u.single.month, u.single.day), (2, 28));
      final leap = upcoming([s('P', birthday: '--02-29')], DateTime.utc(2028, 2, 20), 'UTC', 30);
      expect((leap.single.month, leap.single.day), (2, 29));
    });

    test('"today" is your local date', () {
      // 03:00 UTC on the 12th is still the 11th in Los Angeles.
      final t = DateTime.utc(2026, 11, 12, 3);
      expect(upcoming([s('P', birthday: '--11-11')], t, 'America/Los_Angeles', 14).single.days, 0);
      expect(upcoming([s('P', birthday: '--11-11')], t, 'UTC', 14), isEmpty); // 364 days away
    });

    test('archived people and invalid dates are ignored', () {
      final u = upcoming([
        s('Old', birthday: '--11-12', archived: true),
        s('Bad', birthday: 'nonsense'),
        s('Worse', birthday: '--13-45'),
      ], now, 'UTC', 365);
      expect(u, isEmpty);
    });

    test('important dates: repeating ones recur, one-off ones only count while ahead', () {
      final u = upcoming([
        s('Sam', dates: [
          (label: 'Documentary release', date: '2026-11-20', repeatsYearly: false),
          (label: 'Past event', date: '2026-01-20', repeatsYearly: false),
          (label: 'Anniversary', date: '2020-11-15', repeatsYearly: true),
        ])
      ], now, 'UTC', 30);
      expect(u.map((e) => e.label), ['Sam: Anniversary', 'Sam: Documentary release']);
    });
  });
}
