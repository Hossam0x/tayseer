import 'dart:ui';
import 'package:tayseer/features/user/interactions/data/Model/interaction_usermodel%20.dart';
import 'package:tayseer/my_import.dart';

import '../../Interactions_cubit/interactions_cubit.dart';
import '../../Interactions_cubit/interactions_state.dart';

class GreetingProfileCard extends StatelessWidget {
  final InteractionUserModel item;
  final bool forceBlur;

  const GreetingProfileCard({
    super.key,
    required this.item,
    this.forceBlur = false,
  });

  void _navigateToProfile(BuildContext context) {
    context.pushNamed(
      AppRouter.kMarriageView,
      arguments: {
        'personId': item.userId,
        'fromInteractions': true,
        'isFavorite': item.isFavorite,
        'interactionUser': item,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final shouldBlur = forceBlur || item.isImageBlurred;

    return BlocListener<InteractionsCubit, InteractionsState>(
      listener: (context, state) {
        if (state.actionState == CubitStates.success) {
          _showSuccessAnimation(context);
          Future.delayed(const Duration(milliseconds: 100), () {
            context.read<InteractionsCubit>().resetActionState();
          });
        } else if (state.actionState == CubitStates.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: state.actionMessage ?? context.tr('error_occurred'),
              isSuccess: false,
            ),
          );
          context.read<InteractionsCubit>().resetActionState();
        }
      },
      child: GestureDetector(
        onTap: () => _navigateToProfile(context),
        child: Container(
          height: 160.h,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(0, 0, 0, 0.08),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
          ),
          child: Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: Row(
              children: [
                // Profile Image — بدون GestureDetector، الأب يتكفل
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Stack(
                    children: [
                      shouldBlur
                          ? ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: 15,
                                sigmaY: 15,
                              ),
                              child: AppImage(
                                item.image,
                                width: 130.w,
                                height: 117.h,
                                fit: BoxFit.cover,
                              ),
                            )
                          : AppImage(
                              item.image,
                              width: 130.w,
                              height: 117.h,
                              fit: BoxFit.cover,
                            ),
                      if (shouldBlur)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.2),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),

                // User Info — بدون GestureDetector، الأب يتكفل
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
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
                                  ' ${item.age} ${context.tr('age')}',
                                  style: Styles.textStyle16.copyWith(
                                    fontWeight: FontWeight.w400,
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

                      Row(
                        children: [
                          Flexible(
                            // ✅
                            child: _buildBadge(text: item.day),
                          ),
                          SizedBox(width: 4.w),
                          if (item.country.isNotEmpty)
                            Flexible(
                              // ✅
                              child: _buildBadge(
                                text: item.country,
                                icon: AssetsData.EgyFlagIcon,
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: 4.h),

                      if (item.job.isNotEmpty)
                        _buildBadge(text: item.job, icon: AssetsData.workIcon),
                    ],
                  ),
                ),

                // ✅ زر التحية — behavior: opaque يمنع الـ tap من الوصول للأب
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    context.read<InteractionsCubit>().sendCompliment(
                      userId: item.userId,
                    );
                  },
                  child: Container(
                    width: 55.w,
                    height: 55.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.primary200, AppColors.primary400],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF48174E).withOpacity(0.2),
                          offset: const Offset(0, 2.87),
                          blurRadius: 37.85,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(Icons.star, color: Colors.white, size: 30.r),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor:
          Colors.transparent, // ✅ transparent لأن rootNavigator هيغطي كل حاجة
      useRootNavigator: true, // ✅ هذا هو الحل
      builder: (_) {
        return Center(
          child: Opacity(
            opacity: 0.9,
            child: AppImage(AssetsData.kSuccessMarriageAnimationsLottie),
          ),
        );
      },
    );
    Future.delayed(const Duration(seconds: 4), () {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pop(); // ✅ نفس الـ rootNavigator
      }
    });
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
          Flexible(
            // ✅ أضف Flexible
            child: Text(
              text,
              style: Styles.textStyle12SemiBold.copyWith(
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis, // ✅ أضف ellipsis
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
