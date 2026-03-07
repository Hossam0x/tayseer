import 'package:tayseer/core/widgets/custom_click.dart';
import 'package:tayseer/core/widgets/my_profile_Image.dart';
import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
import 'package:tayseer/features/shared/home/view_model/home_state.dart';
import 'package:tayseer/my_import.dart';

class HomeAppBar extends StatefulWidget {
  const HomeAppBar({super.key, required this.notificationCount});
  final int notificationCount;

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
                    // ⭐ Use state.homeInfo?.image which updates reactively via HomeCubit
                    CustomClick(
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
                        //TODO: Navigate to notifications screen
                      },
                      icon: Stack(
                        clipBehavior: Clip.none,

                        children: [
                          GestureDetector(
                            onTap: () {
                              if (isGuest) {
                                CustomshowDialogWithImage(
                                  context,
                                  title: context.tr('joinUs'),
                                  supTitle: context.tr("guest_login_first"),
                                  icon: Icons.lock_person_outlined,
                                  iconColor: AppColors.kprimaryColor,
                                  bottonText: context.tr("login"),
                                  showCancelButton: true,
                                  cancelText: context.tr('skip'),
                                  onPressed: () {
                                    // ✅ مسح كاش البروفايل القديم عشان اللوجن الجديد يبدأ نضيف
                                    CachNetwork.clearGuestAndProfileCache();
                                    // ✅ ريسيت الـ HomeCubit Singleton
                                    if (getIt.isRegistered<HomeCubit>()) {
                                      getIt.resetLazySingleton<HomeCubit>();
                                    }
                                    context.pushNamedAndRemoveUntil(
                                      AppRouter.kRegisrationView,
                                      predicate: (_) => false,
                                    );
                                  },
                                  onCancel: () {},
                                );
                              } else {
                                context.pushNamed(AppRouter.notification);
                              }
                            },
                            child: AppImage(
                              AssetsData.notificationIcon,
                              height: context.responsiveHeight(23),
                              width: context.responsiveWidth(23),
                              fit: BoxFit.fill,
                            ),
                          ),
                          if (widget.notificationCount > 0)
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
                                    "${widget.notificationCount}",
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
