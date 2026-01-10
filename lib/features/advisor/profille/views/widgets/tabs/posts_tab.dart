import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/features/advisor/home/model/post_model.dart';
import 'package:tayseer/features/advisor/home/view_model/home_cubit.dart';
import 'package:tayseer/features/advisor/home/view_model/home_state.dart';
import 'package:tayseer/my_import.dart';

class PostsTab extends StatefulWidget {
  const PostsTab({super.key});

  @override
  State<PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends State<PostsTab> {
  late HomeCubit _homeCubit;

  @override
  void initState() {
    super.initState();
    _homeCubit = context.read<HomeCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        // فلترة المنشورات لعرض منشورات المستخدم الحالي فقط
        // TODO: استبدل "current_user_id" بمعرف المستخدم الفعلي
        final userPosts = state.posts
            .where((post) => post.advisorId == "current_user_id")
            .toList();

        if (userPosts.isEmpty && state.postsState != CubitStates.loading) {
          return const SharedEmptyState(title: "لا توجد منشورات");
        }

        if (state.postsState == CubitStates.loading && userPosts.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.kprimaryColor),
          );
        }

        return RefreshIndicator(
          color: AppColors.kprimaryColor,
          onRefresh: () async {
            await _homeCubit.fetchPosts();
          },
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            itemCount: userPosts.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < userPosts.length) {
                final post = userPosts[index];
                return Column(
                  children: [
                    _buildPostItem(post),
                    if (index < userPosts.length - 1) Gap(16.h),
                  ],
                );
              } else if (state.isLoadingMore) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.kprimaryColor,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  Widget _buildPostItem(PostModel post) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundImage: NetworkImage(post.avatar),
              ),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.name,
                      style: Styles.textStyle14Bold.copyWith(
                        color: AppColors.blackColor,
                      ),
                    ),
                    Gap(4.h),
                    Text(
                      "${post.category} • ${post.timeAgo}",
                      style: Styles.textStyle12.copyWith(
                        color: AppColors.secondary400,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: Colors.grey.shade500),
                onPressed: () {
                  _showPostOptions(post);
                },
              ),
            ],
          ),
          Gap(12.h),

          // Content
          Text(
            post.content,
            style: Styles.textStyle14.copyWith(
              color: AppColors.blackColor,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          // Images Preview (if any)
          if (post.images.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  post.images.first,
                  height: 150.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // Stats
          Gap(12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 18.sp,
                        color: Colors.grey.shade500,
                      ),
                      Gap(4.w),
                      Text(
                        "${post.likesCount}",
                        style: Styles.textStyle12.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  Gap(16.w),
                  Row(
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        size: 18.sp,
                        color: Colors.grey.shade500,
                      ),
                      Gap(4.w),
                      Text(
                        "${post.commentsCount}",
                        style: Styles.textStyle12.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                "مشاهدة المنشور",
                style: Styles.textStyle12.copyWith(
                  color: AppColors.kprimaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPostOptions(PostModel post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Gap(16.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Gap(24.h),
              _buildOptionItem(
                icon: Icons.edit_outlined,
                text: "تعديل المنشور",
                onTap: () {
                  Navigator.pop(context);
                  // TODO: تعديل المنشور
                },
              ),
              _buildOptionItem(
                icon: Icons.delete_outlined,
                text: "حذف المنشور",
                textColor: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(post);
                },
              ),
              _buildOptionItem(
                icon: Icons.share_outlined,
                text: "مشاركة المنشور",
                onTap: () {
                  Navigator.pop(context);
                  // TODO: مشاركة المنشور
                },
              ),
              Gap(32.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String text,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.black),
      title: Text(
        text,
        style: Styles.textStyle14.copyWith(color: textColor ?? Colors.black),
      ),
      onTap: onTap,
    );
  }

  void _showDeleteConfirmation(PostModel post) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            "حذف المنشور",
            style: Styles.textStyle16Bold.copyWith(color: AppColors.blackColor),
            textAlign: TextAlign.center,
          ),
          content: Text(
            "هل أنت متأكد من حذف هذا المنشور؟ لا يمكن التراجع عن هذه الخطوة.",
            style: Styles.textStyle14.copyWith(color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "إلغاء",
                      style: Styles.textStyle14.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: حذف المنشور من API
                      _deletePost(post);
                    },
                    child: Text(
                      "حذف",
                      style: Styles.textStyle14Bold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePost(PostModel post) async {
    try {
      // TODO: تنفيذ حذف المنشور من API
      // await _homeCubit.deletePost(post.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "تم حذف المنشور بنجاح",
            style: Styles.textStyle14.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "حدث خطأ أثناء حذف المنشور",
            style: Styles.textStyle14.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

}
