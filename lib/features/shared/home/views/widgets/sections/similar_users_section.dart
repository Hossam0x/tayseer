import 'package:tayseer/features/shared/home/model/similar_user_model.dart';
import 'package:tayseer/my_import.dart';

class SimilarUsersSection extends StatefulWidget {
  const SimilarUsersSection({super.key, required this.users});
  final List<SimilarUserModel> users;

  @override
  State<SimilarUsersSection> createState() => _SimilarUsersSectionState();
}

class _SimilarUsersSectionState extends State<SimilarUsersSection> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.users.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 280.h,
      margin: EdgeInsets.symmetric(vertical: 24.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          // Segmented Indicator like Stories
          Row(
            children: List.generate(
              widget.users.length.clamp(0, 8),
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: Container(
                    height: 3.h,
                    decoration: BoxDecoration(
                      color: _currentPage >= index 
                          ? AppColors.kprimaryColor 
                          : AppColors.kprimaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Gap(16.h),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.users.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final user = widget.users[index];
                return GestureDetector(
                  onTap: () {
                    context.pushNamed(
                      AppRouter.kUserPublicProfileView,
                      arguments: user.id.toString(),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.kprimaryColor.withValues(alpha: 0.05),
                          Colors.white,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30.r),
                      border: Border.all(
                        color: AppColors.kprimaryColor.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Large Glowing Avatar
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 100.w,
                              height: 100.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.kprimaryColor.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            CircleAvatar(
                              radius: 45.r,
                              backgroundColor: Colors.white,
                              backgroundImage: user.image != null 
                                  ? NetworkImage(user.image!) 
                                  : null,
                              child: user.image == null 
                                  ? Icon(Icons.person, size: 40, color: Colors.grey.shade300)
                                  : null,
                            ),
                          ],
                        ),
                        Gap(20.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                context.tr('similar_users'),
                                style: Styles.textStyle12.copyWith(
                                  color: AppColors.kprimaryColor,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Gap(4.h),
                              Text(
                                user.name ?? '',
                                style: Styles.textStyle20.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Gap(8.h),
                              Wrap(
                                spacing: 8.w,
                                runSpacing: 4.h,
                                children: [
                                  _FeatureTag(label: '${user.age} ${context.tr('age')}'),
                                  _FeatureTag(label: user.city ?? ''),
                                ],
                              ),
                              Gap(16.h),
                              // Similarity percentage
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.flash_on_rounded, color: Colors.green, size: 14.sp),
                                    Gap(4.w),
                                    Text(
                                      '95% ${context.tr('similarity')}',
                                      style: Styles.textStyle12.copyWith(
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureTag extends StatelessWidget {
  const _FeatureTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        label,
        style: Styles.textStyle12.copyWith(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
