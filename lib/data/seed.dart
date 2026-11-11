import '../models/enums.dart';
import '../models/exercise.dart';
import '../models/session.dart';
import '../models/set_entry.dart';
import '../utils/dates.dart';

/// Sample data for first launch in debug builds, relative to [today].
List<Session> seedSessions(DateTime today) {
  DateTime d(int n) => addDays(today, n);
  const bw = Equipment.bodyweight, free = Equipment.freeWeights;
  const reps = Measure.reps, time = Measure.time;
  const dyn = Motion.dynamic, iso = Motion.isometric;

  Exercise ex(String name, Equipment e, Measure m, Motion mo, List<(int, num)> sets) => Exercise(
        name: name,
        equipment: e,
        measure: m,
        motion: mo,
        sets: [for (final (v, w) in sets) SetEntry(value: v, weight: w == 0 ? null : w.toDouble())],
      );

  return [
    Session(date: d(-3), parts: [BodyPart.chest, BodyPart.triceps, BodyPart.shoulders], done: true, exercises: [
      ex('Bench press', free, reps, dyn, [(10, 40), (8, 45), (6, 50)]),
      ex('Push-up', bw, reps, dyn, [(15, 0), (12, 0)]),
      ex('Dumbbell shoulder press', free, reps, dyn, [(10, 14), (10, 14), (8, 16)]),
    ]),
    Session(date: d(-1), parts: [BodyPart.core], done: true, exercises: [
      ex('Plank', bw, time, iso, [(60, 0), (45, 0)]),
      ex('Hollow hold', bw, time, iso, [(30, 0), (30, 0), (30, 0)]),
      ex('Hanging leg raise', bw, reps, dyn, [(12, 0), (10, 0)]),
    ]),
    Session(date: d(0), parts: [BodyPart.quads, BodyPart.glutes, BodyPart.hamstrings], exercises: [
      ex('Back squat', free, reps, dyn, [(8, 60), (8, 60), (8, 60)]),
      ex('Wall sit', bw, time, iso, [(60, 10)]),
    ]),
    Session(date: d(2), parts: [BodyPart.back, BodyPart.biceps], exercises: [
      ex('Pull-up', bw, reps, dyn, [(8, 0), (6, 0), (6, 0)]),
      ex('Dumbbell curl', free, reps, dyn, [(12, 10), (10, 12)]),
    ]),
    Session(date: d(5), parts: [BodyPart.fullBody]),
  ];
}
