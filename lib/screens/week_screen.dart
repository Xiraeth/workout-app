import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lucide_icons_flutter/lucide_icons_500.dart';

import '../models/session.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../utils/dates.dart';
import '../utils/format.dart';
import '../widgets/app_buttons.dart';
import '../widgets/common.dart';
import '../widgets/session_card.dart';
import '../widgets/settings_sheet.dart';
import '../widgets/week_strip.dart';
import 'session_screen.dart';

class WeekScreen extends ConsumerWidget {
  const WeekScreen({super.key});

  void _open(BuildContext context, String id) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => SessionScreen(sessionId: id)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionsProvider);
    final selected = ref.watch(selectedDateProvider);
    final settings = ref.watch(settingsProvider);
    final today = dateOnly(ref.watch(clockProvider)());

    final daySessions = sessions.where((s) => sameDay(s.date, selected)).toList();
    final upcoming = comingUp(sessions, today: today, selected: selected);
    final rel = relativeDay(selected, today);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(Space.side, 8, Space.side, 14),
                decoration: const BoxDecoration(border: Border(bottom: Rule.thickSide)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('WEEK ${isoWeek(selected)} · ${isoWeekYear(selected)}',
                              style: AppText.caps(11, em: 0.1, color: AppColors.accent700)),
                          Text(monthLong(selected), style: AppText.h1, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    AppIconButton(
                      icon: LucideIcons.settings,
                      tooltip: 'Settings',
                      onPressed: () => showSettingsSheet(context),
                    ),
                    const SizedBox(width: 4),
                    AppIconButton(
                      icon: LucideIcons.chevronLeft,
                      tooltip: 'Previous week',
                      bordered: true,
                      onPressed: () => ref.read(selectedDateProvider.notifier).shift(-7),
                    ),
                    const SizedBox(width: 4),
                    AppIconButton(
                      icon: LucideIcons.chevronRight,
                      tooltip: 'Next week',
                      bordered: true,
                      onPressed: () => ref.read(selectedDateProvider.notifier).shift(7),
                    ),
                  ],
                ),
              ),
              WeekStrip(
                selected: selected,
                today: today,
                weekStart: settings.weekStart,
                sessions: sessions,
                onSelect: ref.read(selectedDateProvider.notifier).select,
              ),
              // Body
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(Space.side),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(child: Text(dayTitle(selected), style: AppText.h4)),
                          if (rel.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(rel.toUpperCase(), style: AppText.caps(12, em: 0.08, color: AppColors.accent700)),
                          ],
                        ],
                      ),
                    ),
                    for (final (i, s) in daySessions.indexed) ...[
                      if (i > 0) const SizedBox(height: 8),
                      SessionCard(session: s, today: today, onTap: () => _open(context, s.id)),
                    ],
                    if (daySessions.isEmpty) const _EmptyDay(),
                    if (upcoming.isNotEmpty) ...[
                      Container(
                        margin: const EdgeInsets.only(top: 28),
                        padding: const EdgeInsets.only(bottom: 8),
                        decoration: const BoxDecoration(border: Border(bottom: Rule.thickSide)),
                        child: Text('COMING UP', style: AppText.h6),
                      ),
                      for (final s in upcoming) UpcomingRow(session: s, onTap: () => _open(context, s.id)),
                    ],
                  ],
                ),
              ),
              BottomBar(
                child: AppButton(
                  label: 'New session · ${dayShort(selected)}',
                  icon: LucideIcons500.plus,
                  iconSize: 18,
                  variant: BtnVariant.primary,
                  block: true,
                  height: 48,
                  fontSize: 15,
                  onPressed: () {
                    final s = Session(date: selected);
                    ref.read(sessionsProvider.notifier).add(s);
                    _open(context, s.id);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(border: Border(top: Rule.thickSide, bottom: Rule.thickSide)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nothing scheduled', style: AppText.body.copyWith(fontSize: 17, fontWeight: FontWeight.w800, height: 1.4)),
          Text('Plan a session for this day, or log one you already did.', style: AppText.muted13.copyWith(height: 1.55)),
        ],
      ),
    );
  }
}
