import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/features/advisor/profille/data/models/profile_visitors_model.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile/profile_visitors_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile/profile_visitors_state.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/boost/boost_button_sliver.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/visitors/visitor_item.dart';
import 'package:tayseer/my_import.dart';

class VisitorsList extends StatelessWidget {
  const VisitorsList({super.key});

  static final _skeletonVisitors = List.generate(
    6,
    (i) => ProfileVisitorModel(
      id: '$i',
      name: 'Loading User Name',
      userType: 'User',
      lastVisitedAt: DateTime.now().toIso8601String(),
      image: '',
      email: '',
      username: '',
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileVisitorsCubit, ProfileVisitorsState>(
      builder: (context, state) {
        if (state is ProfileVisitorsFailure) {
          return CustomErrorView(
            onRetry: () => context.read<ProfileVisitorsCubit>().fetchVisitors(),
          );
        }

        final isLoading = state is ProfileVisitorsLoading;
        final isSubscribed = state is ProfileVisitorsSuccess
            ? state.isSubscribed
            : false;
        final visitors = state is ProfileVisitorsSuccess
            ? state.visitors
            : _skeletonVisitors;

        if (state is ProfileVisitorsSuccess && visitors.isEmpty) {
          return Center(
            child: Text(
              context.tr('no_visitors_yet'),
              style: Styles.textStyle16.copyWith(color: AppColors.secondary600),
            ),
          );
        }

        return Skeletonizer(
          enabled: isLoading,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
            itemCount: visitors.length,
            separatorBuilder: (_, __) => Divider(color: Colors.grey[300]),
            itemBuilder: (context, index) {
              final isLast = index == visitors.length - 1;
              return Column(
                children: [
                  VisitorItem(
                    visitor: visitors[index],
                    isSubscribed: isSubscribed,
                  ),
                  if (isLast) ...[
                    Gap(24.h),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 30.h,
                        left: 50.w,
                        right: 50.w,
                      ),
                      child: BoostButton(
                        text: context.tr('boost_button'),
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRouter.kPackagesView,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        );
      },
    );
  }
}
