import 'package:tayseer/my_import.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    super.key,
    required this.userName,
    required this.notificationCount,
  });
  final String userName;
  final int notificationCount;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        width: context.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetsData.homeBarBackgroundImage),
            fit: BoxFit.fill,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.only(
              top: context.responsiveHeight(16),
              left: context.responsiveWidth(24),
              right: context.responsiveWidth(24),
            ),
            child: Row(
              children: [
                _buildProfile(context),
                Gap(context.responsiveWidth(14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GradientText(
                        text: context.tr("welcomeAdvisor"),
                        style: Styles.textStyle24Bold,
                        gradient: AppColors.blueOrangeGradient,
                      ),
                      Text(
                        "$userName !",
                        style: Styles.textStyle20Bold.copyWith(
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: () {
                    //TODO: Navigate to notifications screen
                  },
                  icon: Stack(
                    clipBehavior: Clip.none,

                    children: [
                      AppImage(
                        AssetsData.notificationIcon,
                        height: context.responsiveHeight(23),
                        width: context.responsiveWidth(23),
                        fit: BoxFit.fill,
                      ),
                      if (notificationCount > 0)
                        Positioned(
                          top: context.responsiveHeight(-8),
                          right: context.responsiveWidth(-6),

                          child: Container(
                            padding: EdgeInsets.all(4.r),
                            decoration: BoxDecoration(
                              color: AppColors.kprimaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "$notificationCount",
                                style: Styles.textStyle10Bold.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
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

  Container _buildProfile(BuildContext context) {
    return Container(
      width: context.responsiveWidth(40),
      height: context.responsiveWidth(40),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        shape: BoxShape.circle,
        image: DecorationImage(
          image: AssetImage(AssetsData.avatarImage),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
