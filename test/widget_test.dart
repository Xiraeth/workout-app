import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workoutlog/data/session_repository.dart';
import 'package:workoutlog/data/settings_repository.dart';
import 'package:workoutlog/main.dart';
import 'package:workoutlog/models/enums.dart';
import 'package:workoutlog/models/session.dart';
import 'package:workoutlog/screens/week_screen.dart';
import 'package:workoutlog/state/providers.dart';
import 'package:workoutlog/widgets/app_buttons.dart';
import 'package:workoutlog/widgets/settings_sheet.dart';
import 'package:workoutlog/utils/dates.dart';

final today = DateTime(2026, 11, 11); // a Wednesday

Future<ProviderContainer> pumpApp(WidgetTester tester, {List<Session> sessions = const []}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(ProviderScope(
    overrides: [
      clockProvider.overrideWithValue(() => today),
      sessionRepositoryProvider.overrideWithValue(MemorySessionRepository()),
      settingsRepositoryProvider.overrideWithValue(MemorySettingsRepository()),
      initialSessionsProvider.overrideWithValue(sessions),
    ],
    child: const WorkoutLogApp(),
  ));
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(WeekScreen)));
}

bool isEnabled(WidgetTester tester, Finder label) =>
    tester.widget<AppButton>(find.ancestor(of: label, matching: find.byType(AppButton))).onPressed != null;

Future<void> tapText(WidgetTester tester, String text) async {
  if (find.text(text).evaluate().isEmpty) {
    // Lazily built list item: scroll the front-most list until it exists.
    await tester.scrollUntilVisible(find.text(text), 200, scrollable: find.descendant(of: find.byType(ListView).last, matching: find.byType(Scrollable)).first);
  }
  // Centre it, so floating bottom bars don't cover it.
  await Scrollable.ensureVisible(tester.element(find.text(text)), alignment: 0.5);
  await tester.pumpAndSettle();
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('week view shows the day, its sessions and what is coming up', (tester) async {
    await pumpApp(tester, sessions: [
      Session(date: today, parts: [BodyPart.quads]),
      Session(date: addDays(today, 2), parts: [BodyPart.back, BodyPart.biceps]),
      Session(date: addDays(today, -1), parts: [BodyPart.core]),
    ]);

    expect(find.text('WEEK 46 · 2026'), findsOneWidget);
    expect(find.text('November'), findsOneWidget);
    expect(find.text('Wednesday 11 November'), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('Quads'), findsOneWidget);
    expect(find.text('Planned'), findsNWidgets(2)); // the status tag and the week summary
    expect(find.text('Coming up'), findsOneWidget);
    expect(find.text('Back · Biceps'), findsOneWidget);
    expect(find.text('FRI'), findsOneWidget);
    expect(find.text('New session · Wed 11'), findsOneWidget);

    // Yesterday's unfinished session shows as missed.
    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();
    expect(find.text('YESTERDAY'), findsOneWidget);
    expect(find.text('Missed'), findsOneWidget);
  });

  testWidgets('next week moves the selection by 7 days', (tester) async {
    final c = await pumpApp(tester);
    await tester.tap(find.byTooltip('Next week'));
    await tester.pumpAndSettle();
    expect(c.read(selectedDateProvider), DateTime(2026, 11, 18));
    expect(find.text('Nothing scheduled'), findsOneWidget);
  });

  testWidgets('an untouched new session is discarded on back', (tester) async {
    final c = await pumpApp(tester);
    await tapText(tester, 'New session · Wed 11');
    expect(find.text('Wednesday 11 Nov'), findsOneWidget);
    expect(c.read(sessionsProvider), hasLength(1));

    await tapText(tester, 'Week');
    expect(c.read(sessionsProvider), isEmpty);
    expect(find.text('Nothing scheduled'), findsOneWidget);
  });

  testWidgets('a session with body parts is kept, in canonical order', (tester) async {
    final c = await pumpApp(tester);
    await tapText(tester, 'New session · Wed 11');
    await tapText(tester, 'Full body');
    await tapText(tester, 'Chest');
    expect(find.text('2 selected'), findsOneWidget);
    await tapText(tester, 'Week');

    final s = c.read(sessionsProvider).single;
    expect(s.parts, [BodyPart.chest, BodyPart.fullBody]);
    expect(find.text('Chest · Full body'), findsOneWidget);
  });

  testWidgets('exercise sheet: save rules, isometric, sets', (tester) async {
    final c = await pumpApp(tester, sessions: [Session(date: today, parts: [BodyPart.core])]);
    await tapText(tester, 'Core');
    await tapText(tester, 'Add exercise');

    expect(find.text('New exercise'), findsOneWidget);
    expect(isEnabled(tester, find.text('Save')), isFalse);
    expect(find.text('Remove exercise from session'), findsNothing);

    await tester.enterText(find.byType(TextField).first, '   ');
    await tester.pump();
    expect(isEnabled(tester, find.text('Save')), isFalse);

    await tester.enterText(find.byType(TextField).first, 'Hollow hold');
    await tester.pump();
    expect(isEnabled(tester, find.text('Save')), isTrue);

    // Isometric switches the measure to time.
    expect(find.text('REPS'), findsOneWidget);
    await tapText(tester, 'Isometric');
    expect(find.text('TIME (SEC)'), findsOneWidget);

    // One set: remove is disabled.
    expect(tester.widget<AppIconButton>(find.ancestor(of: find.byTooltip('Remove set'), matching: find.byType(AppIconButton))).onPressed, isNull);

    // Add set copies the last set.
    await tester.enterText(find.widgetWithText(TextField, '45'), '30');
    await tapText(tester, 'Add set');
    expect(find.widgetWithText(TextField, '30'), findsNWidgets(2));

    await tapText(tester, 'Save');
    final e = c.read(sessionsProvider).single.exercises.single;
    expect(e.name, 'Hollow hold');
    expect((e.measure, e.motion), (Measure.time, Motion.isometric));
    expect(e.sets.map((s) => s.value), [30, 30]);
    expect(find.text('2 × 30s  ·  Bodyweight'), findsOneWidget);
    expect(find.text('BODYWEIGHT · TIMED · ISOMETRIC'), findsOneWidget);
  });

  testWidgets('quick pick sets name and type; cancel discards; remove deletes', (tester) async {
    final c = await pumpApp(tester, sessions: [Session(date: today, parts: [BodyPart.chest])]);
    await tapText(tester, 'Chest');
    await tapText(tester, 'Add exercise');
    await tapText(tester, 'Bench press');
    expect(find.text('WEIGHT'), findsOneWidget);
    await tapText(tester, 'Save');
    expect(c.read(sessionsProvider).single.exercises.single.equipment, Equipment.freeWeights);

    // Edit, change name, cancel: unchanged.
    await tapText(tester, 'Bench press');
    expect(find.text('Edit exercise'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Incline press');
    await tapText(tester, 'Cancel');
    expect(c.read(sessionsProvider).single.exercises.single.name, 'Bench press');

    // Remove from session.
    await tapText(tester, 'Bench press');
    expect(find.text('Edit exercise'), findsOneWidget);
    await tapText(tester, 'Remove exercise from session');
    expect(c.read(sessionsProvider).single.exercises, isEmpty);
    expect(find.text('No exercises yet.'), findsOneWidget);
  });

  testWidgets('a new exercise name is remembered and offered next time', (tester) async {
    final c = await pumpApp(tester, sessions: [Session(date: today, parts: [BodyPart.shoulders])]);
    await tapText(tester, 'Shoulders');
    await tapText(tester, 'Add exercise');

    await tester.enterText(find.byType(TextField).first, 'Shoulder press');
    await tester.pump();
    expect(find.text('New exercise. Saving adds it to your exercises.'), findsOneWidget);
    expect(find.text('Plank'), findsNothing); // filtered out
    await tapText(tester, 'Free weights');
    await tapText(tester, 'Save');

    final library = c.read(exerciseLibraryProvider);
    expect(library.last.name, 'Shoulder press');
    expect(library.last.equipment, Equipment.freeWeights);

    // Next time it's a quick pick, and picking it brings its type.
    await tapText(tester, 'Add exercise');
    await tester.enterText(find.byType(TextField).first, 'press');
    await tester.pump();
    expect(find.text('Bench press'), findsOneWidget);
    expect(find.text('Shoulder press'), findsNWidgets(2)); // chip + the row behind the sheet
    await tester.tap(find.descendant(of: find.byType(Wrap), matching: find.text('Shoulder press')));
    await tester.pumpAndSettle();
    expect(find.text('New exercise. Saving adds it to your exercises.'), findsNothing);
    await tapText(tester, 'Save');
    expect(c.read(exerciseLibraryProvider).where((t) => t.name == 'Shoulder press'), hasLength(1));
    expect(c.read(sessionsProvider).single.exercises.last.equipment, Equipment.freeWeights);
  });

  testWidgets('holding a quick pick removes it from the list', (tester) async {
    final c = await pumpApp(tester, sessions: [Session(date: today, parts: [BodyPart.core])]);
    await tapText(tester, 'Core');
    await tapText(tester, 'Add exercise');
    await tester.longPress(find.text('Plank'));
    await tester.pumpAndSettle();
    expect(find.text('Remove "Plank"?'), findsOneWidget);
    await tapText(tester, 'Remove');
    expect(find.text('Plank'), findsNothing);
    expect(c.read(exerciseLibraryProvider).any((t) => t.name == 'Plank'), isFalse);
  });

  testWidgets('delete dialog: keep, then delete', (tester) async {
    final c = await pumpApp(tester, sessions: [Session(date: today, parts: [BodyPart.back])]);
    await tapText(tester, 'Back');
    await tester.tap(find.byTooltip('Delete session'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this session?'), findsOneWidget);
    expect(find.text('Wednesday 11 Nov and its 0 exercises will be removed.'), findsOneWidget);

    await tapText(tester, 'Keep');
    expect(c.read(sessionsProvider), hasLength(1));

    await tester.tap(find.byTooltip('Delete session'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Delete');
    expect(c.read(sessionsProvider), isEmpty);
    expect(find.byType(WeekScreen), findsOneWidget);
    expect(find.text('Nothing scheduled'), findsOneWidget);
  });

  testWidgets('mark complete toggles done', (tester) async {
    final c = await pumpApp(tester, sessions: [Session(date: addDays(today, 2), parts: [BodyPart.calves])]);
    await tapText(tester, 'Calves');
    await tapText(tester, 'Mark complete early');
    expect(c.read(sessionsProvider).single.done, isTrue);
    expect(find.text('Completed · tap to reopen'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    await tapText(tester, 'Completed · tap to reopen');
    expect(c.read(sessionsProvider).single.done, isFalse);
  });

  testWidgets('settings: week start and units', (tester) async {
    final c = await pumpApp(tester);
    expect(find.text('MO'), findsOneWidget);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Sunday');
    await tapText(tester, 'lb');
    await tester.tap(find.descendant(of: find.byType(SettingsSheet), matching: find.text('Done')));
    await tester.pumpAndSettle();
    expect(c.read(settingsProvider).weekStart, WeekStart.sunday);
    expect(c.read(settingsProvider).unit, WeightUnit.lb);
    // The strip now starts on Sunday 8 November.
    final first = tester.getTopLeft(find.text('SU')).dx;
    expect(first, lessThan(tester.getTopLeft(find.text('MO')).dx));
  });
}
