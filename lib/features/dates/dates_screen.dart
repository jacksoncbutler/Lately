import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/profile_format.dart';
import '../../domain/ranking.dart';
import '../home/home_data.dart';
import '../profile/profile_screen.dart';

/// Birthdays (people and their people) and important dates over the next 12
/// months. Birthdays with a known year also say how old they turn.
class DatesScreen extends ConsumerWidget {
  const DatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(peopleProvider).value;
    final rels = ref.watch(allRelationshipsProvider).value ?? const <RelationshipRow>[];
    final dates = ref.watch(allImportantDatesProvider).value ?? const <ImportantDateRow>[];
    final zone = ref.watch(userZoneProvider).value;
    final now = ref.read(nowProvider)();

    final list = (people == null || zone == null)
        ? const <UpcomingDate>[]
        : upcoming(
            buildDateSources(people: people, relationships: rels, importantDates: dates),
            now,
            zone,
            365,
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dates',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
      ),
      body: people == null || zone == null
          ? const Center(child: CircularProgressIndicator())
          : list.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No birthdays saved yet. Add them on a profile.',
                        textAlign: TextAlign.center),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                  children: [
                    Card(
                      child: Column(children: [
                        for (var i = 0; i < list.length; i++) ...[
                          if (i > 0) const Divider(),
                          ListTile(
                            key: Key('date-$i'),
                            title: Text(list[i].label, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: _sub(list[i]) == null ? null : Text(_sub(list[i])!),
                            trailing: Text(
                              list[i].days == 0 ? 'Today' : weekdayDate(list[i].date),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                                builder: (_) => ProfileScreen(
                                    personId: list[i].personId, backLabel: 'Dates'))),
                          ),
                        ],
                      ]),
                    ),
                  ],
                ),
    );
  }

  static String? _sub(UpcomingDate d) {
    final parts = [
      if (d.sub.isNotEmpty) d.sub,
      if (d.turns != null) 'Turns ${d.turns}',
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }
}
