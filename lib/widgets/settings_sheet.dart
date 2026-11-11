import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data/backup.dart';
import '../models/enums.dart';
import '../state/backup_actions.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../utils/format.dart';
import 'app_buttons.dart';
import 'common.dart';
import 'delete_dialog.dart';

Future<void> showSettingsSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      barrierColor: AppColors.scrim,
      builder: (_) => const SettingsSheet(),
    );

/// Units, week start, and export/import of all data. Changes save immediately.
class SettingsSheet extends ConsumerStatefulWidget {
  const SettingsSheet({super.key});

  @override
  ConsumerState<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends ConsumerState<SettingsSheet> {
  bool _busy = false;

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      await exportBackup(ref);
    } catch (e) {
      if (mounted) await showMessageDialog(context, title: "Couldn't export", body: '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    setState(() => _busy = true);
    try {
      final Backup? backup;
      try {
        backup = await pickBackup();
      } on FormatException catch (e) {
        if (mounted) await showMessageDialog(context, title: "Couldn't import", body: e.message);
        return;
      }
      if (backup == null || !mounted) return;

      final current = ref.read(sessionsProvider).length;
      final ok = await showConfirmDialog(
        context,
        title: 'Replace your data?',
        body: 'Your ${plural(current, 'session')} and exercise list will be replaced by the '
            '${plural(backup.sessions.length, 'session')} in this backup. '
            'A copy of your current data is kept on the phone.',
        confirm: 'Replace',
      );
      if (ok != true || !mounted) return;

      await restoreBackup(ref, backup);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(content: Text('Imported ${plural(backup.sessions.length, 'session')}')));
    } catch (e) {
      if (mounted) await showMessageDialog(context, title: "Couldn't import", body: '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final sessions = ref.watch(sessionsProvider).length;
    final exercises = ref.watch(exerciseLibraryProvider).length;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.side, 6, 10, 6),
            child: Row(
              children: [
                Expanded(child: Text('Settings', style: AppText.h3)),
                AppButton(label: 'Done', variant: BtnVariant.ghost, height: 40, onPressed: () => Navigator.of(context).pop()),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(Space.side, 8, Space.side, bottomGap(context, min: 28)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const FieldLabel('Units'),
                      SegControl<WeightUnit>(
                        options: WeightUnit.values,
                        value: settings.unit,
                        labelOf: (u) => u.name,
                        onChanged: notifier.setUnit,
                      ),
                      const SizedBox(height: 16),
                      const FieldLabel('Week starts on'),
                      SegControl<WeekStart>(
                        options: WeekStart.values,
                        value: settings.weekStart,
                        labelOf: (w) => w.label,
                        onChanged: notifier.setWeekStart,
                      ),
                      const SizedBox(height: 12),
                      Text('Units are labels only; logged numbers are not converted.', style: AppText.tiny),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const IconTile(icon: LucideIcons.databaseBackup, hue: Hue.sky, size: 40),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Your data', style: AppText.title),
                                Text('${plural(sessions, 'session')} · ${plural(exercises, 'exercise')} on this phone', style: AppText.small),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Export saves everything to one file you can keep in Drive, email or anywhere else. '
                        'Import loads a file back and replaces what is on this phone.',
                        style: AppText.tiny,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: 'Export',
                              icon: LucideIcons.share2,
                              variant: BtnVariant.tonal,
                              block: true,
                              onPressed: _busy ? null : _export,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AppButton(
                              label: 'Import',
                              icon: LucideIcons.fileDown,
                              block: true,
                              onPressed: _busy ? null : _import,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
