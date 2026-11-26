import 'package:flutter/material.dart';

import '../domain/phone.dart';
import 'theme.dart';

/// What a [PhoneField] currently holds.
class PhoneValue {
  const PhoneValue(this.parse);
  final PhoneParse parse;

  /// The international form, else what was typed; null when empty.
  String? get stored => parse.stored;
}

/// A country-code button beside the number box. Type a number in any form:
/// `+351 912 345 678` fills the country in for you, a leading `0` means the
/// person's own country, and a plain number uses the country shown (the US to
/// start, then the person's country once their city is chosen). It is saved in
/// international form, which WhatsApp needs.
class PhoneField extends StatefulWidget {
  const PhoneField({
    super.key,
    required this.initial,
    required this.homeIso,
    required this.onChanged,
  });

  /// A saved number, or null.
  final String? initial;

  /// The person's country (from their timezone), when known.
  final String? homeIso;
  final ValueChanged<PhoneValue> onChanged;

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> {
  final _controller = TextEditingController();
  late String _iso;
  bool _chosen = false; // you picked the country yourself

  @override
  void initState() {
    super.initState();
    _iso = widget.homeIso ?? defaultCountryIso;
    final initial = widget.initial?.trim() ?? '';
    if (initial.isNotEmpty) {
      final p = parsePhone(initial, boxIso: widget.homeIso, homeIso: widget.homeIso);
      if (p.e164 != null && p.iso != null) {
        _iso = p.iso!;
        _chosen = true;
        _controller.text = p.national;
      } else {
        _controller.text = initial;
      }
    }
  }

  @override
  void didUpdateWidget(PhoneField old) {
    super.didUpdateWidget(old);
    // The person's city changed: the country follows, unless you chose one.
    if (old.homeIso != widget.homeIso && !_chosen) {
      _iso = widget.homeIso ?? defaultCountryIso;
      WidgetsBinding.instance.addPostFrameCallback((_) => _emit());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  PhoneParse get _parse => parsePhone(_controller.text,
      boxIso: _iso, homeIso: widget.homeIso, boxChosen: _chosen);

  void _emit() => widget.onChanged(PhoneValue(_parse));

  void _typed(String text) {
    // A + number carries its own country: show it.
    if (text.trim().startsWith('+') || text.trim().startsWith('00')) {
      final p = parsePhone(text);
      if (p.iso != null && countryByIso(p.iso) != null) _iso = p.iso!;
    }
    setState(() {});
    _emit();
  }

  Future<void> _pickCountry() async {
    final iso = await showModalBottomSheet<String>(
      context: context,
      // Keep clear of the camera cutout and the status bar.
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => _CountrySheet(first: [?widget.homeIso, defaultCountryIso], selected: _iso),
    );
    if (iso != null) {
      setState(() {
        _iso = iso;
        _chosen = true;
      });
      _emit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = LatelyColors.of(context);
    final country = countryByIso(_iso);
    final p = _parse;
    final pc = countryByIso(p.iso);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 56,
          child: OutlinedButton(
            key: const Key('country-button'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: const Size(0, 56),
            ),
            onPressed: _pickCountry,
            child: Text('${flagEmoji(_iso)} +${country?.dial ?? ''}'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            key: const Key('phone-field'),
            controller: _controller,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: 'Phone number'),
            onChanged: _typed,
          ),
        ),
      ]),
      if (_controller.text.trim().isNotEmpty && p.e164 != null && pc != null)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            key: const Key('phone-hint'),
            p.valid
                ? 'Saved as +${pc.dial} ${p.national}'
                : "Saved as +${pc.dial} ${p.national}. That doesn't look like a complete number.",
            style: TextStyle(fontSize: 12, color: c.muted),
          ),
        ),
    ]);
  }
}

class _CountrySheet extends StatefulWidget {
  const _CountrySheet({required this.first, required this.selected});
  final List<String> first;
  final String selected;

  @override
  State<_CountrySheet> createState() => _CountrySheetState();
}

class _CountrySheetState extends State<_CountrySheet> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final list = searchCountries(_q, first: widget.first);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              key: const Key('country-search'),
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search by country or code',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _q = v),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('No country matches that.'))
                : ListView.builder(
                    padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final c = list[i];
                      return ListTile(
                        key: Key('country-${c.iso}'),
                        leading: Text(flagEmoji(c.iso), style: const TextStyle(fontSize: 22)),
                        title: Text(c.name),
                        trailing: Text('+${c.dial}'),
                        selected: c.iso == widget.selected,
                        onTap: () => Navigator.pop(context, c.iso),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}
