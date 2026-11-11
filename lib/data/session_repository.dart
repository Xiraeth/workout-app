import 'package:flutter/foundation.dart';

import '../models/session.dart';
import 'json_file_store.dart';

/// Storage for sessions. Screens and state only see this interface, so a
/// sqlite implementation (e.g. drift) can replace the JSON one later, with a
/// one-time import of `sessions.json`.
abstract class SessionRepository {
  /// Null when nothing has been stored yet (first launch).
  Future<List<Session>?> load();
  Future<void> save(List<Session> sessions);
}

/// `{"version": 1, "sessions": [...]}` in one file.
class JsonSessionRepository implements SessionRepository {
  JsonSessionRepository(this.store);

  static const version = 1;
  final JsonFileStore store;

  @override
  Future<List<Session>?> load() async {
    try {
      final json = await store.read();
      if (json == null) return null;
      final map = json as Map<String, dynamic>;
      final v = map['version'] as int;
      if (v > version) throw FormatException('sessions.json version $v is newer than this app ($version)');
      return [for (final s in map['sessions'] as List) Session.fromJson(s as Map<String, dynamic>)];
    } catch (e) {
      debugPrint('Could not read sessions, moving file aside: $e');
      await store.quarantine();
      return [];
    }
  }

  @override
  Future<void> save(List<Session> sessions) =>
      store.write({'version': version, 'sessions': [for (final s in sessions) s.toJson()]});
}

/// Keeps nothing on disk; used in tests.
class MemorySessionRepository implements SessionRepository {
  MemorySessionRepository([this.saved]);

  List<Session>? saved;

  @override
  Future<List<Session>?> load() async => saved;

  @override
  Future<void> save(List<Session> sessions) async => saved = List.of(sessions);
}
