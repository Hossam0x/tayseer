import 'package:tayseer/my_import.dart';

class FollowerItem extends StatelessWidget {
  final String name;
  final String username;
  final bool isFollowing;
  final VoidCallback onToggleFollow;

  const FollowerItem({
    super.key,
    required this.name,
    required this.username,
    required this.isFollowing,
    required this.onToggleFollow,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 15.h),
          child: Row(
            children: [
              // الصورة الرمزية (الجهة اليمنى)
              Container(
                width: 55.r,
                height: 55.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                ),
                child: ClipOval(
                  child: Image.asset(AssetsData.avatarImage, fit: BoxFit.cover),
                  // ملحوظة: يمكنك إضافة BackdropFilter هنا إذا أردت استمرار تأثير التغبيش
                ),
              ),
              SizedBox(width: 12.w),

              // بيانات المستخدم (الوسط)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    name,
                    style: Styles.textStyle16.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    username,
                    style: Styles.textStyle14.copyWith(color: Colors.grey),
                  ),
                ],
              ),

              const Spacer(),

              // زر المتابعة / إلغاء المتابعة (الجهة اليسرى)
              isFollowing
                  ? Container(
                      width: 115.w,
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary100,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: AppColors.primary500),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6.r),
                          onTap: onToggleFollow,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Center(
                              child: Text(
                                'إلغاء المتابعة',
                                style: Styles.textStyle16SemiBold.copyWith(
                                  color: AppColors.primary400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : CustomBotton(
                      // الزر الممتلئ للمتابعة
                      title: 'متابعة',
                      onPressed: onToggleFollow,
                      width: 110.w,
                      height: 40.h,
                      useGradient: true,
                    ),
            ],
          ),
        ),
        Divider(color: Colors.grey.shade400, height: 0.5.h, thickness: 0.5.h),
      ],
    );
  }
}
