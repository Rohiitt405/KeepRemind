class UpdateInfo {
  final bool hasUpdate;
  final String currentVersion;
  final String latestVersion;
  final String downloadUrl;
  final String releasePageUrl;
  final String releaseNotes;

  const UpdateInfo({
    required this.hasUpdate,
    required this.currentVersion,
    required this.latestVersion,
    required this.downloadUrl,
    required this.releasePageUrl,
    required this.releaseNotes,
  });

  factory UpdateInfo.fromGithubJson({
    required Map<String, dynamic> json,
    required String currentVersion,
    required bool hasUpdate,
  }) {
    String downloadUrl = "";

    final assets = json["assets"];

    if (assets is List) {
      for (final asset in assets) {
        final name = asset["name"]?.toString().toLowerCase() ?? "";

        if (name.contains("arm64") && name.endsWith(".apk")) {
          downloadUrl = asset["browser_download_url"] ?? "";
          break;
        }
      }

      if (downloadUrl.isEmpty) {
        for (final asset in assets) {
          final name = asset["name"]?.toString().toLowerCase() ?? "";

          if (name.endsWith(".apk")) {
            downloadUrl = asset["browser_download_url"]?.toString() ?? "";
            break;
          }
        }
      }
    }

    return UpdateInfo(
      hasUpdate: hasUpdate, 
      currentVersion: currentVersion, 
      latestVersion: (json["tag_name"] ?? "")
        .toString()
        .replaceFirst(RegExp(r'^v'), ''), 
      downloadUrl: downloadUrl, 
      releasePageUrl: (json["html_url"] ?? "").toString(), 
      releaseNotes: (json["body"] ?? "").toString(),
    );
  }

  @override
  String toString() {
    return '''
      UpdateInfo(
        hasUpdate: $hasUpdate,
        currentVersion: $currentVersion,
        latestVersion: $latestVersion,
        download: $downloadUrl,
        releasePageUrl: $releasePageUrl
      )
    ''';
  }
}