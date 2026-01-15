import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/features/shared/home/model/post_model.dart';
import 'package:tayseer/my_import.dart';

class PostsTabView extends StatelessWidget {
  const PostsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    // قائمة الـ dummy posts من ملف post_model.dart
    final posts = dummyPosts;

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];

        return PostCard(post: post, key: ValueKey(post.postId));
      },
    );
  }
}

class PostCardUI extends StatelessWidget {
  final PostModel post;
  final bool isDetailsView;
  final Widget repostHeader;
  final Widget userInfoHeader;
  final Widget contentText;
  final Widget postMedia;
  final Widget postStats;
  final Widget postActions;
  final VoidCallback? onCardTap;
  final EdgeInsetsGeometry? padding;

  const PostCardUI({
    super.key,
    required this.post,
    this.isDetailsView = false,
    required this.repostHeader,
    required this.userInfoHeader,
    required this.contentText,
    required this.postMedia,
    required this.postStats,
    required this.postActions,
    this.onCardTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardTap,
      child: Container(
        padding:
            padding ??
            EdgeInsets.symmetric(
              vertical: context.responsiveHeight(14),
              horizontal: context.responsiveWidth(10),
            ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: isDetailsView
              ? BorderRadius.zero
              : BorderRadius.circular(15.r),
          border: isDetailsView
              ? null
              : Border.all(color: Colors.grey.shade200),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.repostedBy != null) ...[
              repostHeader,
              Gap(context.responsiveHeight(8)),
            ],
            userInfoHeader,
            Gap(context.responsiveHeight(15)),
            contentText,
            Gap(context.responsiveHeight(12)),
            postMedia,
            Gap(context.responsiveHeight(15)),
            postStats,
            Gap(context.responsiveHeight(8)),
            postActions,
          ],
        ),
      ),
    );
  }
}

// --- Data Generator (Mock Backend) ---
List<PostModel> dummyPosts = [
  // 1.
  PostModel(
    name: "Tech Reviewer",
    userName: "@tech_guru_99",
    isFollowing: true,
    avatar: AssetsData.avatarImage,
    isVerified: true,
    category: "Technology",
    timeAgo: "1 hour ago",
    content:
        "Finally upgraded my workspace! 🖥️✨\n\nI've been planning this overhaul for months. Switched to a dual monitor setup...",
    images: [
      "https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=600&q=80",
      "https://images.unsplash.com/photo-1504639725590-34d0984388bd?auto=format&fit=crop&w=600&q=80",
      "https://images.unsplash.com/photo-1585565804112-f201f68c48b4?auto=format&fit=crop&w=600&q=80",
    ],
    contentType: PostContentType.post, // ✅
    commentsCount: 89,
    sharesCount: 12,
    likesCount: 560,
    topReactions: [ReactionType.care, ReactionType.love],
    myReaction: null,
    repostedBy: "أحمد علي",
    postId: '1',
    advisorId: '',
  ),

  // 2.
  PostModel(
    name: "كرتون زمان",
    userName: "@old_school_toons",
    isFollowing: false,
    avatar: AssetsData.avatarImage,
    isVerified: false,
    category: "ترفيه",
    timeAgo: "منذ ساعتين",
    content:
        "لما تصحى من النوم وتلاقي البيت كله مقلوب 😂🐇\n\nبجد  كرتون زمان يا جماعة الفيديو ده بيمثل حالتي...",
    contentType: PostContentType.video,
    videoUrl:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    commentsCount: 1200,
    sharesCount: 500,
    likesCount: 10500,
    topReactions: [ReactionType.care, ReactionType.love],
    myReaction: null,
    repostedBy: null,
    postId: '2',
    advisorId: '',
  ),

  // 3.
  PostModel(
    name: "قرآن",
    userName: "@old_school_toons",
    isFollowing: false,
    avatar: AssetsData.avatarImage,
    isVerified: false,
    category: ".",
    timeAgo: "منذ ساعتين",
    content: ".",
    contentType: PostContentType.reel,
    videoUrl:
        "https://tayseer-app.com/uploads/post/6947e98df9f8bce3bf355fc0/1766931632045-963800153-video_2025-12-28_16-17-55.mp4",
    commentsCount: 1200,
    sharesCount: 500,
    likesCount: 10500,
    topReactions: [ReactionType.dislike, ReactionType.love],
    myReaction: null,
    repostedBy: null,
    postId: '3',
    advisorId: '',
  ),
];
