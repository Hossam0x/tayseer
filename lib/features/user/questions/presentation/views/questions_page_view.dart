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

class QuestionsPageView extends StatefulWidget {
  final UserTypeEnum currentUserType;
  final Gender selectedGender;
  final int lastQuestionNumber;

  const QuestionsPageView({
    super.key,
    required this.currentUserType,
    required this.selectedGender,
    required this.lastQuestionNumber,
  });

  @override
  State<QuestionsPageView> createState() => _QuestionsPageViewState();
}

class _QuestionsPageViewState extends State<QuestionsPageView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  /// ✅ هنا بنخزن كل الإجابات اللي المستخدم اختارها في الجلسة الحالية
  final Map<String, dynamic> _answers = {};

  @override
  void initState() {
    super.initState();
    _jumpToLastQuestion();
  }

  void _jumpToLastQuestion() {
    final questions = _getQuestions();
    final startIndex = questions.indexWhere(
      (q) => q.questionNumber == widget.lastQuestionNumber,
    );
    log(
      ">>>>>>>>>... startIndex: $startIndex, lastQuestionNumber: ${widget.lastQuestionNumber}",
    );

    if (startIndex != -1) {
      _currentPage = startIndex + 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_currentPage);
        }
      });
    }
  }

  // ─────────────────────────────────────────────────────
  // ✅ Question List Builder - بيتبني كل مرة setState تتنادى
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
        titleKey: 'enter_your_name',
        questionNumber: 5,
        questionCategoryEnum: 'name',
        type: QuestionType.textInput,
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
        titleKey: QuestionsData.genderedKey('are_you_smoker'),
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
        displayKeyMapper: QuestionsData.genderedKey,
      ),
      if (!kCurrentUserData!.isSingle )
        QuestionPageConfig(
          titleKey: 'has_children',
          questionNumber: 11,
          questionCategoryEnum: 'hasChildren',
          items: QuestionsData.yesNo,
          type: QuestionType.selectableList,
        ),
      if (!kCurrentUserData!.isSingle &&
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
      if (!kCurrentUserData!.isSingle&&
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
        items: QuestionsData.genderedJobs,
        type: QuestionType.selectableList,
        showSearch: true,
        searchHintKey: 'search_job',
        displayKeyMapper: null, // ✅ الـ keys نفسها gendered — مش محتاج mapper
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
  // Build
  // ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final questions = _getQuestions();
    final totalPages = questions.length;

    // حماية: لو الصفحة الحالية أكبر من عدد الأسئلة
    if (_currentPage >= totalPages) {
      _currentPage = totalPages - 1;
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
              Builder(
                builder: (context) {
                  final progress = (_currentPage + 1) / totalPages;
                  return QuestionHeader(
                    progress: progress,
                    titleKey: questions[_currentPage].titleKey,
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
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
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

  // ─────────────────────────────────────────────────────
  // ✅ Answer Submission - بيعمل setState عشان القائمة تتحدث
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

    // ✅ 1) نخزن الإجابة في الـ map
    _answers[config.questionCategoryEnum] = answerKey;

    // ✅ 2) نعمل setState عشان _getQuestions() تتنفذ تاني بالشروط الجديدة
    setState(() {});

    // 3) نجهز الإجابات للـ API
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

    // 4) نبعت للـ API
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
    if (_currentPage + 1 < questions.length) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // آخر سؤال → روح للصفحة اللي بعد كده
      context.pushReplacementNamed(AppRouter.kPersonalInfoView);
    }
  }
}
