import 'package:flutter/material.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/features/user/my_space/data/enum/session_enum.dart';

class SessionDetailsHelper {
  SessionDetailsHelper._();

  /// Parse session status from string
  static SessionStatus parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return SessionStatus.confirmed;
      case 'completed':
        return SessionStatus.completed;
      case 'cancelled':
        return SessionStatus.cancelled;
      case 'awaiting_payment':
        return SessionStatus.awaitingPayment;
      case 'pending':
      default:
        return SessionStatus.pending;
    }
  }

  /// Format date to Arabic format
  static String formatDateArabic(DateTime date) {
    const days = [
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];

    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    final dayName = days[date.weekday % 7];
    final monthName = months[date.month - 1];

    return "$dayName، ${date.day} $monthName ${date.year}";
  }

  /// Returns the localization key for a given session status text.
  static String getStatusTextKey(SessionStatus status) {
    switch (status) {
      case SessionStatus.confirmed:
        return 'status_confirmed_text';
      case SessionStatus.completed:
        return 'status_completed_text';
      case SessionStatus.pending:
        return 'status_pending_text';
      case SessionStatus.cancelled:
        return 'status_cancelled_text';
      case SessionStatus.awaitingPayment:
        return 'status_awaiting_payment_text';
    }
  }

  /// Get status display info (text is a localization key — resolve with context.tr())
  static SessionStatusInfo getStatusInfo(SessionStatus status) {
    switch (status) {
      case SessionStatus.confirmed:
        return SessionStatusInfo(
          bgColor: const Color(0xFFFFF0F3),
          iconColor: const Color(0xFFD65A73),
          textKey: 'status_confirmed_text',
          icon: Icons.check_circle_outline,
        );
      case SessionStatus.completed:
        return SessionStatusInfo(
          bgColor: const Color(0xFFF0FFF4),
          iconColor: const Color(0xFF28A745),
          textKey: 'status_completed_text',
          icon: Icons.check_circle_outline,
        );
      case SessionStatus.pending:
        return SessionStatusInfo(
          bgColor: const Color(0xFFFFFAF0),
          iconColor: const Color(0xFFEAA800),
          textKey: 'status_pending_text',
          icon: Icons.access_time_filled_outlined,
        );
      case SessionStatus.cancelled:
        return SessionStatusInfo(
          bgColor: const Color(0xFFFFF0F0),
          iconColor: const Color(0xFFDC3545),
          textKey: 'status_cancelled_text',
          icon: Icons.cancel_outlined,
        );
      case SessionStatus.awaitingPayment:
        return SessionStatusInfo(
          bgColor: const Color(0xFFF0F4FF),
          iconColor: const Color(0xFF3A5BF0),
          textKey: 'status_awaiting_payment_text',
          icon: Icons.payment_outlined,
        );
    }
  }

  /// Get payment method display info (displayTextKey is a localization key)
  static PaymentMethodInfo getPaymentMethodInfo(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'vodafone cash':
        return PaymentMethodInfo(
          icon: AssetsData.vodacasheIcon,
          displayTextKey: 'payment_method_vodafone_cash',
          rawText: null,
        );
      default:
        return PaymentMethodInfo(
          icon: AssetsData.bankAccountIcon,
          displayTextKey: null,
          rawText: paymentMethod,
        );
    }
  }
}

/// Model for status display info — textKey is a localization key, resolve with context.tr(textKey)
class SessionStatusInfo {
  final Color bgColor;
  final Color iconColor;
  final String textKey;
  final IconData icon;

  const SessionStatusInfo({
    required this.bgColor,
    required this.iconColor,
    required this.textKey,
    required this.icon,
  });
}

/// Model for payment method display info.
/// If [displayTextKey] is non-null, resolve via context.tr(displayTextKey).
/// Otherwise use [rawText] directly.
class PaymentMethodInfo {
  final String icon;
  final String? displayTextKey;
  final String? rawText;

  const PaymentMethodInfo({
    required this.icon,
    required this.displayTextKey,
    required this.rawText,
  });
}
