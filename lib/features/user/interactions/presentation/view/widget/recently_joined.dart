
// ═══════════════════════════════════════════════════════════════════
// Recently Joined Widget
// ═══════════════════════════════════════════════════════════════════
import 'dart:ui';

import 'package:tayseer/features/user/interactions/data/Model/Iinteraction_usermodel%20.dart';
import 'package:tayseer/my_import.dart';

class RecentlyJoined extends StatelessWidget {
  final InteractionUserModel item;
  final bool forceBlur;

  const RecentlyJoined({super.key, required this.item, this.forceBlur = false});

  @override
  Widget build(BuildContext context) {
    final shouldBlur = forceBlur || item.isImageBlurred;

    return Container(
      margin: EdgeInsets.only(top: 10.h, left: 4.w),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.08),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: SizedBox(
        height: 190.h,
        width: 110.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppImage(item.image, fit: BoxFit.cover,height: 100.h,),
                    if (shouldBlur)
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(color: Colors.black.withOpacity(0.2)),
                      ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: 10.h, right: 4.w, left: 4.w),
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
                                style: Styles.textStyle14SemiBold,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 5.w),
                            if (item.isverified)
                              Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 16.sp,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  _buildBadge(text: context.tr("recently_joined"), icon: AssetsData.joinedIcon),
                  SizedBox(height: 8.h),
                  if (item.country.isNotEmpty)
                    _buildBadge(
                      text: item.country,
                      icon: AssetsData.EgyFlagIcon,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({required String text, String? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(186, 186, 186, 0.24),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            AppImage(icon, width: 14.w, height: 15.h),
            SizedBox(width: 4.w),
          ],
          Text(
            text,
            style: Styles.textStyle14SemiBold.copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
