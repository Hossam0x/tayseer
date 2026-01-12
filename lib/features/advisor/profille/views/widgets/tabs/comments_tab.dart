import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/my_import.dart';

class CommentsTab extends StatelessWidget {
  const CommentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // بيانات تجريبية للتعليقات
    final List<Map<String, dynamic>> comments = [
      {
        'userName': 'احمد علي',
        'userImage': 'assets/images/user1.jpg',
        'userId': 'ahmed_ali',
        'isVerified': true,
        'comment':
            'شكراً لك على هذه المعلومات القيمة، كانت مفيدة جداً لمشروعي.',
        'timestamp': 'منذ يومين',
        'likes': 15,
        'replies': 3,
        'postOwner': 'محمد خالد',
      },
      {
        'userName': 'سارة محمد',
        'userImage': 'assets/images/user2.jpg',
        'userId': 'sara_mohamed',
        'isVerified': false,
        'comment': 'هل يمكنك توضيح النقطة الثانية أكثر؟ أريد فهمها بشكل أفضل.',
        'timestamp': 'منذ 5 ساعات',
        'likes': 8,
        'replies': 1,
        'postOwner': 'أحمد سعيد',
      },
      {
        'userName': 'خالد حسن',
        'userImage': 'assets/images/user3.jpg',
        'userId': 'khaled_hassan',
        'isVerified': true,
        'comment':
            'أتفق معك تماماً في هذه النقاط، خاصة فيما يتعلق بإدارة المخاطر.',
        'timestamp': 'منذ ساعة',
        'likes': 23,
        'replies': 7,
        'postOwner': 'فاطمة عمر',
      },
      {
        'userName': 'نورا أحمد',
        'userImage': 'assets/images/user4.jpg',
        'userId': 'nora_ahmed',
        'isVerified': true,
        'comment': 'شكراً على التوضيح المفصل، هل لديك مصادر إضافية عن الموضوع؟',
        'timestamp': 'منذ 3 أيام',
        'likes': 12,
        'replies': 4,
        'postOwner': 'ياسر علي',
      },
      {
        'userName': 'عمر خالد',
        'userImage': 'assets/images/user5.jpg',
        'userId': 'omar_khaled',
        'isVerified': false,
        'comment': 'تجربة رائعة، استفدت كثيراً من هذه النصائح العملية.',
        'timestamp': 'منذ أسبوع',
        'likes': 31,
        'replies': 9,
        'postOwner': 'ريم أحمد',
      },
    ];

    if (comments.isEmpty) {
      return const SharedEmptyState(title: "لا توجد تعليقات");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                children: [
                  Text(
                    'أرسل إليك',
                    style: Styles.textStyle12.copyWith(
                      color: AppColors.hintText,
                    ),
                  ),
                  Gap(4.h),
                  Text(
                    '@ahmed',
                    style: Styles.textStyle12.copyWith(
                      color: AppColors.mentionComment,
                    ),
                  ),
                ],
              ),
              // Header مع الصورة والمعلومات
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // معلومات المستخدم
                  Expanded(
                    child: Row(
                      children: [
                        // الصورة الشخصية
                        SizedBox(
                          width: 45.w,
                          height: 45.h,
                          child: CircleAvatar(
                            radius: 18.r,
                            backgroundColor: const Color(0xFFE5E7EB),
                            backgroundImage: AssetImage(AssetsData.avatarImage),
                            child: comment['userImage'] == null
                                ? Icon(
                                    Icons.person,
                                    color: Colors.black38,
                                    size: 20.sp,
                                  )
                                : null,
                          ),
                        ),
                        Gap(12.h),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // اسم المستخدم والعلامة الزرقاء
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  comment['userName'],
                                  style: Styles.textStyle14Bold.copyWith(
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                                Gap(4.h),
                                if (comment['isVerified'] as bool)
                                  Padding(
                                    padding: EdgeInsets.only(left: 4.w),
                                    child: Icon(
                                      Icons.verified,
                                      color: const Color(0xFF3B82F6),
                                      size: 16.sp,
                                    ),
                                  ),
                              ],
                            ),
                            // Username واليوزرنيم والوقت
                            Gap(4.h),
                            Row(
                              children: [
                                Text(
                                  '.@${comment['userId']}',
                                  style: Styles.textStyle14.copyWith(
                                    color: AppColors.secondary300,
                                  ),
                                ),
                                Gap(8.w),
                                Icon(
                                  Icons.public,
                                  size: 12.sp,
                                  color: AppColors.hintText,
                                ),
                                Gap(4.w),
                                Text(
                                  comment['timestamp'],
                                  style: Styles.textStyle10.copyWith(
                                    color: AppColors.hintText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // زر النقاط الثلاث
                  GestureDetector(
                    onTap: () {
                      _showCommentOptions(context, comment);
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: Icon(
                        Icons.more_vert,
                        color: AppColors.hintText,
                        size: 22.sp,
                      ),
                    ),
                  ),
                ],
              ),
              Gap(4.h),

              // نص التعليق
              Text(
                comment['comment'],
                style: Styles.textStyle14.copyWith(color: AppColors.blackColor),
              ),

              Gap(12.h),

              // الأكشن (إعجابك والرد)
              Row(
                children: [
                  // أيقونة القلب وعدد الإعجابات
                  InkWell(
                    onTap: () {},
                    child: Row(
                      children: [
                        AppImage(AssetsData.icCommentLike),
                        Gap(4.w),
                        Text(
                          '${comment['likes']}',
                          style: Styles.textStyle14.copyWith(
                            color: const Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Gap(4.w),
                        Text(
                          'إعجابك',
                          style: Styles.textStyle14.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Gap(12.w),
                  // فاصلة
                  Text(
                    '•',
                    style: Styles.textStyle14.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  Gap(12.w),

                  Text(
                    'رد',
                    style: Styles.textStyle14.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              Divider(color: AppColors.whiteCardBack),
            ],
          ),
        );
      },
    );
  }

  void _showCommentOptions(BuildContext context, Map<String, dynamic> comment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Gap(16.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Gap(24.h),

              // زر نسخ التعليق
              _buildOptionItem(
                context: context,
                icon: Icons.copy_outlined,
                text: "نسخ التعليق",
                onTap: () {
                  Navigator.pop(context);
                  _copyComment(context, comment);
                },
              ),

              // زر مشاركة التعليق
              _buildOptionItem(
                context: context,
                icon: Icons.share_outlined,
                text: "مشاركة التعليق",
                onTap: () {
                  Navigator.pop(context);
                  _shareComment(context, comment);
                },
              ),

              // زر الرد على التعليق
              _buildOptionItem(
                context: context,
                icon: Icons.reply_outlined,
                text: "الرد على التعليق",
                onTap: () {
                  Navigator.pop(context);
                  _replyToComment(context, comment);
                },
              ),

              // زر حذف التعليق (فقط إذا كان التعليق للمستخدم)
              _buildOptionItem(
                context: context,
                icon: Icons.delete_outlined,
                text: "حذف التعليق",
                textColor: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _deleteComment(context, comment);
                },
              ),

              Gap(32.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.black, size: 22.sp),
      title: Text(
        text,
        style: Styles.textStyle14.copyWith(
          color: textColor ?? Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
    );
  }

  // دالة نسخ التعليق
  void _copyComment(BuildContext context, Map<String, dynamic> comment) {
    // TODO: تنفيذ نسخ النص
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "تم نسخ التعليق",
          style: Styles.textStyle14.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // دالة مشاركة التعليق
  void _shareComment(BuildContext context, Map<String, dynamic> comment) {
    // TODO: تنفيذ المشاركة
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "جاري مشاركة التعليق...",
          style: Styles.textStyle14.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.kprimaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // دالة الرد على التعليق
  void _replyToComment(BuildContext context, Map<String, dynamic> comment) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController controller = TextEditingController();

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            "الرد على التعليق",
            style: Styles.textStyle16Bold.copyWith(color: AppColors.blackColor),
            textAlign: TextAlign.center,
          ),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "اكتب ردك هنا...",
              hintStyle: Styles.textStyle14.copyWith(
                color: Colors.grey.shade400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: EdgeInsets.all(16.w),
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "إلغاء",
                      style: Styles.textStyle14.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kprimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: حفظ الرد في API
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "تم إرسال الرد بنجاح",
                            style: Styles.textStyle14.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: Text(
                      "إرسال",
                      style: Styles.textStyle14Bold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // دالة حذف التعليق
  void _deleteComment(BuildContext context, Map<String, dynamic> comment) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            "حذف التعليق",
            style: Styles.textStyle16Bold.copyWith(color: AppColors.blackColor),
            textAlign: TextAlign.center,
          ),
          content: Text(
            "هل أنت متأكد من حذف هذا التعليق؟ لا يمكن التراجع عن هذه الخطوة.",
            style: Styles.textStyle14.copyWith(color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "إلغاء",
                      style: Styles.textStyle14.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: حذف التعليق من API
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "تم حذف التعليق بنجاح",
                            style: Styles.textStyle14.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: Text(
                      "حذف",
                      style: Styles.textStyle14Bold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
