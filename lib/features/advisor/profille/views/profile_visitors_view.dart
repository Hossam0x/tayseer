import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/profile_visitors_repo.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_visitors_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/visitors/visitors_list.dart';
import 'package:tayseer/my_import.dart';

class ProfileVisitorsView extends StatelessWidget {
  const ProfileVisitorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
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
                child: DecoratedBox(
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
                    const Expanded(child: VisitorsList()),
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
