// lib/features/user/questions/view/questions_page_view.dart

import 'package:tayseer/core/enum/male_female.dart';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/features/user/questions/refact_question/widget/custom_question_header.dart';
import 'package:tayseer/features/user/questions/refact_question/widget/question_page.dart';
import 'package:tayseer/features/user/questions/refact_question/widget/question_page_config.dart';
import 'package:tayseer/features/user/questions/view_model/questions_cubit.dart';
import 'package:tayseer/features/user/questions/view_model/questions_state.dart';

import '../../../../my_import.dart';

class QuestionsPageView extends StatelessWidget {
  final UserTypeEnum currentUserType;
  final Gender selectedGender;

  QuestionsPageView({
    super.key,
    required this.currentUserType,
    required this.selectedGender,
  });

  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);

  /// ✅ خريطة الهوايات مع الأيقونات
  static final Map<String, String> _hobbiesWithIcons = {
    'hobby_music': AssetsData.kmusicIcon,
    'hobby_sports': AssetsData.ksportsIcon,
    'hobby_travel': AssetsData.ktravelIcon,
    'hobby_reading': AssetsData.kreadingIcon,
    'hobby_cooking': AssetsData.kcookingIcon,
    'hobby_drawing': AssetsData.kdrawingIcon,
    'hobby_mountain_climbing': AssetsData.kmountainIcon,
    'hobby_meditation': AssetsData.kmeditationIcon,
    'hobby_photography': AssetsData.kphotographyIcon,
    'hobby_sewing': AssetsData.ksewingIcon,
    'hobby_writing': AssetsData.kwritingIcon,
    'hobby_cycling': AssetsData.kcyclingIcon,
    'hobby_tourism': AssetsData.kswimmingIcon,
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

      // 11. عدد الأطفال
      QuestionPageConfig(
        titleKey: 'children_number',
        questionNumber: 12,
        questionCategoryEnum: 'childrenNumber',
        items: const ['child_1', 'child_2', 'child_3', 'child_4', 'child_5'],
        type: QuestionType.selectableList,
        showSearch: false,
      ),

      // 12. حالة إقامة الأطفال
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

      // ✅ 18. الهوايات (Multi-Select)
      QuestionPageConfig(
        titleKey: 'choose_hobbies',
        questionNumber: 19,
        questionCategoryEnum: 'hobbies',
        type: QuestionType.multiSelectChips,
        itemsWithIcons: _hobbiesWithIcons,
      ),

      // 19. الحجاب (للإناث فقط)
      if (selectedGender == Gender.female)
        QuestionPageConfig(
          titleKey: 'do_you_wear_hijab',
          questionNumber: 21,
          questionCategoryEnum: 'wearHijab',
          items: const ['yes', 'no'],
          type: QuestionType.selectableList,
          showSearch: false,
        ),
    ];

    return questions;
  }

  @override
  Widget build(BuildContext context) {
    final questions = _getQuestions(context);
    final totalPages = questions.length;

    return Scaffold(
      body: CustomBackground(
        child: BlocListener<QuestionsCubit, QuestionsState>(
          listenWhen: (previous, current) =>
              previous.answerQuestionsState != current.answerQuestionsState,
          listener: (context, state) {
            if (state.answerQuestionsState == CubitStates.success) {
              _goToNextPage(totalPages, context);
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
    // ✅ تحويل الإجابة للـ format المطلوب
    List<Map<String, dynamic>> answers;

    if (answer is List<String>) {
      // Multi-Select (Hobbies)
      answers = answer.map((e) => {'answer': e}).toList();
    } else {
      // Single Select
      answers = [
        {'answer': answer.toString()},
      ];
    }

    context.read<QuestionsCubit>().sendAnswerQuestions(
      question: context.tr(config.titleKey),
      questionCategoryEnum: config.questionCategoryEnum,
      questionNumber: config.questionNumber,
      answers: answers,
    );
  }

  void _goToNextPage(int totalPages, BuildContext context) {
    if (_currentPage.value < totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // ✅ انتهت الأسئلة
      context.pushReplacementNamed(AppRouter.kPersonalInfoView);
    }
  }
}
