import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/exercise_library_repository.dart';
import '../data/session_repository.dart';
import '../data/settings_repository.dart';
import '../models/enums.dart';
import '../models/exercise.dart';
import '../models/exercise_template.dart';
import '../models/session.dart';
import '../models/settings.dart';
import '../utils/dates.dart';

/// Today's date; overridden in tests.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

DateTime todayOf(Ref ref) => dateOnly(ref.read(clockProvider)());

// Repositories and the data loaded at startup. main() overrides these.
final sessionRepositoryProvider = Provider<SessionRepository>((ref) => MemorySessionRepository());
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) => MemorySettingsRepository());
final initialSessionsProvider = Provider<List<Session>>((ref) => const []);
final initialSettingsProvider = Provider<AppSettings>((ref) => const AppSettings());
final exerciseLibraryRepositoryProvider = Provider<ExerciseLibraryRepository>((ref) => MemoryExerciseLibraryRepository());
final initialExerciseLibraryProvider = Provider<List<ExerciseTemplate>>((ref) => defaultTemplates());

/// All sessions. Every change is saved straight away.
class SessionsNotifier extends Notifier<List<Session>> {
  @override
  List<Session> build() => ref.read(initialSessionsProvider);

  void _set(List<Session> next) {
    state = List.unmodifiable(next);
    ref.read(sessionRepositoryProvider).save(state);
  }

  Session? byId(String id) {
    for (final s in state) {
      if (s.id == id) return s;
    }
    return null;
  }

  void add(Session s) => _set([...state, s]);

  void update(String id, Session Function(Session) fn) => _set([for (final s in state) s.id == id ? fn(s) : s]);

  void remove(String id) => _set(state.where((s) => s.id != id).toList());

  void replaceAll(List<Session> sessions) => _set(sessions);
}

final sessionsProvider = NotifierProvider<SessionsNotifier, List<Session>>(SessionsNotifier.new);

/// The day selected in the week view.
class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => todayOf(ref);

  void select(DateTime d) => state = dateOnly(d);
  void shift(int days) => state = addDays(state, days);
}

final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(initialSettingsProvider);

  void _set(AppSettings s) {
    state = s;
    ref.read(settingsRepositoryProvider).save(s);
  }

  void setUnit(WeightUnit u) => _set(state.copyWith(unit: u));
  void setWeekStart(WeekStart w) => _set(state.copyWith(weekStart: w));
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

/// The user's exercise list, offered as quick picks. Saving an exercise adds it.
class ExerciseLibraryNotifier extends Notifier<List<ExerciseTemplate>> {
  @override
  List<ExerciseTemplate> build() => ref.read(initialExerciseLibraryProvider);

  void _set(List<ExerciseTemplate> next) {
    state = List.unmodifiable(next);
    ref.read(exerciseLibraryRepositoryProvider).save(state);
  }

  /// Adds the exercise's name and type, or updates the type of the entry with that name.
  void remember(Exercise e) => _set(upsertTemplate(state, e));

  void remove(String id) => _set(state.where((t) => t.id != id).toList());
}

final exerciseLibraryProvider =
    NotifierProvider<ExerciseLibraryNotifier, List<ExerciseTemplate>>(ExerciseLibraryNotifier.new);
