class VersionHelper {
  const VersionHelper._();

  static bool isNewerVersion({
    required String latestVersion,
    required String currentVersion,
  }) {
    final latestParts = latestVersion.split('.');
    final currentParts = currentVersion.split('.');

    final maxLength = latestParts.length > currentParts.length
        ? latestParts.length
        : currentParts.length;

    for (int i = 0; i < maxLength; i++) {
      final latest = i < latestParts.length
          ? int.tryParse(latestParts[i]) ?? 0
          : 0;

      final current = i < currentParts.length
          ? int.tryParse(currentParts[i]) ?? 0
          : 0;

      if (latest > current) {
        return true;
      }

      if (latest < current) {
        return false;
      }
    }
    return false;
  }
}
