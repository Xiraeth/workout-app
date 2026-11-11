import 'dart:convert';
import 'dart:io';

/// Reads and writes one JSON document. Writes go to a temp file that is then
/// renamed, so a crash mid-write can't leave a half-written file. Writes are
/// serialised so a later save never lands before an earlier one.
class JsonFileStore {
  JsonFileStore(this.file);

  final File file;
  Future<void> _pending = Future.value();

  /// Null if the file doesn't exist. Throws [FormatException] if it can't be parsed.
  Future<Object?> read() async {
    if (!await file.exists()) return null;
    return jsonDecode(await file.readAsString());
  }

  Future<void> write(Object json) {
    final text = const JsonEncoder.withIndent(' ').convert(json);
    return _pending = _pending.then((_) async {
      final tmp = File('${file.path}.tmp');
      await tmp.parent.create(recursive: true);
      await tmp.writeAsString(text, flush: true);
      await tmp.rename(file.path);
    });
  }

  /// Moves an unreadable file aside so it isn't overwritten.
  Future<void> quarantine() async {
    if (await file.exists()) await file.rename('${file.path}.bad');
  }
}
