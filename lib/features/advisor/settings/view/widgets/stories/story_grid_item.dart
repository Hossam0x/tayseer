import 'package:tayseer/features/advisor/stories/stories.dart';
import 'package:tayseer/my_import.dart';

class StoryGridItem extends StatelessWidget {
  final StoryModel story;
  const StoryGridItem({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    final date = story.createdAt;
    return ClipRRect(
      borderRadius: BorderRadius.circular(30.r),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _StoryImage(imageUrl: story.image),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
          ),
          Positioned(
            top: 15.h,
            right: 15.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    date.day.toString(),
                    style: Styles.textStyle16Meduim.copyWith(
                      color: AppColors.blackColor,
                    ),
                  ),
                  Text(
                    _monthName(date.month),
                    style: Styles.textStyle12.copyWith(
                      color: AppColors.blackColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _monthName(int month) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return months[month - 1];
  }
}

class _StoryImage extends StatelessWidget {
  final String imageUrl;
  const _StoryImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          color: Colors.grey.shade300,
          child: Center(
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.primary100,
        child: Center(
          child: Icon(Icons.photo, color: AppColors.primary300, size: 40.sp),
        ),
      ),
    );
  }
}
