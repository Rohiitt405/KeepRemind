class VersionHelper {
  const VersionHelper._();

  static bool isNewerVersion({
    required String lastestVersion,
    required String currentVersion,
  }) {
    final lastestParts = lastestVersion.split('.');
    final currentParts = currentVersion.split('.');

    final maxLength = 
      lastestParts.length > currentParts.length
        ? lastestParts.length
        : currentParts.length;
      
    for(int i=0; i < maxLength; i++) {
      final latest = 
        i < lastestParts.length ? int.tryParse(lastestParts[i]) ?? 0 : 0;

      final current = 
        i < currentParts.length ? int.tryParse(currentParts[i]) ?? 0 : 0;

      if(latest > current) {
        return true;
      }

      if(latest < current) {
        return false;
      }
    }
    return false;
  }
}