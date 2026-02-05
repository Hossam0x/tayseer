import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/features/user/my_space/data/enum/session_enum.dart';

class SessionDetailsHelper {
  SessionDetailsHelper._();

  /// Parse session status from string
  static SessionStatus parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return SessionStatus.confirmed;
      case 'completed':
        return SessionStatus.completed;
      case 'cancelled':
        return SessionStatus.cancelled;
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

  /// Get status display info
  static SessionStatusInfo getStatusInfo(SessionStatus status) {
    switch (status) {
      case SessionStatus.confirmed:
        return SessionStatusInfo(
          bgColor: const Color(0xFFFFF0F3),
          iconColor: const Color(0xFFD65A73),
          text: "مؤكدة - تم التأكيد الموعد من الاستشاري",
          icon: Icons.check_circle_outline,
        );
      case SessionStatus.completed:
        return SessionStatusInfo(
          bgColor: const Color(0xFFF0FFF4),
          iconColor: const Color(0xFF28A745),
          text: "مكتملة",
          icon: Icons.check_circle_outline,
        );
      case SessionStatus.pending:
        return SessionStatusInfo(
          bgColor: const Color(0xFFFFFAF0),
          iconColor: const Color(0xFFEAA800),
          text: "قيد المراجعة - بانتظار تأكيد المستشار للموعد",
          icon: Icons.access_time_filled_outlined,
        );
      case SessionStatus.cancelled:
        return SessionStatusInfo(
          bgColor: const Color(0xFFFFF0F0),
          iconColor: const Color(0xFFDC3545),
          text: "مرفوضة - يرجى اختيار موعد آخر",
          icon: Icons.cancel_outlined,
        );
    }
  }

  /// Get payment method display info
  static PaymentMethodInfo getPaymentMethodInfo(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'vodafone cash':
        return PaymentMethodInfo(
          icon: AssetsData.vodacasheIcon,
          displayText: "فودافون كاش",
        );
      default:
        return PaymentMethodInfo(
          icon: AssetsData.bankAccountIcon,
          displayText: paymentMethod,
        );
    }
  }
}

/// Model for status display info
class SessionStatusInfo {
  final Color bgColor;
  final Color iconColor;
  final String text;
  final IconData icon;

  const SessionStatusInfo({
    required this.bgColor,
    required this.iconColor,
    required this.text,
    required this.icon,
  });
}

/// Model for payment method display info
class PaymentMethodInfo {
  final String icon;
  final String displayText;

  const PaymentMethodInfo({required this.icon, required this.displayText});
}
