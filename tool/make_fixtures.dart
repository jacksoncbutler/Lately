// Regenerates the sample backup files in test/fixtures (with correct
// checksums). Run from the repo root: dart run tool/make_fixtures.dart
// Add a new fixture here for every backup format version; never edit or
// delete an old one, because old files must always keep importing.
import 'dart:convert';
import 'dart:io';

import 'package:lately/data/backup/backup_codec.dart';

const t0 = '2026-11-08T05:00:00Z';

Map<String, dynamic> settings() => {
      'awakeStart': '08:00',
      'awakeEnd': '22:00',
      'blockOrder': ['next_time', 'family', 'interests', 'about'],
    };

Map<String, dynamic> group(String id, String name, int days) => {
      'id': id,
      'name': name,
      'defaultIntervalDays': days,
      'createdAt': t0,
      'updatedAt': t0,
    };

void write(String name, String version, Map<String, dynamic> data) {
  final file = {
    'format': 'lately-backup',
    'formatVersion': version,
    'appVersion': '0.3.0',
    'exportedAt': '2026-11-08T07:15:00Z',
    'checksum': checksumOf(jsonDecode(jsonEncode(data))),
    'data': data,
  };
  File('test/fixtures/$name')
      .writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(file)}\n');
}

void main() {
  // 1.0 exactly as in the technical plan's example.
  write('backup_v1_0_minimal.json', '1.0', {
    'settings': settings(),
    'groups': [group('g-001', 'Friends', 30)],
    'people': [
      {
        'id': 'p-001',
        'displayName': 'Sam',
        'groupId': 'g-001',
        'timezone': 'Europe/Lisbon',
        'contactMethod': {'type': 'text', 'value': '+351000000000'},
        'birthday': '--03-14',
        'createdAt': '2026-11-08T05:10:00Z',
        'updatedAt': '2026-11-08T05:10:00Z',
      }
    ],
    'chats': [
      {
        'id': 'c-001',
        'personId': 'p-001',
        'occurredAt': '2026-10-30T18:00:00Z',
        'type': 'call',
        'length': 'catchup',
        'depth': 'varied',
        'createdAt': '2026-10-30T18:40:00Z',
        'updatedAt': '2026-10-30T18:40:00Z',
      }
    ],
    'lines': [
      {
        'id': 'l-001',
        'personId': 'p-001',
        'block': 'next_time',
        'text': 'Ask about the new job',
        'done': false,
        'createdAt': '2026-11-01T09:00:00Z',
        'updatedAt': '2026-11-01T09:00:00Z',
      }
    ],
    'familyMembers': [],
    'importantDates': [],
    'customBlocks': [],
  });

  // 1.0 using every collection and optional field, including a soft delete.
  write('backup_v1_0_full.json', '1.0', {
    'settings': {
      ...settings(),
      'id': 'settings',
      'createdAt': t0,
      'updatedAt': '2026-11-02T10:00:00Z',
      'skipPolicy': 'midnight',
      'theme': 'light',
    },
    'groups': [
      group('g-parents', 'Parents', 14),
      group('g-friends', 'Friends', 30),
    ],
    'people': [
      {
        'id': 'p-ruth',
        'displayName': 'Ruth',
        'fullName': 'Ruth Anne Cole',
        'middleName': 'Anne',
        'groupId': 'g-friends',
        'timezone': 'Pacific/Auckland',
        'timezoneConfirmed': true,
        'contactMethod': {'type': 'text', 'value': '+64 555 0199'},
        'phone': '+64 555 0199',
        'socials': ['@ruth'],
        'hometown': 'Wellington',
        'birthday': '1990-09-27',
        'intervalOverrideDays': 21,
        'lastTalkedEstimate': '2026-08-01T00:00:00Z',
        'snoozedUntil': '2026-11-15T00:00:00Z',
        'skippedUntil': '2026-11-09T11:00:00Z',
        'createdAt': t0,
        'updatedAt': '2026-11-02T10:00:00Z',
      },
      {
        'id': 'p-old',
        'displayName': 'Archived Al',
        'groupId': 'g-friends',
        'timezone': 'UTC',
        'contactMethod': {'type': 'call'},
        'archivedAt': '2026-10-01T00:00:00Z',
        'createdAt': t0,
        'updatedAt': '2026-10-01T00:00:00Z',
      },
    ],
    'customBlocks': [
      {'id': 'b-gifts', 'key': 'gifts', 'name': 'Gift ideas', 'sortOrder': 1, 'createdAt': t0, 'updatedAt': t0}
    ],
    'familyMembers': [
      {
        'id': 'f-dana',
        'personId': 'p-ruth',
        'name': 'Dana',
        'relation': 'partner',
        'birthday': '--10-03',
        'addedInChatId': 'c-1',
        'createdAt': t0,
        'updatedAt': t0,
      }
    ],
    'chats': [
      {
        'id': 'c-1',
        'personId': 'p-ruth',
        'occurredAt': '2026-10-25T12:00:00Z',
        'timeApproximate': true,
        'type': 'person',
        'depth': 'deep',
        'length': 'long',
        'durationMinutes': 60,
        'feelings': ['happy', 'tired'],
        'note': 'Visited in Wellington',
        'source': 'manual',
        'createdAt': '2026-10-26T08:00:00Z',
        'updatedAt': '2026-10-26T08:00:00Z',
      }
    ],
    'lines': [
      {
        'id': 'l-1',
        'personId': 'p-ruth',
        'block': 'next_time',
        'text': 'Ask about the garden',
        'done': true,
        'doneAt': '2026-10-25T12:30:00Z',
        'chatId': 'c-1',
        'sortOrder': 1,
        'createdAt': t0,
        'updatedAt': '2026-10-25T12:30:00Z',
      },
      {
        'id': 'l-2',
        'personId': 'p-ruth',
        'block': 'family',
        'text': 'Loves rock climbing',
        'relationshipId': 'f-dana',
        'addedInChatId': 'c-1',
        'createdAt': t0,
        'updatedAt': t0,
      },
      {
        'id': 'l-deleted',
        'personId': 'p-ruth',
        'block': 'about',
        'text': 'Removed line',
        'createdAt': t0,
        'updatedAt': '2026-10-30T00:00:00Z',
        'deletedAt': '2026-10-30T00:00:00Z',
      },
    ],
    'importantDates': [
      {
        'id': 'd-1',
        'personId': 'p-ruth',
        'label': 'Documentary release',
        'date': '2027-03-01',
        'repeatsYearly': false,
        'createdAt': t0,
        'updatedAt': t0,
      }
    ],
  });

  // A later minor version: fields and a collection this app does not know.
  write('backup_v1_7_unknown_fields.json', '1.7', {
    'settings': {...settings(), 'futureSetting': {'a': 1}},
    'gifts': [
      {'id': 'x-1', 'idea': 'Tea'}
    ],
    'groups': [
      {...group('g-001', 'Friends', 30), 'icon': 'star'}
    ],
    'people': [
      {
        'id': 'p-001',
        'displayName': 'Sam',
        'groupId': 'g-001',
        'timezone': 'Europe/Lisbon',
        'contactMethod': {'type': 'text', 'value': '+351000000000', 'verified': true},
        'pronouns': 'they/them',
        'createdAt': t0,
        'updatedAt': t0,
      }
    ],
    'chats': [
      {
        'id': 'c-001',
        'personId': 'p-001',
        'occurredAt': '2026-10-30T18:00:00Z',
        'type': 'video',
        'length': 'catchup',
        'depth': 'varied',
        'mood': 'bright',
        'createdAt': t0,
        'updatedAt': t0,
      }
    ],
    'lines': [],
    'familyMembers': [],
    'importantDates': [],
    'customBlocks': [],
  });
}
