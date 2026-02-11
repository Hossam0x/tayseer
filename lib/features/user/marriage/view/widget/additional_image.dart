import 'package:tayseer/features/user/marriage/view_model/marriage_cubit.dart';
import 'package:tayseer/my_import.dart';

class AdditionalImageSection extends StatelessWidget {
  final String imageUrl;
  final String? personId;
  final bool? isHastar;
  const AdditionalImageSection({
    super.key,
    required this.imageUrl,
    this.personId,
    this.isHastar,
  });

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
          isHastar == true
              ? Positioned(
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
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
