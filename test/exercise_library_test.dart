import 'package:flutter_test/flutter_test.dart';
import 'package:workoutlog/data/exercise_library_repository.dart';
import 'package:workoutlog/models/enums.dart';
import 'package:workoutlog/models/exercise.dart';
import 'package:workoutlog/models/exercise_template.dart';
import 'package:workoutlog/models/session.dart';
import 'package:workoutlog/models/set_entry.dart';

Exercise ex(String name, {Equipment eq = Equipment.bodyweight, Measure m = Measure.reps}) =>
    Exercise(name: name, equipment: eq, measure: m, sets: [SetEntry()]);

void main() {
  test('upsert adds new names at the end', () {
    final list = upsertTemplate(defaultTemplates(), ex('  Shoulder press ', eq: Equipment.freeWeights));
    expect(list.length, 11);
    expect(list.last.name, 'Shoulder press');
    expect(list.last.equipment, Equipment.freeWeights);
  });

  test('upsert matches names case-insensitively and updates the type in place', () {
    final before = defaultTemplates();
    final plank = before.firstWhere((t) => t.name == 'Plank');
    final list = upsertTemplate(before, ex('plank', m: Measure.reps));
    expect(list.length, before.length);
    final after = list.firstWhere((t) => t.id == plank.id);
    expect(after.name, 'Plank');
    expect(after.measure, Measure.reps);
    expect(list.indexOf(after), before.indexOf(plank));
  });

  test('blank names are ignored', () {
    expect(upsertTemplate(defaultTemplates(), ex('   ')).length, 10);
  });

  test('the first list includes exercises already logged, once each', () {
    final sessions = [
      Session(date: DateTime(2026, 1, 1), exercises: [ex('Hollow hold', m: Measure.time), ex('Plank')]),
      Session(date: DateTime(2026, 1, 2), exercises: [ex('hollow hold')]),
    ];
    final list = initialLibrary(sessions);
    expect(list.length, 11);
    expect(list.last.name, 'Hollow hold');
    expect(list.last.measure, Measure.time);
    // A logged preset keeps the preset's type.
    expect(list.firstWhere((t) => t.name == 'Plank').measure, Measure.time);
  });

  test('json round trip', () {
    final t = defaultTemplates().first;
    final back = ExerciseTemplate.fromJson(t.toJson());
    expect((back.id, back.name, back.equipment, back.measure, back.motion), (t.id, t.name, t.equipment, t.measure, t.motion));
  });
}
