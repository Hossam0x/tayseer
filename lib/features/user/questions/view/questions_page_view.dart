// lib/features/user/questions/view/questions_page_view.dart

import 'package:tayseer/core/enum/auth_enum.dart';
import 'package:tayseer/core/enum/male_female.dart';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/features/user/questions/view/widget/custom_question_header.dart';
import 'package:tayseer/features/user/questions/view/widget/question_page.dart';
import 'package:tayseer/features/user/questions/view/widget/question_page_config.dart';
import 'package:tayseer/features/user/questions/view_model/questions_cubit.dart';
import 'package:tayseer/features/user/questions/view_model/questions_state.dart';

import '../../../../my_import.dart';

class QuestionsPageView extends StatelessWidget {
  final UserTypeEnum currentUserType;
  final Gender selectedGender;
  final int lastQuestionNumber;

  QuestionsPageView({
    super.key,
    required this.currentUserType,
    required this.selectedGender,
    required this.lastQuestionNumber,
  });

  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);

  // ✅ متغير لتخزين الإجابات (key) للمنطق الشرطي
  final Map<String, dynamic> _answers = {};

  /// ✅ خريطة الهوايات مع الأيقونات
  /// ✅ خريطة الاهتمامات المقسمة حسب الفئات
  static final Map<String, Map<String, String>> _interestsWithCategories = {
    // =============== الرياضة ===============
    'category_sports': {
      'interest_baseball': '⚾',
      'interest_running': '🏃',
      'interest_weightlifting': '🏋️',
      'interest_gymnastics': '🤸',
      'interest_golf': '⛳',
      'interest_tennis': '🎾',
      'interest_swimming': '🏊',
      'interest_dancing': '💃',
      'interest_skating': '⛸️',
      'interest_yoga': '🧘',
      'interest_flying_disc': '🥏',
      'interest_badminton': '🏸',
      'interest_skiing': '⛷️',
      'interest_cycling': '🚴',
      'interest_basketball': '🏀',
      'interest_football': '⚽',
      'interest_karate': '🥋',
      'interest_boxing': '🥊',
      'interest_archery': '🏹',
      'interest_horse_riding': '🏇',
    },

    // =============== فنون وثقافة ===============
    'category_arts_culture': {
      'interest_theater': '🎭',
      'interest_magic': '🪄',
      'interest_music': '🎵',
      'interest_painting': '🎨',
      'interest_photography': '📷',
      'interest_cinema': '🎬',
      'interest_reading': '📚',
      'interest_writing': '✍️',
      'interest_poetry': '📝',
      'interest_history': '🏛️',
      'interest_languages': '🗣️',
      'interest_museums': '🖼️',
      'interest_calligraphy': '🖋️',
      'interest_sculpture': '🗿',
      'interest_design': '🎯',
      'interest_fashion': '👗',
    },

    // =============== المجتمع ===============
    'category_community': {
      'interest_volunteering': '🤝',
      'interest_charity': '💝',
      'interest_teaching': '👨‍🏫',
      'interest_mentoring': '🧑‍🤝‍🧑',
      'interest_elderly_care': '👴',
      'interest_children_care': '👶',
      'interest_environment': '🌱',
      'interest_animal_care': '🐾',
      'interest_blood_donation': '🩸',
      'interest_community_events': '🎉',
      'interest_social_work': '💼',
      'interest_human_rights': '⚖️',
    },

    // =============== التكنولوجيا ===============
    'category_technology': {
      'interest_programming': '💻',
      'interest_gaming': '🎮',
      'interest_ai': '🤖',
      'interest_web_dev': '🌐',
      'interest_mobile_apps': '📱',
      'interest_cybersecurity': '🔒',
      'interest_data_science': '📊',
      'interest_electronics': '🔌',
      'interest_robotics': '🦾',
      'interest_vr_ar': '🥽',
      'interest_3d_printing': '🖨️',
      'interest_drones': '🚁',
      'interest_smart_home': '🏠',
      'interest_blockchain': '⛓️',
    },

    // =============== النزهات ===============
    'category_outdoors': {
      'interest_hiking': '🥾',
      'interest_camping': '🏕️',
      'interest_fishing': '🎣',
      'interest_beach': '🏖️',
      'interest_mountain_climbing': '🏔️',
      'interest_gardening': '🌻',
      'interest_picnic': '🧺',
      'interest_bird_watching': '🦅',
      'interest_stargazing': '🌟',
      'interest_road_trips': '🚗',
      'interest_sailing': '⛵',
      'interest_diving': '🤿',
      'interest_surfing': '🏄',
      'interest_kayaking': '🛶',
      'interest_rock_climbing': '🧗',
      'interest_paragliding': '🪂',
    },

    // =============== الطعام والمشروبات ===============
    'category_food_drinks': {
      'interest_cooking': '👨‍🍳',
      'interest_baking': '🧁',
      'interest_grilling': '🍖',
      'interest_coffee': '☕',
      'interest_tea': '🍵',
      'interest_smoothies': '🥤',
      'interest_sushi': '🍣',
      'interest_pizza': '🍕',
      'interest_desserts': '🍰',
      'interest_healthy_food': '🥗',
      'interest_street_food': '🌮',
      'interest_fine_dining': '🍽️',
      'interest_food_photography': '📸',
      'interest_chocolate': '🍫',
      'interest_ice_cream': '🍦',
    },
  };

  /// ✅ خريطة الإيمان مع الإيموجي
  static final Map<String, String> _faithWithEmoji = {
    'faith_dua': '🙏',
    'faith_umrah': '🕋',
    'faith_charity_work': '💼',
    'faith_dawah': '📢',
    'faith_sadaqah': '🤝',
    'faith_hadith': '📖',
    'faith_tahajjud': '😊',
    'faith_dhikr': '📿',
    'faith_multiple_prayers': '🕌',
    'faith_sunnah_prayer': '🙏',
    'faith_nafila_prayer': '🕯️',
    'faith_hajj': '🕋',
    'faith_five_prayers': '☪️',
    'faith_fiqh': '📚',
    'faith_fasting': '🌙',
    'faith_tasawwuf': '😇',
    'faith_good_manners': '🤲',
    'faith_friday_prayer': '🕌',
  };

  /// ✅ خريطة نوايا الزواج
  static final Map<String, Map<String, String>> _marriageIntentions = {
    // اود التواصل مع الشخص خلال
    'intention_contact_period': {
      'period_1_3_months': '',
      'period_4_7_months': '',
      'period_7_12_months': '',
      'period_1_2_years': '',
    },

    // فترة الخطوبة ستكون
    'intention_engagement_period': {
      'period_1_3_months': '',
      'period_4_7_months': '',
      'period_7_12_months': '',
      'period_1_2_years': '',
    },

    // ارغب في الزواج
    'intention_marriage_period': {
      'period_1_3_months': '',
      'period_4_7_months': '',
      'period_7_12_months': '',
      'period_1_2_years': '',
    },
  };

  List<QuestionPageConfig> _getQuestions(BuildContext context) {
    final List<QuestionPageConfig> questions = [
      // 1. الجنسية
      QuestionPageConfig(
        titleKey: 'choose_nationality',
        questionNumber: 2,
        questionCategoryEnum: 'nationality',
        items: const [
          'nationality_saudi',
          'nationality_egyptian',
          'nationality_emirati',
          'nationality_kuwaiti',
          'nationality_qatari',
          'nationality_bahraini',
          'nationality_jordanian',
          'nationality_palestinian',
          'nationality_moroccan',
          'nationality_tunisian',
        ],
        type: QuestionType.selectableList,
        showSearch: true,
        searchHintKey: 'search_nationality',
      ),

      // 2. الدولة
      QuestionPageConfig(
        titleKey: 'choose_country',
        questionNumber: 3,
        questionCategoryEnum: 'country',
        items: const [
          'country_saudi',
          'country_egypt',
          'country_emirati',
          'country_kuwait',
          'country_qatar',
          'country_bahrain',
          'country_jordan',
          'country_palestine',
          'country_morocco',
          'country_tunisia',
        ],
        type: QuestionType.selectableList,
        showSearch: true,
        searchHintKey: 'search_country',
      ),

      // 3. العمر
      QuestionPageConfig(
        titleKey: 'choose_age',
        questionNumber: 4,
        questionCategoryEnum: 'age',
        type: QuestionType.picker,
        minValue: 18,
        maxValue: 100,
        initialValue: 20,
      ),

      // 4. الحالة الاجتماعية
      QuestionPageConfig(
        titleKey: 'choose_social_status',
        questionNumber: 5,
        questionCategoryEnum: 'socialStatus',
        items: const [
          'social_single',
          'social_married',
          'social_divorced',
          'social_widowed',
        ],
        type: QuestionType.selectableList,
        showSearch: false,
      ),

      // 5. الوزن
      QuestionPageConfig(
        titleKey: 'choose_weight',
        questionNumber: 6,
        questionCategoryEnum: 'weight',
        type: QuestionType.picker,
        minValue: 40,
        maxValue: 150,
        initialValue: 70,
        unit: 'kg',
      ),

      // 6. الطول
      QuestionPageConfig(
        titleKey: 'choose_height',
        questionNumber: 7,
        questionCategoryEnum: 'height',
        type: QuestionType.picker,
        minValue: 100,
        maxValue: 220,
        initialValue: 170,
        unit: 'cm',
      ),

      // 7. لون البشرة
      QuestionPageConfig(
        titleKey: 'choose_skin_color',
        questionNumber: 8,
        questionCategoryEnum: 'skinColor',
        items: const [
          'skin_very_light',
          'skin_light',
          'skin_medium',
          'skin_dark',
          'skin_very_dark',
        ],
        type: QuestionType.selectableList,
        showSearch: false,
      ),

      // 8. التدخين
      QuestionPageConfig(
        titleKey: 'are_you_smoker',
        questionNumber: 9,
        questionCategoryEnum: 'smoker',
        items: const ['yes', 'no'],
        type: QuestionType.selectableList,
        showSearch: false,
      ),

      // 9. الالتزام الديني
      QuestionPageConfig(
        titleKey: 'religious_commitment',
        questionNumber: 10,
        questionCategoryEnum: 'religiousCommitment',
        items: const [
          'religion_full',
          'religion_partial',
          'religion_sometimes',
          'religion_none',
        ],
        type: QuestionType.selectableList,
        showSearch: false,
      ),

      // 10. هل لديك أطفال
      QuestionPageConfig(
        titleKey: 'has_children',
        questionNumber: 11,
        questionCategoryEnum: 'hasChildren',
        items: const ['yes', 'no'],
        type: QuestionType.selectableList,
        showSearch: false,
      ),

      // ✅ 11. عدد الأطفال (يظهر فقط إذا كان hasChildren = yes)
      QuestionPageConfig(
        titleKey: 'children_number',
        questionNumber: 12,
        questionCategoryEnum: 'childrenNumber',
        items: const ['child_1', 'child_2', 'child_3', 'child_4', 'child_5'],
        type: QuestionType.selectableList,
        showSearch: false,
        dependsOnQuestion: 'hasChildren',
        requiredAnswer: 'yes',
      ),

      // ✅ 12. حالة إقامة الأطفال (يظهر فقط إذا كان hasChildren = yes)
      QuestionPageConfig(
        titleKey: 'children_living_status',
        questionNumber: 13,
        questionCategoryEnum: 'childrenLivingStatus',
        items: const [
          'living_currently',
          'living_future',
          'living_current_future',
          'living_no',
        ],
        type: QuestionType.selectableList,
        showSearch: false,
        dependsOnQuestion: 'hasChildren',
        requiredAnswer: 'yes',
      ),

      // 13. المستوى التعليمي
      QuestionPageConfig(
        titleKey: 'education_level',
        questionNumber: 14,
        questionCategoryEnum: 'educationLevel',
        items: const [
          'education_primary',
          'education_secondary',
          'education_diploma',
          'education_bachelor',
          'education_master',
          'education_phd',
          'education_none',
        ],
        type: QuestionType.selectableList,
        showSearch: false,
      ),

      // 14. الوظيفة
      QuestionPageConfig(
        titleKey: 'choose_job',
        questionNumber: 15,
        questionCategoryEnum: 'job',
        items: const [
          'job_student',
          'job_teacher',
          'job_engineer',
          'job_doctor',
          'job_nurse',
          'job_driver',
          'job_business',
          'job_unemployed',
          'job_other',
        ],
        type: QuestionType.selectableList,
        showSearch: true,
        searchHintKey: 'search_job',
      ),

      // 15. جهة العمل
      QuestionPageConfig(
        titleKey: 'choose_employer',
        questionNumber: 16,
        questionCategoryEnum: 'chooseEmployer',
        items: const [
          'employer_government',
          'employer_private',
          'employer_institution',
          'employer_freelance',
          'employer_unemployed',
        ],
        type: QuestionType.selectableList,
        showSearch: true,
        searchHintKey: 'search_employer',
      ),

      // 16. قبول الزواج من متزوج (للإناث فقط)
      if (selectedGender == Gender.female)
        QuestionPageConfig(
          titleKey: 'accept_married',
          questionNumber: 17,
          questionCategoryEnum: 'acceptMarried',
          items: const ['yes', 'no'],
          type: QuestionType.selectableList,
          showSearch: false,
        ),

      // 17. الحالة الصحية
      QuestionPageConfig(
        titleKey: 'health_status',
        questionNumber: 18,
        questionCategoryEnum: 'healthStatus',
        items: const [
          'health_excellent',
          'health_good',
          'health_followup',
          'health_chronic',
          'health_unstable',
        ],
        type: QuestionType.selectableList,
        showSearch: false,
      ),

      // ✅ 19. الهوايات (Multi-Select)
      QuestionPageConfig(
        titleKey: 'choose_hobbies',
        questionNumber: 19,
        questionCategoryEnum: 'hobbies',
        type: QuestionType.categorizedMultiSelectChips,
        categorizedItems: _interestsWithCategories,
      ),
      // ✅ 20. الإيمان (Multi-Select)
      QuestionPageConfig(
        titleKey: 'choose_faith',
        subtitleKey: 'faith_subtitle',
        questionNumber: 20,
        questionCategoryEnum: 'faith',
        type: QuestionType.multiSelectChips,
        itemsWithIcons: _faithWithEmoji,
      ),

      // 21. الحجاب (للإناث فقط)
      if (selectedGender == Gender.female)
        QuestionPageConfig(
          titleKey: 'do_you_wear_hijab',
          questionNumber: 21,
          questionCategoryEnum: 'wearHijab',
          items: const ['yes', 'no'],
          type: QuestionType.selectableList,
          showSearch: false,
        ),

      // 22. Add Your CV
      QuestionPageConfig(
        titleKey: 'add_your_cv',
        questionNumber: 22,
        questionCategoryEnum: AuthEnum.addYourCv.name,
        type: QuestionType.textInput,
      ),
      // ✅ 23. نوايا الزواج (Categorized Single Select) - جديد
      QuestionPageConfig(
        titleKey: 'marriage_intentions',
        questionNumber: 23,
        questionCategoryEnum: 'marriageIntentions',
        type: QuestionType.categorizedSingleSelectChips,
        categorizedItems: _marriageIntentions,
      ),
      // الاسره 24
      QuestionPageConfig(
        titleKey: 'family',
        questionNumber: 24,
        questionCategoryEnum: 'familyAcceptance',
        items: const ['no_problem_children', 'do_not_want_children'],
        type: QuestionType.selectableList,
        showSearch: false,
      ),

      // 25. السفر للخارج
      QuestionPageConfig(
        titleKey: 'travel',
        questionNumber: 25,
        questionCategoryEnum: 'intendTravelAbroad',
        items: const ['intend_travel_abroad', 'do_not_intend_travel'],
        type: QuestionType.selectableList,
        showSearch: false,
      ),

      // 26. هل تأكل فقط الطعام الحلال؟
      QuestionPageConfig(
        titleKey: 'eat_halal_only',
        questionNumber: 26,
        questionCategoryEnum: 'eatHalalOnly',
        items: const ['yes', 'no'],
        type: QuestionType.selectableList,
        showSearch: false,
      ),
      // 27. هل تشرب الكحول؟
      QuestionPageConfig(
        titleKey: 'drink_alcohol',
        questionNumber: 27,
        questionCategoryEnum: 'drinkAlcohol',
        items: const ['yes', 'no'],
        type: QuestionType.selectableList,
        showSearch: false,
      ),
    ];

    return questions;
  }

  // ✅ دالة للتحقق هل السؤال يجب عرضه بناءً على الشروط
  bool _shouldShowQuestion(QuestionPageConfig config) {
    if (config.dependsOnQuestion == null) {
      return true; // لا يوجد شرط، اعرض السؤال
    }

    final dependsOnAnswer = _answers[config.dependsOnQuestion];
    return dependsOnAnswer == config.requiredAnswer;
  }

  // ✅ دالة للحصول على الصفحة التالية المتاحة
  int _getNextAvailablePage(
    List<QuestionPageConfig> questions,
    int currentIndex,
  ) {
    for (int i = currentIndex + 1; i < questions.length; i++) {
      if (_shouldShowQuestion(questions[i])) {
        return i;
      }
    }
    return -1; // لا توجد صفحات متاحة (انتهت الأسئلة)
  }

  @override
  Widget build(BuildContext context) {
    final questions = _getQuestions(context);
    final totalPages = questions.length;

    // إذا تم تمرير آخر رقم سؤال من السيرفر، نحدد الصفحة التي تحتوي على السؤال التالي
    final targetQuestionNumber = lastQuestionNumber + 1;
    final startIndex = questions.indexWhere(
      (q) => q.questionNumber == targetQuestionNumber,
    );

    if (startIndex != -1 && _currentPage.value == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(startIndex);
          _currentPage.value = startIndex;
        }
      });
    }

    return Scaffold(
      body: CustomBackground(
        child: BlocListener<QuestionsCubit, QuestionsState>(
          listenWhen: (previous, current) =>
              previous.answerQuestionsState != current.answerQuestionsState,
          listener: (context, state) {
            if (state.answerQuestionsState == CubitStates.success) {
              _goToNextPage(questions, context);
            } else if (state.answerQuestionsState == CubitStates.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                CustomSnackBar(
                  context,
                  text: state.errorMessage ?? 'حدث خطأ ما',
                  isError: true,
                ),
              );
            }
          },
          child: Column(
            children: [
              SizedBox(height: context.height * 0.06),

              /// HEADER WITH PROGRESS
              ValueListenableBuilder<int>(
                valueListenable: _currentPage,
                builder: (context, currentPage, _) {
                  final progress = (currentPage + 1) / totalPages;
                  return QuestionHeader(
                    progress: progress,
                    titleKey: questions[currentPage].titleKey,
                    showBackButton: true,
                  );
                },
              ),

              const SizedBox(height: 20),

              /// PAGE VIEW
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: totalPages,
                  onPageChanged: (index) {
                    _currentPage.value = index;
                  },
                  itemBuilder: (context, index) {
                    return QuestionPage(
                      config: questions[index],
                      onAnswer: (dynamic answer) {
                        _submitAnswer(context, questions[index], answer);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitAnswer(
    BuildContext context,
    QuestionPageConfig config,
    dynamic answer,
  ) {
    // ✅ استخراج الـ key والـ value
    final dynamic answerKey;
    final dynamic answerValue;

    if (answer is Map) {
      answerKey = answer['key'];
      answerValue = answer['value'];
    } else {
      answerKey = answer;
      answerValue = answer;
    }

    // ✅ حفظ الـ key في _answers للمنطق الشرطي
    _answers[config.questionCategoryEnum] = answerKey;

    // ✅ إرسال الـ value (النص المترجم) للـ Backend
    List<Map<String, dynamic>> answers;

    if (answerValue is List<String>) {
      answers = answerValue.map((e) => {'answer': e}).toList();
    } else {
      answers = [
        {'answer': answerValue.toString()},
      ];
    }

    context.read<QuestionsCubit>().sendAnswerQuestions(
      question: context.tr(config.titleKey),
      questionCategoryEnum: config.questionCategoryEnum,
      questionNumber: config.questionNumber,
      answers: answers,
    );
  }

  // ✅ دالة الانتقال للصفحة التالية
  void _goToNextPage(List<QuestionPageConfig> questions, BuildContext context) {
    final nextPageIndex = _getNextAvailablePage(questions, _currentPage.value);

    if (nextPageIndex != -1) {
      _pageController.animateToPage(
        nextPageIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // ✅ انتهت الأسئلة
      context.pushReplacementNamed(AppRouter.kPersonalInfoView);
    }
  }
}
