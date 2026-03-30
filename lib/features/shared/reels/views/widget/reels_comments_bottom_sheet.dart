import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tayseer/core/models/comment_model.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/widgets/comment_card/comment_callbacks.dart';
import 'package:tayseer/core/widgets/comment_card/comment_card.dart';
import 'package:tayseer/features/shared/home/reposiotry/home_repository.dart';
import 'package:tayseer/features/shared/post_details/presentation/manager/post_details_cubit/post_details_cubit.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/widgets/comment_input_area.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/widgets/comments_ui_state.dart';
import 'package:tayseer/my_import.dart';

/// ✅ Callback لمزامنة عدد الكومنتات مع الريلز
typedef OnCommentCountChanged =
    void Function(int newCount, bool isCommented, bool? isAnonymous);

class ReelsCommentsBottomSheet extends StatefulWidget {
  final PostModel post;
  final OnCommentCountChanged? onCommentCountChanged;

  const ReelsCommentsBottomSheet({
    super.key,
    required this.post,
    this.onCommentCountChanged,
  });

  @override
  State<ReelsCommentsBottomSheet> createState() =>
      _ReelsCommentsBottomSheetState();
}

class _ReelsCommentsBottomSheetState extends State<ReelsCommentsBottomSheet> {
  late final PostDetailsCubit _postDetailsCubit;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _commentKeys = {};

  // ═══════════════════════════════════════════════════════════
  // 📌 DELTA TRACKING — لتتبع الإضافات والحذف بدقة
  // ═══════════════════════════════════════════════════════════
  StreamSubscription<PostDetailsState>? _deltaSubscription;
  PostDetailsState? _prevState;
  bool _initialLoadDone = false;
  // ignore: unused_field
  int _baseline = 0;
  int _commentDelta = 0;

  @override
  void initState() {
    super.initState();
    _postDetailsCubit = PostDetailsCubit(
      homeRepository: getIt<HomeRepository>(),
      postId: widget.post.postId,
      isCommented: widget.post.isCommented,
      isAnonymous: widget.post.isAnonymous,
    );

    // ✅ الاشتراك في stream لتتبع الـ delta
    _prevState = _postDetailsCubit.state;
    _deltaSubscription = _postDetailsCubit.stream.listen(_trackCommentDelta);
  }

  /// ✅ تتبع الـ delta بين الإضافات والحذف (مع تجاهل Initial Load والـ Pagination)
  void _trackCommentDelta(PostDetailsState curr) {
    final prev = _prevState;
    _prevState = curr;
    if (prev == null) return;

    final prevNonTemp = prev.comments.where((c) => !c.isTemp).length;
    final currNonTemp = curr.comments.where((c) => !c.isTemp).length;

    // 1️⃣ أول تحميل خلص — سجّل الـ baseline وارجع
    if (!_initialLoadDone && curr.commentsState == CubitStates.success) {
      _initialLoadDone = true;
      _baseline = currNonTemp;
      return;
    }

    if (!_initialLoadDone) return;

    // 2️⃣ Pagination خلصت — حدّث الـ baseline بس (مش تغيير حقيقي)
    if (prev.isLoadingMore && !curr.isLoadingMore) {
      _baseline = currNonTemp;
      return;
    }

    // 3️⃣ تغيير حقيقي (إضافة أو حذف) — مش pagination ومش loading
    if (prevNonTemp != currNonTemp &&
        !curr.isLoadingMore &&
        !prev.isLoadingMore) {
      final localDelta = currNonTemp - prevNonTemp;
      _commentDelta += localDelta;
      _baseline = currNonTemp;

      // ✅ تحديث فوري لعدد الكومنتات في الريلز
      _notifyCountChange();
    }
  }

  /// ✅ إبلاغ الريلز بالعدد الجديد
  void _notifyCountChange() {
    final newCount = (widget.post.commentsCount + _commentDelta).clamp(
      0,
      999999,
    );
    widget.onCommentCountChanged?.call(
      newCount,
      widget.post.isCommented || _commentDelta > 0,
      widget.post.isAnonymous,
    );
  }

  @override
  void dispose() {
    _deltaSubscription?.cancel();

    // ✅ مزامنة نهائية عند الإغلاق
    if (_commentDelta != 0) {
      _notifyCountChange();
    }

    _postDetailsCubit.close();
    _scrollController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 SCROLL TO COMMENT
  // ═══════════════════════════════════════════════════════════

  void _scrollToComment(String commentId, {bool isForReply = false}) async {
    final key = _commentKeys[commentId];
    if (key?.currentContext == null) return;

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted || key!.currentContext == null) return;

    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: 1.0,
    );

    await Future.delayed(const Duration(milliseconds: 350));
    if (mounted && _scrollController.hasClients) {
      final currentOffset = _scrollController.offset;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final targetOffset = (currentOffset + 60).clamp(0.0, maxScroll);
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  GlobalKey _getKeyForComment(String commentId) =>
      _commentKeys.putIfAbsent(commentId, () => GlobalKey());

  // ═══════════════════════════════════════════════════════════
  // 📌 BUILD
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          child: BlocProvider.value(
            value: _postDetailsCubit,
            child: Scaffold(
              backgroundColor: Colors.white,
              resizeToAvoidBottomInset: false,
              body: Column(
                children: [
                  _buildSheetHeader(context),
                  Gap(6.h),
                  Expanded(child: _buildCommentsBody()),
                  const CommentInputArea(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 HEADER
  // ═══════════════════════════════════════════════════════════

  Widget _buildSheetHeader(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag Handle
        Container(
          margin: EdgeInsets.only(top: 10.h, bottom: 6.h),
          width: 40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: Colors.grey[350],
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        // Title Row
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close, color: Colors.black, size: 24.sp),
              ),
              const Spacer(),
              Text(
                context.tr(AppStrings.comments),
                style: Styles.textStyle16.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              SizedBox(width: 24.sp),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 COMMENTS BODY
  // ═══════════════════════════════════════════════════════════

  Widget _buildCommentsBody() {
    return RefreshIndicator(
      color: AppColors.kprimaryColor,
      onRefresh: () async => _postDetailsCubit.loadComments(isRefresh: true),
      child: BlocListener<PostDetailsCubit, PostDetailsState>(
        listenWhen: (prev, curr) =>
            prev.scrollTrigger != curr.scrollTrigger &&
            curr.scrollToCommentId != null,
        listener: (context, state) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToComment(
              state.scrollToCommentId!,
              isForReply: state.activeReplyId == state.scrollToCommentId,
            );
            _postDetailsCubit.clearScrollTarget();
          });
        },
        child:
            BlocSelector<PostDetailsCubit, PostDetailsState, CommentsUIState>(
              selector: _selectCommentsState,
              builder: (context, uiState) {
                final cubit = context.read<PostDetailsCubit>();

                final commentCallbacks = CommentCallbacks(
                  onLike: (comment, isReply) =>
                      cubit.toggleLike(isReply, comment.id),
                  onReplyToggle: cubit.toggleReply,
                  onEditToggle: cubit.toggleEdit,
                  onCancelEdit: cubit.cancelEdit,
                  onCancelReply: cubit.cancelReply,
                  onSaveEdit: (id, content, isReply) => cubit.saveEditedComment(
                    commentId: id,
                    newContent: content,
                    isReply: isReply,
                  ),
                  onHideComment: (commentId) =>
                      cubit.toggleHideComment(commentId: commentId),
                  onHideReply: (replyId) =>
                      cubit.toggleHideReply(replyId: replyId),
                  onSendReply: (parentId, text) =>
                      cubit.addReply(parentId, text),
                  onLoadReplies: cubit.loadReplies,
                  onDeleteReply: (id) => cubit.deleteReply(replyId: id),
                  onDeleteComment: (id) => cubit.deleteComment(commentId: id),
                );

                // Loading
                if (uiState.isLoading && uiState.comments.isEmpty) {
                  return const _CommentsShimmer();
                }

                // Error
                if (uiState.error != null && uiState.comments.isEmpty) {
                  return _ErrorState(
                    message: uiState.error!,
                    onRetry: cubit.loadComments,
                  );
                }

                // Empty
                if (uiState.comments.isEmpty) {
                  return const _EmptyCommentsState();
                }

                // ✅ Comments List
                return CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == uiState.comments.length) {
                              return _PaginationWidget(
                                isLoadingMore: uiState.isLoadingMore,
                                hasMore: uiState.hasMore,
                                onLoadMore: cubit.loadMoreComments,
                              );
                            }

                            final comment = uiState.comments[index];
                            final isLast = index == uiState.comments.length - 1;

                            return Column(
                              children: [
                                Container(
                                  key: _getKeyForComment(comment.id),
                                  child: _CommentItemProxy(
                                    comment: comment,
                                    callbacks: commentCallbacks,
                                    editingCommentId: uiState.editingCommentId,
                                    isReplying:
                                        uiState.activeReplyId == comment.id,
                                    isEditLoading: uiState.isEditLoading,
                                    isReplyLoading:
                                        uiState.activeReplyId == comment.id &&
                                        uiState.isReplyLoading,
                                  ),
                                ),
                                if (!isLast)
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12.h,
                                    ),
                                    child: Divider(
                                      color: Colors.grey.shade200,
                                      height: 1.h,
                                    ),
                                  ),
                              ],
                            );
                          },
                          childCount:
                              uiState.comments.length +
                              (uiState.hasMore || uiState.isLoadingMore
                                  ? 1
                                  : 0),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: Gap(20.h)),
                  ],
                );
              },
            ),
      ),
    );
  }

  CommentsUIState _selectCommentsState(PostDetailsState state) =>
      CommentsUIState(
        comments: state.comments,
        isLoading: state.commentsState == CubitStates.loading,
        hasMore: state.hasMoreComments,
        isLoadingMore: state.isLoadingMore,
        error: state.commentsState == CubitStates.failure
            ? state.errorMessage
            : null,
        editingCommentId: state.editingCommentId,
        activeReplyId: state.activeReplyId,
        isEditLoading: state.editingState == CubitStates.loading,
        isReplyLoading: state.addingReplyState == CubitStates.loading,
      );
}

// ══════════════════════════════════════════════════════════════
// 📌 HELPER WIDGETS
// ══════════════════════════════════════════════════════════════

class _CommentItemProxy extends StatelessWidget {
  final CommentModel comment;
  final CommentCallbacks callbacks;
  final String? editingCommentId;
  final bool isReplying;
  final bool isEditLoading;
  final bool isReplyLoading;

  const _CommentItemProxy({
    required this.comment,
    required this.callbacks,
    this.editingCommentId,
    this.isReplying = false,
    this.isEditLoading = false,
    this.isReplyLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (comment.isTemp) {
      return IgnorePointer(
        ignoring: true,
        child: Opacity(
          opacity: 0.5,
          child: CommentCard(
            comment: comment,
            isReply: false,
            editingCommentId: null,
            isReplying: false,
            isEditLoading: false,
            isReplyLoading: false,
            isLoadingReplies: false,
            callbacks: CommentCallbacks.empty,
          ),
        ),
      );
    }

    return CommentCard(
      comment: comment,
      callbacks: callbacks,
      editingCommentId: editingCommentId,
      isReplying: isReplying,
      isEditLoading: isEditLoading,
      isReplyLoading: isReplyLoading,
      isLoadingReplies: comment.isLoadingReplies,
    );
  }
}

class _PaginationWidget extends StatelessWidget {
  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback onLoadMore;

  const _PaginationWidget({
    required this.isLoadingMore,
    required this.hasMore,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return Padding(
        padding: EdgeInsets.all(16.h),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (hasMore) {
      return TextButton(
        onPressed: onLoadMore,
        child: Text(
          context.tr(AppStrings.loadMore),
          style: Styles.textStyle14SemiBold,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

// ══════════════════════════════════════════════════════════════
// 📌 STATE WIDGETS
// ══════════════════════════════════════════════════════════════

class _EmptyCommentsState extends StatelessWidget {
  const _EmptyCommentsState();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppImage(AssetsData.noCommentsIcon, height: 130.h),
              Gap(20.h),
              Text(
                context.tr(AppStrings.noComments),
                style: Styles.textStyle14.copyWith(color: AppColors.kGreyB3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
          Gap(10.h),
          TextButton(
            onPressed: onRetry,
            child: Text(
              context.tr(AppStrings.retry),
              style: Styles.textStyle14SemiBold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentsShimmer extends StatelessWidget {
  const _CommentsShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                Gap(10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120.w,
                        height: 14.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      Gap(8.h),
                      Container(
                        width: double.infinity,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      Gap(6.h),
                      Container(
                        width: 200.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
