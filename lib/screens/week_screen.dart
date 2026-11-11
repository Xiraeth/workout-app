import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/enums.dart';
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

    final weekStart = weekStartFor(selected, settings.weekStart);
    final week = sessions.where((s) => !s.date.isBefore(weekStart) && s.date.isBefore(addDays(weekStart, 7))).toList();
    final done = week.where((s) => s.done).toList();
    final planned = week.where((s) => s.status(today) == SessionStatus.planned).length;
    final setsDone = done.fold(0, (n, s) => n + s.exercises.fold(0, (m, e) => m + e.sets.where((x) => x.value != null).length));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.only(bottom: 120),
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(Space.side, 12, Space.side, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('WEEK ${isoWeek(selected)} · ${isoWeekYear(selected)}', style: AppText.overline),
                              const SizedBox(height: 2),
                              Text(monthLong(selected), style: AppText.h1, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        AppIconButton(icon: LucideIcons.settings, tooltip: 'Settings', onPressed: () => showSettingsSheet(context)),
                        const SizedBox(width: 8),
                        AppIconButton(
                          icon: LucideIcons.chevronLeft,
                          tooltip: 'Previous week',
                          onPressed: () => ref.read(selectedDateProvider.notifier).shift(-7),
                        ),
                        const SizedBox(width: 8),
                        AppIconButton(
                          icon: LucideIcons.chevronRight,
                          tooltip: 'Next week',
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(Space.side, 16, Space.side, 0),
                    child: WeekSummary(done: done.length, planned: planned, sets: setsDone),
                  ),

                  // The selected day
                  Padding(
                    padding: const EdgeInsets.fromLTRB(Space.side, 28, Space.side, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 2, bottom: 12),
                          child: Row(
                            children: [
                              Expanded(child: Text(dayTitle(selected), style: AppText.h4)),
                              if (rel.isNotEmpty) TintPill(rel.toUpperCase()),
                            ],
                          ),
                        ),
                        for (final (i, s) in daySessions.indexed) ...[
                          if (i > 0) const SizedBox(height: 12),
                          SessionCard(session: s, today: today, onTap: () => _open(context, s.id)),
                        ],
                        if (daySessions.isEmpty) const _EmptyDay(),
                        if (upcoming.isNotEmpty) ...[
                          const SizedBox(height: 28),
                          const SectionTitle('Coming up'),
                          UpcomingList(sessions: upcoming, onOpen: (s) => _open(context, s.id)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BottomBar(
                  child: AppButton(
                    label: 'New session · ${dayShort(selected)}',
                    icon: LucideIcons.plus,
                    variant: BtnVariant.primary,
                    block: true,
                    height: 54,
                    fontSize: 16,
                    onPressed: () {
                      final s = Session(date: selected);
                      ref.read(sessionsProvider.notifier).add(s);
                      _open(context, s.id);
                    },
                  ),
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
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const IconTile(icon: LucideIcons.coffee, hue: Hue.amber),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nothing scheduled', style: AppText.title),
                const SizedBox(height: 2),
                Text('Plan a session for this day, or log one you already did.', style: AppText.small),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
