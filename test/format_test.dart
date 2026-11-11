import 'package:flutter_test/flutter_test.dart';
import 'package:workoutlog/models/enums.dart';
import 'package:workoutlog/models/exercise.dart';
import 'package:workoutlog/models/session.dart';
import 'package:workoutlog/models/set_entry.dart';
import 'package:workoutlog/utils/dates.dart';
import 'package:workoutlog/utils/format.dart';

Exercise ex(List<(int?, double?)> sets, {Equipment eq = Equipment.freeWeights, Measure m = Measure.reps}) =>
    Exercise(name: 'X', equipment: eq, measure: m, sets: [for (final (v, w) in sets) SetEntry(value: v, weight: w)]);

void main() {
  group('setSummary', () {
    test('equal values and weights', () {
      expect(setSummary(ex([(8, 60), (8, 60), (8, 60)]), WeightUnit.kg), '3 × 8  ·  60 kg');
    });
    test('different values and a weight range', () {
      expect(setSummary(ex([(10, 40), (8, 45), (6, 50)]), WeightUnit.kg), '10 / 8 / 6  ·  40–50 kg');
    });
    test('timed bodyweight', () {
      expect(setSummary(ex([(60, null), (60, null)], eq: Equipment.bodyweight, m: Measure.time), WeightUnit.kg),
          '2 × 1:00  ·  Bodyweight');
    });
    test('bodyweight with added load uses the unit label', () {
      expect(setSummary(ex([(60, 10)], eq: Equipment.bodyweight, m: Measure.time), WeightUnit.lb), '1 × 1:00  ·  BW + 10 lb');
    });
    test('free weights without load', () {
      expect(setSummary(ex([(12, null)]), WeightUnit.kg), '1 × 12  ·  No load');
    });
    test('empty values are ignored', () {
      expect(setSummary(ex([(null, 50)]), WeightUnit.kg), 'No sets logged');
      expect(setSummary(ex([(5, 100), (null, 20)]), WeightUnit.kg), '1 × 5  ·  100 kg');
    });
    test('decimals', () {
      expect(setSummary(ex([(5, 42.5), (5, 40)]), WeightUnit.kg), '2 × 5  ·  40–42.5 kg');
    });
  });

  test('formatTime', () {
    expect(formatTime(45), '45s');
    expect(formatTime(60), '1:00');
    expect(formatTime(95), '1:35');
  });

  test('typeLine', () {
    expect(typeLine(ex([(1, null)])), 'Free weights · Reps · Dynamic');
    expect(typeLine(Exercise(name: 'P', measure: Measure.time, motion: Motion.isometric, sets: [SetEntry()])),
        'Bodyweight · Timed · Isometric');
  });

  group('dates', () {
    test('isoWeek around year boundaries', () {
      expect(isoWeek(DateTime(2026, 11, 11)), 46);
      expect(isoWeek(DateTime(2024, 12, 30)), 1);
      expect(isoWeekYear(DateTime(2024, 12, 30)), 2025);
      expect(isoWeek(DateTime(2021, 1, 3)), 53);
      expect(isoWeekYear(DateTime(2021, 1, 3)), 2020);
    });
    test('weekStartFor', () {
      final wed = DateTime(2026, 11, 11);
      expect(weekStartFor(wed, WeekStart.monday), DateTime(2026, 11, 9));
      expect(weekStartFor(wed, WeekStart.sunday), DateTime(2026, 11, 8));
      final sun = DateTime(2026, 11, 15);
      expect(weekStartFor(sun, WeekStart.monday), DateTime(2026, 11, 9));
      expect(weekStartFor(sun, WeekStart.sunday), DateTime(2026, 11, 15));
    });
    test('labels', () {
      final d = DateTime(2026, 11, 11);
      expect(dayTitle(d), 'Wednesday 11 November');
      expect(sessionTitle(d), 'Wednesday 11 Nov');
      expect(dayShort(d), 'Wed 11');
      expect(relativeDay(d, DateTime(2026, 11, 10)), 'Tomorrow');
      expect(relativeDay(d, DateTime(2026, 11, 12)), 'Yesterday');
      expect(relativeDay(d, d), 'Today');
      expect(relativeDay(d, DateTime(2026, 11, 1)), '');
    });
  });

  group('sessions', () {
    final today = DateTime(2026, 11, 11);

    test('status', () {
      expect(Session(date: today, done: true).status(today), SessionStatus.done);
      expect(Session(date: addDays(today, -1)).status(today), SessionStatus.missed);
      expect(Session(date: today).status(today), SessionStatus.planned);
      expect(Session(date: addDays(today, 3)).status(today), SessionStatus.planned);
    });

    test('meta and titles', () {
      final s = Session(date: today, parts: [BodyPart.quads, BodyPart.chest], exercises: [ex([(1, null)])]);
      expect(sessionMeta(s), '1 exercise · 1 set');
      expect(sessionDisplayTitle(s), 'Chest · Quads'); // canonical order
      expect(sessionDisplayTitle(Session(date: today)), 'Untitled session');
      expect(sessionExerciseList(Session(date: today)), 'No exercises yet');
    });

    test('togglePart keeps canonical order', () {
      var s = Session(date: today);
      for (final p in [BodyPart.fullBody, BodyPart.back, BodyPart.chest]) {
        s = s.togglePart(p);
      }
      expect(s.parts, [BodyPart.chest, BodyPart.back, BodyPart.fullBody]);
      expect(s.togglePart(BodyPart.back).parts, [BodyPart.chest, BodyPart.fullBody]);
    });

    test('comingUp: not done, today or later, not the selected day, sorted, max 4', () {
      final list = [
        Session(date: addDays(today, 5)),
        Session(date: addDays(today, -1)), // past
        Session(date: addDays(today, 2), done: true), // done
        Session(date: today),
        Session(date: addDays(today, 1)), // selected
        Session(date: addDays(today, 3)),
        Session(date: addDays(today, 4)),
        Session(date: addDays(today, 9)),
      ];
      final r = comingUp(list, today: today, selected: addDays(today, 1));
      expect(r.map((s) => daysBetween(today, s.date)), [0, 3, 4, 5]);
    });
  });
}
