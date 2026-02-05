import 'package:tayseer/my_import.dart';

class EmptyExploration extends StatelessWidget {
  const EmptyExploration({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.14),
          AppImage(AssetsData.lockImage, width: 160.w),

          SizedBox(height: 24.h),

          Text(
            context.tr("complete_your_profile"), // ✅ ترجمة
            textAlign: TextAlign.center,
            style: Styles.textStyle16SemiBold.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.kTextGrey,
            ),
          ),

          SizedBox(height: 11.h),

          Text(
            context.tr("complete_your_profile_description"), // ✅ ترجمة
            textAlign: TextAlign.center,
            style: Styles.textStyle14.copyWith(
              color: AppColors.secondary600,
              fontWeight: FontWeight.w400,
              height: 1.5.h,
            ),
          ),

          SizedBox(height: 40.h),

          CustomBotton(
            radius: 16,
            useGradient: true,
            title: context.tr("complete_your_profile_bott"), // ✅ ترجمة
            onPressed: () {
              // ⭐ الانتقال لتاب الملف الشخصي (Profile tab)
              final layoutCubit = context.read<LayoutCubit>();
              layoutCubit.changeIndex(4); // Profile tab index
            },
          ),
        ],
      ),
    );
  }
}