import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/profile_format.dart';

/// The outcome of the birthday dialog. [value] is null when cleared. The
/// dialog itself returns null when cancelled.
class BirthdayChoice {
  const BirthdayChoice(this.value);
  final String? value;
}

/// Month and day are chosen from lists (nothing to format by hand); the year
/// is optional and typed as plain digits.
Future<BirthdayChoice?> showBirthdayPicker(BuildContext context, {String? initial}) =>
    showDialog<BirthdayChoice>(
      context: context,
      builder: (_) => _BirthdayDialog(initial: initial),
    );

class _BirthdayDialog extends StatefulWidget {
  const _BirthdayDialog({this.initial});
  final String? initial;

  @override
  State<_BirthdayDialog> createState() => _BirthdayDialogState();
}

class _BirthdayDialogState extends State<_BirthdayDialog> {
  int? _month;
  int? _day;
  late final TextEditingController _year;

  @override
  void initState() {
    super.initState();
    final p = parseBirthday(widget.initial);
    _month = p?.month;
    _day = p?.day;
    _year = TextEditingController(text: p?.year?.toString() ?? '');
  }

  @override
  void dispose() {
    _year.dispose();
    super.dispose();
  }

  /// null = no year; -1 = typed but not a usable year.
  int? get _yearValue {
    final t = _year.text.trim();
    if (t.isEmpty) return null;
    final y = int.tryParse(t);
    return (y == null || t.length != 4 || y < 1900 || y > 2100) ? -1 : y;
  }

  String? get _error {
    final y = _yearValue;
    if (y == -1) return 'Use a 4-digit year, or leave it blank';
    if (_month != null && _day != null && formatBirthday(_month!, _day!, year: y) == null) {
      return 'That date does not exist in $y';
    }
    return null;
  }

  bool get _valid => _month != null && _day != null && _error == null;

  @override
  Widget build(BuildContext context) {
    final maxDay = _month == null
        ? 31
        : daysInMonth(_month!, year: _yearValue == -1 ? null : _yearValue);
    return AlertDialog(
      title: const Text('Birthday'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<int>(
                key: const Key('bday-month'),
                initialValue: _month,
                decoration: const InputDecoration(labelText: 'Month'),
                items: [
                  for (var m = 1; m <= 12; m++)
                    DropdownMenuItem(value: m, child: Text(monthNames[m - 1])),
                ],
                onChanged: (v) => setState(() {
                  _month = v;
                  final max = daysInMonth(v!, year: _yearValue == -1 ? null : _yearValue);
                  if (_day != null && _day! > max) _day = max;
                }),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<int>(
                key: const Key('bday-day'),
                initialValue: _day,
                decoration: const InputDecoration(labelText: 'Day'),
                items: [
                  for (var d = 1; d <= maxDay; d++) DropdownMenuItem(value: d, child: Text('$d')),
                ],
                onChanged: (v) => setState(() => _day = v),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          TextField(
            key: const Key('bday-year'),
            controller: _year,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
            decoration: const InputDecoration(
              labelText: 'Year (optional)',
              helperText: 'Leave blank if you do not know it',
            ),
            onChanged: (_) => setState(() {
              // A year can shorten February: keep the day inside the month.
              if (_month != null && _day != null) {
                final max = daysInMonth(_month!, year: _yearValue == -1 ? null : _yearValue);
                if (_day! > max) _day = max;
              }
            }),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
            ),
        ]),
      ),
      actions: [
        if (widget.initial != null)
          TextButton(
            onPressed: () => Navigator.pop(context, const BirthdayChoice(null)),
            child: const Text('Clear'),
          ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _valid
              ? () {
                  final y = _yearValue;
                  Navigator.pop(context, BirthdayChoice(formatBirthday(_month!, _day!, year: y)));
                }
              : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
