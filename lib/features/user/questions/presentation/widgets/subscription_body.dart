// lib/features/subscription/view/subscription_screen.dart

import 'package:tayseer/features/shared/home/reposiotry/home_repository.dart';
import 'package:tayseer/features/user/questions/data/models/subscription_plan_model.dart';
import 'package:tayseer/features/user/questions/presentation/manager/questions_cubit.dart';
import 'package:tayseer/features/user/questions/presentation/manager/questions_state.dart';
import 'package:tayseer/my_import.dart';

class SubscriptionBody extends StatefulWidget {
  const SubscriptionBody({super.key});

  @override
  State<SubscriptionBody> createState() => _SubscriptionBodyState();
}

class _SubscriptionBodyState extends State<SubscriptionBody> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // ✅ تعريف بيانات الخطط
  late final List<SubscriptionPlanModel> _plans;

  @override
  void initState() {
    super.initState();
    _initPlans();
    _ensureUuidCached();
  }

  /// يضمن إن الـ uuid محفوظ في الكاش قبل أي عملية دفع
  /// لو اليوزر فتح الصفحة دي قبل ما يدخل الـ Home
  Future<void> _ensureUuidCached() async {
    final cachedUuid = CachNetwork.getStringData(key: kUuid);
    if (cachedUuid.isNotEmpty) return; // موجود بالفعل

    // مش موجود → اجلبه من الـ API وكيشه
    await getIt<HomeRepository>().fetchNameAndImage();
  }

  void _initPlans() {
    // يمكنك استبدال مسارات الصور بالمسارات الصحيحة من AssetsData
    _plans = [
      // 1. الخطة الأساسية (وردي)
      SubscriptionPlanModel(
        type: PlanType.basic,
        titleKey: 'basic_plan_title', // "خطة اساسية محدودة"
        buttonTextKey: 'continue_limited', // "استمرار في الحساب المحدود"
        primaryColor: const Color(0xFFE57373), // لون وردي
        secondaryColor: const Color(0xFFFCE4EC), // خلفية فاتحة
        shadowColor: const Color(0xFFEF9A9A),
        features: [
          SubscriptionFeature(
            imagePath: AssetsData.kFeature1,
            titleKey: 'feature_limited_browse',
          ),
          SubscriptionFeature(
            imagePath: AssetsData.kFeature2,
            titleKey: 'feature_cant_see_likes',
          ),
          SubscriptionFeature(
            imagePath: AssetsData.kFeature3,
            titleKey: 'feature_3_factors',
          ),
        ],
      ),
      // 2. الخطة المميزة (أزرق)
      SubscriptionPlanModel(
        type: PlanType.premium,
        titleKey: 'premium_plan_title', // "تساعدك في ايجاد شريكك"
        buttonTextKey: 'get_all_features_123', // "احصل علي جميع المزايا"
        primaryColor: const Color(0xFF42A5F5), // لون أزرق
        secondaryColor: const Color(0xFFE3F2FD), // خلفية فاتحة
        shadowColor: const Color(0xFF90CAF9),
        features: [
          SubscriptionFeature(
            imagePath: AssetsData.kFeature1,
            titleKey: 'feature_unlimited_browse',
          ),
          SubscriptionFeature(
            imagePath: AssetsData.kFeature2,
            titleKey: 'feature_see_likes',
          ),
          SubscriptionFeature(
            imagePath: AssetsData.kFeature3,
            titleKey: 'feature_20_factors',
          ),
        ],
      ),
      // 3. الخطة الذهبية (ذهبي/أصفر)
      SubscriptionPlanModel(
        type: PlanType.gold,
        titleKey: 'gold_plan_title', // "للاستمتاع بمزايا اكثر"
        buttonTextKey: 'get_gold_features_123',
        primaryColor: const Color(0xFFFFCA28), // لون ذهبي
        secondaryColor: const Color(0xFFFFF8E1), // خلفية فاتحة
        shadowColor: const Color(0xFFFFE082),
        extraBadgeTextKey: 'extra_gold_features', // "+5 مجاملات + 5 تعزيزات"
        features: [
          SubscriptionFeature(
            imagePath: AssetsData.kFeature1,
            titleKey: 'feature_gold_browse',
          ),
          SubscriptionFeature(
            imagePath: AssetsData.kFeature2,
            titleKey: 'feature_gold_likes',
          ),
          SubscriptionFeature(
            imagePath: AssetsData.kFeature3,
            titleKey: 'feature_gold_factors',
          ),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPlan = _plans[_currentIndex];

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              currentPlan.secondaryColor.withOpacity(0.5),
              currentPlan.secondaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ✅ الـ PageView (المحتوى الرئيسي)
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _plans.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    return _buildPlanPage(context, _plans[index]);
                  },
                ),
              ),

              // ✅ التابات (Tabs) السفلية المخصصة
              _buildCustomTabs(context),

              const SizedBox(height: 20),

              // ✅ زر الإجراء (Button)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                  child: BlocConsumer<QuestionsCubit, QuestionsState>(
                    listener: (context, state) {
                      if (state.answerQuestionsState == CubitStates.loading) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              const Center(child: CustomloadingApp()),
                        );
                      } else if (state.answerQuestionsState ==
                          CubitStates.success) {
                        // close loading dialog only (don't pop the current route)
                        if (Navigator.canPop(context)) Navigator.pop(context);
                        context.pushNamedAndRemoveUntil(
                          AppRouter.kUserLayoutView,
                          predicate: (route) => false,
                        );
                      } else if (state.answerQuestionsState ==
                          CubitStates.failure) {
                        // close loading dialog only (don't pop the current route)
                        if (Navigator.canPop(context)) Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          CustomSnackBar(
                            context,
                            text:
                                state.errorMessage ??
                                context.tr("submit_failed"),
                            isSuccess: false,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return CustomBotton(
                        key: ValueKey<int>(_currentIndex),
                        width: context.width,
                        title: context.tr(currentPlan.buttonTextKey),
                        useGradient: currentPlan.type == PlanType.basic,
                        backGroundcolor: currentPlan.type == PlanType.gold
                            ? currentPlan.primaryColor
                            : currentPlan.type == PlanType.premium
                            ? currentPlan.primaryColor
                            : null,
                        onPressed: () async {
                          if (currentPlan.type == PlanType.basic) {
                            context.read<QuestionsCubit>().sendAnswerQuestions(
                              question: "subscription",
                              questionCategoryEnum: "subscription",
                              questionNumber: 30,
                              answerCompleted: true,
                              answers: [
                                {'answer': 'تم'},
                              ],
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildPlanPage(BuildContext context, SubscriptionPlanModel plan) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: context.height * 0.05),

          // ✅ العنوان
          Text(
            context.tr(plan.titleKey),
            textAlign: TextAlign.center,
            style: Styles.textStyle18Bold.copyWith(
              color: AppColors.kscandryTextColor,
            ),
          ),

          SizedBox(height: context.height * 0.05),

          // ✅ الميزات (أيقونات ونصوص)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: plan.features.map((feature) {
                return Expanded(
                  child: Column(
                    children: [
                      // دائرة الصورة
                      AppImage(
                        feature.imagePath,
                        width: context.width * 0.22,
                        height: context.height * 0.15,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 12),
                      // النص
                      Text(
                        context.tr(feature.titleKey),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: context.height * 0.05),

          // ✅ الشارة الإضافية (للخطة الذهبية فقط)
          if (plan.extraBadgeTextKey != null)
            Transform.rotate(
              angle: -0.1, // ميلان بسيط
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF9A9A), // لون خلفية الشارة
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  context.tr(plan.extraBadgeTextKey!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            const SizedBox(height: 40), // مساحة فارغة للحفاظ على التناسق
        ],
      ),
    );
  }

  Widget _buildCustomTabs(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 80, // ارتفاع منطقة التابس
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // الخط الرمادي الخلفي
          Positioned(
            bottom: 30, // موضع الخط
            left: 0,
            right: 0,
            child: Container(height: 5, color: Colors.grey[300]),
          ),

          // التابس
          Row(
            children: [
              _buildTabItem(0, 'basic_plan_tab', _plans[0].primaryColor),
              _buildTabItem(1, 'premium_plan_tab', _plans[1].primaryColor),
              _buildTabItem(2, 'gold_plan_tab', _plans[2].primaryColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String titleKey, Color color) {
    final bool isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // ✅ المؤشر (المربع الملون مع السهم)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isSelected ? 1.0 : 0.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                transform: Matrix4.translationValues(0, isSelected ? 0 : 10, 0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        context.tr(
                          index == 0
                              ? 'basic'
                              : index == 1
                              ? 'premium'
                              : 'gold',
                        ),
                        // يمكن استخدام titleKey هنا لو أردت النص داخل المربع
                        // لكن الصورة تظهر النص داخل المربع هو اسم الخطة المختصر
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // السهم المثلث للأسفل
                    CustomPaint(
                      size: const Size(12, 8),
                      painter: TrianglePainter(color: color),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ✅ النقطة على الخط (أو النص السفلي إذا لم يكن مختار)
            // في التصميم: عندما لا يكون مختاراً يظهر النص بالأسفل، وعندما يختار يختفي النص السفلي ويظهر المربع العلوي
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isSelected
                  ? const SizedBox(
                      height: 20,
                    ) // مساحة فارغة لأن العنوان انتقل للأعلى
                  : Padding(
                      padding: const EdgeInsets.only(
                        top: 14,
                      ), // لضبط الموقع تحت الخط
                      child: Text(
                        context.tr(titleKey),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Painter لرسم المثلث الصغير أسفل مربع العنوان
class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0); // Top left
    path.lineTo(size.width, 0); // Top right
    path.lineTo(size.width / 2, size.height); // Bottom center
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
