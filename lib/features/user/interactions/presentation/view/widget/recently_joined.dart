import 'dart:ui';

import 'package:tayseer/my_import.dart';

import '../../../data/Model/interaction_usermodel .dart';

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

    return GestureDetector(
      onTap: () {
        context.pushNamed(
          AppRouter.kMarriageView,
          arguments: {'personId': item.userId},
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
          height: isCompact ? 170.h : 190.h, // ✅ ارتفاع مصغر
          width: isCompact ? 100.w : 110.w, // ✅ عرض مصغر
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
                                height: isCompact ? 80.h : 100.h,
                              ),
                            )
                          : AppImage(
                              item.image,
                              fit: BoxFit.cover,
                              height: isCompact ? 80.h : 100.h,
                            ),
                      if (shouldBlur)
                        Container(color: Colors.black.withOpacity(0.2)),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(
                  top: isCompact ? 6.h : 10.h, // ✅ مسافة مصغرة
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
                                    fontSize: isCompact
                                        ? 12.sp
                                        : 14.sp, // ✅ حجم خط مصغر
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              if (item.isverified)
                                Icon(
                                  Icons.verified,
                                  color: Colors.blue,
                                  size: isCompact
                                      ? 13.sp
                                      : 16.sp, // ✅ حجم أيقونة مصغر
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isCompact ? 4.h : 8.h), // ✅ مسافة مصغرة
                    _buildBadge(
                      text: context.tr("recently_joined"),
                      icon: AssetsData.joinedIcon,
                      isCompact: isCompact,
                    ),
                    SizedBox(height: isCompact ? 4.h : 8.h), // ✅ مسافة مصغرة
                    if (item.country.isNotEmpty) ...[
                      _buildBadge(
                        text: item.country,
                        icon: "",
                        isCompact: isCompact,
                      ),
                    ] else ...[
                      _buildBadge(text: "", icon: "", isCompact: isCompact),
                    ],
                  ],
                ),
              ),
            ],
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
