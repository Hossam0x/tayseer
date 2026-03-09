import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/profille/data/models/profile_visitors_model.dart';
import 'package:tayseer/features/advisor/profille/data/models/visitor_itemm.dart';
import 'package:tayseer/features/advisor/profille/data/repo/profile_visitors_repo.dart';
import 'package:tayseer/features/advisor/profille/presentation/view_model/profile_visitors_cubit/profile_visitors_cubit.dart';
import 'package:tayseer/features/advisor/profille/presentation/view_model/profile_visitors_cubit/profile_visitors_state.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/boost_button_sliver.dart';
import 'package:tayseer/my_import.dart';

class ProfileVisitorsView extends StatelessWidget {
  const ProfileVisitorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileVisitorsCubit(ProfileVisitorsRepoImpl(getIt<ApiService>()))
            ..fetchVisitors(),
      child: Scaffold(
        body: AdvisorBackground(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 110.h,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AssetsData.homeBarBackgroundImage),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    Gap(10.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: SimpleAppBar(
                        title: context.tr('who_viewed_your_profile'),
                        isLargeTitle: true,
                      ),
                    ),
                    Gap(20.h),
                    Expanded(
                      child:
                          BlocBuilder<
                            ProfileVisitorsCubit,
                            ProfileVisitorsState
                          >(
                            builder: (context, state) {
                              if (state is ProfileVisitorsFailure) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        state.errorMessage,
                                        style: Styles.textStyle14.copyWith(
                                          color: AppColors.kRedColor,
                                        ),
                                      ),
                                      Gap(10.h),
                                      ElevatedButton(
                                        onPressed: () => context
                                            .read<ProfileVisitorsCubit>()
                                            .fetchVisitors(),
                                        child: Text(context.tr('retry')),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              // Prepare data for Skeleton or Success
                              final bool isLoading =
                                  state is ProfileVisitorsLoading;
                              final bool isSubscribed =
                                  state is ProfileVisitorsSuccess
                                  ? state.isSubscribed
                                  : false;

                              final List<ProfileVisitorModel> visitors =
                                  state is ProfileVisitorsSuccess
                                  ? state.visitors
                                  : List.generate(
                                      6,
                                      (index) => ProfileVisitorModel(
                                        id: '1',
                                        name: 'Loading User Name',
                                        userType: 'User',
                                        lastVisitedAt: DateTime.now()
                                            .toIso8601String(),
                                        image: '',
                                        email: '',
                                        username: '',
                                      ),
                                    );

                              if (state is ProfileVisitorsSuccess &&
                                  visitors.isEmpty) {
                                return Center(
                                  child: Text(
                                    context.tr('no_visitors_yet'),
                                    style: Styles.textStyle16.copyWith(
                                      color: AppColors.secondary600,
                                    ),
                                  ),
                                );
                              }

                              return Skeletonizer(
                                enabled: isLoading,
                                child: ListView.separated(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24.w,
                                    vertical: 10.h,
                                  ),
                                  itemCount: visitors.length,
                                  itemBuilder: (context, index) {
                                    if (index == visitors.length - 1) {
                                      return Column(
                                        children: [
                                          VisitorItem(
                                            visitor: visitors[index],
                                            isSubscribed: isSubscribed,
                                          ),
                                          Gap(24.h),
                                          Padding(
                                            padding: EdgeInsets.only(
                                              bottom: 30.h,
                                              left: 50.w,
                                              right: 50.w,
                                            ),
                                            child: BoostButton(
                                              text: context.tr('boost_button'),
                                              onPressed: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  AppRouter.kPackagesView,
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                    return VisitorItem(
                                      visitor: visitors[index],
                                      isSubscribed: isSubscribed,
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return Divider(color: Colors.grey[300]);
                                  },
                                ),
                              );
                            },
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
  }
}
