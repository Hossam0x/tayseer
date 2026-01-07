import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/features/advisor/home/model/post_model.dart';
import 'package:tayseer/features/advisor/home/view_model/home_cubit.dart';
import 'package:tayseer/features/advisor/home/view_model/home_state.dart';
import 'package:tayseer/features/advisor/home/view_model/post_details_cubit/post_details_cubit.dart';
import 'package:tayseer/features/advisor/home/views/widgets/comment_input_area.dart';
import 'package:tayseer/features/advisor/home/views/widgets/comment_item_widget.dart';
import 'package:tayseer/my_import.dart';

class PostDetailsView extends StatelessWidget {
  final PostModel post;
  final VideoPlayerController? cachedController;
  final HomeCubit homeCubit;
  const PostDetailsView({
    super.key,
    required this.post,
    this.cachedController,
    required this.homeCubit,
  });

  @override
  Widget build(BuildContext context) {
    var blocBuilder = BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        // البحث عن البوست المحدث في الـ state
        PostModel updatedPost = post;

        final foundPost = state.posts.firstWhere(
          (p) => p.postId == post.postId,
          orElse: () => post,
        );
        updatedPost = foundPost;

        return PostCard(
          post: updatedPost,
          isDetailsView: true,
          sharedController: cachedController,
        );
      },
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<PostDetailsCubit>()),
        BlocProvider.value(value: homeCubit),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            post.name,
            style: Styles.textStyle16.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: blocBuilder),
                  SliverToBoxAdapter(child: Gap(10.h)),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    sliver: BlocBuilder<PostDetailsCubit, PostDetailsState>(
                      buildWhen: (previous, current) {
                        if (previous is PostDetailsLoaded &&
                            current is PostDetailsLoaded) {
                          return previous.comments != current.comments;
                        }
                        return true;
                      },
                      builder: (context, state) {
                        if (state is PostDetailsLoaded) {
                          return SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final comment = state.comments[index];
                              return Column(
                                children: [
                                  CommentItemWidget(comment: comment),
                                  if (index != state.comments.length - 1)
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
                            }, childCount: state.comments.length),
                          );
                        }
                        return const SliverToBoxAdapter(
                          child: SizedBox.shrink(),
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(child: Gap(20.h)),
                ],
              ),
            ),
            const CommentInputArea(),
          ],
        ),
      ),
    );
  }
}
