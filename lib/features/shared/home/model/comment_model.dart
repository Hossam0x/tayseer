// lib/features/advisor/home/model/comment_model.dart

class CommenterModel {
  final String id;
  final String name;
  final String userName;
  final String? avatar;
  final bool isVerified;
  final String userType;

  const CommenterModel({
    required this.id,
    required this.name,
    required this.userName,
    this.avatar,
    required this.isVerified,
    required this.userType,
  });

  factory CommenterModel.fromJson(Map<String, dynamic> json) {
    return CommenterModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      userName: json['userName'] ?? '',
      avatar: json['avatar'],
      isVerified: json['isVerified'] ?? false,
      userType: json['userType'] ?? '',
    );
  }
}
class CommentModel {
  final String id;
  final String comment;
  final int likes;
  final int repliesNumber;
  final String timeAgo;
  final String createdAt;
  final bool isLiked;
  final bool isOwner;
  final CommenterModel commenter;
  final bool isFollowing;
  final List<CommentModel> replies;
  final bool isLoadingReplies;
  final int repliesCurrentPage;
  final int repliesTotalPages;
  
  // ✅ NEW: للتفريق بين الكومنت المؤقت والحقيقي
  final bool isTemp;

  const CommentModel({
    required this.id,
    required this.comment,
    required this.likes,
    required this.repliesNumber,
    required this.timeAgo,
    required this.createdAt,
    required this.isLiked,
    required this.isOwner,
    required this.commenter,
    required this.isFollowing,
    this.replies = const [],
    this.isLoadingReplies = false,
    this.repliesCurrentPage = 0,
    this.repliesTotalPages = 1,
    this.isTemp = false, // ✅ Default = false
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? '',
      comment: json['comment'] ?? '',
      likes: json['likes'] ?? 0,
      repliesNumber: json['repliesNumber'] ?? 0,
      timeAgo: json['timeAgo'] ?? '',
      createdAt: json['createdAt'] ?? '',
      isLiked: json['isLiked'] ?? false,
      isOwner: json['isOwner'] ?? false,
      commenter: CommenterModel.fromJson(json['commenter'] ?? {}),
      isFollowing: json['isFollowing'] ?? false,
      isTemp: false, // اللي جاي من السيرفر مش temp
    );
  }

  // ✅ NEW: Factory لإنشاء كومنت مؤقت
  factory CommentModel.temp({
    required String tempId,
    required String content,
    required CommenterModel commenter,
  }) {
    return CommentModel(
      id: tempId,
      comment: content,
      likes: 0,
      repliesNumber: 0,
      timeAgo: 'الآن',
      createdAt: DateTime.now().toIso8601String(),
      isLiked: false,
      isOwner: true,
      commenter: commenter,
      isFollowing: false,
      isTemp: true, // ✅ هذا كومنت مؤقت
    );
  }

  CommentModel copyWith({
    String? id,
    String? comment,
    int? likes,
    int? repliesNumber,
    String? timeAgo,
    String? createdAt,
    bool? isLiked,
    bool? isOwner,
    CommenterModel? commenter,
    bool? isFollowing,
    List<CommentModel>? replies,
    bool? isLoadingReplies,
    int? repliesCurrentPage,
    int? repliesTotalPages,
    bool? isTemp, // ✅ NEW
  }) {
    return CommentModel(
      id: id ?? this.id,
      comment: comment ?? this.comment,
      likes: likes ?? this.likes,
      repliesNumber: repliesNumber ?? this.repliesNumber,
      timeAgo: timeAgo ?? this.timeAgo,
      createdAt: createdAt ?? this.createdAt,
      isLiked: isLiked ?? this.isLiked,
      isOwner: isOwner ?? this.isOwner,
      commenter: commenter ?? this.commenter,
      isFollowing: isFollowing ?? this.isFollowing,
      replies: replies ?? this.replies,
      isLoadingReplies: isLoadingReplies ?? this.isLoadingReplies,
      repliesCurrentPage: repliesCurrentPage ?? this.repliesCurrentPage,
      repliesTotalPages: repliesTotalPages ?? this.repliesTotalPages,
      isTemp: isTemp ?? this.isTemp, // ✅ NEW
    );
  }

  bool get hasMoreReplies => repliesCurrentPage < repliesTotalPages;
}

// // --- Data Generator (Updated Mock Data) ---
// List<CommentModel> dummyComments = [
//   // 1. كومنت رئيسي طويل مع 3 ردود متفاوتة الطول
//   CommentModel(
//     id: "1",
//     name: "Anna Mary",
//     userName: "@anamert",
//     avatar: "https://i.pravatar.cc/150?img=5",
//     isVerified: true,
//     timeAgo: "منذ يومين",
//     content:
//         "هذا كلام جميل جداً وفي غاية الروعة. بصراحة أنتِ دكتورة شاطرة جداً ومتمكنة من أدواتك. الشرح كان وافي وسلس، وغطى كل الجوانب اللي كنت بدور عليها بقالي فترة. استمري في هذا المحتوى الهادف ❤️👏.",
//     likesCount: 145,
//     isLiked: true,
//     isOwner: true,
//     replies: [
//       // رد 1.1: قصير
//       CommentModel(
//         id: "11",
//         name: "صلاح سعد صلاح حافظ كساب",
//         userName: "@salah_salah",
//         avatar: "https://i.pravatar.cc/150?img=11",
//         isVerified: true,
//         timeAgo: "منذ يوم",
//         content: "فعلاً أتفق معاكي، الدكتورة أسلوبها ممتع جداً.",
//         likesCount: 12,
//         isLiked: false,
//       ),
//       // رد 1.2: متوسط
//       CommentModel(
//         id: "12",
//         name: "سارة محمد",
//         userName: "@sara_m",
//         avatar: "https://i.pravatar.cc/150?img=9",
//         isVerified: false,
//         timeAgo: "منذ 5 ساعات",
//         content:
//             "بالضبط! أنا كنت تايهة في الموضوع ده قبل ما أشوف الفيديو، بس دلوقتي الصورة وضحت تماماً. شكراً ليكي يا دكتورة.",
//         likesCount: 8,
//         isLiked: true,
//       ),
//       // رد 1.3: طويل (نصيحة إضافية)
//       CommentModel(
//         id: "13",
//         name: "كريم محمود",
//         userName: "@karim_m",
//         avatar: "https://i.pravatar.cc/150?img=68",
//         isVerified: false,
//         timeAgo: "منذ ساعتين",
//         content:
//             "عايز أضيف نقطة كمان بعد إذنكم، الجزء الخاص بالتطبيق العملي في الدقيقة الخامسة كان عبقري، وهو ده اللي بيفرق الشرح النظري عن الواقع. يا ريت تكتري من الأمثلة دي في الفيديوهات الجاية.",
//         likesCount: 5,
//         isLiked: false,
//       ),
//     ],
//   ),

//   // 2. سؤال تقني طويل مع رد تفصيلي من الآدمن
//   CommentModel(
//     id: "2",
//     name: "خالد يوسف",
//     userName: "@khaled_yousef",
//     avatar: "https://i.pravatar.cc/150?img=33",
//     isVerified: false,
//     timeAgo: "منذ 4 ساعات",
//     content:
//         "لو سمحتي يا دكتورة، عندي استفسار بخصوص النقطة الثانية. هل لو استخدمنا الطريقة دي مع الأنظمة القديمة هتشتغل بنفس الكفاءة؟ ولا محتاجين نعمل تحديثات معينة الأول؟ لأني جربت قبل كده وواجهت مشاكل في التوافق.",
//     likesCount: 20,
//     isLiked: false,

//     replies: [
//       CommentModel(
//         id: "21",
//         name: "tayseer Admin",
//         userName: "@tayseer_app",
//         avatar: AssetsData.avatarImage, // صورة الآدمن
//         isVerified: true,
//         timeAgo: "الآن",
//         content:
//             "أهلاً بك يا أستاذ خالد. سؤال ممتاز! ✅\nبالنسبة للأنظمة القديمة، يفضل عمل تحديث للـ Libraries الأساسية أولاً لضمان عدم حدوث تعارض. الطريقة المشروحة في الفيديو مخصصة للإصدارات الحديثة (v2.0 وما فوق). هبعتلك رابط في الخاص فيه شرح مفصل لطريقة التحديث.",
//         likesCount: 55,
//         isOwner: true, // رد صاحب البوست
//       ),
//     ],
//   ),

//   // 3. نقد بناء (نص طويل جداً بدون ردود)
//   CommentModel(
//     id: "3",
//     name: "ناقد سينمائي",
//     userName: "@movie_critic",
//     avatar: "https://i.pravatar.cc/150?img=12",
//     isVerified: true,
//     isFollowing: true,
//     timeAgo: "منذ 6 ساعات",
//     content:
//         "الفكرة العامة ممتازة، ولكن عندي تحفظ بسيط على الإضاءة في المشاهد الخارجية. حسيت إنها كانت ساطعة زيادة عن اللزوم وده أثر على وضوح التفاصيل في الخلفية. كمان الانتقال بين المشاهد كان ممكن يكون أنعم من كده. مجرد رأي تقني، لكن المحتوى ككل هايل ومجهود يحترم جداً.",
//     likesCount: 89,
//     isLiked: true,
//     replies: [],
//   ),

//   // 4. نقاش جدلي (Thread)
//   CommentModel(
//     id: "4",
//     name: "مروان بابلو",
//     userName: "@marwan_pablo",
//     avatar: "https://i.pravatar.cc/150?img=59",
//     isVerified: true,
//     timeAgo: "منذ 8 ساعات",
//     content:
//         "مش مقتنع بصراحة، حاسس إن الموضوع واخد أكبر من حجمه، والنتائج دي ممكن نوصلها بطرق أسهل بكتير من غير كل التعقيدات دي.",
//     likesCount: 5,
//     isLiked: false,
//     replies: [
//       CommentModel(
//         id: '41',
//         name: "مهندس برمجيات",
//         userName: "@soft_eng_22",
//         avatar: "https://i.pravatar.cc/150?img=60",
//         isVerified: false,
//         timeAgo: "منذ 7 ساعات",
//         content:
//             "يا صديقي الطرق الأسهل اللي بتتكلم عنها مش بتدي نفس الـ Performance في المشاريع الكبيرة. الحل ده معمول عشان الـ Scalability مش عشان المشاريع الصغيرة.",
//         likesCount: 40,
//         isLiked: true,
//       ),
//       CommentModel(
//         id: "42",
//         name: "مروان بابلو",
//         userName: "@marwan_pablo",
//         avatar: "https://i.pravatar.cc/150?img=59",
//         isVerified: true,
//         timeAgo: "منذ 6 ساعات",
//         content:
//             "وجهة نظر تحترم، بس أنا بتكلم من واقع تجربتي في السوق المحلي، أغلب العملاء مش بيحتاجوا الـ Scale ده.",
//         likesCount: 2,
//         isLiked: false,
//       ),
//     ],
//   ),
// ];
