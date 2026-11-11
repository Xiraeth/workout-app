import 'enums.dart';
import 'ids.dart';
import 'set_entry.dart';

class Exercise {
  Exercise({
    String? id,
    required this.name,
    this.equipment = Equipment.bodyweight,
    this.measure = Measure.reps,
    this.motion = Motion.dynamic,
    required List<SetEntry> sets,
  })  : id = id ?? newId(),
        sets = List.unmodifiable(sets);

  /// Defaults for a new exercise: bodyweight / reps / dynamic, one empty set.
  factory Exercise.blank() => Exercise(name: '', sets: [SetEntry()]);

  final String id;
  final String name;
  final Equipment equipment;
  final Measure measure;
  final Motion motion;
  final List<SetEntry> sets; // at least one while editing

  Exercise copyWith({String? name, Equipment? equipment, Measure? measure, Motion? motion, List<SetEntry>? sets}) => Exercise(
        id: id,
        name: name ?? this.name,
        equipment: equipment ?? this.equipment,
        measure: measure ?? this.measure,
        motion: motion ?? this.motion,
        sets: sets ?? this.sets,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'equipment': equipment.name,
        'measure': measure.name,
        'motion': motion.name,
        'sets': [for (final s in sets) s.toJson()],
      };

  factory Exercise.fromJson(Map<String, dynamic> j) => Exercise(
        id: j['id'] as String,
        name: j['name'] as String,
        equipment: Equipment.values.byName(j['equipment'] as String),
        measure: Measure.values.byName(j['measure'] as String),
        motion: Motion.values.byName(j['motion'] as String),
        sets: [for (final s in j['sets'] as List) SetEntry.fromJson(s as Map<String, dynamic>)],
      );
}
