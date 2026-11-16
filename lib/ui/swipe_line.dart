import 'package:flutter/material.dart';

import 'theme.dart';

/// One short line, with the same behaviour on every screen:
/// tap to edit in place, swipe left to delete (the caller shows an Undo bar),
/// swipe right does nothing, and a trash icon appears while editing.
class SwipeLine extends StatefulWidget {
  const SwipeLine({
    super.key,
    required this.id,
    required this.text,
    required this.onSave,
    required this.onDelete,
    this.lead,
    this.dim = false,
    this.onTap,
    this.singleLine = false,
  });

  final String id;
  final String text;
  final ValueChanged<String> onSave;
  final VoidCallback onDelete;

  /// Shown before the text, such as the Next time checkbox.
  final Widget? lead;
  final bool dim;

  /// A fixed-height row: long text is cut off with an ellipsis (the whole line
  /// shows when you edit it or expand the block). When false the row grows to
  /// show the whole line.
  final bool singleLine;

  /// When set, tapping the text does this instead of editing in place (used
  /// by Their people, where a tap opens the person's card).
  final VoidCallback? onTap;

  @override
  State<SwipeLine> createState() => _SwipeLineState();
}

class _SwipeLineState extends State<SwipeLine> {
  bool _editing = false;
  bool _gone = false;
  bool _finished = false;
  late final TextEditingController _controller;
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
    _focus.addListener(() {
      if (!_focus.hasFocus && _editing) _commit();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _startEdit() {
    _finished = false;
    _controller.text = widget.text;
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _commit() {
    if (_finished) return;
    _finished = true;
    final t = _controller.text.trim();
    setState(() => _editing = false);
    if (t.isNotEmpty && t != widget.text) widget.onSave(t);
  }

  void _trash() {
    _finished = true;
    setState(() => _editing = false);
    widget.onDelete();
  }

  @override
  Widget build(BuildContext context) {
    final c = LatelyColors.of(context);
    if (_gone) return const SizedBox.shrink();

    if (_editing) {
      return Container(
        constraints: widget.singleLine
            ? const BoxConstraints.tightFor(height: 44)
            : const BoxConstraints(minHeight: 44),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: c.line))),
        child: Row(children: [
          Expanded(
            child: TextField(
              key: Key('edit-${widget.id}'),
              controller: _controller,
              focusNode: _focus,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              textCapitalization: TextCapitalization.sentences,
              // A fixed-height row edits on one line; an expanded one can wrap.
              minLines: 1,
              maxLines: widget.singleLine ? 1 : 4,
              onEditingComplete: _commit,
            ),
          ),
          IconButton(
            key: Key('trash-${widget.id}'),
            tooltip: 'Delete line',
            icon: const Icon(Icons.delete_outline),
            onPressed: _trash,
          ),
        ]),
      );
    }

    return Dismissible(
      key: Key('dismiss-${widget.id}'),
      direction: DismissDirection.endToStart, // swipe right does nothing
      dismissThresholds: const {DismissDirection.endToStart: 0.35},
      background: Container(
        color: c.dangerSoft,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('Delete',
            style: TextStyle(color: c.danger, fontWeight: FontWeight.w700, fontSize: 13)),
      ),
      onDismissed: (_) {
        setState(() => _gone = true);
        widget.onDelete();
      },
      child: Container(
        // A fixed-height row is 44 in all, divider line included, so the blank
        // ruled rows (also 44) and real lines make the same height.
        constraints: widget.singleLine ? const BoxConstraints.tightFor(height: 44) : null,
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(top: BorderSide(color: c.line)),
        ),
        child: InkWell(
          key: Key('line-${widget.id}'),
          onTap: widget.onTap ?? _startEdit,
          child: Container(
            constraints: widget.singleLine ? null : const BoxConstraints(minHeight: 44),
            child: Row(children: [
              if (widget.lead != null) ...[widget.lead!, const SizedBox(width: 10)],
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    widget.text,
                    maxLines: widget.singleLine ? 1 : null,
                    overflow: widget.singleLine ? TextOverflow.ellipsis : null,
                    style: TextStyle(
                      fontSize: 14.5,
                      color: widget.dim ? c.muted : c.ink,
                      decoration: widget.dim ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Shows an Undo bar after a delete, the same everywhere.
void showUndoBar(BuildContext context, String message, VoidCallback onUndo) {
  final m = ScaffoldMessenger.of(context);
  // Newest message wins: drop anything still queued behind the current one.
  m.clearSnackBars();
  m.showSnackBar(SnackBar(
    content: Text(message),
    action: SnackBarAction(label: 'Undo', onPressed: onUndo),
    // A snack bar with an action stays up until dismissed unless told not to.
    persist: false,
    duration: const Duration(seconds: 3),
  ));
}
