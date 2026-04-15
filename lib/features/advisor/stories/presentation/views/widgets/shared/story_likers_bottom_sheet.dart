import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/user_advisor_profile_view.dart';
import 'package:tayseer/features/user/user_profile/views/user_public_profile_view.dart';
import 'package:tayseer/my_import.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Likers Bottom Sheet — draggable, paginated & profile navigation
// ─────────────────────────────────────────────────────────────────────────────
class StoryLikersBottomSheet extends StatefulWidget {
  final List<StoryUserModel> likers;

  const StoryLikersBottomSheet({super.key, required this.likers});

  @override
  State<StoryLikersBottomSheet> createState() => _StoryLikersBottomSheetState();
}

class _StoryLikersBottomSheetState extends State<StoryLikersBottomSheet> {
  static const int _pageSize = 15;
  int _visibleCount = _pageSize;

  void _onScroll(ScrollController controller) {
    if (controller.position.pixels >=
        controller.position.maxScrollExtent - 100) {
      if (_visibleCount < widget.likers.length) {
        setState(() {
          _visibleCount = (_visibleCount + _pageSize).clamp(
            0,
            widget.likers.length,
          );
        });
      }
    }
  }

  void _navigateToProfile(BuildContext context, StoryUserModel user) {
    final isAdvisorUser = user.userType.toLowerCase() == 'advisor';
    if (isAdvisorUser) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserAdvisorProfileView(advisorId: user.id),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserPublicProfileView(userId: user.id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedLikers = widget.likers.take(_visibleCount).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.25,
      maxChildSize: 0.92,
      expand: false,
      snap: true,
      snapSizes: const [0.45, 0.7, 0.92],
      builder: (context, scrollController) {
        scrollController.addListener(() => _onScroll(scrollController));
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              // Title row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 18.sp,
                      ),
                    ),
                    Gap(10.w),
                    Text(
                      context.tr('story_likers'),
                      style: Styles.textStyle16SemiBold,
                    ),
                    const Spacer(),
                    if (widget.likers.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.kprimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '${widget.likers.length}',
                          style: Styles.textStyle12.copyWith(
                            color: AppColors.kprimaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey[100]),
              // List
              Expanded(
                child: widget.likers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 48.sp,
                              color: Colors.grey[300],
                            ),
                            Gap(12.h),
                            Text(
                              context.tr('no_likers_yet'),
                              style: Styles.textStyle14.copyWith(
                                color: AppColors.kGreyB3,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        itemCount: displayedLikers.length,
                        itemBuilder: (context, index) {
                          final user = displayedLikers[index];
                          return GestureDetector(
                            onTap: () => _navigateToProfile(context, user),
                            child: Container(
                              margin: EdgeInsets.only(bottom: 4.h),
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 24.r,
                                        backgroundImage: NetworkImage(
                                          user.image,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          width: 14.w,
                                          height: 14.w,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.5.w,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.favorite,
                                            color: Colors.white,
                                            size: 8.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Gap(12.w),
                                  Expanded(
                                    child: Text(
                                      user.name,
                                      style: Styles.textStyle14SemiBold,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14.sp,
                                    color: Colors.grey[400],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8.h),
            ],
          ),
        );
      },
    );
  }
}
