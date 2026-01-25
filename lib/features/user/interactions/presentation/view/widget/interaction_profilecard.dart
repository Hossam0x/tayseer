import 'dart:ui';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_cubit.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/StatusRibbonwidget.dart';
import 'package:tayseer/my_import.dart';

import '../../../data/Model/InteractionUserModel .dart';

class InteractionProfileCard extends StatelessWidget {
  final InteractionUserModel item;

  const InteractionProfileCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 1. جسم الكارت الأساسي
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(0, 0, 0, 0.08),
            borderRadius: BorderRadius.circular(20.r),
          
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // الصورة الأصلية
                      AppImage(
                        item.image,
                        fit: BoxFit.cover,
                      ),
                      
                      // تأثير الـ Blur
                      if (item.isImageBlurred)
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            color: Colors.black.withOpacity(0.1),
                          ),
                        ),
                      
                      // ✅ Favorite Icon (مع وظيفة الإعجاب)
                      if (item.isFavorite)
                        Positioned(
                          top: 12.h,
                          left: 12.w,
                          child: GestureDetector(
                            onTap: () {
                              // إزالة من المفضلة
                              context.read<InteractionsCubit>().toggleFavorite(
                                userId: item.userId,
                                isAdd: false,
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                              
                                shape: BoxShape.circle,
                              
                              ),
                              child: Icon(
                                Icons.favorite,
                                color: AppColors.primary400,
                                size: 26.sp,
                              ),
                            ),
                          ),
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
                                  '${item.name},',
                                  style: Styles.textStyle16SemiBold,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                ' ${item.age} سنة',
                                style: Styles.textStyle16.copyWith(
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(width: 5.w),
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
                    
                    Row(
                      children: [
                        _buildBadge(text: item.day),
                        SizedBox(width: 8.w),
                        _buildBadge(
                          text: item.country,
                          icon: AssetsData.EgyFlagIcon,
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 8.h),
                    
                    _buildBadge(
                      text: item.job,
                      icon: AssetsData.workIcon,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 2. الشعار (Ribbon)
        if (item.likedHim)
          StatusRibbonwidget(
            statusText: "نال أعجابك",
            topTextPosition: 28.h,
            rightTextPosition: 1.w,
          )
        else if (item.sentCompliment)
          StatusRibbonwidget(
            statusText: "أرسلت مجاملة",
            topTextPosition: 26.h,
            rightTextPosition: -2.w,
          )
        else if (item.likedMe)
          StatusRibbonwidget(
            statusText: "اُعجب بك",
            topTextPosition: 30.h,
            rightTextPosition: 5.w,
          ),
      ],
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
            AppImage(icon, width: 14.w),
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