import 'package:tayseer/core/widgets/my_profile_Image.dart';
import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
import 'package:tayseer/features/shared/home/view_model/home_state.dart';
import 'package:tayseer/my_import.dart';

class HomeAppBar extends StatefulWidget {
  const HomeAppBar({super.key});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final userName = state.homeInfo?.name ?? '';
          final notificationsCount = state.homeInfo?.notifications ?? 0;

          return Container(
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
                    GestureDetector(
                      onTap: () {
                        if (isUser) {
                          context.read<LayoutCubit>().changeIndex(4);
                        } else if (isAdvisor) {
                          context.read<LayoutCubit>().changeIndex(3);
                        }
                      },
                      child: MyProfileImage(imageUrl: state.homeInfo?.image),
                    ),
                    Gap(context.responsiveWidth(14)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GradientText(
                            text: isAdvisor
                                ? context.tr("welcomeAdvisor")
                                : context.tr("welcome"),
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
                        context.pushNamed(AppRouter.notification);
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

                          if (notificationsCount > 0)
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
                                    "$notificationsCount",
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
          );
        },
      ),
    );
  }
}
