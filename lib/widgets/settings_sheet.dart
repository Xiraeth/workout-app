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

    return Column(
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
          child: AppCard(
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
        ),
      ],
    );
  }
}
