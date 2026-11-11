import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/enums.dart';
import '../models/session.dart';
import '../theme/tokens.dart';
import '../utils/format.dart';
import 'app_buttons.dart';
import 'common.dart';

/// The colour of a session: its first body part's group, or indigo.
Hue hueForSession(Session s) => s.parts.isEmpty ? Hue.indigo : hueForPart(s.parts.first);

/// A session on the selected day.
class SessionCard extends StatelessWidget {
  const SessionCard({super.key, required this.session, required this.today, required this.onTap});

  final Session session;
  final DateTime today;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final done = session.status(today) == SessionStatus.done;
    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(icon: done ? LucideIcons.check : LucideIcons.dumbbell, hue: done ? Hue.green : hueForSession(session)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(sessionDisplayTitle(session), style: AppText.title)),
                    const SizedBox(width: 8),
                    StatusTag(session.status(today)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(sessionMeta(session), style: AppText.small.copyWith(fontWeight: FontWeight.w600, color: AppColors.accentDark)),
                const SizedBox(height: 6),
                Text(sessionExerciseList(session), style: AppText.small),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Coming up": a single card of rows with a date tile, title and meta.
class UpcomingList extends StatelessWidget {
  const UpcomingList({super.key, required this.sessions, required this.onOpen});

  final List<Session> sessions;
  final ValueChanged<Session> onOpen;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          for (final (i, s) in sessions.indexed) ...[
            if (i > 0) const Divider(height: 1, thickness: 1, indent: 76, color: AppColors.line),
            _UpcomingRow(session: s, onTap: () => onOpen(s)),
          ],
        ],
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({required this.session, required this.onTap});

  final Session session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hue = hueForSession(session);
    return Pressable(
      onTap: onTap,
      scale: 0.99,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: hue.tint, borderRadius: BorderRadius.circular(14)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(weekdayShort(session.date).toUpperCase(),
                    style: AppText.badge.copyWith(fontSize: 10, letterSpacing: 0.5, color: hue.text)),
                Text('${session.date.day}', style: AppText.h4.copyWith(height: 1.1, color: hue.text)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sessionDisplayTitle(session), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.title.copyWith(fontSize: 16)),
                const SizedBox(height: 2),
                Text(sessionMeta(session), style: AppText.small),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.faint),
        ],
      ),
    );
  }
}

/// Three tinted tiles summarising the week on screen.
class WeekSummary extends StatelessWidget {
  const WeekSummary({super.key, required this.done, required this.planned, required this.sets});

  final int done;
  final int planned;
  final int sets;

  @override
  Widget build(BuildContext context) {
    Widget tile(String value, String label, Hue hue, IconData icon) => Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            decoration: BoxDecoration(color: hue.tint, borderRadius: BorderRadius.circular(Radii.tile)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 14, color: hue.text),
                    const SizedBox(width: 5),
                    Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: AppText.badge.copyWith(color: hue.text))),
                  ],
                ),
                const SizedBox(height: 6),
                Text(value, style: AppText.h2.copyWith(fontSize: 26, color: hue.solid)),
              ],
            ),
          ),
        );

    return Row(
      children: [
        tile('$done', 'Done', Hue.green, LucideIcons.circleCheck),
        const SizedBox(width: 10),
        tile('$planned', 'Planned', Hue.indigo, LucideIcons.calendarClock),
        const SizedBox(width: 10),
        tile('$sets', 'Sets done', Hue.orange, LucideIcons.flame),
      ],
    );
  }
}
