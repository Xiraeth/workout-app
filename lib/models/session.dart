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
    this.copiedFromId,
  })  : id = id ?? newId(),
        date = dateOnly(date),
        parts = List.unmodifiable(canonicalParts(parts)),
        exercises = List.unmodifiable(exercises);

  final String id;
  final DateTime date; // date only
  final List<BodyPart> parts; // canonical order
  final bool done;
  final List<Exercise> exercises;

  /// The session this one was copied from, for comparing with it.
  final String? copiedFromId;

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
        copiedFromId: copiedFromId,
      );

  /// A new, not-done session on [date] with the same body parts and exercises
  /// (sets, reps/time and weights included), remembering this one as its source.
  Session copyTo(DateTime date) => Session(
        date: date,
        parts: parts,
        exercises: [for (final e in exercises) e.duplicate()],
        copiedFromId: id,
      );

  Session togglePart(BodyPart p) => copyWith(parts: parts.contains(p) ? (parts.where((x) => x != p).toList()) : [...parts, p]);

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': dateKey(date),
        'parts': [for (final p in parts) p.name],
        'done': done,
        'exercises': [for (final e in exercises) e.toJson()],
        if (copiedFromId != null) 'copiedFromId': copiedFromId,
      };

  factory Session.fromJson(Map<String, dynamic> j) => Session(
        id: j['id'] as String,
        date: parseDateKey(j['date'] as String),
        parts: [for (final p in j['parts'] as List) BodyPart.values.byName(p as String)],
        done: j['done'] as bool,
        exercises: [for (final e in j['exercises'] as List) Exercise.fromJson(e as Map<String, dynamic>)],
        copiedFromId: j['copiedFromId'] as String?,
      );
}

List<BodyPart> canonicalParts(Iterable<BodyPart> parts) {
  final set = parts.toSet();
  return [for (final p in BodyPart.values) if (set.contains(p)) p];
}

/// The exercise in [source] that [e] should be compared with: the one it was
/// copied from, or else one with the same name (for exercises added later).
Exercise? previousExercise(Session? source, Exercise e) {
  if (source == null) return null;
  for (final x in source.exercises) {
    if (e.copiedFromId != null && x.id == e.copiedFromId) return x;
  }
  final name = e.name.trim().toLowerCase();
  for (final x in source.exercises) {
    if (x.name.trim().toLowerCase() == name) return x;
  }
  return null;
}
