import 'dart:ui';
import 'package:tayseer/core/constant/marriage_constants.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/regards_purchase_sheet.dart';
import '../../../data/Model/interaction_usermodel .dart';

import '../../Interactions_cubit/interactions_cubit.dart';
import '../../Interactions_cubit/interactions_state.dart';
class RecentlyJoined extends StatelessWidget {
  final InteractionUserModel item;
  final bool forceBlur;
  final bool isCompact; // ✅ معامل جديد للعرض المصغر

  const RecentlyJoined({
    super.key,
    required this.item,
    this.forceBlur = false,
    this.isCompact = false, // ✅ القيمة الافتراضية
  });

  @override
  Widget build(BuildContext context) {
    final shouldBlur = forceBlur || item.isImageBlurred;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    // ✅ عرض الكارد يتحسب من عرض الشاشة عشان يشتغل صح على iPad
    final cardWidth = isTablet
        ? screenWidth * 0.16
        : (isCompact ? 100.w : 110.w);
    final cardHeight = isTablet
        ? screenWidth * 0.28
        : (isCompact ? 170.h : 190.h);
    final imageHeight = isTablet ? screenWidth * 0.16 : (isCompact ? 80.h : 100.h);
    final fontSize = isTablet ? 11.0 : (isCompact ? 12.sp : 14.sp);
    final iconSize = isTablet ? 12.0 : (isCompact ? 13.sp : 16.sp);

    return GestureDetector(
      onTap: () {
        // لو مش مشترك — اعرض sheet الاشتراك
        final isSubscribed = context.read<InteractionsCubit>().state.isSubscribed;
        if (!isSubscribed) {
          showGoldPurchaseSheet(context);
          return;
        }
        context.pushNamed(
          AppRouter.kMarriageView,
          arguments: {
            'personId': item.userId,
            'fromInteractions': true,
            'isFavorite': item.isFavorite,
            'interactionUser': item,
          },
        );
      },
      child: Container(
        margin: EdgeInsets.only(top: 10.h, left: 4.w),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 0.08),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: SizedBox(
          height: cardHeight,
          width: cardWidth,
          child: Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        shouldBlur
                            ? ImageFiltered(
                                imageFilter: ImageFilter.blur(
                                  sigmaX: 15,
                                  sigmaY: 15,
                                ),
                                child: AppImage(
                                  item.image,
                                  fit: BoxFit.cover,
                                  height: imageHeight,
                                ),
                              )
                            : AppImage(
                                item.image,
                                fit: BoxFit.cover,
                                height: imageHeight,
                              ),
                        if (shouldBlur)
                          Container(color: Colors.black.withOpacity(0.2)),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(
                    top: isCompact ? 6.h : 10.h,
                    right: 4.w,
                    left: 4.w,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    item.name,
                                    style: Styles.textStyle14SemiBold.copyWith(
                                      fontSize: fontSize,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                if (item.isverified)
                                  Icon(
                                    Icons.verified,
                                    color: Colors.blue,
                                    size: iconSize,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isCompact ? 4.h : 8.h),
                      _buildBadge(
                        text: context.tr("recently_joined"),
                        icon: AssetsData.joinedIcon,
                        isCompact: isCompact || isTablet,
                      ),
                      SizedBox(height: isCompact ? 4.h : 8.h),
                      if (item.country.isNotEmpty) ...[
                        _buildBadge(
                          text:
                              '${CountryFlagUtils.getFlag(item.country)} ${context.tr(item.country)}',
                          isCompact: isCompact || isTablet,
                        ),
                      ] else ...[
                        _buildBadge(text: "", icon: "", isCompact: isCompact || isTablet),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({
    required String text,
    String? icon,
    bool isCompact = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6.w : 10.w, // ✅ padding مصغر
        vertical: isCompact ? 3.h : 4.h,
      ),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(186, 186, 186, 0.24),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            AppImage(
              icon,
              width: isCompact ? 11.w : 14.w, // ✅ حجم أيقونة مصغر
              height: isCompact ? 12.h : 15.h,
            ),
            SizedBox(width: 3.w),
          ],
          Flexible(
            child: Text(
              text,
              style: Styles.textStyle14SemiBold.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: isCompact ? 11.sp : 14.sp, // ✅ حجم خط مصغر
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
