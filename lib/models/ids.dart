import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Stable ids for sessions, exercises and sets (future primary keys).
String newId() => _uuid.v4();
