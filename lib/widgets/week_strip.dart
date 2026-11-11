import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../models/session.dart';
import '../theme/tokens.dart';
import '../utils/dates.dart';
import '../utils/format.dart';

/// Seven equal day cells for the week containing [selected].
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
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: Rule.thickSide)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: _DayCell(
                  date: addDays(start, i),
                  isSelected: sameDay(addDays(start, i), selected),
                  isToday: sameDay(addDays(start, i), today),
                  sessions: sessions.where((s) => sameDay(s.date, addDays(start, i))).toList(),
                  onTap: () => onSelect(addDays(start, i)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.date, required this.isSelected, required this.isToday, required this.sessions, required this.onTap});

  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final List<Session> sessions;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = isSelected ? AppColors.bg : (isToday ? AppColors.accent : AppColors.ink);
    final has = sessions.isNotEmpty;
    final anyDone = sessions.any((s) => s.done);

    return Semantics(
      selected: isSelected,
      button: true,
      label: '${dayTitle(date)}${has ? ', ${sessions.length} session${sessions.length == 1 ? '' : 's'}' : ''}',
      excludeSemantics: true,
      child: Material(
        color: isSelected ? AppColors.ink : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashFactory: NoSplash.splashFactory,
          highlightColor: isSelected ? Colors.transparent : AppColors.inkAlpha(0.04),
          hoverColor: isSelected ? Colors.transparent : AppColors.inkAlpha(0.04),
          child: Container(
            decoration: const BoxDecoration(border: Border(right: Rule.thinSide)),
            padding: const EdgeInsets.fromLTRB(8, 10, 0, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(weekdayTwo(date).toUpperCase(), style: AppText.caps(11, em: 0.08, color: fg)),
                const SizedBox(height: 3),
                Text('${date.day}',
                    style: TextStyle(fontFamily: AppText.family, fontSize: 22, fontWeight: FontWeight.w800, height: 1.05, color: fg)),
                const SizedBox(height: 3),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: has && anyDone ? AppColors.accent : Colors.transparent,
                    border: Border.all(color: has ? AppColors.accent : Colors.transparent, width: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
