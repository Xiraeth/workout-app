import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/enums.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import 'app_buttons.dart';
import 'common.dart';

Future<void> showSettingsSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      barrierColor: AppColors.scrim,
      builder: (_) => const SettingsSheet(),
    );

/// Units and week start. Changes save immediately.
class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Container(
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.ink, width: 2))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(Space.side, 10, 12, 10),
            decoration: const BoxDecoration(border: Border(bottom: Rule.thickSide)),
            child: Row(
              children: [
                Expanded(child: Text('Settings', style: AppText.body.copyWith(fontSize: 15, fontWeight: FontWeight.w800, height: 1.2))),
                AppButton(label: 'Done', variant: BtnVariant.ghost, onPressed: () => Navigator.of(context).pop()),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(Space.side, 18, Space.side, bottomGap(context, min: 28)),
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
                const SizedBox(height: 12),
                const FieldLabel('Week starts on'),
                SegControl<WeekStart>(
                  options: WeekStart.values,
                  value: settings.weekStart,
                  labelOf: (w) => w.label,
                  onChanged: notifier.setWeekStart,
                ),
                const SizedBox(height: 8),
                Text('Units are labels only; logged numbers are not converted.', style: AppText.muted12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
