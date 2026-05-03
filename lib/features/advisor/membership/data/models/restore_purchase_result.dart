/// Represents the result of a restore-purchase API call.
///
/// [case] can be:
///   - `NO_SUBSCRIPTION` – no Apple subscription found
///   - `NEW_LINK`        – subscription found and linked to this account
///   - `CONFLICT`        – subscription found but linked to another account
class RestorePurchaseResult {
  final RestoreCase restoreCase;
  final String message;
  final String? productId;
  final String? purchaseId;

  const RestorePurchaseResult({
    required this.restoreCase,
    required this.message,
    this.productId,
    this.purchaseId,
  });

  factory RestorePurchaseResult.fromJson(Map<String, dynamic> json) {
    final caseStr = (json['case'] as String? ?? '').toUpperCase();
    final restoreCase = switch (caseStr) {
      'NEW_LINK' => RestoreCase.newLink,
      'CONFLICT' => RestoreCase.conflict,
      _ => RestoreCase.noSubscription,
    };
    return RestorePurchaseResult(
      restoreCase: restoreCase,
      message: json['message']?.toString() ?? '',
      productId: json['productId']?.toString(),
      purchaseId: json['purchaseId']?.toString(),
    );
  }
}

enum RestoreCase { noSubscription, newLink, conflict }
