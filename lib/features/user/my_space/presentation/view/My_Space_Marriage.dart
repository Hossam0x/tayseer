import 'package:tayseer/my_import.dart';

class MySpaceMarriageContent extends StatelessWidget {
  const MySpaceMarriageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetsData.homeBackgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppImage(AssetsData.guestLockImage, width: 228.w),

                  SizedBox(height: 24.w),

                  Text(
                    context.tr('complete_your_profile'),
                    textAlign: TextAlign.center,
                    style: Styles.textStyle16SemiBold.copyWith(
                      color: AppColors.kTextGrey,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  Text(
                    context.tr('complete_your_profile_description'),
                    textAlign: TextAlign.center,
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.kGrey666,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 40.h),

                  CustomBotton(
                    radius: 16.r,
                    useGradient: true,
                    title: context.tr('complete_your_profile_bott'),
                    onPressed: () {
                      context.pushNamed(AppRouter.kChooseGenderView);
                    },
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 90.h),
        ],
      ),
    );
  }
}
