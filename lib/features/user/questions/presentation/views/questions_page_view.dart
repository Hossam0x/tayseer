import 'dart:developer';

import 'package:tayseer/core/enum/auth_enum.dart';
import 'package:tayseer/core/enum/male_female.dart';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/features/user/questions/data/models/question_page_config.dart';
import 'package:tayseer/features/user/questions/data/models/questions_data.dart';
import 'package:tayseer/features/user/questions/presentation/widgets/custom_question_header.dart';
import 'package:tayseer/features/user/questions/presentation/widgets/question_page.dart';
import 'package:tayseer/features/user/questions/presentation/manager/questions_cubit.dart';
import 'package:tayseer/features/user/questions/presentation/manager/questions_state.dart';
import 'package:tayseer/my_import.dart';

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

  /// Stores answer keys for conditional logic between questions.
  final Map<String, dynamic> _answers = {};

  // ─────────────────────────────────────────────────────
  // Question List Builder
  // ─────────────────────────────────────────────────────

  List<QuestionPageConfig> _getQuestions() {
    return [
      QuestionPageConfig(
        titleKey: 'choose_nationality',
        questionNumber: 2,
        questionCategoryEnum: 'nationality',
        items: QuestionsData.nationalities,
        type: QuestionType.selectableList,
        showSearch: true,
        searchHintKey: 'search_nationality',
      ),
      QuestionPageConfig(
        titleKey: 'choose_country',
        questionNumber: 3,
        questionCategoryEnum: 'country',
        items: QuestionsData.countries,
        type: QuestionType.selectableList,
        showSearch: true,
        searchHintKey: 'search_country',
      ),
      QuestionPageConfig(
        titleKey: 'choose_age',
        questionNumber: 4,
        questionCategoryEnum: 'age',
        type: QuestionType.picker,
        minValue: 18,
        maxValue: 100,
        initialValue: 20,
      ),
      QuestionPageConfig(
        titleKey: 'choose_social_status',
        questionNumber: 5,
        questionCategoryEnum: 'socialStatus',
        items: QuestionsData.socialStatuses,
        type: QuestionType.selectableList,
      ),
      QuestionPageConfig(
        titleKey: 'choose_weight',
        questionNumber: 6,
        questionCategoryEnum: 'weight',
        type: QuestionType.picker,
        minValue: 40,
        maxValue: 160,
        initialValue: 55,
        unit: 'kg',
      ),
      QuestionPageConfig(
        titleKey: 'choose_height',
        questionNumber: 7,
        questionCategoryEnum: 'height',
        type: QuestionType.picker,
        minValue: 120,
        maxValue: 220,
        initialValue: 160,
        unit: 'cm',
      ),
      QuestionPageConfig(
        titleKey: 'choose_skin_color',
        questionNumber: 8,
        questionCategoryEnum: 'skinColor',
        items: QuestionsData.skinColors,
        type: QuestionType.selectableList,
      ),
      QuestionPageConfig(
        titleKey: 'are_you_smoker',
        questionNumber: 9,
        questionCategoryEnum: 'smoker',
        items: QuestionsData.yesNo,
        type: QuestionType.selectableList,
      ),
      QuestionPageConfig(
        titleKey: 'religious_commitment',
        questionNumber: 10,
        questionCategoryEnum: 'religiousCommitment',
        items: QuestionsData.religiousCommitments,
        type: QuestionType.selectableList,
      ),
      if (kCurrentUserData?.socialStatus != 'single')
        QuestionPageConfig(
          titleKey: 'has_children',
          questionNumber: 11,
          questionCategoryEnum: 'hasChildren',
          items: QuestionsData.yesNo,
          type: QuestionType.selectableList,
        ),
      if (kCurrentUserData?.socialStatus != 'single' &&
          kCurrentUserData?.hasChildren == true)
        QuestionPageConfig(
          titleKey: 'children_number',
          questionNumber: 12,
          questionCategoryEnum: 'childrenNumber',
          items: QuestionsData.childrenNumbers,
          type: QuestionType.selectableList,
          dependsOnQuestion: 'hasChildren',
          requiredAnswer: 'yes',
        ),
      if (kCurrentUserData?.socialStatus != 'single' &&
          kCurrentUserData?.hasChildren == true)
        QuestionPageConfig(
          titleKey: 'children_living_status',
          questionNumber: 13,
          questionCategoryEnum: 'childrenLivingStatus',
          items: QuestionsData.childrenLivingStatuses,
          type: QuestionType.selectableList,
          dependsOnQuestion: 'hasChildren',
          requiredAnswer: 'yes',
        ),
      QuestionPageConfig(
        titleKey: 'education_level',
        questionNumber: 14,
        questionCategoryEnum: 'educationLevel',
        items: QuestionsData.educationLevels,
        type: QuestionType.selectableList,
      ),
      QuestionPageConfig(
        titleKey: 'choose_job',
        questionNumber: 15,
        questionCategoryEnum: 'job',
        items: QuestionsData.jobs,
        type: QuestionType.selectableList,
        showSearch: true,
        searchHintKey: 'search_job',
      ),
      QuestionPageConfig(
        titleKey: 'choose_employer',
        questionNumber: 16,
        questionCategoryEnum: 'chooseEmployer',
        items: QuestionsData.employers,
        type: QuestionType.selectableList,
        showSearch: true,
        searchHintKey: 'search_employer',
      ),
      if (selectedGender == Gender.female ||
          (kCurrentUserData?.socialStatus != 'single' &&
              selectedGender == Gender.male))
        QuestionPageConfig(
          titleKey: kCurrentUserData?.gender == "male"
              ? 'do_you_want_to_have_more_than_one_wife'
              : 'accept_married',
          questionNumber: 17,
          questionCategoryEnum: 'acceptMarried',
          items: QuestionsData.yesNo,
          type: QuestionType.selectableList,
        ),
      QuestionPageConfig(
        titleKey: 'health_status',
        questionNumber: 18,
        questionCategoryEnum: 'healthStatus',
        items: QuestionsData.healthStatuses,
        type: QuestionType.selectableList,
      ),
      QuestionPageConfig(
        titleKey: 'choose_hobbies',
        questionNumber: 19,
        questionCategoryEnum: 'hobbies',
        type: QuestionType.categorizedMultiSelectChips,
        categorizedItems: QuestionsData.interestsWithCategories,
      ),
      QuestionPageConfig(
        titleKey: 'choose_faith',
        subtitleKey: 'faith_subtitle',
        questionNumber: 20,
        questionCategoryEnum: 'faith',
        type: QuestionType.multiSelectChips,
        itemsWithIcons: QuestionsData.faithWithEmoji,
      ),
      if (selectedGender == Gender.female)
        QuestionPageConfig(
          titleKey: 'do_you_wear_hijab',
          questionNumber: 21,
          questionCategoryEnum: 'wearHijab',
          items: QuestionsData.yesNo,
          type: QuestionType.selectableList,
        ),
      QuestionPageConfig(
        titleKey: 'add_your_cv',
        questionNumber: 22,
        questionCategoryEnum: AuthEnum.addYourCv.name,
        type: QuestionType.textInput,
      ),
      QuestionPageConfig(
        titleKey: 'marriage_intentions',
        questionNumber: 23,
        questionCategoryEnum: 'marriageIntentions',
        type: QuestionType.categorizedSingleSelectChips,
        categorizedItems: QuestionsData.marriageIntentions,
      ),
      QuestionPageConfig(
        titleKey: 'family',
        questionNumber: 24,
        questionCategoryEnum: 'familyAcceptance',
        items: QuestionsData.familyOptions,
        type: QuestionType.selectableList,
      ),
      QuestionPageConfig(
        titleKey: 'travel',
        questionNumber: 25,
        questionCategoryEnum: 'intendTravelAbroad',
        items: QuestionsData.travelOptions,
        type: QuestionType.selectableList,
      ),
      QuestionPageConfig(
        titleKey: 'drink_alcohol',
        questionNumber: 26,
        questionCategoryEnum: 'drinkAlcohol',
        items: QuestionsData.yesNo,
        type: QuestionType.selectableList,
      ),
    ];
  }

  // ─────────────────────────────────────────────────────
  // Conditional Question Logic
  // ─────────────────────────────────────────────────────

  bool _shouldShowQuestion(QuestionPageConfig config) {
    if (config.dependsOnQuestion == null) return true;
    final dependsOnAnswer = _answers[config.dependsOnQuestion];
    return dependsOnAnswer == config.requiredAnswer;
  }

  int _getNextAvailablePage(
    List<QuestionPageConfig> questions,
    int currentIndex,
  ) {
    for (int i = currentIndex + 1; i < questions.length; i++) {
      if (_shouldShowQuestion(questions[i])) return i;
    }
    return -1;
  }

  // ─────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final questions = _getQuestions();
    final totalPages = questions.length;

    final startIndex = questions.indexWhere(
      (q) => q.questionNumber == lastQuestionNumber,
    );
    log(
      ">>>>>>>>>... startIndex: $startIndex, lastQuestionNumber: $lastQuestionNumber",
    );
    log(">>>>>>>>>>>>>.. ${kCurrentUserData?.toJson()}");
    if (startIndex != -1 && _currentPage.value == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(startIndex + 1);
          _currentPage.value = startIndex + 1;
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

              /// Header with progress
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

              /// Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: totalPages,
                  onPageChanged: (index) => _currentPage.value = index,
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

  // ─────────────────────────────────────────────────────
  // Answer Submission
  // ─────────────────────────────────────────────────────

  void _submitAnswer(
    BuildContext context,
    QuestionPageConfig config,
    dynamic answer,
  ) {
    final dynamic answerKey;

    if (answer is Map) {
      answerKey = answer['key'];
    } else {
      answerKey = answer;
    }

    _answers[config.questionCategoryEnum] = answerKey;

    List<Map<String, dynamic>> answers;

    if (answerKey is List<String>) {
      answers = answerKey.map((e) => {'answer': e}).toList();
    } else if (answerKey is Map<String, String>) {
      answers = answerKey.values.map((value) => {'answer': value}).toList();
    } else {
      answers = [
        {'answer': answerKey.toString()},
      ];
    }

    context.read<QuestionsCubit>().sendAnswerQuestions(
      question: context.tr(config.titleKey),
      questionCategoryEnum: config.questionCategoryEnum,
      questionNumber: config.questionNumber,
      answers: answers,
    );
  }

  // ─────────────────────────────────────────────────────
  // Navigation
  // ─────────────────────────────────────────────────────

  void _goToNextPage(List<QuestionPageConfig> questions, BuildContext context) {
    final nextPageIndex = _getNextAvailablePage(questions, _currentPage.value);

    if (nextPageIndex != -1) {
      _pageController.animateToPage(
        nextPageIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.pushReplacementNamed(AppRouter.kPersonalInfoView);
    }
  }
}
