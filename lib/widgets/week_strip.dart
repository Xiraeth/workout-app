import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../models/session.dart';
import '../theme/tokens.dart';
import '../utils/dates.dart';
import '../utils/format.dart';
import 'app_buttons.dart';

/// Seven rounded day pills for the week containing [selected].
class WeekStrip extends StatelessWidget {
  const WeekStrip({
    super.key,
    required this.selected,
    required this.today,
    required this.weekStart,
    required this.sessions,
    required this.onSelect,
  });

  final DateTime selected;
  final DateTime today;
  final WeekStart weekStart;
  final List<Session> sessions;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final start = weekStartFor(selected, weekStart);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _DayPill(
                  date: addDays(start, i),
                  isSelected: sameDay(addDays(start, i), selected),
                  isToday: sameDay(addDays(start, i), today),
                  sessions: sessions.where((s) => sameDay(s.date, addDays(start, i))).toList(),
                  today: today,
                  onTap: () => onSelect(addDays(start, i)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.sessions,
    required this.today,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final List<Session> sessions;
  final DateTime today;
  final VoidCallback onTap;

  /// Done beats planned beats missed.
  Color? get _dot {
    if (sessions.isEmpty) return null;
    final statuses = sessions.map((s) => s.status(today)).toSet();
    final s = statuses.contains(SessionStatus.done)
        ? SessionStatus.done
        : statuses.contains(SessionStatus.planned)
            ? SessionStatus.planned
            : SessionStatus.missed;
    return hueForStatus(s).solid;
  }

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(18);
    final fg = isSelected ? Colors.white : (isToday ? AppColors.accent : AppColors.ink);
    final sub = isSelected ? Colors.white.withValues(alpha: 0.8) : (isToday ? AppColors.accent : AppColors.muted);
    final dot = _dot;

    return Semantics(
      selected: isSelected,
      button: true,
      label: '${dayTitle(date)}${sessions.isEmpty ? '' : ', ${sessions.length} session${sessions.length == 1 ? '' : 's'}'}',
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        borderRadius: r,
        scale: 0.94,
        decoration: BoxDecoration(
          gradient: isSelected ? accentGradient : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: r,
          border: isToday && !isSelected ? Border.all(color: AppColors.accent, width: 1.5) : null,
          boxShadow: isSelected ? Shadows.glow(AppColors.accent) : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Text(weekdayTwo(date).toUpperCase(),
                style: AppText.badge.copyWith(fontSize: 11, letterSpacing: 0.6, color: sub)),
            const SizedBox(height: 4),
            Text('${date.day}', style: AppText.h3.copyWith(fontSize: 19, color: fg, height: 1.1)),
            const SizedBox(height: 6),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dot == null ? Colors.transparent : (isSelected ? Colors.white : dot),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
