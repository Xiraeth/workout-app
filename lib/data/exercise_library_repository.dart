import 'package:flutter/foundation.dart';

import '../models/exercise_template.dart';
import '../models/session.dart';
import 'json_file_store.dart';

/// Storage for the user's exercise list (`exercises.json`).
abstract class ExerciseLibraryRepository {
  /// Null when nothing has been stored yet.
  Future<List<ExerciseTemplate>?> load();
  Future<void> save(List<ExerciseTemplate> templates);
}

class JsonExerciseLibraryRepository implements ExerciseLibraryRepository {
  JsonExerciseLibraryRepository(this.store);

  static const version = 1;
  final JsonFileStore store;

  @override
  Future<List<ExerciseTemplate>?> load() async {
    try {
      final json = await store.read();
      if (json == null) return null;
      final map = json as Map<String, dynamic>;
      return [for (final t in map['exercises'] as List) ExerciseTemplate.fromJson(t as Map<String, dynamic>)];
    } catch (e) {
      debugPrint('Could not read exercise list, moving file aside: $e');
      await store.quarantine();
      return null;
    }
  }

  @override
  Future<void> save(List<ExerciseTemplate> templates) =>
      store.write({'version': version, 'exercises': [for (final t in templates) t.toJson()]});
}

class MemoryExerciseLibraryRepository implements ExerciseLibraryRepository {
  List<ExerciseTemplate>? saved;

  @override
  Future<List<ExerciseTemplate>?> load() async => saved;

  @override
  Future<void> save(List<ExerciseTemplate> templates) async => saved = List.of(templates);
}

/// The first list: the built-in exercises plus every exercise already logged.
List<ExerciseTemplate> initialLibrary(List<Session> sessions) {
  var list = defaultTemplates();
  for (final s in sessions) {
    for (final e in s.exercises) {
      if (!list.any((t) => t.key == nameKey(e.name))) list = upsertTemplate(list, e);
    }
  }
  return list;
}
