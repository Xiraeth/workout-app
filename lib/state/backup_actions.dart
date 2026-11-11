import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/backup.dart';
import 'providers.dart';

/// Everything currently stored.
Backup currentBackup(WidgetRef ref) => Backup(
      sessions: ref.read(sessionsProvider),
      exercises: ref.read(exerciseLibraryProvider),
      settings: ref.read(settingsProvider),
    );

/// Writes a backup file and opens the share sheet (Drive, email, Files…).
Future<void> exportBackup(WidgetRef ref) async {
  final now = DateTime.now();
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/${backupFileName(now)}');
  await file.writeAsString(currentBackup(ref).toJsonString(now), flush: true);
  await SharePlus.instance.share(ShareParams(
    files: [XFile(file.path, mimeType: 'application/json')],
    subject: 'Fitdger backup',
  ));
}

/// Lets the user pick a backup file. Null if they cancelled; throws
/// [FormatException] with a readable message if it isn't a valid backup.
Future<Backup?> pickBackup() async {
  final picked = await FilePicker.pickFile();
  if (picked == null) return null;
  final bytes = await picked.readAsBytes();
  final String text;
  try {
    text = utf8.decode(bytes);
  } on FormatException {
    throw const FormatException("This file isn't a Fitdger backup.");
  }
  return Backup.parse(text);
}

/// Replaces all data with [backup], keeping a copy of the current data as
/// `before-import.json` in the app's data folder first.
Future<void> restoreBackup(WidgetRef ref, Backup backup) async {
  final dir = ref.read(dataDirProvider);
  if (dir != null) {
    final now = DateTime.now();
    await File('$dir/before-import.json').writeAsString(currentBackup(ref).toJsonString(now), flush: true);
  }
  ref.read(sessionsProvider.notifier).replaceAll(backup.sessions);
  ref.read(exerciseLibraryProvider.notifier).replaceAll(backup.exercises);
  ref.read(settingsProvider.notifier).replace(backup.settings);
}
