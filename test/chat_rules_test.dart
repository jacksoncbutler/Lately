import 'package:flutter_test/flutter_test.dart';
import 'package:lately/domain/chat_rules.dart';

void main() {
  test('length buckets follow the duration slider', () {
    expect(lengthForMinutes(1), 'quick');
    expect(lengthForMinutes(20), 'quick');
    expect(lengthForMinutes(21), 'catchup');
    expect(lengthForMinutes(45), 'catchup');
    expect(lengthForMinutes(46), 'long');
    expect(lengthForMinutes(60), 'long');
  });

  group('when it happened', () {
    final now = DateTime(2026, 11, 11, 14, 10);

    test('just now is now and exact', () {
      final t = chatTime(ChatWhen.now, now);
      expect(t.occurredAt, now.toUtc());
      expect(t.approximate, isFalse);
    });

    test('yesterday is the current time minus one day and exact', () {
      final t = chatTime(ChatWhen.yesterday, now);
      expect(t.occurredAt, DateTime(2026, 11, 10, 14, 10).toUtc());
      expect(t.approximate, isFalse);
    });

    test('another day is date only: noon local, approximate', () {
      final t = chatTime(ChatWhen.otherDay, now, date: DateTime(2026, 11, 5));
      final local = t.occurredAt.toLocal();
      expect((local.year, local.month, local.day, local.hour, local.minute), (2026, 11, 5, 12, 0));
      expect(t.approximate, isTrue);
    });

    test('another day is never in the future', () {
      // Today, but it is only 9:00, so noon has not happened yet.
      final morning = DateTime(2026, 11, 11, 9, 0);
      final t = chatTime(ChatWhen.otherDay, morning, date: DateTime(2026, 11, 11));
      expect(t.occurredAt.isAfter(morning.toUtc()), isFalse);
      expect(t.approximate, isTrue);
      // A date in the future is clamped to now.
      final f = chatTime(ChatWhen.otherDay, now, date: DateTime(2027, 1, 1));
      expect(f.occurredAt.isAfter(now.toUtc()), isFalse);
    });

    test('another day needs a date', () {
      expect(() => chatTime(ChatWhen.otherDay, now), throwsArgumentError);
    });
  });

  test('ago text', () {
    expect(agoText(0.2), 'today');
    expect(agoText(1), '1 day ago');
    expect(agoText(5.9), '5 days ago');
    expect(agoText(14), '2 weeks ago');
    expect(agoText(59), '8 weeks ago');
    expect(agoText(60), '2 months ago');
    expect(agoText(400), '13 months ago');
  });

  test('days since never goes negative', () {
    final now = DateTime(2026, 11, 11);
    expect(daysSince(DateTime(2026, 11, 1), now), 10);
    expect(daysSince(DateTime(2026, 12, 1), now), 0);
  });

  group('who the popup starts on', () {
    final now = DateTime.utc(2026, 11, 11, 14);
    final a = LogCandidate('a', name: 'Ann', daysSinceContact: 60, intervalDays: 30); // ratio 2
    final b = LogCandidate('b', name: 'Bo', daysSinceContact: 21, intervalDays: 14); // 1.5
    final c = LogCandidate('c', name: 'Cy', daysSinceContact: 90, intervalDays: 30); // 3

    test('the most overdue, by ratio not by days', () {
      expect(defaultLogPersonId(candidates: [a, b], now: now), 'a');
      expect(defaultLogPersonId(candidates: [a, b, c], now: now), 'c');
    });

    test('ties go to the name, A to Z', () {
      final x = LogCandidate('x', name: 'Zed', daysSinceContact: 30, intervalDays: 30);
      final y = LogCandidate('y', name: 'Abe', daysSinceContact: 30, intervalDays: 30);
      expect(defaultLogPersonId(candidates: [x, y], now: now), 'y');
    });

    test('someone you just tapped Contact for wins, for three hours', () {
      expect(
          defaultLogPersonId(
              candidates: [a, b],
              recentContactPersonId: 'b',
              recentContactAt: now.subtract(const Duration(hours: 2, minutes: 59)),
              now: now),
          'b');
      expect(
          defaultLogPersonId(
              candidates: [a, b],
              recentContactPersonId: 'b',
              recentContactAt: now.subtract(const Duration(hours: 3)),
              now: now),
          'a');
    });

    test('a recent contact who is no longer a candidate is ignored', () {
      expect(
          defaultLogPersonId(
              candidates: [a],
              recentContactPersonId: 'gone',
              recentContactAt: now,
              now: now),
          'a');
    });

    test('nobody means no default', () {
      expect(defaultLogPersonId(candidates: [], now: now), isNull);
    });

    test('freshness', () {
      expect(recentContactIsFresh(null, now), isFalse);
      expect(recentContactIsFresh(now.subtract(const Duration(hours: 1)), now), isTrue);
      expect(recentContactIsFresh(now.subtract(const Duration(hours: 4)), now), isFalse);
    });
  });
}
