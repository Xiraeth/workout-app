import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:workoutlog/data/json_file_store.dart';
import 'package:workoutlog/data/seed.dart';
import 'package:workoutlog/data/session_repository.dart';
import 'package:workoutlog/models/enums.dart';
import 'package:workoutlog/models/exercise.dart';
import 'package:workoutlog/models/session.dart';
import 'package:workoutlog/models/set_entry.dart';

void main() {
  late Directory dir;
  late File file;
  late JsonSessionRepository repo;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('workoutlog_test');
    file = File('${dir.path}/sessions.json');
    repo = JsonSessionRepository(JsonFileStore(file));
  });
  tearDown(() => dir.deleteSync(recursive: true));

  test('missing file loads as null (first launch)', () async {
    expect(await repo.load(), isNull);
  });

  test('round trip keeps ids, nulls, enums and dates', () async {
    final s = Session(
      date: DateTime(2026, 11, 11),
      parts: [BodyPart.core, BodyPart.chest],
      done: true,
      exercises: [
        Exercise(name: 'Plank', measure: Measure.time, motion: Motion.isometric, sets: [
          SetEntry(value: 60),
          SetEntry(value: null, weight: 12.5),
        ]),
      ],
    );
    await repo.save([s]);

    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    expect(json['version'], 1);
    expect((json['sessions'] as List).first['date'], '2026-11-11');

    final loaded = (await JsonSessionRepository(JsonFileStore(file)).load())!;
    final l = loaded.single;
    expect(l.id, s.id);
    expect(l.date, DateTime(2026, 11, 11));
    expect(l.parts, [BodyPart.chest, BodyPart.core]);
    expect(l.done, isTrue);
    final e = l.exercises.single;
    expect(e.id, s.exercises.single.id);
    expect((e.equipment, e.measure, e.motion), (Equipment.bodyweight, Measure.time, Motion.isometric));
    expect(e.sets, s.exercises.single.sets);
    expect(e.sets[1].value, isNull);
    expect(e.sets[1].weight, 12.5);
  });

  test('seed data survives a round trip', () async {
    final seed = seedSessions(DateTime(2026, 11, 11));
    await repo.save(seed);
    final loaded = (await repo.load())!;
    expect(loaded.length, 5);
    expect(loaded.map((s) => s.exercises.length), [3, 3, 2, 2, 0]);
  });

  test('a corrupt file is moved aside and loads as empty', () async {
    file.writeAsStringSync('{not json');
    expect(await repo.load(), isEmpty);
    expect(File('${file.path}.bad').existsSync(), isTrue);
    expect(file.existsSync(), isFalse);
  });

  test('rapid saves land in order', () async {
    final a = Session(date: DateTime(2026, 1, 1));
    final b = Session(date: DateTime(2026, 1, 2));
    // ignore: unawaited_futures
    repo.save([a]);
    await repo.save([a, b]);
    expect((await repo.load())!.length, 2);
  });
}
