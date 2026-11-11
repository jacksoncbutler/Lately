import 'package:flutter_test/flutter_test.dart';
import 'package:lately/domain/profile_format.dart';

void main() {
  test('birthday labels, with and without a year', () {
    expect(birthdayLabel('--03-14'), 'Mar 14');
    expect(birthdayLabel('1990-09-27'), 'Sep 27');
    expect(birthdayLabel(null), isNull);
    expect(birthdayLabel('March 14'), isNull);
    expect(birthdayLabel('--13-01'), isNull);
  });

  test('short dates drop the year only when it is this year', () {
    final now = DateTime(2026, 11, 11);
    expect(shortDate(DateTime(2026, 9, 21, 12), now), 'Sep 21');
    expect(shortDate(DateTime(2025, 9, 21, 12), now), 'Sep 21, 2025');
  });

  test('chat summary', () {
    expect(chatSummary(type: 'call', length: 'catchup', depth: 'varied', minutes: 30, feelings: ['Happy']),
        'Call · Catch-up · Varied · 30 min · happy');
    expect(chatSummary(type: 'person', length: 'long', depth: 'deep', minutes: 60), 'In person · Long · Deep · 60+ min');
    expect(chatSummary(type: 'video', length: 'quick', depth: 'shallow'), 'Video · Quick · Shallow');
  });

  test('relationship line', () {
    expect(relationshipLine('Rosa', 'grandmother'), 'Rosa, grandmother');
    expect(relationshipLine('Rosa', null), 'Rosa');
    expect(relationshipLine('Rosa', '  '), 'Rosa');
  });

  test('dialable numbers', () {
    expect(dialableNumber('+351 555 0142'), '+3515550142');
    expect(dialableNumber('(555) 010-0100'), '5550100100');
    expect(dialableNumber('@sam.r'), isNull);
    expect(dialableNumber('sam123456'), isNull);
    expect(dialableNumber('12'), isNull);
    expect(dialableNumber(null), isNull);
  });
}
