import 'package:tayseer/my_import.dart';

class AdditionalImageSection extends StatelessWidget {
  final String imageUrl;
  const AdditionalImageSection({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Stack(
        children: [
          AppImage(
            imageUrl,
            width: context.width,
            height: context.height * 0.4,
            fit: BoxFit.cover,
          ),
          Positioned(
            bottom: 15.h,
            left: 15.w,
            child: CircleAvatar(
              backgroundColor: HexColor('cccab3'),
              child: Icon(
                Icons.star,
                color: AppColors.kWhiteColor,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
