class BackupResult {
  final bool cancelled;
  final int totalItems;
  final String? filePath;

  const BackupResult({
    required this.cancelled,
    required this.totalItems,
    this.filePath,
  });

  factory BackupResult.success({
    required int totalItems,
    required String filePath,
  }) {
    return BackupResult(
      cancelled: false,
      totalItems: totalItems,
      filePath: filePath,
    );
  }

  factory BackupResult.cancelled() {
    return const BackupResult(
      cancelled: true,
      totalItems: 0,
    );
  }

  bool get isSuccess => !cancelled;
}