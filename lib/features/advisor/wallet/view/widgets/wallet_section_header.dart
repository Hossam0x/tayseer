import 'package:tayseer/my_import.dart';

class WalletSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const WalletSectionHeader({
    super.key,
    required this.title,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 25.w, left: 8.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Styles.textStyle20Bold.copyWith(
              color: AppColors.primaryText,
            ),
          ),
          TextButton(
            onPressed: onViewAll,
            child: Text(
              context.tr('view_all'),
              style: Styles.textStyle14.copyWith(color: AppColors.primary400),
            ),
          ),
        ],
      ),
    );
  }
}
