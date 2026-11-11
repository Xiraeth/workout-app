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
    this.copiedFromId,
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

  /// The exercise this one was copied from (in another session), for "Last time".
  final String? copiedFromId;

  /// A copy with new ids for itself and its sets, remembering this one as its source.
  Exercise duplicate() => Exercise(
        name: name,
        equipment: equipment,
        measure: measure,
        motion: motion,
        sets: [for (final s in sets) s.duplicate()],
        copiedFromId: id,
      );

  Exercise copyWith({String? name, Equipment? equipment, Measure? measure, Motion? motion, List<SetEntry>? sets}) => Exercise(
        id: id,
        name: name ?? this.name,
        equipment: equipment ?? this.equipment,
        measure: measure ?? this.measure,
        motion: motion ?? this.motion,
        sets: sets ?? this.sets,
        copiedFromId: copiedFromId,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'equipment': equipment.name,
        'measure': measure.name,
        'motion': motion.name,
        'sets': [for (final s in sets) s.toJson()],
        if (copiedFromId != null) 'copiedFromId': copiedFromId,
      };

  factory Exercise.fromJson(Map<String, dynamic> j) => Exercise(
        id: j['id'] as String,
        name: j['name'] as String,
        equipment: Equipment.values.byName(j['equipment'] as String),
        measure: Measure.values.byName(j['measure'] as String),
        motion: Motion.values.byName(j['motion'] as String),
        sets: [for (final s in j['sets'] as List) SetEntry.fromJson(s as Map<String, dynamic>)],
        copiedFromId: j['copiedFromId'] as String?,
      );
}
