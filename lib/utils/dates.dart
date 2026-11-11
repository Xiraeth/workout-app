import '../models/enums.dart';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Calendar arithmetic that is safe across DST changes.
DateTime addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);

int daysBetween(DateTime from, DateTime to) =>
    DateTime.utc(to.year, to.month, to.day).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

String _two(int n) => n.toString().padLeft(2, '0');

/// `yyyy-MM-dd`, the storage format.
String dateKey(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';

DateTime parseDateKey(String s) {
  final p = s.split('-').map(int.parse).toList();
  return DateTime(p[0], p[1], p[2]);
}

/// The first day of the week containing [d].
DateTime weekStartFor(DateTime d, WeekStart start) {
  final dow = d.weekday % 7; // Sunday = 0
  final ws = start == WeekStart.sunday ? 0 : 1;
  return addDays(dateOnly(d), -((dow - ws + 7) % 7));
}

/// ISO-8601 week number.
int isoWeek(DateTime d) {
  final t = DateTime.utc(d.year, d.month, d.day);
  final thursday = t.add(Duration(days: 4 - t.weekday));
  final jan1 = DateTime.utc(thursday.year, 1, 1);
  return thursday.difference(jan1).inDays ~/ 7 + 1;
}

/// The year that [isoWeek] belongs to (can differ from [DateTime.year] around New Year).
int isoWeekYear(DateTime d) {
  final t = DateTime.utc(d.year, d.month, d.day);
  return t.add(Duration(days: 4 - t.weekday)).year;
}
