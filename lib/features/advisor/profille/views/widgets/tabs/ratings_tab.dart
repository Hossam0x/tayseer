import 'package:tayseer/features/advisor/profille/views/cubit/ratings_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/ratings_state.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/tabs/ratings/ratings_add_button.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/tabs/ratings/ratings_error_section.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/tabs/ratings/ratings_list.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/tabs/ratings/ratings_load_more_button.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/tabs/ratings/ratings_skeleton.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/tabs/ratings/ratings_summary_section.dart';
import 'package:tayseer/my_import.dart';

class RatingsTab extends StatefulWidget {
  final String advisorId;
  final bool isMe;

  const RatingsTab({
    super.key,
    required this.advisorId,
    required this.isMe,
  });

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
      child: Column(
        children: [
          if (!isMe && isUser)
            RatingsAddButton(
              advisorId: advisorId,
              reviewController: reviewController,
            ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            child: Column(
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
    );
  }
}
