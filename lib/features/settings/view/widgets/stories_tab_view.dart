import 'package:tayseer/my_import.dart';

class StoriesTabView extends StatelessWidget {
  const StoriesTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(20.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 0.8,
      ),
      itemCount: 9, // Example count
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(25.r),
          child: Stack(
            children: [
              // Story Background Image
              AppImage(
                AssetsData.storyPlaceholder,
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              // Date Badge (Matches UI image)
              Positioned(
                top: 20.h,
                right: 20.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Column(
                    children: [
                      Text('23', style: Styles.textStyle16),
                      Text('نوفمبر', style: Styles.textStyle12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
