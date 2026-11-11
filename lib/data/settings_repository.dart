import '../models/settings.dart';
import 'json_file_store.dart';

abstract class SettingsRepository {
  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
}

class JsonSettingsRepository implements SettingsRepository {
  JsonSettingsRepository(this.store);

  final JsonFileStore store;

  @override
  Future<AppSettings> load() async {
    try {
      final json = await store.read();
      return json == null ? const AppSettings() : AppSettings.fromJson(json as Map<String, dynamic>);
    } catch (_) {
      return const AppSettings();
    }
  }

  @override
  Future<void> save(AppSettings settings) => store.write(settings.toJson());
}

class MemorySettingsRepository implements SettingsRepository {
  AppSettings saved = const AppSettings();

  @override
  Future<AppSettings> load() async => saved;

  @override
  Future<void> save(AppSettings settings) async => saved = settings;
}
