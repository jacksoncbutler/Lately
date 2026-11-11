import 'package:flutter/material.dart';

import '../domain/timezones.dart';

/// Offline city search that confirms the choice by showing the current local
/// time there. [zone] is the chosen IANA zone (null until chosen).
class CityPicker extends StatefulWidget {
  const CityPicker({
    super.key,
    required this.zone,
    required this.onChanged,
    required this.now,
    this.deviceZone,
  });

  final String? zone;
  final ValueChanged<String?> onChanged;
  final DateTime Function() now;

  /// Offers a one-tap "same as mine" when set.
  final String? deviceZone;

  @override
  State<CityPicker> createState() => _CityPickerState();
}

class _CityPickerState extends State<CityPicker> {
  final _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zone = widget.zone;
    if (zone != null) {
      return Row(
        children: [
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                      text: zoneLabel(zone),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  TextSpan(
                      text: ' · ${clockText(zone, widget.now())} there',
                      style: TextStyle(color: Theme.of(context).hintColor)),
                ])),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _q.clear();
              widget.onChanged(null);
            },
            child: const Text('Change'),
          ),
        ],
      );
    }
    final matches = searchCities(_q.text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _q,
          decoration: const InputDecoration(
              hintText: 'Search a city, such as Lisbon',
              border: OutlineInputBorder()),
          onChanged: (_) => setState(() {}),
        ),
        for (final m in matches)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft),
              onPressed: () => widget.onChanged(m.zone),
              child: Text(
                  '${m.name}${m.country.isEmpty ? '' : ', ${m.country}'} · ${clockText(m.zone, widget.now())} there'),
            ),
          ),
        if (_q.text.trim().isNotEmpty && matches.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('No city found. Try a nearby larger city.',
                style: Theme.of(context).textTheme.bodySmall),
          ),
        if (widget.deviceZone != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => widget.onChanged(widget.deviceZone),
              child: Text('Same as mine (${zoneLabel(widget.deviceZone!)})'),
            ),
          ),
      ],
    );
  }
}
