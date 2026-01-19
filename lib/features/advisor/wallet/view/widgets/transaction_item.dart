import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/wallet/data/models/transaction_model.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final bool showTime;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.showTime = true,
  });

  // الحصول على الأيقونة المناسبة حسب نوع المعاملة
  String _getIconPath(TransactionType type) {
    switch (type) {
      case TransactionType.refund:
        return AssetsData.icWallet;
      case TransactionType.withdraw:
        return AssetsData.icBank;
      case TransactionType.subscription:
        return AssetsData.icSubscription;
      case TransactionType.booking:
        if (transaction.title.contains('حدث')) {
          return AssetsData.eventIcon;
        } else {
          return AssetsData.icBookSession;
        }
      case TransactionType.deposit:
        return AssetsData.icWallet;
    }
  }

  // الحصول على لون الخلفية للأيقونة
  Color _getIconBackgroundColor(TransactionType type) {
    switch (type) {
      case TransactionType.refund:
        return AppColors.mainColor.withOpacity(0.2);
      case TransactionType.withdraw:
        return AppColors.pendingColor.withOpacity(0.2);
      case TransactionType.subscription:
        return AppColors.primary200.withOpacity(0.2);
      case TransactionType.booking:
        if (transaction.title.contains('حدث')) {
          return AppColors.primary300.withOpacity(0.2);
        } else {
          return AppColors.pendingColor.withOpacity(0.2);
        }
      case TransactionType.deposit:
        return AppColors.alertColor.withOpacity(0.2);
    }
  }

  // الحصول على لون الأيقونة
  Color _getIconColor(TransactionType type) {
    switch (type) {
      case TransactionType.refund:
        return AppColors.mainColor;
      case TransactionType.withdraw:
        return AppColors.pendingColor;
      case TransactionType.subscription:
        return AppColors.primary400;
      case TransactionType.booking:
        if (transaction.title.contains('حدث')) {
          return AppColors.primary300;
        } else {
          return AppColors.pendingColor;
        }
      case TransactionType.deposit:
        return AppColors.alertColor;
    }
  }

  // تنسيق التاريخ والوقت
  String _getDateTime() {
    if (showTime) {
      return '${transaction.date} ${transaction.time}';
    }
    return transaction.date;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
      child: Row(
        children: [
          // الأيقونة
          CircleAvatar(
            radius: 25.r,
            backgroundColor: _getIconBackgroundColor(transaction.type),
            child: SvgPicture.asset(
              _getIconPath(transaction.type),
              width: 23.w,
              color: _getIconColor(transaction.type),
            ),
          ),
          SizedBox(width: 15.w),
          // تفاصيل المعاملة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: Styles.textStyle16Bold.copyWith(
                    color: AppColors.primaryText,
                  ),
                ),
                // if (transaction.subtitle.isNotEmpty) ...[
                //   SizedBox(height: 4.h),
                //   Text(
                //     transaction.subtitle,
                //     style: Styles.textStyle14.copyWith(
                //       color: AppColors.secondaryText,
                //       fontSize: 12.sp,
                //     ),
                //   ),
                // ],
                // SizedBox(height: 4.h),
                Text(
                  _getDateTime(),
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          // المبلغ
          Text(
            '${transaction.isPositive ? '+' : '-'}${transaction.amount.toStringAsFixed(0)} ر.س',
            style: Styles.textStyle16Bold.copyWith(
              color: transaction.pending == true
                  ? AppColors.pendingColor
                  : transaction.isPositive
                  ? AppColors.mainColor
                  : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
