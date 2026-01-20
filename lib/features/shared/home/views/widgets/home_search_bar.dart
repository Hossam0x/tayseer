import 'package:tayseer/my_import.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveWidth(28),
          vertical: context.responsiveWidth(16),
        ),
        child: Hero(
          tag: 'search_bar_tag',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                context.pushNamed(AppRouter.kAdvisorSearchView);
              },
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                height: context.responsiveHeight(45),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: AppColors.kGreyB3, size: 26.sp),
                      Gap(context.responsiveWidth(10)),
                      Text(
                        context.tr("search_hint"),
                        style: Styles.textStyle14.copyWith(
                          color: AppColors.kGreyB3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
