import 'package:tayseer/features/shared/home/model/best_advisor_model.dart';
import 'package:tayseer/my_import.dart';

class BestAdvisorSection extends StatefulWidget {
  const BestAdvisorSection({super.key, required this.advisors});

  final List<BestAdvisorModel> advisors;

  @override
  State<BestAdvisorSection> createState() => _BestAdvisorSectionState();
}

class _BestAdvisorSectionState extends State<BestAdvisorSection> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.advisors.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('best_advisors'),
                      style: Styles.textStyle20.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.kprimaryColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      context.tr('expert_guidance_for_you'),
                      style: Styles.textStyle12.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                // Custom indicator like stories but for pages
                Row(
                  children: List.generate(
                    widget.advisors.length.clamp(0, 5),
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      height: 4.h,
                      width: _currentPage == index ? 20.w : 6.w,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.kprimaryColor
                            : AppColors.kprimaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Gap(16.h),
          SizedBox(
            height: 240.h,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.advisors.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) => _AdvisorCarouselItem(
                advisor: widget.advisors[index],
                isSelected: _currentPage == index,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvisorCarouselItem extends StatelessWidget {
  const _AdvisorCarouselItem({required this.advisor, required this.isSelected});

  final BestAdvisorModel advisor;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 400),
      scale: isSelected ? 1.0 : 0.95,
      child: GestureDetector(
        onTap: () {
          // Navigate to UserAdvisorProfileView
          context.pushNamed(
            AppRouter
                .kUserProfileView, // Assuming this is UserAdvisorProfileView based on history
            arguments: {'advisorId': advisor.id},
          );
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.kprimaryColor.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: Stack(
              children: [
                // Background Pattern or subtle gradient
                Positioned(
                  top: -50,
                  right: -50,
                  child: CircleAvatar(
                    radius: 100,
                    backgroundColor: AppColors.kprimaryColor.withValues(
                      alpha: 0.03,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      // Avatar with border
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.kprimaryColor.withValues(
                              alpha: 0.2,
                            ),
                            width: 1.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 45.r,
                          backgroundColor: Colors.grey.shade100,
                          backgroundImage: advisor.image != null
                              ? NetworkImage(advisor.image!)
                              : null,
                          child: advisor.image == null
                              ? Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey.shade400,
                                )
                              : null,
                        ),
                      ),
                      Gap(16.w),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    advisor.name ?? '',
                                    style: Styles.textStyle18.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        color: Colors.amber,
                                        size: 14.sp,
                                      ),
                                      Gap(2.w),
                                      Text(
                                        advisor.rate?.toString() ?? '0',
                                        style: Styles.textStyle12.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Gap(4.h),
                            Text(
                              advisor.yearsOfExperience != null
                                  ? '${advisor.yearsOfExperience} ${context.tr('years_experience')}'
                                  : '',
                              style: Styles.textStyle14.copyWith(
                                color: AppColors.kprimaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Gap(8.h),
                            Text(
                              advisor.subtitle ?? '',
                              style: Styles.textStyle12.copyWith(
                                color: Colors.grey.shade600,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
        ),
      ),
    );
  }
}
