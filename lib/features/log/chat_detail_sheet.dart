import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/profile_format.dart';
import '../../ui/theme.dart';

Future<void> showChatDetailSheet(BuildContext context,
        {required String personId, required ChatRow chat}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ChatDetailSheet(personId: personId, chat: chat),
    );

/// One logged chat and what was new from it: Next time items covered, new
/// people, and new lines in Interests, About and other blocks.
class ChatDetailSheet extends ConsumerWidget {
  const ChatDetailSheet({super.key, required this.personId, required this.chat});
  final String personId;
  final ChatRow chat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final now = ref.read(nowProvider);
    final lines = ref.watch(linesProvider(personId)).value ?? const <LineRow>[];
    final rels = ref.watch(relationshipsProvider(personId)).value ?? const <RelationshipRow>[];
    final custom = ref.watch(customBlocksProvider).value ?? const <CustomBlockRow>[];

    final covered = lines.where((l) => l.chatId == chat.id).toList();
    final learned = lines.where((l) => l.addedInChatId == chat.id && l.relationshipId == null).toList();
    final folks = rels.where((r) => r.addedInChatId == chat.id).toList();
    final names = {
      'interests': 'Interests',
      'about': 'About',
      'next_time': 'Added to Next time',
      for (final b in custom) b.key: b.name,
    };
    final blockKeys = <String>[];
    for (final l in learned) {
      if (!blockKeys.contains(l.block)) blockKeys.add(l.block);
    }
    final feelings =
        chat.feelings == null ? const <String>[] : (jsonDecode(chat.feelings!) as List).cast<String>();
    final nothing = covered.isEmpty && learned.isEmpty && folks.isEmpty;
    final hasNote = chat.note != null && chat.note!.isNotEmpty;

    Widget group(String title, List<String> items) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 6),
              child: Text(title.toUpperCase(),
                  style: t.labelSmall?.copyWith(letterSpacing: 0.9, fontWeight: FontWeight.w600)),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(children: [
                  for (var i = 0; i < items.length; i++)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: i == 0
                          ? null
                          : BoxDecoration(
                              border: Border(top: BorderSide(color: LatelyColors.of(context).line))),
                      child: Text(items[i]),
                    ),
                ]),
              ),
            ),
          ],
        );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Expanded(child: Text(shortDate(chat.occurredAt, now()), style: t.titleLarge)),
            IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close)),
          ]),
          Text(
              chatSummary(
                type: chat.type,
                length: chat.length,
                depth: chat.depth,
                minutes: chat.durationMinutes,
              ),
              style: t.bodyMedium),
          if (feelings.isNotEmpty)
            Text('Feeling ${feelings.join(', ')}', style: t.bodySmall),
          if (hasNote) group('What it was about', [chat.note!]),
          if (nothing && !hasNote)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Nothing was recorded from this chat.'),
            ),
          if (covered.isNotEmpty)
            group('Covered from Next time', [for (final l in covered) l.lineText]),
          if (folks.isNotEmpty)
            group('New in their people', [for (final f in folks) relationshipLine(f.name, f.relation)]),
          for (final k in blockKeys)
            group(names[k] ?? 'Other', [
              for (final l in learned.where((x) => x.block == k)) l.lineText,
            ]),
        ]),
      ),
    );
  }
}
