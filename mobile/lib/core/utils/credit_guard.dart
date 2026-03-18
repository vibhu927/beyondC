class InsufficientCreditsException implements Exception {
  InsufficientCreditsException({
    required this.requiredCredits,
    required this.availableCredits,
  });

  final int requiredCredits;
  final int availableCredits;

  @override
  String toString() {
    return 'Insufficient credits: required $requiredCredits, available $availableCredits';
  }
}

Future<T> runWithCreditGuard<T>({
  required int availableCredits,
  required int cost,
  required Future<void> Function(int delta) applyOptimisticDelta,
  required Future<T> Function() action,
}) async {
  if (availableCredits < cost) {
    throw InsufficientCreditsException(
      requiredCredits: cost,
      availableCredits: availableCredits,
    );
  }

  await applyOptimisticDelta(cost);

  try {
    return await action();
  } catch (_) {
    await applyOptimisticDelta(-cost);
    rethrow;
  }
}
