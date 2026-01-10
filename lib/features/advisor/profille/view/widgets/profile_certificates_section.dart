import 'package:tayseer/my_import.dart';

class ProfileCertificatesSection extends StatelessWidget {
  const ProfileCertificatesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 24.h),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: _buildCertificateItem(context),
          );
        },
      ),
    );
  }

  Widget _buildCertificateItem(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        border: Border.all(color: AppColors.primary100),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            height: 85.w,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: AppImage(
                AssetsData.certificatePlaceholder,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Gap(16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "بكالوريوس علم النفس",
                  style: Styles.textStyle16Meduim.copyWith(
                    color: AppColors.secondary800,
                  ),
                ),
                Gap(4.h),
                Text(
                  "جامعة الملك فيصل",
                  style: Styles.textStyle16.copyWith(
                    color: AppColors.secondary600,
                  ),
                ),
                Gap(4.h),
                Text(
                  "1991",
                  style: Styles.textStyle16.copyWith(
                    color: AppColors.secondary600,
                  ),
                ),
              ],
            ),
          ),
          Gap(16.w),
          AppImage(AssetsData.editIcon),
        ],
      ),
    );
  }
}
