import 'package:tayseer/core/models/pagination_model.dart';
import 'package:tayseer/features/shared/home/model/past_match_model.dart';
import 'package:tayseer/my_import.dart';

class BestMatchesSection extends StatefulWidget {
  const BestMatchesSection({
    super.key,
    required this.matches,
    required this.pagination,
    this.onLoadMore,
    this.isLoadingMore = false,
  });

  final List<PastMatchModel> matches;
  final PaginationModel? pagination;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;

  @override
  State<BestMatchesSection> createState() => _BestMatchesSectionState();
}

class _BestMatchesSectionState extends State<BestMatchesSection> {
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

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);

    if (widget.matches.isNotEmpty &&
        index >= (widget.matches.length * 0.75).floor() &&
        widget.onLoadMore != null &&
        !widget.isLoadingMore &&
        _hasMoreData()) {
      widget.onLoadMore!();
    }
  }

  bool _hasMoreData() {
    if (widget.pagination == null) return false;
    return widget.pagination!.currentPage < widget.pagination!.totalPages;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.matches.isEmpty) return const SizedBox.shrink();

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
                      context.tr('best_matches'),
                      style: Styles.textStyle20.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.kprimaryColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      context.tr('best_matches_desc'),
                      style: Styles.textStyle12.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (widget.pagination != null)
                      Text(
                        '${widget.matches.length} / ${widget.pagination!.totalCount}',
                        style: Styles.textStyle10.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    Gap(4.h),
                    Row(
                      children: List.generate(
                        widget.matches.length.clamp(0, 5),
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          height: 4.h,
                          width: _currentPage == index ? 20.w : 6.w,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? AppColors.kprimaryColor
                                : AppColors.kprimaryColor.withValues(
                                    alpha: 0.2,
                                  ),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Gap(16.h),
          SizedBox(
            height: 200.h,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.matches.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) => _MatchCard(
                match: widget.matches[index],
                isSelected: _currentPage == index,
              ),
            ),
          ),
          if (widget.isLoadingMore)
            Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Center(
                child: SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.kprimaryColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match, required this.isSelected});

  final PastMatchModel match;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 400),
      scale: isSelected ? 1.0 : 0.95,
      child: GestureDetector(
        onTap: () {
          context.pushNamed(
            AppRouter.kUserPublicProfileView,
            arguments: match.id.toString(),
          );
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                if (match.image != null)
                  Image.network(
                    match.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.kprimaryColor.withValues(alpha: 0.1),
                    ),
                  )
                else
                  Container(
                    color: AppColors.kprimaryColor.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey.shade300,
                    ),
                  ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.75),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
                // Content
                Positioned(
                  bottom: 16.h,
                  left: 16.w,
                  right: 16.w,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          match.name ?? '',
                          style: Styles.textStyle18.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (match.matchRate != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.kprimaryColor,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.kprimaryColor.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.favorite_rounded,
                                color: Colors.white,
                                size: 12.sp,
                              ),
                              Gap(4.w),
                              Text(
                                '${match.matchRate}%',
                                style: Styles.textStyle10.copyWith(
                                  color: Colors.white,
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
        ),
      ),
    );
  }
}
