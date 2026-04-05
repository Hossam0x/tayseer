import 'package:tayseer/features/shared/profile/cubit/ratings/ratings_cubit.dart';
import 'package:tayseer/features/shared/profile/cubit/ratings/ratings_state.dart';
import 'package:tayseer/features/shared/profile/widgets/ratings/ratings_add_button.dart';
import 'package:tayseer/features/shared/profile/widgets/ratings/ratings_error_section.dart';
import 'package:tayseer/features/shared/profile/widgets/ratings/ratings_list.dart';
import 'package:tayseer/features/shared/profile/widgets/ratings/ratings_load_more_button.dart';
import 'package:tayseer/features/shared/profile/widgets/ratings/ratings_skeleton.dart';
import 'package:tayseer/features/shared/profile/widgets/ratings/ratings_summary_section.dart';
import 'package:tayseer/my_import.dart';

class RatingsTab extends StatefulWidget {
  final String advisorId;
  final bool isMe;

  const RatingsTab({super.key, required this.advisorId, required this.isMe});

  @override
  State<RatingsTab> createState() => _RatingsTabState();
}

class _RatingsTabState extends State<RatingsTab>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _reviewController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<RatingsCubit, RatingsState>(
      builder: (context, state) {
        if (state.state == CubitStates.loading) {
          return const RatingsSkeleton();
        }

        if (state.state == CubitStates.failure && state.ratings.isEmpty) {
          return RatingsErrorSection(advisorId: widget.advisorId);
        }

        return _RatingsContent(
          advisorId: widget.advisorId,
          isMe: widget.isMe,
          state: state,
          reviewController: _reviewController,
        );
      },
    );
  }
}

class _RatingsContent extends StatelessWidget {
  final String advisorId;
  final bool isMe;
  final RatingsState state;
  final TextEditingController reviewController;

  const _RatingsContent({
    required this.advisorId,
    required this.isMe,
    required this.state,
    required this.reviewController,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () =>
          context.read<RatingsCubit>().refresh(advisorId: advisorId),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            if (!isMe && isUser)
              RatingsAddButton(
                advisorId: advisorId,
                reviewController: reviewController,
              ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              child: state.summary == null && state.ratings.isEmpty
                  ? Padding(
                      padding: EdgeInsets.only(top: 80.h),
                      child: Center(
                        child: Column(
                          children: [
                            AppImage(
                              AssetsData.icNoContentSeach,
                              height: 150.h,
                            ),
                            Gap(16.h),
                            Text(
                              context.tr('no_results'),
                              style: Styles.textStyle16.copyWith(
                                color: AppColors.kGreyB3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        RatingsSummarySection(state: state),
                        Gap(20.h),
                        RatingsList(state: state),
                      ],
                    ),
            ),
            if (state.hasMore)
              RatingsLoadMoreButton(advisorId: advisorId, state: state),
            Gap(20.h),
          ],
        ),
      ),
    );
  }
}
