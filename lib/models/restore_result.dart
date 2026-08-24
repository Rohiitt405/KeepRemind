class RestoreResult {
  final bool cancelled;
  final int totalItems;
  final int restoredItems;
  final int duplicateItems;
  final int skippedItems;

  const RestoreResult({
    required this.cancelled,
    required this.totalItems,
    required this.restoredItems,
    required this.duplicateItems,
    required this.skippedItems,
  });

  factory RestoreResult.success({
    required int totalItems,
    required int restoredItems,
    required int duplicateItems,
    required int skippedItems,
  }) {
    return RestoreResult(
      cancelled: false,
      totalItems: totalItems,
      restoredItems: restoredItems,
      duplicateItems: duplicateItems,
      skippedItems: skippedItems,
    );
  }

  factory RestoreResult.cancelled() {
    return const RestoreResult(
      cancelled: true,
      totalItems: 0,
      restoredItems: 0,
      duplicateItems: 0,
      skippedItems: 0,
    );
  }

  bool get isSuccess => !cancelled;
}