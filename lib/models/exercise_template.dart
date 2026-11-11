import 'enums.dart';
import 'exercise.dart';
import 'ids.dart';

/// An entry in the user's exercise list: a name and its type, offered as a
/// quick pick when adding an exercise to a session.
class ExerciseTemplate {
  ExerciseTemplate({
    String? id,
    required this.name,
    required this.equipment,
    required this.measure,
    required this.motion,
  }) : id = id ?? newId();

  factory ExerciseTemplate.fromExercise(Exercise e) =>
      ExerciseTemplate(name: e.name.trim(), equipment: e.equipment, measure: e.measure, motion: e.motion);

  final String id;
  final String name;
  final Equipment equipment;
  final Measure measure;
  final Motion motion;

  /// Names match case-insensitively, ignoring surrounding spaces.
  String get key => nameKey(name);

  ExerciseTemplate withTypeOf(Exercise e) =>
      ExerciseTemplate(id: id, name: name, equipment: e.equipment, measure: e.measure, motion: e.motion);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'equipment': equipment.name,
        'measure': measure.name,
        'motion': motion.name,
      };

  factory ExerciseTemplate.fromJson(Map<String, dynamic> j) => ExerciseTemplate(
        id: j['id'] as String,
        name: j['name'] as String,
        equipment: Equipment.values.byName(j['equipment'] as String),
        measure: Measure.values.byName(j['measure'] as String),
        motion: Motion.values.byName(j['motion'] as String),
      );
}

String nameKey(String name) => name.trim().toLowerCase();

/// The built-in starting list.
List<ExerciseTemplate> defaultTemplates() {
  const bw = Equipment.bodyweight, free = Equipment.freeWeights;
  const reps = Measure.reps, time = Measure.time;
  const dyn = Motion.dynamic, iso = Motion.isometric;
  ExerciseTemplate t(String n, Equipment e, Measure m, Motion mo) =>
      ExerciseTemplate(name: n, equipment: e, measure: m, motion: mo);
  return [
    t('Push-up', bw, reps, dyn),
    t('Pull-up', bw, reps, dyn),
    t('Plank', bw, time, iso),
    t('Wall sit', bw, time, iso),
    t('Dip', bw, reps, dyn),
    t('Bench press', free, reps, dyn),
    t('Back squat', free, reps, dyn),
    t('Deadlift', free, reps, dyn),
    t('Dumbbell curl', free, reps, dyn),
    t('Farmer hold', free, time, iso),
  ];
}

/// Adds [e] to [list], or updates the type of the entry with the same name.
List<ExerciseTemplate> upsertTemplate(List<ExerciseTemplate> list, Exercise e) {
  final key = nameKey(e.name);
  if (key.isEmpty) return list;
  final i = list.indexWhere((t) => t.key == key);
  if (i < 0) return [...list, ExerciseTemplate.fromExercise(e)];
  return [for (final (j, t) in list.indexed) j == i ? t.withTypeOf(e) : t];
}
