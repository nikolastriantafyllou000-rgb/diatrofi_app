import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

Future<String> saveExportFiles(Map<String, String> files) async {
  Directory? baseDir;
  try {
    baseDir = await getDownloadsDirectory();
  } catch (_) {
    baseDir = null;
  }
  baseDir ??= await getApplicationDocumentsDirectory();

  final exportDir = Directory(p.join(baseDir.path, 'diatrofi_exports'));
  await exportDir.create(recursive: true);

  for (final entry in files.entries) {
    await File(
      p.join(exportDir.path, entry.key),
    ).writeAsString('﻿${entry.value}');
  }

  return exportDir.path;
}
