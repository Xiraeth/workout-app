import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'data/exercise_library_repository.dart';
import 'data/json_file_store.dart';
import 'data/seed.dart';
import 'data/session_repository.dart';
import 'data/settings_repository.dart';
import 'screens/week_screen.dart';
import 'state/providers.dart';
import 'theme/app_theme.dart';
import 'utils/dates.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(overlayStyle);

  final dir = await getApplicationDocumentsDirectory();
  final sessionRepo = JsonSessionRepository(JsonFileStore(File('${dir.path}/sessions.json')));
  final settingsRepo = JsonSettingsRepository(JsonFileStore(File('${dir.path}/settings.json')));

  var sessions = await sessionRepo.load();
  if (sessions == null) {
    // First launch: sample data in debug builds only.
    sessions = kDebugMode ? seedSessions(dateOnly(DateTime.now())) : [];
    await sessionRepo.save(sessions);
  }
  final settings = await settingsRepo.load();

  final libraryRepo = JsonExerciseLibraryRepository(JsonFileStore(File('${dir.path}/exercises.json')));
  var library = await libraryRepo.load();
  if (library == null) {
    library = initialLibrary(sessions);
    await libraryRepo.save(library);
  }

  runApp(ProviderScope(
    overrides: [
      sessionRepositoryProvider.overrideWithValue(sessionRepo),
      settingsRepositoryProvider.overrideWithValue(settingsRepo),
      initialSessionsProvider.overrideWithValue(sessions),
      initialSettingsProvider.overrideWithValue(settings),
      exerciseLibraryRepositoryProvider.overrideWithValue(libraryRepo),
      initialExerciseLibraryProvider.overrideWithValue(library),
      dataDirProvider.overrideWithValue(dir.path),
    ],
    child: const WorkoutLogApp(),
  ));
}

class WorkoutLogApp extends StatelessWidget {
  const WorkoutLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Log',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const WeekScreen(),
    );
  }
}
