import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../models/backup_model.dart';
import '../models/backup_result.dart';
import '../models/restore_result.dart';
import '../exceptions/backup_exception.dart';
import 'firestore_service.dart';

class BackupService {
  final FirestoreService _firestoreService;

  BackupService({
    FirestoreService? firestoreService,
  }) : _firestoreService = firestoreService ?? FirestoreService();

  String _normalizeUrl(String url) {
    return url.trim().toLowerCase();
  }

  Future<BackupResult> createBackup() async {
    final savedLinks = await _firestoreService.getSavedLinkOnce();

    final backup = BackupModel.create(
      items: savedLinks,
    );

    final jsonString = const JsonEncoder.withIndent(
      ' ',
    ).convert(backup.toMap());

    final bytes = Uint8List.fromList(
      utf8.encode(jsonString),
    );

    final fileName = _generateBackupFileName();

    final savedPath = await FilePicker.saveFile(
      dialogTitle: 'Save KeepRemind Backup',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: bytes,
    );

    if (savedPath == null) {
      return BackupResult.cancelled();
    }

    return BackupResult.success(
      totalItems: savedLinks.length,
      filePath: savedPath.toString(),
    );
  }

  Future<RestoreResult> restoreBackup() async {
    final file = await FilePicker.pickFile(
      dialogTitle: 'Select KeepRemind Backup',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (file == null) {
      return RestoreResult.cancelled();
    }

    final bytes = await file.readAsBytes();

    if (bytes.isEmpty) {
      throw const BackupException(
        'The selected backup file is empty.',
      );
    }

    final String jsonString;

    try {
      jsonString = utf8.decode(
        bytes,
        allowMalformed: false,
      );
    } on FormatException {
      throw const BackupException(
        'The selected backup file contains invalid text.',
      );
    }

    final dynamic decodedJson;

    try {
      decodedJson = jsonDecode(jsonString);
    } on FormatException {
      throw const BackupException(
        'The selected file is not valid JSON.',
      );
    }

    if (decodedJson is! Map) {
      throw const BackupException(
        'Invalid KeepRemind backup format.',
      );
    }

    final backupMap = Map<String, dynamic>.from(
      decodedJson,
    );

    final BackupModel backup;

    try {
      backup = BackupModel.fromMap(
        backupMap,
      );
    } on FormatException catch (e) {
      throw BackupException(
        e.message,
      );
    }

    if (!backup.isSupportedVersion) {
      throw BackupException(
        'Backup version ${backup.backupVersion} '
        'is not supported by this version of KeepRemind.',
      );
    }

    final existingLinks =
        await _firestoreService.getSavedLinkOnce();

    final existingUrls = existingLinks
        .map((link) => _normalizeUrl(link.url))
        .toSet();

    var restoredCount = 0;
    var duplicateCount = 0;
    var skippedCount = 0;

    for (final backupLink in backup.items) {
      final normalizedUrl = _normalizeUrl(
        backupLink.url,
      );

      if (normalizedUrl.isEmpty) {
        skippedCount++;
        continue;
      }

      if (existingUrls.contains(normalizedUrl)) {
        duplicateCount++;
        continue;
      }

      try {
        final restoredLink = backupLink.copyWith(
          id: '',
          isGenerating: false,
        );

        await _firestoreService.restoreSavedLink(
          restoredLink,
        );

        existingUrls.add(normalizedUrl);
        restoredCount++;
      } catch (_) {
        skippedCount++;
      }
    }

    return RestoreResult.success(
      totalItems: backup.items.length,
      restoredItems: restoredCount,
      duplicateItems: duplicateCount,
      skippedItems: skippedCount,
    );
  }

  String _generateBackupFileName() {
    final now = DateTime.now();

    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');

    return 'KeepRemind_Backup_'
        '$year-$month-$day'
        '_$hour-$minute-$second.json';
  }
}