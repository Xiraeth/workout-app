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
import 'models/enums.dart';
import 'screens/week_screen.dart';
import 'state/providers.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';
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

class WorkoutLogApp extends ConsumerStatefulWidget {
  const WorkoutLogApp({super.key});

  @override
  ConsumerState<WorkoutLogApp> createState() => _WorkoutLogAppState();
}

/// Picks the light or dark [Palette] from the appearance setting and the
/// phone's theme. Colours are read from [Palette.current] while building, so on
/// a change every widget is rebuilt in place (open screens and sheets stay open).
class _WorkoutLogAppState extends ConsumerState<WorkoutLogApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _applyPalette(rebuild: false); // nothing is built yet
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() => _applyPalette();

  void _applyPalette({bool rebuild = true}) {
    final appearance = ref.read(settingsProvider).appearance;
    final dark = switch (appearance) {
      Appearance.dark => true,
      Appearance.light => false,
      Appearance.system => WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark,
    };
    if (Palette.current.isDark == dark) return;
    Palette.current = dark ? Palette.dark : Palette.light;
    SystemChrome.setSystemUIOverlayStyle(overlayStyle);
    if (!rebuild || !mounted) return;
    setState(() {});
    void markDirty(Element e) {
      e.markNeedsBuild();
      e.visitChildren(markDirty);
    }

    (context as Element).visitChildren(markDirty);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(settingsProvider.select((s) => s.appearance), (_, _) => _applyPalette());
    return MaterialApp(
      title: 'Workout Log',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const WeekScreen(),
    );
  }
}
