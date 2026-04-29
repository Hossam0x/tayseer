import 'package:tayseer/my_import.dart';

class TermsActions extends StatelessWidget {
  final String subscriptionType;
  final VoidCallback onAccept;

  const TermsActions({
    super.key,
    required this.subscriptionType,
    required this.onAccept,
  });

  bool get _isUltra => subscriptionType == 'ultra';
  bool get _isGold => subscriptionType == 'gold';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // زرار الاشتراك/الترقية — مخفي لو ultra
        if (!_isUltra) ...[
          GestureDetector(
            onTap: () {
              if (_isGold) {
                Navigator.pushNamed(
                  context,
                  AppRouter.kPackagesView,
                  arguments: {'initialPage': 2},
                );
              } else {
                Navigator.pushNamed(context, AppRouter.kPackagesView);
              }
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.kprimaryColor, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isGold
                        ? Icons.upgrade_rounded
                        : Icons.workspace_premium_outlined,
                    color: AppColors.kprimaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isGold
                        ? context.tr('upgrade_to_reduce_commission')
                        : context.tr('subscribe_to_reduce_commission'),
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.kprimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Gap(10.h),
        ],

        CustomBotton(
          width: double.infinity,
          height: 54.h,
          useGradient: true,
          title: context.tr('accept_and_continue'),
          onPressed: onAccept,
        ),
      ],
    );
  }
}
