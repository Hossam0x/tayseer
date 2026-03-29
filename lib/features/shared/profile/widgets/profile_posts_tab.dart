import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/core/widgets/post_card/post_shimmer.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/features/shared/home/views/widgets/home_post_feed.dart'
    as home_feed;
import 'package:tayseer/features/shared/post_details/presentation/views/post_details_view.dart';
import 'package:tayseer/my_import.dart';

// ─────────────────────────────────────────────────────────────
// Contract — any cubit driving a profile posts tab implements this.
// Getters delegate to state so the widget reads from the cubit directly.
// ─────────────────────────────────────────────────────────────
abstract class ProfilePostsCubitContract<S> extends Cubit<S> {
  ProfilePostsCubitContract(super.initialState);

  // State accessors (implemented as getters delegating to `state`)
  List<PostModel> get posts;
  CubitStates get postsState;
  String? get postsErrorMessage;
  bool get hasMore;
  bool get isLoadingMore;

  CubitStates get shareActionState;
  String? get shareMessage;
  bool? get isShareAdded;

  CubitStates get saveActionState;
  String? get saveMessage;

  CubitStates get deletePostActionState;
  String? get deletePostMessage;

  CubitStates get archivePostActionState;
  String? get archivePostMessage;

  CubitStates get blockUserActionState;
  String? get blockUserMessage;

  // Actions
  void reactToPost({required String postId, ReactionType? reactionType});
  Future<void> toggleSharePost({required String postId});
  Future<void> toggleSavePost({required String postId});
  void deletePost({required String postId});
  void toggleHidePost({required String postId});
  void archivePost({required String postId});
  Future<void> blockUser({String? visiblePostId, required String advisorId});
  Future<void> fetchPosts({bool loadMore = false});
  void updatePostLocally(PostModel updatedPost);
}

// ─────────────────────────────────────────────────────────────
// Shared posts tab — generic over the cubit type C.
// Reads data from cubit getters, NOT from the raw state cast.
// ─────────────────────────────────────────────────────────────
class ProfilePostsTab<C extends ProfilePostsCubitContract>
    extends StatelessWidget {
  final String heroPrefix;

  const ProfilePostsTab({super.key, required this.heroPrefix});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<C>();

    return MultiBlocListener(
      listeners: [
        BlocListener<C, dynamic>(
          listenWhen: (_, __) => cubit.shareActionState != CubitStates.initial,
          listener: (context, _) {
            switch (cubit.shareActionState) {
              case CubitStates.success:
                cubit.isShareAdded == true
                    ? AppToast.success(
                        context,
                        cubit.shareMessage ?? context.tr('shared_success'),
                      )
                    : AppToast.info(
                        context,
                        cubit.shareMessage ?? context.tr('unshared_success'),
                      );
                break;
              case CubitStates.failure:
                AppToast.error(
                  context,
                  cubit.shareMessage ?? context.tr('shared_error'),
                );
                break;
              default:
                break;
            }
          },
        ),
        BlocListener<C, dynamic>(
          listenWhen: (_, __) => cubit.saveActionState != CubitStates.initial,
          listener: (context, _) {
            if (cubit.saveActionState == CubitStates.success) {
              AppToast.success(
                context,
                cubit.saveMessage ?? context.tr('saved_success'),
              );
            } else if (cubit.saveActionState == CubitStates.failure) {
              AppToast.error(
                context,
                cubit.saveMessage ?? context.tr('save_error'),
              );
            }
          },
        ),
        BlocListener<C, dynamic>(
          listenWhen: (_, __) =>
              cubit.deletePostActionState != CubitStates.initial,
          listener: (context, _) {
            if (cubit.deletePostActionState == CubitStates.success) {
              AppToast.success(
                context,
                cubit.deletePostMessage ?? context.tr('delete_success'),
              );
            } else if (cubit.deletePostActionState == CubitStates.failure) {
              AppToast.error(
                context,
                cubit.deletePostMessage ?? context.tr('delete_error'),
              );
            }
          },
        ),
        BlocListener<C, dynamic>(
          listenWhen: (_, __) =>
              cubit.archivePostActionState != CubitStates.initial,
          listener: (context, _) {
            if (cubit.archivePostActionState == CubitStates.success) {
              AppToast.success(
                context,
                cubit.archivePostMessage ?? context.tr('archive_success'),
              );
            } else if (cubit.archivePostActionState == CubitStates.failure) {
              AppToast.error(
                context,
                cubit.archivePostMessage ?? context.tr('archive_error'),
              );
            }
          },
        ),
        BlocListener<C, dynamic>(
          listenWhen: (_, __) =>
              cubit.blockUserActionState != CubitStates.initial,
          listener: (context, _) {
            switch (cubit.blockUserActionState) {
              case CubitStates.loading:
                CustomloadingApp.show(context);
                break;
              case CubitStates.success:
                CustomloadingApp.hide(context);
                AppToast.success(
                  context,
                  cubit.blockUserMessage ?? context.tr('blocked_successfully'),
                );
                break;
              case CubitStates.failure:
                CustomloadingApp.hide(context);
                AppToast.error(
                  context,
                  cubit.blockUserMessage ?? context.tr('failed_to_block'),
                );
                break;
              default:
                break;
            }
          },
        ),
      ],
      child: BlocBuilder<C, dynamic>(
        buildWhen: (_, __) => true, // cubit getters always reflect latest state
        builder: (context, _) {
          // Read from cubit getters — never cast the state object
          if (cubit.postsState == CubitStates.loading && cubit.posts.isEmpty) {
            return _buildShimmer();
          }
          if (cubit.postsState == CubitStates.failure && cubit.posts.isEmpty) {
            return CustomErrorView(
              message: cubit.postsErrorMessage,
              onRetry: () => cubit.fetchPosts(),
            );
          }
          if (cubit.posts.isEmpty) {
            return Padding(
              padding: EdgeInsets.only(top: 100.h),
              child: SharedEmptyState(title: context.tr('no_posts_yet')),
            );
          }

          return RefreshIndicator(
            color: AppColors.kprimaryColor,
            onRefresh: () => cubit.fetchPosts(),
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  itemCount: cubit.posts.length,
                  itemBuilder: (context, index) {
                    return ProfilePostItem<C>(
                      key: ValueKey(cubit.posts[index].postId),
                      postId: cubit.posts[index].postId,
                      cubit: cubit,
                      heroPrefix: heroPrefix,
                      showGap: index < cubit.posts.length - 1,
                    );
                  },
                ),
                if (cubit.hasMore)
                  _buildLoadMore(context, cubit)
                else if (cubit.posts.isNotEmpty)
                  const home_feed.EndOfFeedIndicator(),
                Gap(40.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmer() => ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: EdgeInsets.symmetric(vertical: 16.h),
    itemCount: 3,
    itemBuilder: (_, i) =>
        Column(children: [const PostCardShimmer(), if (i < 2) Gap(16.h)]),
  );

  Widget _buildLoadMore(BuildContext context, C cubit) {
    if (cubit.isLoadingMore) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (_, i) =>
            Column(children: [const PostCardShimmer(), if (i < 2) Gap(16.h)]),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => cubit.fetchPosts(loadMore: true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.kWhiteColor,
            foregroundColor: AppColors.kprimaryColor,
            side: BorderSide(color: AppColors.kprimaryColor, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            padding: EdgeInsets.symmetric(vertical: 12.h),
            elevation: 0,
          ),
          child: Text(
            context.tr('load_more_posts'),
            style: Styles.textStyle14Meduim.copyWith(
              color: AppColors.kprimaryColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shared post item — streams updates directly from the cubit
// ─────────────────────────────────────────────────────────────
class ProfilePostItem<C extends ProfilePostsCubitContract>
    extends StatefulWidget {
  final String postId;
  final C cubit;
  final String heroPrefix;
  final bool showGap;

  const ProfilePostItem({
    super.key,
    required this.postId,
    required this.cubit,
    required this.heroPrefix,
    this.showGap = false,
  });

  @override
  State<ProfilePostItem<C>> createState() => _ProfilePostItemState<C>();
}

class _ProfilePostItemState<C extends ProfilePostsCubitContract>
    extends State<ProfilePostItem<C>>
    with AutomaticKeepAliveClientMixin {
  late final Stream<PostModel?> _postStream;
  late final PostCallbacks _callbacks;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // Stream the specific post from the cubit's post list
    _postStream = widget.cubit.stream
        .map(
          (_) => widget.cubit.posts
              .where((p) => p.postId == widget.postId)
              .firstOrNull,
        )
        .distinct();

    _callbacks = PostCallbacks(
      postUpdatesStream: _postStream,
      onReactionChanged: (id, type) =>
          widget.cubit.reactToPost(postId: id, reactionType: type),
      onShareTap: (id) => widget.cubit.toggleSharePost(postId: id),
      onHashtagTap: _onHashtagTap,
      onSave: (id) => widget.cubit.toggleSavePost(postId: id),
      onDelete: (id) => widget.cubit.deletePost(postId: id),
      onHide: (id) => widget.cubit.toggleHidePost(postId: id),
      onBlock: (postId, userId) =>
          widget.cubit.blockUser(visiblePostId: postId, advisorId: userId),
      onArchive: (id) => widget.cubit.archivePost(postId: id),
      onEdit: _onEdit,
    );
  }

  void _onEdit(PostModel post) {
    // الـ post_options_bottom_sheet بيهاندل الـ navigation لـ kUpdatePostView
    // وبيستدعي onEdit بعد ما يرجع الـ result — مش محتاجين نعمل حاجة هنا
    widget.cubit.updatePostLocally(post);
  }

  void _onHashtagTap(String hashtag) {
    final clean = hashtag.startsWith('#') ? hashtag.substring(1) : hashtag;
    context.pushNamed(
      AppRouter.kAdvisorSearchView,
      arguments: {'query': clean, 'tab': 'posts'},
    );
  }

  void _onNavigateToDetails(
    BuildContext ctx,
    PostModel post,
    VideoPlayerController? controller,
  ) {
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => PostDetailsView(
          isFromProfile: true,
          heroPrefix: widget.heroPrefix,
          post: post,
          cachedController: controller,
          callbacks: _callbacks,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        // Use BlocSelector to rebuild only when this specific post changes
        BlocSelector<C, dynamic, PostModel?>(
          selector: (_) => widget.cubit.posts
              .where((p) => p.postId == widget.postId)
              .firstOrNull,
          builder: (context, post) {
            if (post == null) return const SizedBox.shrink();
            return PostCard(
              isFromProfile: true,
              heroPrefix: widget.heroPrefix,
              post: post,
              callbacks: _callbacks,
              onNavigateToDetails: _onNavigateToDetails,
            );
          },
        ),
        if (widget.showGap) Gap(16.h),
      ],
    );
  }
}
