import 'package:tayseer/core/utils/assets.dart';

class CommentModel {
  final String id;
  final String name;
  final String userName;
  final String avatar;
  final bool isVerified;
  final String content;
  final String timeAgo;
  final int likesCount;
  final bool isLiked;
  final bool isOwner; // هل هذا التعليق يخصني؟
  final bool isFollowing; // هل أتابع صاحب التعليق؟

  // ✅ قائمة الردود (Nested Comments)
  final List<CommentModel> replies;

  CommentModel({
    required this.id,
    required this.name,
    required this.userName,
    required this.avatar,
    this.isVerified = false,
    required this.content,
    required this.timeAgo,
    this.likesCount = 0,
    this.isLiked = false,
    this.isOwner = false,
    this.replies = const [],
    this.isFollowing = false,
  });
}

// --- Data Generator (Updated Mock Data) ---
List<CommentModel> dummyComments = [
  // 1. كومنت رئيسي طويل مع 3 ردود متفاوتة الطول
  CommentModel(
    id: "1",
    name: "Anna Mary",
    userName: "@anamert",
    avatar: "https://i.pravatar.cc/150?img=5",
    isVerified: true,
    timeAgo: "منذ يومين",
    content:
        "هذا كلام جميل جداً وفي غاية الروعة. بصراحة أنتِ دكتورة شاطرة جداً ومتمكنة من أدواتك. الشرح كان وافي وسلس، وغطى كل الجوانب اللي كنت بدور عليها بقالي فترة. استمري في هذا المحتوى الهادف ❤️👏.",
    likesCount: 145,
    isLiked: true,
    isOwner: true,
    replies: [
      // رد 1.1: قصير
      CommentModel(
        id: "11",
        name: "صلاح سعد صلاح حافظ كساب",
        userName: "@salah_salah",
        avatar: "https://i.pravatar.cc/150?img=11",
        isVerified: true,
        timeAgo: "منذ يوم",
        content: "فعلاً أتفق معاكي، الدكتورة أسلوبها ممتع جداً.",
        likesCount: 12,
        isLiked: false,
      ),
      // رد 1.2: متوسط
      CommentModel(
        id: "12",
        name: "سارة محمد",
        userName: "@sara_m",
        avatar: "https://i.pravatar.cc/150?img=9",
        isVerified: false,
        timeAgo: "منذ 5 ساعات",
        content:
            "بالضبط! أنا كنت تايهة في الموضوع ده قبل ما أشوف الفيديو، بس دلوقتي الصورة وضحت تماماً. شكراً ليكي يا دكتورة.",
        likesCount: 8,
        isLiked: true,
      ),
      // رد 1.3: طويل (نصيحة إضافية)
      CommentModel(
        id: "13",
        name: "كريم محمود",
        userName: "@karim_m",
        avatar: "https://i.pravatar.cc/150?img=68",
        isVerified: false,
        timeAgo: "منذ ساعتين",
        content:
            "عايز أضيف نقطة كمان بعد إذنكم، الجزء الخاص بالتطبيق العملي في الدقيقة الخامسة كان عبقري، وهو ده اللي بيفرق الشرح النظري عن الواقع. يا ريت تكتري من الأمثلة دي في الفيديوهات الجاية.",
        likesCount: 5,
        isLiked: false,
      ),
    ],
  ),

  // 2. سؤال تقني طويل مع رد تفصيلي من الآدمن
  CommentModel(
    id: "2",
    name: "خالد يوسف",
    userName: "@khaled_yousef",
    avatar: "https://i.pravatar.cc/150?img=33",
    isVerified: false,
    timeAgo: "منذ 4 ساعات",
    content:
        "لو سمحتي يا دكتورة، عندي استفسار بخصوص النقطة الثانية. هل لو استخدمنا الطريقة دي مع الأنظمة القديمة هتشتغل بنفس الكفاءة؟ ولا محتاجين نعمل تحديثات معينة الأول؟ لأني جربت قبل كده وواجهت مشاكل في التوافق.",
    likesCount: 20,
    isLiked: false,

    replies: [
      CommentModel(
        id: "21",
        name: "tayseer Admin",
        userName: "@tayseer_app",
        avatar: AssetsData.avatarImage, // صورة الآدمن
        isVerified: true,
        timeAgo: "الآن",
        content:
            "أهلاً بك يا أستاذ خالد. سؤال ممتاز! ✅\nبالنسبة للأنظمة القديمة، يفضل عمل تحديث للـ Libraries الأساسية أولاً لضمان عدم حدوث تعارض. الطريقة المشروحة في الفيديو مخصصة للإصدارات الحديثة (v2.0 وما فوق). هبعتلك رابط في الخاص فيه شرح مفصل لطريقة التحديث.",
        likesCount: 55,
        isOwner: true, // رد صاحب البوست
      ),
    ],
  ),

  // 3. نقد بناء (نص طويل جداً بدون ردود)
  CommentModel(
    id: "3",
    name: "ناقد سينمائي",
    userName: "@movie_critic",
    avatar: "https://i.pravatar.cc/150?img=12",
    isVerified: true,
    isFollowing: true,
    timeAgo: "منذ 6 ساعات",
    content:
        "الفكرة العامة ممتازة، ولكن عندي تحفظ بسيط على الإضاءة في المشاهد الخارجية. حسيت إنها كانت ساطعة زيادة عن اللزوم وده أثر على وضوح التفاصيل في الخلفية. كمان الانتقال بين المشاهد كان ممكن يكون أنعم من كده. مجرد رأي تقني، لكن المحتوى ككل هايل ومجهود يحترم جداً.",
    likesCount: 89,
    isLiked: true,
    replies: [],
  ),

  // 4. نقاش جدلي (Thread)
  CommentModel(
    id: "4",
    name: "مروان بابلو",
    userName: "@marwan_pablo",
    avatar: "https://i.pravatar.cc/150?img=59",
    isVerified: true,
    timeAgo: "منذ 8 ساعات",
    content:
        "مش مقتنع بصراحة، حاسس إن الموضوع واخد أكبر من حجمه، والنتائج دي ممكن نوصلها بطرق أسهل بكتير من غير كل التعقيدات دي.",
    likesCount: 5,
    isLiked: false,
    replies: [
      CommentModel(
        id: '41',
        name: "مهندس برمجيات",
        userName: "@soft_eng_22",
        avatar: "https://i.pravatar.cc/150?img=60",
        isVerified: false,
        timeAgo: "منذ 7 ساعات",
        content:
            "يا صديقي الطرق الأسهل اللي بتتكلم عنها مش بتدي نفس الـ Performance في المشاريع الكبيرة. الحل ده معمول عشان الـ Scalability مش عشان المشاريع الصغيرة.",
        likesCount: 40,
        isLiked: true,
      ),
      CommentModel(
        id: "42",
        name: "مروان بابلو",
        userName: "@marwan_pablo",
        avatar: "https://i.pravatar.cc/150?img=59",
        isVerified: true,
        timeAgo: "منذ 6 ساعات",
        content:
            "وجهة نظر تحترم، بس أنا بتكلم من واقع تجربتي في السوق المحلي، أغلب العملاء مش بيحتاجوا الـ Scale ده.",
        likesCount: 2,
        isLiked: false,
      ),
    ],
  ),
];
