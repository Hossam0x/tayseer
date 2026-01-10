import 'package:tayseer/my_import.dart';

class InquiryTab extends StatelessWidget {
  const InquiryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> inquiries = [
      {
        'title': 'هل يمكنك مشاركة الشرائحات الأكاديمية التى حصلت عليها؟',
        'user': 'احمدمحمود',
        'timestamp': 'استفسار',
      },
      {
        'title': 'هل يمكنك مشاركة الشرائحات الأكاديمية التى حصلت عليها؟',
        'user': 'احمدمحمود',
        'timestamp': 'استفسار',
      },
      {
        'title': 'هل يمكنك مساعدتى فى إجابة أسئلة إدارة الأعمال؟',
        'user': 'احمدمحمود',
        'timestamp': 'استفسار',
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: inquiries.length,
      itemBuilder: (context, index) {
        final inquiry = inquiries[index];
        return _buildInquiryCard(inquiry);
      },
    );
  }

  Widget _buildInquiryCard(Map<String, dynamic> inquiry) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.whiteCardBack,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary100, width: 1.w),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'أرسل إليك',
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.primaryText,
                      ),
                    ),
                    Gap(4.w),
                    Text(
                      '@${inquiry['user']}',
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.mentionBlue,
                      ),
                    ),
                    Gap(4.w),
                    Text(
                      inquiry['timestamp'],
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
                Gap(6.h),
                Text(
                  inquiry['title'],
                  style: Styles.textStyle16Meduim.copyWith(
                    color: AppColors.primaryText,
                  ),
                ),
                Gap(8.h),
              ],
            ),
          ),
          Gap(12.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.primary500, width: 1.w),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppImage(AssetsData.icCamera),
                Gap(6.w),
                GradientText(text: 'رد', style: Styles.textStyle20SemiBold),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
