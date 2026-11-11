import '../models/enums.dart';
import '../models/exercise.dart';
import '../models/session.dart';
import 'dates.dart';

const _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const _months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

String weekdayLong(DateTime d) => _weekdays[d.weekday - 1];
String weekdayShort(DateTime d) => weekdayLong(d).substring(0, 3);
String weekdayTwo(DateTime d) => weekdayLong(d).substring(0, 2);
String monthLong(DateTime d) => _months[d.month - 1];
String monthShort(DateTime d) => monthLong(d).substring(0, 3);

/// "Wednesday 11 November"
String dayTitle(DateTime d) => '${weekdayLong(d)} ${d.day} ${monthLong(d)}';

/// "Wednesday 11 Nov"
String sessionTitle(DateTime d) => '${weekdayLong(d)} ${d.day} ${monthShort(d)}';

/// "Wed 11"
String dayShort(DateTime d) => '${weekdayShort(d)} ${d.day}';

/// "11 November 2026"
String dateField(DateTime d) => '${d.day} ${monthLong(d)} ${d.year}';

/// "Today", "Tomorrow", "Yesterday" or ''.
String relativeDay(DateTime d, DateTime today) => switch (daysBetween(today, d)) {
      0 => 'Today',
      1 => 'Tomorrow',
      -1 => 'Yesterday',
      _ => '',
    };

String plural(int n, String word) => '$n $word${n == 1 ? '' : 's'}';

/// `45s` under a minute, otherwise `m:ss`.
String formatTime(int seconds) =>
    seconds >= 60 ? '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}' : '${seconds}s';

/// 40.0 -> "40", 42.5 -> "42.5".
String formatNum(num n) {
  if (n == n.roundToDouble()) return n.toInt().toString();
  return n.toString();
}

/// e.g. `3 × 8  ·  60 kg`, `10 / 8 / 6  ·  40–50 kg`, `2 × 1:00  ·  Bodyweight`.
String setSummary(Exercise e, WeightUnit unit) {
  final sets = e.sets.where((s) => s.value != null).toList();
  if (sets.isEmpty) return 'No sets logged';

  final vals = [for (final s in sets) e.measure == Measure.time ? formatTime(s.value!) : '${s.value}'];
  final left = vals.every((v) => v == vals.first) ? '${sets.length} × ${vals.first}' : vals.join(' / ');

  final ws = [for (final s in sets) s.weight ?? 0];
  final mn = ws.reduce((a, b) => a < b ? a : b), mx = ws.reduce((a, b) => a > b ? a : b);
  final range = mn == mx ? formatNum(mx) : '${formatNum(mn)}–${formatNum(mx)}';
  final u = unit.name;
  final right = e.equipment == Equipment.bodyweight
      ? (mx != 0 ? 'BW + $range $u' : 'Bodyweight')
      : (mx != 0 ? '$range $u' : 'No load');

  return '$left  ·  $right';
}

/// "Bodyweight · Timed · Isometric" (shown uppercase).
String typeLine(Exercise e) => [
      e.equipment.label,
      e.measure == Measure.time ? 'Timed' : 'Reps',
      e.motion.label,
    ].join(' · ');

String sessionDisplayTitle(Session s) => s.parts.isEmpty ? 'Untitled session' : s.parts.map((p) => p.label).join(' · ');

String sessionMeta(Session s) => '${plural(s.exercises.length, 'exercise')} · ${plural(s.setCount, 'set')}';

String sessionExerciseList(Session s) =>
    s.exercises.isEmpty ? 'No exercises yet' : s.exercises.map((e) => e.name).join(', ');

/// Up to 4 sessions not done, dated today or later, not on [selected], sorted by date.
List<Session> comingUp(List<Session> sessions, {required DateTime today, required DateTime selected}) {
  final t = dateOnly(today);
  final indexed = [
    for (final (i, s) in sessions.indexed)
      if (!s.done && !s.date.isBefore(t) && !sameDay(s.date, selected)) (i, s),
  ]..sort((a, b) {
      final c = a.$2.date.compareTo(b.$2.date);
      return c != 0 ? c : a.$1.compareTo(b.$1); // stable
    });
  return [for (final (_, s) in indexed.take(4)) s];
}
