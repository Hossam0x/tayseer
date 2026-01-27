import 'dart:ui'; // ✅ إضافة هذا
import 'package:tayseer/core/widgets/custom_show_dialog.dart';
import 'package:tayseer/my_import.dart';

import '../../../data/Model/Iinteraction_usermodel .dart';
import '../../Interactions_cubit/interactions_cubit.dart';

class GreetingProfileCard extends StatelessWidget {
  final InteractionUserModel item;
  final bool forceBlur; // ✅ إضافة
  
  const GreetingProfileCard({
    super.key,
    required this.item,
    this.forceBlur = false, // ✅ إضافة
  });

  @override
  Widget build(BuildContext context) {
    final shouldBlur = forceBlur || item.isImageBlurred; // ✅ إضافة
    
    return Container(
      height: 160.h,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.08),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          // Profile Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Stack(
              children: [
                AppImage(
                  item.image,
                  width: 130.w,
                  height: 117.h,
                  fit: BoxFit.cover,
                ),
                // ✅ Blur Effect
                if (shouldBlur)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          color: Colors.black.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      
          SizedBox(width: 12.w),

          // User Info
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
                            ' ${item.age} سنة',
                            style: Styles.textStyle16.copyWith(
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(width: 5.w),
                          if (item.isverified)
                            Icon(Icons.verified, color: Colors.blue, size: 16.sp),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.h),
                
                Row(
                  children: [
                    _buildBadge(text: item.day),
                    SizedBox(width: 4.w),
                    if (item.country.isNotEmpty)
                      _buildBadge(
                        text: item.country,
                        icon: AssetsData.EgyFlagIcon,
                      ),
                  ],
                ),
                
                SizedBox(height: 4.h),
                
                if (item.job.isNotEmpty)
                  _buildBadge(text: item.job, icon: AssetsData.workIcon),
              ],
            ),
          ),

          // Star Button
          GestureDetector(
            onTap: () {
              CustomSHowDetailsDialog(
                context,
                title: context.tr('send_a_greeting'),
                onSendPressed: () {
                  context.read<InteractionsCubit>().sendCompliment(
                    userId: item.userId,
                  );
                  
                  context.pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    CustomSnackBar(
                      context,
                      text: "تم ارسال التحية بنجاح",
                      isSuccess: true,
                    ),
                  );
                },
                contantWidget: TextField(
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: context.tr('tell_us_more_about_yourself'),
                    hintStyle: Styles.textStyle12.copyWith(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
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