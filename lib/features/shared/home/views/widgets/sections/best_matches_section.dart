import 'package:tayseer/features/shared/home/model/past_match_model.dart';
import 'package:tayseer/my_import.dart';

class BestMatchesSection extends StatefulWidget {
  const BestMatchesSection({super.key, required this.matches});
  final List<PastMatchModel> matches;

  @override
  State<BestMatchesSection> createState() => _BestMatchesSectionState();
}

class _BestMatchesSectionState extends State<BestMatchesSection> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.matches.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('best_matches'),
                      style: Styles.textStyle22.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      context.tr('best_matches_desc'),
                      style: Styles.textStyle14.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                // Indicator
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.kprimaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '${_currentPage + 1}/${widget.matches.length}',
                    style: Styles.textStyle12.copyWith(
                      color: AppColors.kprimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Gap(16.h),
          SizedBox(
            height: 380.h,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.matches.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) => _MatchPageItem(
                match: widget.matches[index],
                isSelected: _currentPage == index,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchPageItem extends StatelessWidget {
  const _MatchPageItem({required this.match, required this.isSelected});
  final PastMatchModel match;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 400),
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: isSelected ? 0 : 15.h,
      ),
      child: GestureDetector(
        onTap: () {
          context.pushNamed(
            AppRouter.kUserPublicProfileView,
            arguments: match.id.toString(),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32.r),
            image: DecorationImage(
              image: NetworkImage(match.image ?? ''),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.3),
                BlendMode.darken,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32.r),
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.5, 1.0],
              ),
            ),
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Match Rate Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.kprimaryColor,
                    borderRadius: BorderRadius.circular(15.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.kprimaryColor.withValues(alpha: 0.4),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite_rounded, color: Colors.white, size: 14.sp),
                      Gap(6.w),
                      Text(
                        '${match.matchRate ?? 90}% Compatible',
                        style: Styles.textStyle12.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(12.h),
                Text(
                  match.name ?? '',
                  style: Styles.textStyle24.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
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
