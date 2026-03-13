
import 'package:tayseer/features/advisor/profille/views/widgets/tabs/ratings/ratings_dialog.dart';
import 'package:tayseer/my_import.dart';

class RatingsAddButton extends StatelessWidget {
  final String advisorId;
  final TextEditingController reviewController;

  const RatingsAddButton({
    super.key,
    required this.advisorId,
    required this.reviewController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
      child: ElevatedButton(
        onPressed: () => _onAddRatingPressed(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.kprimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          minimumSize: Size(double.infinity, 54.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: AppColors.kWhiteColor, size: 20.w),
            Gap(8.w),
            Text(
              context.tr('add_rating'),
              style: Styles.textStyle16Meduim.copyWith(
                color: AppColors.kWhiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onAddRatingPressed(BuildContext context) {
    if (isGuest) {
      CustomshowDialogWithImage(
        context,
        title: context.tr('joinUs'),
        supTitle: context.tr('guest_login_first'),
        icon: Icons.lock_person_outlined,
        iconColor: AppColors.kprimaryColor,
        bottonText: context.tr('login'),
        showCancelButton: true,
        cancelText: context.tr('skip'),
        onPressed: () {
          CachNetwork.removeData(key: ktoken);
          context.pushNamedAndRemoveUntil(
            AppRouter.kRegisrationView,
            predicate: (_) => false,
          );
        },
        onCancel: () {},
      );
    } else {
      showRateAdvisorDialog(
        context: context,
        advisorId: advisorId,
        reviewController: reviewController,
      );
    }
  }
}
