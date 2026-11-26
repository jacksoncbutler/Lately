import 'package:flutter_test/flutter_test.dart';
import 'package:lately/domain/cities.dart';
import 'package:lately/domain/timezones.dart';

void main() {
  setUpAll(ensureTimezonesLoaded);

  test('every city in the list uses a zone that exists', () {
    for (final c in cityList) {
      expect(isValidZone(c.zone), isTrue, reason: '${c.name} -> ${c.zone}');
    }
  });

  test('city names are unique', () {
    final names = cityList.map((c) => fold(c.name)).toList();
    expect(names.toSet().length, names.length);
  });

  group('local time', () {
    // 2026-11-11 14:10 UTC
    final now = DateTime.utc(2026, 11, 11, 14, 10);
    test('winter and half-hour zones', () {
      expect(clockText('Europe/Lisbon', now), '2:10 pm');
      expect(clockText('America/Chicago', now), '8:10 am');
      expect(clockText('Asia/Kolkata', now), '7:40 pm');
      expect(clockText('Pacific/Auckland', now), '3:10 am'); // +13, next day
    });
    test('daylight saving comes from the database, not a stored offset', () {
      final summer = DateTime.utc(2026, 7, 11, 14, 10);
      expect(clockText('Europe/Lisbon', summer), '3:10 pm');
      expect(clockText('America/Chicago', summer), '9:10 am');
      expect(clockText('Pacific/Auckland', summer), '2:10 am');
    });
    test('midnight and noon read as 12', () {
      expect(clockText('UTC', DateTime.utc(2026, 1, 1, 0, 5)), '12:05 am');
      expect(clockText('UTC', DateTime.utc(2026, 1, 1, 12, 0)), '12:00 pm');
    });
    test('unknown zone falls back to UTC instead of crashing', () {
      expect(clockText('Nowhere/Land', now), '2:10 pm');
    });
    test('hour and minute for the awake window', () {
      final t = hourMinute('Asia/Tokyo', now);
      expect((t.hour, t.minute), (23, 10));
    });
  });

  group('city search', () {
    test('finds by name, case and accents ignored', () {
      expect(searchCities('lisbon').first.zone, 'Europe/Lisbon');
      expect(searchCities('SÃO paulo').first.zone, 'America/Sao_Paulo');
      expect(searchCities('zürich').first.zone, 'Europe/Zurich');
    });
    test('prefix beats contains', () {
      final r = searchCities('port', limit: 10).map((m) => m.name).toList();
      expect(r.first, startsWith('Port'));
      expect(searchCities('porto').first.name, 'Porto');
      expect(searchCities('ndon').map((m) => m.name), contains('London')); // contains, ranked last
      expect(searchCities('lond').first.name, 'London');
    });
    test('finds by country', () {
      final r = searchCities('portugal').map((m) => m.zone);
      expect(r, contains('Europe/Lisbon'));
    });
    test('finds cities that only exist as timezone names', () {
      expect(searchCities('Reykjavik').first.zone, 'Atlantic/Reykjavik');
      expect(searchCities('Tongatapu').first.zone, 'Pacific/Tongatapu');
    });
    test('empty and nonsense queries return nothing', () {
      expect(searchCities(''), isEmpty);
      expect(searchCities('   '), isEmpty);
      expect(searchCities('zzzzqqq'), isEmpty);
    });
    test('limit is respected', () {
      expect(searchCities('a', limit: 3).length, 3);
    });
  });

  test('zone labels', () {
    expect(zoneLabel('Europe/Lisbon'), 'Lisbon');
    expect(zoneLabel('America/Argentina/Buenos_Aires'), 'Buenos Aires');
    expect(zoneLabel('Australia/Sydney'), 'Sydney');
  });
}
