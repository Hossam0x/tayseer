import 'package:tayseer/core/models/category_model.dart';
import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
import 'package:tayseer/features/shared/home/view_model/home_state.dart';
import 'package:tayseer/my_import.dart';

class HomeFilterSection extends StatelessWidget {
  final ScrollController? scrollController;

  const HomeFilterSection({super.key, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: context.responsiveHeight(10),
          right: context.responsiveWidth(24),
          left: context.responsiveWidth(24),
        ),
        child: BlocBuilder<HomeCubit, HomeState>(
          buildWhen: (previous, current) =>
              previous.categoriesState != current.categoriesState ||
              previous.categories != current.categories ||
              previous.selectedCategoryId != current.selectedCategoryId ||
              previous.categoriesIsLoadingMore !=
                  current.categoriesIsLoadingMore,
          builder: (context, state) {
            if (state.categoriesState == CubitStates.loading) {
              return const _ShimmerLoading();
            }

            if (state.categoriesState == CubitStates.failure) {
              // أوفلاين أو فشل → لا تعرض أي حاجة، لما النت يرجع هيتحمل تلقائي
              return const SizedBox.shrink();
            }

            return _FilterList(
              categories: state.categories,
              selectedCategoryId: state.selectedCategoryId,
              isLoadingMore: state.categoriesIsLoadingMore,
              hasMore: state.categoriesHasMore,
              scrollController: scrollController,
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 📋 Filter List Widget
// ─────────────────────────────────────────────────────────────────────────────
class _FilterList extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final bool isLoadingMore;
  final bool hasMore;
  final ScrollController? scrollController;

  const _FilterList({
    required this.categories,
    required this.selectedCategoryId,
    required this.isLoadingMore,
    required this.hasMore,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (!isLoadingMore &&
            hasMore &&
            scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent * 0.9) {
          context.read<HomeCubit>().fetchCategories(loadMore: true);
        }
        return false;
      },
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 8.w,
          children: [
            // "الكل" filter
            _FilterItem(
              title: context.tr('all'),
              isSelected: selectedCategoryId == null,
              onTap: () => context.read<HomeCubit>().selectCategory(null),
            ),
            // Category filters
            ...categories.map((category) {
              return _FilterItem(
                title: category.name,
                isSelected: selectedCategoryId == category.id,
                onTap: () =>
                    context.read<HomeCubit>().selectCategory(category.id),
              );
            }),
            // Loading more indicator
            if (isLoadingMore) const _ShimmerItem(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🔘 Filter Item Widget
// ─────────────────────────────────────────────────────────────────────────────
class _FilterItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterItem({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveWidth(12),
          vertical: context.responsiveHeight(8),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.kprimaryColor.withOpacity(0.6)
              : const Color(0xB8F9F8EC),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          title,
          style: Styles.textStyle14.copyWith(
            color: isSelected ? Colors.black : AppColors.kGreyB3,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ✨ Shimmer Loading Widget
// ─────────────────────────────────────────────────────────────────────────────
class _ShimmerLoading extends StatelessWidget {
  const _ShimmerLoading();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          5,
          (index) => Padding(
            padding: EdgeInsets.only(left: context.responsiveWidth(8)),
            child: const _ShimmerItem(),
          ),
        ),
      ),
    );
  }
}

class _ShimmerItem extends StatelessWidget {
  const _ShimmerItem();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: context.responsiveWidth(80),
        height: context.responsiveHeight(35),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.r),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ❌ Error State Widget
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onRetry,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveWidth(12),
            vertical: context.responsiveHeight(8),
          ),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: Colors.red),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.refresh, size: 16, color: Colors.red),
              Gap(4.w),
              Text(
                "فشل التحميل، اضغط للإعادة",
                style: Styles.textStyle12.copyWith(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
