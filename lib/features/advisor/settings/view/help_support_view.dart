import 'package:tayseer/my_import.dart';

class HelpSupportView extends StatefulWidget {
  const HelpSupportView({super.key});

  @override
  State<HelpSupportView> createState() => _HelpSupportViewState();
}

class _HelpSupportViewState extends State<HelpSupportView> {
  final TextEditingController _problemController = TextEditingController();

  /// حالة فتح / قفل كل سؤال
  final Map<int, bool> _expandedMap = {};

  final List<String> faqs = [
    'ما هو تطبيق تيسير',
    'كيف أحجز جلسة',
    'طرق الدفع المتاحة',
    'كيفية إلغاء الحجز',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AdvisorBackground(
        child: Stack(
          children: [
            /// Background العلوي
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 110.h,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AssetsData.homeBarBackgroundImage),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    Gap(16.h),

                    /// زر الرجوع
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back,
                          color: AppColors.blackColor,
                          size: 24.w,
                        ),
                      ),
                    ),

                    Gap(8.h),

                    /// العنوان
                    Center(
                      child: Text(
                        'المساعدة والدعم',
                        style: Styles.textStyle20Bold,
                      ),
                    ),

                    Gap(36.h),

                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildFaqs(),

                          Gap(24.h),

                          _buildInstructions(),

                          Gap(24.h),

                          _buildReportProblem(),

                          Gap(24.h),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: CustomBotton(
                              title: 'إرسال',
                              useGradient: true,
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  CustomSnackBar(
                                    context,
                                    text: 'تم إرسال المشكلة بنجاح',
                                    isSuccess: true,
                                  ),
                                );
                                _problemController.clear();
                              },
                            ),
                          ),

                          Gap(40.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================== Widgets ==================

  Widget _buildFaqs() {
    return Container(
      padding: EdgeInsets.only(right: 16.w, top: 16.h),
      decoration: BoxDecoration(
        color: AppColors.whiteCard2Back,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الأسئلة الشائعة (FAQs)',
            style: Styles.textStyle18Meduim.copyWith(
              color: AppColors.primaryText,
            ),
          ),
          Gap(16.h),

          Column(
            children: faqs.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              final isExpanded = _expandedMap[index] ?? false;

              return Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _expandedMap[index] = expanded;
                    });
                  },

                  title: Text(
                    question,
                    style: Styles.textStyle16.copyWith(
                      color: AppColors.blackColor,
                    ),
                  ),

                  /// السهم المتحرك
                  trailing: AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.dropDownArrow,
                    ),
                  ),

                  shape: const RoundedRectangleBorder(
                    side: BorderSide(color: Colors.transparent),
                  ),
                  collapsedShape: const RoundedRectangleBorder(
                    side: BorderSide(color: Colors.transparent),
                  ),

                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        right: 16.w,
                        left: 16.w,
                        bottom: 16.h,
                      ),
                      child: Text(
                        'هذا نص توضيحي للإجابة الخاصة بالسؤال.',
                        style: Styles.textStyle14.copyWith(
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.whiteCard2Back,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تعليمات استخدام التطبيق',
            style: Styles.textStyle18Meduim.copyWith(
              color: AppColors.primaryText,
            ),
          ),
          Gap(16.h),

          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.kWhiteColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _InstructionItem(
                  text: '• تسجيل الدخول: أنشئ حسابك أو سجل دخولك.',
                ),
                _InstructionItem(
                  text: '• الحجز: اختر الموعد المناسب وحدد الوقت.',
                ),
                _InstructionItem(text: '• الدفع: ادفع مباشرة عبر التطبيق.'),
                _InstructionItem(text: '• الوصول: ادخل الجلسة في موعدها.'),
                _InstructionItem(text: '• الدعم: تواصل معنا عند أي استفسار.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportProblem() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.whiteCard2Back,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الإبلاغ عن مشكلة',
            style: Styles.textStyle18Meduim.copyWith(
              color: AppColors.primaryText,
            ),
          ),
          Gap(12.h),
          Text(
            'اخبرنا بمشكلتك وسنعود إليك بأسرع وقت!',
            style: Styles.textStyle14,
          ),
          Gap(12.h),
          TextField(
            controller: _problemController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'ادخل تفاصيل المشكلة',
              hintStyle: Styles.textStyle14.copyWith(color: AppColors.hintText),
              filled: true,
              fillColor: AppColors.secondary950,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// عنصر تعليمات
class _InstructionItem extends StatelessWidget {
  final String text;

  const _InstructionItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        text,
        style: Styles.textStyle16.copyWith(color: AppColors.secondary600),
      ),
    );
  }
}
