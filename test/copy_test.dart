import 'package:flutter_test/flutter_test.dart';
import 'package:workoutlog/models/enums.dart';
import 'package:workoutlog/models/exercise.dart';
import 'package:workoutlog/models/session.dart';
import 'package:workoutlog/models/set_entry.dart';

void main() {
  final source = Session(
    date: DateTime(2026, 11, 11),
    parts: [BodyPart.chest, BodyPart.triceps],
    done: true,
    exercises: [
      Exercise(name: 'Bench press', equipment: Equipment.freeWeights, sets: [SetEntry(value: 10, weight: 40), SetEntry(value: 8, weight: 45)]),
      Exercise(name: 'Plank', measure: Measure.time, motion: Motion.isometric, sets: [SetEntry(value: 60)]),
    ],
  );

  test('copyTo keeps parts, exercises and every set value, with new ids', () {
    final c = source.copyTo(DateTime(2026, 11, 16));
    expect(c.id, isNot(source.id));
    expect(c.date, DateTime(2026, 11, 16));
    expect(c.done, isFalse);
    expect(c.parts, source.parts);
    expect(c.copiedFromId, source.id);
    expect(c.exercises.map((e) => e.name), ['Bench press', 'Plank']);
    for (final (i, e) in c.exercises.indexed) {
      final o = source.exercises[i];
      expect(e.id, isNot(o.id));
      expect(e.copiedFromId, o.id);
      expect((e.equipment, e.measure, e.motion), (o.equipment, o.measure, o.motion));
      expect(e.sets.map((s) => (s.value, s.weight)), o.sets.map((s) => (s.value, s.weight)));
      expect(e.sets.map((s) => s.id).toSet().intersection(o.sets.map((s) => s.id).toSet()), isEmpty);
    }
  });

  test('the source link survives JSON and edits', () {
    final c = source.copyTo(DateTime(2026, 11, 16));
    final back = Session.fromJson(c.toJson());
    expect(back.copiedFromId, source.id);
    expect(back.exercises.first.copiedFromId, source.exercises.first.id);
    expect(back.copyWith(done: true).copiedFromId, source.id);
    expect(back.exercises.first.copyWith(name: 'Incline').copiedFromId, source.exercises.first.id);
    // Sessions saved before copying existed have no link.
    expect(Session.fromJson(source.toJson()).copiedFromId, isNull);
  });

  test('previousExercise matches by source id, then by name', () {
    final c = source.copyTo(DateTime(2026, 11, 16));
    expect(previousExercise(source, c.exercises.first)!.id, source.exercises.first.id);
    final renamed = c.exercises.first.copyWith(name: 'Incline press');
    expect(previousExercise(source, renamed)!.id, source.exercises.first.id);
    final addedLater = Exercise(name: ' plank ', sets: [SetEntry()]);
    expect(previousExercise(source, addedLater)!.name, 'Plank');
    expect(previousExercise(source, Exercise(name: 'Dip', sets: [SetEntry()])), isNull);
    expect(previousExercise(null, c.exercises.first), isNull);
  });
}
