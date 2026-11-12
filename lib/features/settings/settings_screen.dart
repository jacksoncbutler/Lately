import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/backup/backup_codec.dart';
import '../../data/backup/backup_models.dart';
import '../../data/providers.dart';
import 'settings_sections.dart';

/// Settings: groups and intervals, profile block order, awake hours, and backup.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  DateTime? _lastExport;
  bool _canUndo = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final svc = ref.read(backupServiceProvider);
    final last = await svc.lastExportAt();
    if (!mounted) return;
    setState(() {
      _lastExport = last;
      _canUndo = svc.canUndoLastImport;
    });
  }

  void _say(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<bool> _ask(String title, String body, String yes, {String no = 'Cancel'}) async =>
      await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: Text(no)),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(yes)),
          ],
        ),
      ) ??
      false;

  Future<void> _export() async {
    final ok = await _ask(
      'Export backup',
      'The backup is a plain text file with personal details about you and '
          'the people you keep. Save it somewhere private.',
      'Continue',
    );
    if (!ok) return;
    setState(() => _busy = true);
    try {
      final platform = ref.read(backupPlatformProvider);
      final file = await ref
          .read(backupServiceProvider)
          .exportToFile(await platform.exportDirectory());
      await platform.shareFile(file);
      await _refresh();
    } catch (e) {
      if (mounted) _say('Could not export: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    setState(() => _busy = true);
    try {
      final text = await ref.read(backupPlatformProvider).pickBackupText();
      if (text == null) return;
      final ParsedBackup backup;
      try {
        backup = parseBackup(text);
      } on BackupException catch (e) {
        if (mounted) await _ask('Cannot import', e.message, 'OK', no: 'Close');
        return;
      }
      if (!mounted) return;
      final mode = await _chooseMode(backup);
      if (mode == null) return;
      if (mode == ImportMode.replace) {
        final sure = await _ask(
          'Replace everything?',
          'All data on this device is replaced by the backup. A copy of what '
              'is here now is kept, so you can undo this from Settings.',
          'Replace',
        );
        if (!sure) return;
      }
      final r = await ref.read(backupServiceProvider).importBackup(backup, mode);
      await _refresh();
      ref.invalidate(groupCountProvider);
      if (mounted) {
        _say(mode == ImportMode.replace
            ? 'Backup restored.'
            : 'Merged: ${r.inserted} added, ${r.updated} updated.');
      }
    } catch (e) {
      if (mounted) _say('Could not import: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<ImportMode?> _chooseMode(ParsedBackup b) {
    final when = b.exportedAt == null ? '' : ' from ${_date(b.exportedAt!)}';
    final people = b.count('people');
    final chats = b.count('chats');
    return showDialog<ImportMode>(
      context: context,
      builder: (c) => SimpleDialog(
        title: Text('Backup$when'),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('$people people, $chats chats, '
                '${b.count('lines')} lines.'),
          ),
          const SizedBox(height: 12),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(c, ImportMode.replace),
            child: const Text('Replace everything on this device'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(c, ImportMode.merge),
            child: const Text('Merge (newest edit wins)'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(c, null),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _undo() async {
    final ok = await _ask('Undo last import?',
        'The data goes back to how it was before the last replace import.', 'Undo');
    if (!ok) return;
    try {
      await ref.read(backupServiceProvider).undoLastImport();
      await _refresh();
      ref.invalidate(groupCountProvider);
      if (mounted) _say('Import undone.');
    } catch (e) {
      if (mounted) _say('Could not undo: $e');
    }
  }

  static String _date(DateTime d) {
    final l = d.toLocal();
    return '${l.year}-${l.month.toString().padLeft(2, '0')}-${l.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Backup', style: text.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Your data lives only on this phone. Export a backup before '
            'installing a new version, and keep the file somewhere safe.',
            style: text.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            _lastExport == null
                ? 'Not exported yet.'
                : 'Last export: ${_date(_lastExport!)}',
            style: text.bodySmall,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _busy ? null : _export,
            icon: const Icon(Icons.upload_file),
            label: const Text('Export backup'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _busy ? null : _import,
            icon: const Icon(Icons.download),
            label: const Text('Import backup'),
          ),
          if (_canUndo) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: _busy ? null : _undo, child: const Text('Undo last import')),
          ],
          const Divider(height: 40),
          const GroupsSection(),
          const Divider(height: 32),
          const BlockOrderSection(),
          const Divider(height: 32),
          const AwakeSection(),
        ],
      ),
    );
  }
}
