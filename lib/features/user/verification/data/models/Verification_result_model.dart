// ===============================
// verification_result_model.dart
// ===============================
 
enum VerificationStatus { approved, rejected }
 
class VerificationResult {
  final bool isVerified;
  final List<String> rejectReasons;
 
  VerificationResult({
    required this.isVerified,
    required this.rejectReasons,
  });
}
 