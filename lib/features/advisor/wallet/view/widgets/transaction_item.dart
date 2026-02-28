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
  String _getIconPath() {
    switch (transaction.type) {
      case 'session':
        return AssetsData.icBookSession;
      case 'event':
        return AssetsData.eventIcon;
      default:
        return AssetsData.icWallet;
    }
  }

  // الحصول على لون الخلفية للأيقونة
  Color _getIconBackgroundColor() {
    switch (transaction.type) {
      case 'session':
        return AppColors.pendingColor.withOpacity(0.2);
      case 'event':
        return AppColors.primary300.withOpacity(0.2);
      default:
        return AppColors.mainColor.withOpacity(0.2);
    }
  }

  // الحصول على لون الأيقونة
  Color _getIconColor() {
    switch (transaction.type) {
      case 'session':
        return AppColors.pendingColor;
      case 'event':
        return AppColors.primary300;
      default:
        return AppColors.mainColor;
    }
  }

  String _getTitle(BuildContext context) {
    if (transaction.type == 'session') {
      return context.tr('consultancy_session');
    } else if (transaction.type == 'event') {
      return context.tr('event_booking');
    }
    return context.tr('transaction');
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
            backgroundColor: _getIconBackgroundColor(),
            child: SvgPicture.asset(
              _getIconPath(),
              width: 23.w,
              color: _getIconColor(),
            ),
          ),
          SizedBox(width: 15.w),
          // تفاصيل المعاملة
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
                SizedBox(height: 4.h),
                Text(
                  transaction.formattedDate,
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.displayAmount} ${transaction.type == 'event' ? '' : context.tr('egp')}',
            style: Styles.textStyle16Bold.copyWith(
              color: transaction.isPositive ? AppColors.mainColor : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
