import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/constants.dart';
import '../../ui/city_picker.dart';

/// For people added in bulk: confirm where they are and roughly when you last
/// talked. Returns true when finished.
Future<bool> showFinishSetupSheet(BuildContext context, PersonRow person) async {
  final done = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => FinishSetupSheet(person: person),
  );
  return done ?? false;
}

class FinishSetupSheet extends ConsumerStatefulWidget {
  const FinishSetupSheet({super.key, required this.person});
  final PersonRow person;

  @override
  ConsumerState<FinishSetupSheet> createState() => _FinishSetupSheetState();
}

class _FinishSetupSheetState extends ConsumerState<FinishSetupSheet> {
  String? _zone;
  int? _days; // 0 = not sure (uses the default)
  String? _deviceZone;

  @override
  void initState() {
    super.initState();
    ref.read(deviceTimezoneProvider).current().then((z) {
      if (mounted) setState(() => _deviceZone = z);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Finish setup for ${widget.person.displayName}', style: t.titleLarge),
            const SizedBox(height: 16),
            Text('Where they are', style: t.labelLarge),
            const SizedBox(height: 4),
            CityPicker(
              zone: _zone,
              now: ref.read(nowProvider),
              deviceZone: _deviceZone,
              onChanged: (z) => setState(() => _zone = z),
            ),
            const SizedBox(height: 16),
            Text('Roughly when did you last talk?', style: t.labelLarge),
            const SizedBox(height: 4),
            Wrap(spacing: 8, children: [
              for (final c in Tune.lastTalkedChoices)
                ChoiceChip(
                  label: Text(c.$1),
                  selected: _days == c.$2,
                  onSelected: (_) => setState(() => _days = c.$2),
                ),
              ChoiceChip(
                label: const Text('Not sure'),
                selected: _days == 0,
                onSelected: (_) => setState(() => _days = 0),
              ),
            ]),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _zone == null || _days == null
                  ? null
                  : () async {
                      final now = ref.read(nowProvider)();
                      final days = _days == 0 ? Tune.defaultLastTalkedDays : _days!;
                      await ref.read(repositoryProvider).finishSetup(
                            widget.person.id,
                            timezone: _zone!,
                            lastTalked: now.subtract(Duration(days: days)),
                          );
                      if (context.mounted) Navigator.pop(context, true);
                    },
              child: const Text('Finish setup'),
            ),
          ],
        ),
      ),
    );
  }
}
