// features/user/user_profile/views/widgets/report_bottom_sheet.dart
import 'package:tayseer/core/widgets/snack_bar_service.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile_cubit.dart';
import 'package:tayseer/my_import.dart';

class UserReportBottomSheet extends StatefulWidget {
  final String reportedId;
  final UserPublicProfileCubit cubit;

  const UserReportBottomSheet({
    super.key,
    required this.reportedId,
    required this.cubit,
  });

  static void show(
    BuildContext context, {
    required String reportedId,
    required UserPublicProfileCubit cubit,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          UserReportBottomSheet(reportedId: reportedId, cubit: cubit),
    );
  }

  @override
  State<UserReportBottomSheet> createState() => _UserReportBottomSheetState();
}

class _UserReportBottomSheetState extends State<UserReportBottomSheet> {
  String? selectedReason;
  final TextEditingController detailsController = TextEditingController();

  final List<String> reasons = [
    'محتوى غير لائق',
    'مضايقة أو تنمر',
    'سبام أو إعلانات',
    'انتهاك للخصوصية',
    'انتهاك حقوق الملكية',
    'عنف أو تهديد',
    'آخر',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10.h),
                    width: 100.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: AppColors.secondary50,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                ),
                Text(
                  'إبلاغ',
                  style: Styles.textStyle18SemiBold.copyWith(
                    color: AppColors.secondary800,
                  ),
                ),
                Gap(16.h),
                DropdownButtonFormField<String>(
                  value: selectedReason,
                  hint: Text('اختر السبب'),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.secondary50),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                  items: reasons
                      .map(
                        (reason) => DropdownMenuItem(
                          value: reason,
                          child: Text(reason),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedReason = value;
                    });
                  },
                ),
                Gap(16.h),
                TextField(
                  controller: detailsController,
                  decoration: InputDecoration(
                    hintText: 'تفاصيل الإبلاغ (اختياري)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.secondary50),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                  maxLines: 3,
                ),
                Gap(24.h),
                ElevatedButton(
                  onPressed: selectedReason != null ? _submitReport : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kRedColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    minimumSize: Size(double.infinity, 48.h),
                  ),
                  child: Text(
                    'إرسال الإبلاغ',
                    style: Styles.textStyle16SemiBold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Gap(16.h),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 18.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26.r),
              ),
              child: Text(
                context.tr(AppStrings.cancel),
                textAlign: TextAlign.center,
                style: Styles.textStyle16SemiBold.copyWith(
                  color: AppColors.secondary800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitReport() async {
    if (selectedReason == null) return;

    // احفظ الـ context الأصلي قبل الـ pop
    final scaffoldContext = context;

    // أغلق الـ bottom sheet أولاً
    Navigator.pop(context);

    // TODO: نفذ الـ API للإبلاغ عن المستخدم
    // await widget.cubit.reportUser(
    //   reportedId: widget.reportedId,
    //   reason: selectedReason!,
    //   reasonDetails: detailsController.text.trim(),
    // );

    // مؤقتًا: عرض رسالة نجاح
    if (!scaffoldContext.mounted) return;

    showSafeSnackBar(
      context: scaffoldContext,
      text: "تم إرسال البلاغ بنجاح",
      isSuccess: true,
    );
  }
}
