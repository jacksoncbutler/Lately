import 'package:flutter_test/flutter_test.dart';
import 'package:lately/domain/people_filter.dart';
import 'package:lately/domain/ranking.dart';
import 'package:lately/domain/timezones.dart';

void main() {
  setUpAll(ensureTimezonesLoaded);
  final now = DateTime.utc(2026, 11, 11, 14, 10);
  const s = RankSettings(userZone: 'UTC');

  test('awake comes from the clock in their own zone', () {
    expect(isAwakeNow('Europe/Lisbon', now, s), isTrue); // 14:10
    expect(isAwakeNow('Asia/Tokyo', now, s), isFalse); // 23:10
    expect(isAwakeNow('Australia/Sydney', now, s), isFalse); // 01:10
  });

  test('sections for each priority combination', () {
    const a = PeopleFilter(awakeFirst: true);
    const d = PeopleFilter(dueFirst: true);
    const both = PeopleFilter(awakeFirst: true, dueFirst: true);
    expect(prioritySection(const PeopleFilter(), awake: true, due: true), isNull);
    expect(prioritySection(a, awake: true, due: false), 'Awake now');
    expect(prioritySection(a, awake: false, due: true), 'Asleep');
    expect(prioritySection(d, awake: false, due: true), 'Due');
    expect(prioritySection(d, awake: true, due: false), 'Not due');
    expect(prioritySection(both, awake: true, due: true), 'Awake and due');
    expect(prioritySection(both, awake: true, due: false), 'Awake, not due');
    expect(prioritySection(both, awake: false, due: true), 'Asleep and due');
    expect(prioritySection(both, awake: false, due: false), 'Asleep, not due');
    expect(prioritySections(both), hasLength(4));
  });

  test('filter state: active, prioritised, clear group', () {
    const f = PeopleFilter(groupId: 'g');
    expect(f.isActive, isTrue);
    expect(f.prioritised, isFalse);
    expect(f.copyWith(clearGroup: true).isActive, isFalse);
  });
}
