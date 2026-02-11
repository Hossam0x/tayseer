import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/features/advisor/event/model/my_event_model.dart';

// --- Enums ---
enum ReactionType { love, care, dislike }

enum PostContentType { post, event, reel, poll }

// --- Helper Functions ---
String getReactionAsset(ReactionType type) {
  switch (type) {
    case ReactionType.love:
      return AssetsData.loveIcon;
    case ReactionType.care:
      return AssetsData.careIcon;
    case ReactionType.dislike:
      return AssetsData.disLikeIcon;
  }
}

// ✅ تحويل String إلى ReactionType
ReactionType? _parseReactionType(String? value) {
  if (value == null) return null;
  switch (value.toLowerCase()) {
    case 'love':
      return ReactionType.love;
    case 'care':
      return ReactionType.care;
    case 'dislike':
      return ReactionType.dislike;
    default:
      return null;
  }
}

// ✅ تحويل String إلى PostContentType
PostContentType _parseContentType(String? value) {
  switch (value?.toLowerCase()) {
    case 'poll':
      return PostContentType.poll;
    case 'reel':
      return PostContentType.reel;
    case 'post':
      return PostContentType.post;
    case 'event':
      return PostContentType.event;
    default:
      return PostContentType.post;
  }
}

// --- Post Model ---
class PostModel {
  // ✅ Spelling corrected: isHidden
  final bool isHidden;
  final String postId;
  final String name;
  final String userName;
  final String advisorId;
  final bool isFollowing;
  final String avatar;
  final bool isVerified;
  final String category;
  final String timeAgo;
  final String content;

  final PostContentType contentType;
  // Media Fields
  final List<ImageModel> images;
  final String? videoUrl;
  final PollModel? pollModel;
  final EventModel? event;

  // Stats
  final int commentsCount;
  final int sharesCount;
  final int likesCount;
  final List<ReactionType> topReactions;

  // User Interaction
  final ReactionType? myReaction;
  final bool isRepostedByMe;
  final String? repostedBy;

  // local
  final bool isSaved;
  final bool isMine;
  final bool isBlocked;

  PostModel({
    required this.postId,
    required this.name,
    required this.userName,
    required this.advisorId,
    required this.isFollowing,
    required this.avatar,
    this.isVerified = false,
    required this.category,
    required this.timeAgo,
    required this.content,
    this.images = const [],
    this.contentType = PostContentType.post,
    this.videoUrl,
    this.pollModel,
    required this.commentsCount,
    required this.sharesCount,
    required this.likesCount,
    required this.topReactions,
    this.myReaction,
    this.repostedBy,
    this.isRepostedByMe = false,
    this.isSaved = false,
    this.isMine = false,
    this.isHidden = false,
    this.isBlocked = false,
    this.event,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      userName: json['userName'] ?? '',
      postId: json['id'] ?? '',
      name: json['name'] ?? '',
      advisorId: json['advisorId'] ?? '',
      isFollowing: json['isFollowing'] ?? false,
      avatar: json['avatar'] ?? '',
      isVerified: json['isVerified'] ?? false,
      category: json['category'] ?? '',
      timeAgo: json['timeAgo'] ?? '',
      content: json['content'] ?? '',
      images:
          (json['images'] as List<dynamic>?)
              ?.map(
                (e) => ImageModel(
                  image: e['image'] ?? '',
                  width: e['width'] ?? 0,
                  height: e['height'] ?? 0,
                ),
              )
              .toList() ??
          [],
      contentType: _parseContentType(json['contentType']),
      videoUrl: json['videoUrl'],
      pollModel: json["pollModel"] != null
          ? PollModel.fromJson(
              json["pollModel"],
              totalPollVotes: json["totalPollVotes"] ?? 0,
            )
          : null,

      event: json['event'] != null ? EventModel.fromJson(json['event']) : null,
      commentsCount: json['commentsCount'] ?? 0,
      sharesCount: json['sharesCount'] ?? 0,
      likesCount: json['likesCount'] ?? 0,
      topReactions:
          (json['topReactions'] as List<dynamic>?)
              ?.map((e) => _parseReactionType(e.toString()))
              .whereType<ReactionType>()
              .toList() ??
          [],
      myReaction: _parseReactionType(json['myReaction']),
      isRepostedByMe: json['isRepostedByMe'] ?? false,
      repostedBy: json['repostedBy'],
      isSaved: json['isSaved'] ?? false,
      isMine: json['isMine'] ?? false,
    );
  }

  // Helper Getters
  bool get hasNoReactions => likesCount == 0 && topReactions.isEmpty;
  bool get hasReactions => likesCount > 0 || topReactions.isNotEmpty;
  bool get hasImages => images.isNotEmpty;
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  bool get isReel => contentType == PostContentType.reel;

  PostModel copyWith({
    String? postId,
    String? name,
    String? advisorId,
    bool? isFollowing,
    String? avatar,
    bool? isVerified,
    String? category,
    String? timeAgo,
    String? content,
    List<ImageModel>? images,
    PostContentType? contentType,
    String? videoUrl,
    PollModel? pollModel,
    int? commentsCount,
    int? sharesCount,
    int? likesCount,
    List<ReactionType>? topReactions,
    ReactionType? myReaction,
    bool clearMyReaction = false,
    bool? isRepostedByMe,
    String? repostedBy,
    bool? isSaved,
    String? userName,
    bool? isMine,
    bool? isHidden,
    bool? isBlocked,
    EventModel? event,
  }) {
    return PostModel(
      postId: postId ?? this.postId,
      name: name ?? this.name,
      advisorId: advisorId ?? this.advisorId,
      isFollowing: isFollowing ?? this.isFollowing,
      avatar: avatar ?? this.avatar,
      isVerified: isVerified ?? this.isVerified,
      category: category ?? this.category,
      timeAgo: timeAgo ?? this.timeAgo,
      content: content ?? this.content,
      images: images ?? this.images,
      contentType: contentType ?? this.contentType,
      videoUrl: videoUrl ?? this.videoUrl,
      pollModel: pollModel ?? this.pollModel,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      likesCount: likesCount ?? this.likesCount,
      topReactions: topReactions ?? this.topReactions,
      myReaction: clearMyReaction ? null : (myReaction ?? this.myReaction),
      isRepostedByMe: isRepostedByMe ?? this.isRepostedByMe,
      repostedBy: repostedBy ?? this.repostedBy,
      isSaved: isSaved ?? this.isSaved,
      userName: userName ?? this.userName,
      isMine: isMine ?? this.isMine,
      isHidden: isHidden ?? this.isHidden,
      isBlocked: isBlocked ?? this.isBlocked,
      event: event ?? this.event,
    );
  }
}

class PollModel {
  final List<PollChoice> pollChoices;
  final int totalPollVotes;

  PollModel({this.pollChoices = const [], this.totalPollVotes = 0});

  factory PollModel.fromJson(
    Map<String, dynamic> json, {
    int totalPollVotes = 0,
  }) {
    final choices =
        (json['pollChoices'] as List<dynamic>?)
            ?.map((e) => PollChoice.fromJson(e))
            .toList() ??
        [];
    // totalPollVotes بييجي من الـ post level مش من جوه pollModel
    final serverTotal = totalPollVotes > 0
        ? totalPollVotes
        : (json['totalPollVotes'] ?? 0);
    // لو لسه 0، نحسبه من مجموع الأصوات
    final calculatedTotal = serverTotal > 0
        ? serverTotal
        : choices.fold<int>(0, (sum, c) => sum + c.votes);

    return PollModel(pollChoices: choices, totalPollVotes: calculatedTotal);
  }

  PollModel copyWith({List<PollChoice>? pollChoices, int? totalPollVotes}) {
    return PollModel(
      pollChoices: pollChoices ?? this.pollChoices,
      totalPollVotes: totalPollVotes ?? this.totalPollVotes,
    );
  }
}

class PollChoice {
  final String choice;
  final int votes;
  final int percentage;
  final bool isSelected;
  final List<String> votersAvatars;

  PollChoice({
    required this.choice,
    required this.votes,
    required this.percentage,
    this.votersAvatars = const [],

    this.isSelected = false,
  });

  factory PollChoice.fromJson(Map<String, dynamic> json) {
    return PollChoice(
      choice: json['choice'] ?? '',
      percentage: json['percentage'] ?? 0,
      votes: json['votes'] ?? 0,
      votersAvatars:
          (json['voters'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isSelected: json['isSelectedByMe'] ?? false,
    );
  }

  PollChoice copyWith({
    String? choice,
    int? votes,
    int? percentage,
    bool? isSelected,
    List<String>? votersAvatars,
  }) {
    return PollChoice(
      choice: choice ?? this.choice,
      votes: votes ?? this.votes,
      percentage: percentage ?? this.percentage,
      isSelected: isSelected ?? this.isSelected,
      votersAvatars: votersAvatars ?? this.votersAvatars,
    );
  }
}

class ImageModel {
  final String image;
  final int width;
  final int height;
  double get aspectRatio => width / height;

  ImageModel({required this.image, required this.width, required this.height});
}

// // --- Data Generator (Mock Backend) ---
// List<PostModel> dummyPosts = [
//   // 1.
//   PostModel(
//     id: "1",
//     name: "Tech Reviewer",
//     userName: "@tech_guru_99",
//     isFollowing: true,
//     avatar: AssetsData.avatarImage,
//     isVerified: true,
//     category: "Technology",
//     timeAgo: "1 hour ago",
//     content:
//         "Finally upgraded my workspace! 🖥️✨\n\nI've been planning this overhaul for months. Switched to a dual monitor setup...",
//     images: [
//       "https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=600&q=80",
//       "https://images.unsplash.com/photo-1504639725590-34d0984388bd?auto=format&fit=crop&w=600&q=80",
//       "https://images.unsplash.com/photo-1585565804112-f201f68c48b4?auto=format&fit=crop&w=600&q=80",
//     ],
//     contentType: PostContentType.post, // ✅
//     commentsCount: 89,
//     sharesCount: 12,
//     likesCount: 560,
//     topReactions: [ReactionType.care, ReactionType.love],
//     myReaction: null,
//     repostedBy: "أحمد علي",
//   ),

//   // 2.
//   PostModel(
//     id: "2",
//     name: "كرتون زمان",
//     userName: "@old_school_toons",
//     isFollowing: false,
//     avatar: AssetsData.avatarImage,
//     isVerified: false,
//     category: "ترفيه",
//     timeAgo: "منذ ساعتين",
//     content:
//         "لما تصحى من النوم وتلاقي البيت كله مقلوب 😂🐇\n\nبجد  كرتون زمان يا جماعة الفيديو ده بيمثل حالتي...",
//     contentType: PostContentType.video,
//     videoUrl:
//         'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
//     commentsCount: 1200,
//     sharesCount: 500,
//     likesCount: 10500,
//     topReactions: [ReactionType.care, ReactionType.love],
//     myReaction: null,
//     repostedBy: null,
//   ),

//   // 3.
//   PostModel(
//     id: "3",
//     name: "قرآن",
//     userName: "@old_school_toons",
//     isFollowing: false,
//     avatar: AssetsData.avatarImage,
//     isVerified: false,
//     category: ".",
//     timeAgo: "منذ ساعتين",
//     content: ".",
//     contentType: PostContentType.reel,
//     videoUrl:
//         "https://tayseer-app.com/uploads/post/6947e98df9f8bce3bf355fc0/1766931632045-963800153-video_2025-12-28_16-17-55.mp4",
//     commentsCount: 1200,
//     sharesCount: 500,
//     likesCount: 10500,
//     topReactions: [ReactionType.dislike, ReactionType.love],
//     myReaction: null,
//     repostedBy: null,
//   ),

//   // 4.
//   PostModel(
//     id: "4",
//     name: "Modern Home",
//     userName: "@minima_list_design",
//     isFollowing: true,
//     avatar: AssetsData.avatarImage,
//     isVerified: true,
//     category: "Design",
//     timeAgo: "3 hours ago",
//     content:
//         "Minimalism is not about having less. It's about making room for more of what matters.\n#Architecture #InteriorDesign #Home",
//     images: [
//       "https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?auto=format&fit=crop&w=600&q=80",
//     ],
//     contentType: PostContentType.post, // ✅
//     commentsCount: 45,
//     sharesCount: 10,
//     likesCount: 300,
//     topReactions: [ReactionType.love],
//     myReaction: ReactionType.care,
//     repostedBy: "سارة محمد",
//   ),

//   // 5. ✅ مثال على بوست بدون تفاعلات
//   PostModel(
//     id: "5",
//     name: "New User",
//     userName: "@new_user_test",
//     isFollowing: false,
//     avatar: AssetsData.avatarImage,
//     isVerified: false,
//     category: "Test",
//     timeAgo: "Just now",
//     content: "هذا بوست جديد بدون أي تفاعلات!",
//     images: [],
//     contentType: PostContentType.post,
//     commentsCount: 0,
//     sharesCount: 0,
//     likesCount: 0, // ✅ صفر
//     topReactions: [], // ✅ فاضية
//     myReaction: null,
//     repostedBy: null,
//   ),

//   // 6.
//   PostModel(
//     id: "6",
//     name: "نادي السينما",
//     userName: "@cinema_club_eg",
//     isFollowing: false,
//     avatar: AssetsData.avatarImage,
//     isVerified: true,
//     category: "أفلام",
//     timeAgo: "أمس",
//     content:
//         "مشهد خيالي يوضح تطور الـ CGI في السنوات الأخيرة.. مذهل! 🤖🔥\n#سينما #تكنولوجيا #أفلام #SciFi",
//     contentType: PostContentType.reel,
//     videoUrl:
//         'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
//     commentsCount: 230,
//     sharesCount: 45,
//     likesCount: 1800,
//     topReactions: [ReactionType.dislike, ReactionType.love, ReactionType.care],
//     myReaction: null,
//     repostedBy: null,
//   ),

//   // ... باقي البوستات
// ];
