import 'package:flutter/material.dart';

import 'swipe_line.dart';
import 'theme.dart';

class BlockItem {
  const BlockItem(this.id, this.text, {this.done = false});
  final String id;
  final String text;
  final bool done;
}

/// A profile block: a title with a plus, short lines, faint ruled rows when
/// empty, and "See all" when there are more than three. Collapsed, every block
/// is the same size (three rows, long lines cut off with an ellipsis); it only
/// grows when you tap See all. Next time has checkboxes and is always full width.
class BlockTile extends StatefulWidget {
  const BlockTile({
    super.key,
    required this.title,
    required this.items,
    required this.open,
    required this.onOpenChanged,
    this.next = false,
    this.wide = false,
    this.onAdd,
    this.onAddRequest,
    this.onSave,
    this.onDelete,
    this.onToggle,
    this.onTapItem,
  });

  final String title;
  final List<BlockItem> items;
  final bool open;
  final ValueChanged<bool> onOpenChanged;

  /// Next time: checkboxes, oldest first, always full width.
  final bool next;

  /// Notes inside a card: every line, growing as needed (no See all).
  final bool wide;

  final ValueChanged<String>? onAdd;

  /// When set, the plus calls this instead of showing the inline add field.
  final VoidCallback? onAddRequest;
  final void Function(String id, String text)? onSave;
  final ValueChanged<String>? onDelete;
  final ValueChanged<String>? onToggle;

  /// When set, tapping a line calls this instead of editing in place.
  final ValueChanged<String>? onTapItem;

  /// Whether the tile needs the full row.
  bool get isWide => next || wide || open;

  @override
  State<BlockTile> createState() => _BlockTileState();
}

class _BlockTileState extends State<BlockTile> {
  bool _adding = false;

  /// Rows shown while a block is collapsed. Every collapsed block is the same
  /// height whatever it holds: header, these rows, and a footer row.
  static const _rows = 3;
  static const _rowHeight = 44.0;
  static const _footerHeight = 48.0;

  void _start() {
    if (widget.onAddRequest != null) {
      widget.onAddRequest!();
    } else {
      setState(() => _adding = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = LatelyColors.of(context);
    final items = widget.items;
    // Notes inside a card show every line. Everything else is a fixed-size
    // tile until you tap See all.
    final collapsed = !widget.wide && !widget.open;
    // Next time keeps the order you added things; the others show the latest first.
    final ordered = widget.next ? items : items.reversed.toList();
    final List<BlockItem> shown;
    if (collapsed) {
      shown = ordered.take(_adding ? _rows - 1 : _rows).toList();
    } else {
      shown = ordered;
    }
    final blanks = (collapsed || widget.wide)
        ? (_rows - shown.length - (_adding ? 1 : 0)).clamp(0, _rows)
        : 0;
    final canExpand = !widget.wide && items.length > _rows;

    return Container(
      key: Key('block-${widget.title}'),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 44,
            child: Row(children: [
              Expanded(
                child: Text(widget.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              IconButton(
                key: Key('add-${widget.title}'),
                tooltip: 'Add to ${widget.title}',
                color: c.accent,
                visualDensity: VisualDensity.compact,
                onPressed: _start,
                icon: const Icon(Icons.add, size: 24),
              ),
            ]),
          ),
          if (_adding)
            SizedBox(
              height: collapsed ? _rowHeight : null,
              child: _AddLine(
                hint: 'Add to ${widget.title.toLowerCase()}',
                onAdd: (t) => widget.onAdd?.call(t),
                onClose: () => setState(() => _adding = false),
              ),
            ),
          for (final it in shown)
            SwipeLine(
              key: ValueKey('${widget.title}-${it.id}'),
              id: it.id,
              text: it.text,
              dim: widget.next && it.done,
              singleLine: collapsed,
              lead: widget.next
                  ? Checkbox(
                      key: Key('check-${it.id}'),
                      value: it.done,
                      onChanged: (_) => widget.onToggle?.call(it.id),
                      visualDensity: VisualDensity.compact,
                    )
                  : null,
              onTap: widget.onTapItem == null ? null : () => widget.onTapItem!(it.id),
              onSave: (t) => widget.onSave?.call(it.id, t),
              onDelete: () => widget.onDelete?.call(it.id),
            ),
          for (var i = 0; i < blanks; i++)
            InkWell(
              key: Key('ruled-${widget.title}-$i'),
              onTap: _start,
              child: Container(
                height: _rowHeight,
                decoration: BoxDecoration(border: Border(top: BorderSide(color: c.line))),
              ),
            ),
          if (!widget.wide)
            SizedBox(
              height: _footerHeight,
              child: canExpand
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        key: Key('expand-${widget.title}'),
                        onPressed: () => widget.onOpenChanged(!widget.open),
                        child: Text(widget.open ? 'Show less' : 'See all (${items.length})'),
                      ),
                    )
                  : null,
            ),
        ],
      ),
    );
  }
}

class _AddLine extends StatefulWidget {
  const _AddLine({required this.hint, required this.onAdd, required this.onClose});
  final String hint;
  final ValueChanged<String> onAdd;
  final VoidCallback onClose;

  @override
  State<_AddLine> createState() => _AddLineState();
}

class _AddLineState extends State<_AddLine> {
  final _c = TextEditingController();
  final _f = FocusNode();
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _f.addListener(() {
      if (!_f.hasFocus) {
        _flush();
        _close();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _f.requestFocus());
  }

  void _flush() {
    final t = _c.text.trim();
    if (t.isNotEmpty) widget.onAdd(t);
    _c.clear();
  }

  void _close() {
    if (_closed) return;
    _closed = true;
    widget.onClose();
  }

  @override
  void dispose() {
    _c.dispose();
    _f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('add-field'),
      controller: _c,
      focusNode: _f,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: widget.hint,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: false,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
      // Enter adds the line and stays open for the next one.
      onEditingComplete: _flush,
    );
  }
}
