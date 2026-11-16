import 'package:flutter/material.dart';

import 'theme.dart';

/// One row of a card-style list, drawn so a long list can still be built
/// lazily (a real Card would need all its rows at once). The first row has the
/// rounded top, the last the rounded bottom, and a hairline separates the rest.
class CardSlice extends StatelessWidget {
  const CardSlice({super.key, required this.first, required this.last, required this.child});
  final bool first;
  final bool last;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = LatelyColors.of(context);
    const r = Radius.circular(22);
    // A Material (not a plain coloured box) so a ListTile inside shows its ink.
    return Material(
      color: c.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: first ? r : Radius.zero,
          bottom: last ? r : Radius.zero,
        ),
        // Two touching rows share one 1-point line (0.5 each).
        side: BorderSide(color: c.line, width: 0.5),
      ),
      child: child,
    );
  }
}
