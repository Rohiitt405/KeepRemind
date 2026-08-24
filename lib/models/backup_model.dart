import 'saved_link_model.dart';

class BackupModel {
  static const int currentVersion = 1;
  static const String appName = 'KeepRemind';

  final int backupVersion;
  final String app;
  final DateTime createdAt;
  final List<SavedLink> items;

  const BackupModel({
    required this.backupVersion,
    required this.app,
    required this.createdAt,
    required this.items,
  });

  factory BackupModel.create({
    required List<SavedLink> items
  }) {
    return BackupModel(
      backupVersion: currentVersion,
      app: appName,
      createdAt: DateTime.now(),
      items: items,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'backupVersion': backupVersion,
      'app': app,
      'createdAt': createdAt.toIso8601String(),
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  factory BackupModel.fromMap(Map<String, dynamic> map) {
    final backupVersion = map['backupVersion'];

    if(backupVersion is! int) {
      throw const FormatException(
        'Invalid backup version.',
      );
    }

    final app = map['app'];

    if(app is! String || app != appName) {
      throw const FormatException(
        'This backup does not belong to KeepRemind.',
      );
    }
    
    final createdAtString = map['createdAt'];
    
    if(createdAtString is! String) {
      throw const FormatException(
        'Invalid backup creation date.',
      );
    }

    final createdAt = DateTime.tryParse(createdAtString);

    if(createdAt == null) {
      throw const FormatException(
        'Invalid backup creation date.',
      );
    }

    final rawItems = map['items'];

    if(rawItems is! List) {
      throw const FormatException(
        'Invalid backup items.',
      );
    }

    final items = <SavedLink>[];

    for(final rawItem in rawItems) {
      if(rawItem is! Map) {
        throw const FormatException(
          'Invalid saved link data.',
        );
      }

      final itemMap = Map<String, dynamic>.from(rawItem); 
      final id = itemMap['id'];

      items.add(
        SavedLink.fromMap(
          id is String ? id : '', 
          itemMap
        ),
      );
    }

    return BackupModel(
      backupVersion: backupVersion,
      app: app,
      createdAt: createdAt,
      items: items,
    );
  }

  bool get isSupportedVersion {
    return backupVersion >= 1 && backupVersion <= currentVersion;
  }
}

// Factory backup