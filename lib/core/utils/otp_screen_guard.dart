import 'package:tayseer/core/utils/otp_resumption_service.dart';

/// Thin façade over [OtpResumptionService] that keeps the original
/// `enter()` / `exit()` call-site API used by every OTP screen widget.
///
/// Screens that only call [enter] / [exit] (without a specific
/// [OtpResumptionContext]) are recorded as [OtpScreenType.authOtp] by
/// default.  Screens that need a richer context call
/// [OtpResumptionService.instance.save] directly.
class OtpScreenGuard {
  OtpScreenGuard._();

  /// True when at least one OTP screen is currently mounted (in-memory only).
  /// Survives soft resume (app backgrounded but NOT killed by OS).
  static bool get isActive => OtpResumptionService.instance.isActiveInMemory;

  /// Register an OTP screen as active with a specific context.
  /// Persists to SharedPreferences so a process-death resume is handled too.
  static Future<void> enterWithContext(OtpResumptionContext ctx) {
    return OtpResumptionService.instance.save(ctx);
  }

  /// Unregister an OTP screen.  Clears SharedPreferences record.
  static Future<void> exit() {
    return OtpResumptionService.instance.clear();
  }
}
