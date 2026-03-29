import 'dart:ui';
import 'package:tayseer/features/user/marriage/view_model/marriage_cubit.dart';
import 'package:tayseer/my_import.dart';

class AdditionalImageSection extends StatelessWidget {
  final String imageUrl;
  final String? personId;
  final bool? isHastar;
  final bool shouldBlur; // ✅ جديد

  const AdditionalImageSection({
    super.key,
    required this.imageUrl,
    this.personId,
    this.isHastar,
    this.shouldBlur = false, // ✅
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Stack(
        children: [
          // ✅ الصورة مع دعم الـ blur
          if (shouldBlur)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: SizedBox(
                width: double.infinity,
                height: context.height * 0.4,
                child: AppImage(imageUrl, fit: BoxFit.cover),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: context.height * 0.4,
              child: AppImage(imageUrl, fit: BoxFit.cover),
            ),

          // ✅ طبقة تعتيم فوق الـ blur
          if (shouldBlur)
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),

          // ✅ زر النجمة
          if (isHastar == true)
            Positioned(
              bottom: 15.h,
              left: 15.w,
              child: CircleAvatar(
                backgroundColor: HexColor('cccab3'),
                child: IconButton(
                  icon: Icon(
                    Icons.star,
                    color: AppColors.kWhiteColor,
                    size: 20.sp,
                  ),
                  onPressed: () {
                    if (personId != null) {
                      context.read<MarriageCubit>().sendRegard(
                        personId: personId!,
                      );
                    }
                  },
                ),
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}
