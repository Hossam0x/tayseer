import 'dart:ui';
import 'package:tayseer/features/user/user_profile/views/widgets/regards_purchase_sheet.dart';
import 'package:tayseer/my_import.dart';

class CompatibilitySection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> tags;
  final bool isBlurred;

  const CompatibilitySection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tags,
    this.isBlurred = false,
  });

  static const _goldDark = Color(0xFF8B6914);
  static const _goldMid = Color(0xFFB8860B);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [HexColor('e5eef9'), HexColor('f9e1e8')],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Styles.textStyle16Bold),
          Text(
            subtitle,
            style: Styles.textStyle12.copyWith(color: AppColors.kGreyColor),
          ),
          Gap(10.h),
          if (isBlurred) _buildBlurredTags(context) else _buildTags(),
        ],
      ),
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) => _buildTag(tag)).toList(),
    );
  }

  Widget _buildBlurredTags(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Blurred tags
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) => _buildTag(tag)).toList(),
          ),
        ),
        Gap(22.h),
        // Gold unlock button — centered, doesn't overlap the tags
        Center(
          child: GestureDetector(
            onTap: () => showGoldPurchaseSheet(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_goldDark, _goldMid],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: _goldDark.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium_rounded,
                      color: Colors.white, size: 20.sp),
                  Gap(10.w),
                  Text(
                    context.tr('unlock_compatibility'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: HexColor('f8f7fb'),
        borderRadius: BorderRadius.circular(13.r),
        border: Border.all(color: AppColors.kWhiteColor),
      ),
      child: Text(text, style: Styles.textStyle12SemiBold),
    );
  }
}
