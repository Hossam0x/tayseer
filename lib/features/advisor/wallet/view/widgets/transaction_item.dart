import 'package:intl/intl.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/wallet/data/models/transaction_model.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionItem({super.key, required this.transaction});

  static const Color _amber = Color(0xFFF6B551);

  String _getIconPath() {
    switch (transaction.type) {
      case 'session_reservation':
        return AssetsData.icBookSession;
      case 'event_reservation':
        return AssetsData.eventIcon;
      case 'withdraw_request':
        return AssetsData.icBank;
      case 'deposit':
      case 'withdraw':
      default:
        return AssetsData.icWallet;
    }
  }

  Color _getIconBg() {
    switch (transaction.type) {
      case 'session_reservation':
        return AppColors.pendingColor.withOpacity(0.2);
      case 'event_reservation':
        return AppColors.primary300.withOpacity(0.2);
      case 'withdraw_request':
        return _amber.withOpacity(0.2);
      default:
        return AppColors.mainColor.withOpacity(0.2);
    }
  }

  Color _getIconColor() {
    switch (transaction.type) {
      case 'session_reservation':
        return AppColors.pendingColor;
      case 'event_reservation':
        return AppColors.primary300;
      case 'withdraw_request':
        return _amber;
      default:
        return AppColors.mainColor;
    }
  }

  Color _getAmountColor() {
    if (transaction.type == 'withdraw_request') return _amber;
    return transaction.isPositive ? AppColors.mainColor : Colors.red;
  }

  String _getTitle(BuildContext context) {
    switch (transaction.type) {
      case 'session_reservation':
        return context.tr('consultancy_session');
      case 'event_reservation':
        return context.tr('event_booking');
      case 'deposit':
        return context.tr('deposit');
      case 'withdraw':
        return context.tr('withdraw');
      case 'withdraw_request':
        return context.tr('withdraw_request');
      default:
        return context.tr('transaction');
    }
  }

  /// Format: "24 ديسمبر 2025 11:16 م" or "Dec 24, 2025 11:16 PM"
  String _formatDate(BuildContext context) {
    final dt = transaction.createdAt;
    if (dt == null) return '';
    final isAr = context.isArabicLang;
    final locale = isAr ? 'ar' : 'en';
    // date part: "24 ديسمبر 2025" or "Dec 24, 2025"
    final datePart = isAr
        ? DateFormat('d MMMM yyyy', locale).format(dt)
        : DateFormat('MMM d, yyyy', locale).format(dt);
    // time part with am/pm
    final timePart = DateFormat('hh:mm a', locale).format(dt);
    return '$datePart  $timePart';
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25.r,
            backgroundColor: _getIconBg(),
            child: SvgPicture.asset(
              _getIconPath(),
              width: 23.w,
              colorFilter: ColorFilter.mode(_getIconColor(), BlendMode.srcIn),
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTitle(context),
                  style: Styles.textStyle16Bold.copyWith(
                    color: AppColors.primaryText,
                  ),
                ),
                if (dateStr.isNotEmpty) ...[
                  SizedBox(height: 3.h),
                  Text(
                    dateStr,
                    style: Styles.textStyle12.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${transaction.displayAmount} ${transaction.currency}',
            style: Styles.textStyle16Bold.copyWith(color: _getAmountColor()),
          ),
        ],
      ),
    );
  }
}
