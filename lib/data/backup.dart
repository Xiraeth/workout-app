import 'dart:convert';

import '../models/exercise_template.dart';
import '../models/session.dart';
import '../models/settings.dart';
import '../utils/dates.dart';

/// Everything the app stores, in one file the user can keep elsewhere:
/// `{"app": "workoutlog", "version": 1, "exportedAt": ..., "sessions": [...], "exercises": [...], "settings": {...}}`.
/// The `app` field stays "workoutlog" (the app's original name) so older
/// backups keep importing.
class Backup {
  const Backup({required this.sessions, required this.exercises, required this.settings});

  static const app = 'workoutlog';
  static const version = 1;

  final List<Session> sessions;
  final List<ExerciseTemplate> exercises;
  final AppSettings settings;

  String toJsonString(DateTime exportedAt) => const JsonEncoder.withIndent(' ').convert({
        'app': app,
        'version': version,
        'exportedAt': exportedAt.toUtc().toIso8601String(),
        'sessions': [for (final s in sessions) s.toJson()],
        'exercises': [for (final t in exercises) t.toJson()],
        'settings': settings.toJson(),
      });

  /// Throws [FormatException] with a readable message if [text] isn't a backup from this app.
  static Backup parse(String text) {
    final Object? json;
    try {
      json = jsonDecode(text);
    } on FormatException {
      throw const FormatException("This file isn't a Fitdger backup.");
    }
    if (json is! Map<String, dynamic> || json['app'] != app) {
      throw const FormatException("This file isn't a Fitdger backup.");
    }
    final v = json['version'];
    if (v is! int || v > version) {
      throw const FormatException('This backup was made by a newer version of the app.');
    }
    try {
      return Backup(
        sessions: [for (final s in json['sessions'] as List) Session.fromJson(s as Map<String, dynamic>)],
        exercises: [for (final t in (json['exercises'] as List? ?? const [])) ExerciseTemplate.fromJson(t as Map<String, dynamic>)],
        settings: json['settings'] is Map<String, dynamic> ? AppSettings.fromJson(json['settings'] as Map<String, dynamic>) : const AppSettings(),
      );
    } catch (_) {
      throw const FormatException('This backup is damaged and could not be read.');
    }
  }
}

/// e.g. `fitdger-2026-11-11.json`
String backupFileName(DateTime now) => 'fitdger-${dateKey(now)}.json';
