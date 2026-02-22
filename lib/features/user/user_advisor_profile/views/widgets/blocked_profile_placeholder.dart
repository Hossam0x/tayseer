import 'package:tayseer/my_import.dart';

class BlockedProfilePlaceholder extends StatelessWidget {
  final bool isSliver;
  const BlockedProfilePlaceholder({super.key, this.isSliver = true});

  @override
  Widget build(BuildContext context) {
    if (isSliver) {
      return SliverToBoxAdapter(child: _buildBody(context));
    }
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 40.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppImage(
            AssetsData.icBlockedSettings,
            width: 80.w,
            height: 80.w,
            color: AppColors.kRedColor,
          ),
          Gap(16.h),
          Text(
            context.tr('blocked_account_title'),
            textAlign: TextAlign.center,
            style: Styles.textStyle16Bold.copyWith(
              color: AppColors.secondary800,
            ),
          ),
          Gap(8.h),
          Text(
            context.tr('blocked_account_message'),
            textAlign: TextAlign.center,
            style: Styles.textStyle14.copyWith(
              color: AppColors.secondary400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
