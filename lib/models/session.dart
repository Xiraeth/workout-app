import '../utils/dates.dart';
import 'enums.dart';
import 'exercise.dart';
import 'ids.dart';

class Session {
  Session({
    String? id,
    required DateTime date,
    List<BodyPart> parts = const [],
    this.done = false,
    List<Exercise> exercises = const [],
  })  : id = id ?? newId(),
        date = dateOnly(date),
        parts = List.unmodifiable(canonicalParts(parts)),
        exercises = List.unmodifiable(exercises);

  final String id;
  final DateTime date; // date only
  final List<BodyPart> parts; // canonical order
  final bool done;
  final List<Exercise> exercises;

  bool get isEmpty => exercises.isEmpty && parts.isEmpty;

  int get setCount => exercises.fold(0, (n, e) => n + e.sets.length);

  /// Done, otherwise Missed before [today] and Planned from [today] on.
  SessionStatus status(DateTime today) {
    if (done) return SessionStatus.done;
    return date.isBefore(dateOnly(today)) ? SessionStatus.missed : SessionStatus.planned;
  }

  Session copyWith({DateTime? date, List<BodyPart>? parts, bool? done, List<Exercise>? exercises}) => Session(
        id: id,
        date: date ?? this.date,
        parts: parts ?? this.parts,
        done: done ?? this.done,
        exercises: exercises ?? this.exercises,
      );

  Session togglePart(BodyPart p) => copyWith(parts: parts.contains(p) ? (parts.where((x) => x != p).toList()) : [...parts, p]);

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': dateKey(date),
        'parts': [for (final p in parts) p.name],
        'done': done,
        'exercises': [for (final e in exercises) e.toJson()],
      };

  factory Session.fromJson(Map<String, dynamic> j) => Session(
        id: j['id'] as String,
        date: parseDateKey(j['date'] as String),
        parts: [for (final p in j['parts'] as List) BodyPart.values.byName(p as String)],
        done: j['done'] as bool,
        exercises: [for (final e in j['exercises'] as List) Exercise.fromJson(e as Map<String, dynamic>)],
      );
}

List<BodyPart> canonicalParts(Iterable<BodyPart> parts) {
  final set = parts.toSet();
  return [for (final p in BodyPart.values) if (set.contains(p)) p];
}
