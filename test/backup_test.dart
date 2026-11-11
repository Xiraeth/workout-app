import 'package:flutter_test/flutter_test.dart';
import 'package:workoutlog/data/backup.dart';
import 'package:workoutlog/data/seed.dart';
import 'package:workoutlog/models/enums.dart';
import 'package:workoutlog/models/exercise_template.dart';
import 'package:workoutlog/models/settings.dart';

void main() {
  final today = DateTime(2026, 11, 11);

  test('round trip keeps sessions, exercise list and settings', () {
    final b = Backup(
      sessions: seedSessions(today),
      exercises: defaultTemplates(),
      settings: const AppSettings(unit: WeightUnit.lb, weekStart: WeekStart.sunday, appearance: Appearance.dark),
    );
    final back = Backup.parse(b.toJsonString(today));
    expect(back.sessions.map((s) => s.id), b.sessions.map((s) => s.id));
    expect(back.sessions.first.exercises.first.sets, b.sessions.first.exercises.first.sets);
    expect(back.exercises.map((t) => t.name), b.exercises.map((t) => t.name));
    expect(back.settings.unit, WeightUnit.lb);
    expect(back.settings.weekStart, WeekStart.sunday);
    expect(back.settings.appearance, Appearance.dark);
  });

  test('rejects files that are not backups', () {
    expect(() => Backup.parse('not json'), throwsA(isA<FormatException>()));
    expect(() => Backup.parse('{"sessions": []}'), throwsA(isA<FormatException>()));
    expect(() => Backup.parse('[1, 2]'), throwsA(isA<FormatException>()));
  });

  test('rejects newer versions and damaged contents with clear messages', () {
    expect(
      () => Backup.parse('{"app": "workoutlog", "version": 99, "sessions": []}'),
      throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('newer version'))),
    );
    expect(
      () => Backup.parse('{"app": "workoutlog", "version": 1, "sessions": [{"id": 3}]}'),
      throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('damaged'))),
    );
  });

  test('missing exercise list and settings fall back to defaults', () {
    final b = Backup.parse('{"app": "workoutlog", "version": 1, "sessions": []}');
    expect(b.sessions, isEmpty);
    expect(b.exercises, isEmpty);
    expect(b.settings.unit, WeightUnit.kg);
    expect(b.settings.appearance, Appearance.system);
  });

  test('file name', () {
    expect(backupFileName(today), 'fitdger-2026-11-11.json');
  });
}
