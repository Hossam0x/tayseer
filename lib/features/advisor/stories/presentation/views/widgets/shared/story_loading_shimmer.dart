import 'package:tayseer/my_import.dart';

class StoriesLoadingShimmer extends StatelessWidget {
  final int count;
  const StoriesLoadingShimmer({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          count,
          (_) => Padding(
            padding: EdgeInsetsDirectional.only(
              end: context.responsiveWidth(14),
            ),
            child: Shimmer.fromColors(
              baseColor: AppColors.secondary100,
              highlightColor: AppColors.kWhiteColor.withOpacity(0.5),
              child: Column(
                children: [
                  Container(
                    width: context.responsiveWidth(76),
                    height: context.responsiveWidth(76),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  Gap(context.responsiveHeight(6)),
                  Container(
                    width: context.responsiveWidth(60),
                    height: context.responsiveHeight(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
