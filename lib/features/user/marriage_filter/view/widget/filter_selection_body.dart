import 'package:tayseer/core/constant/marriage_constants.dart';
import 'package:tayseer/features/user/questions/data/models/questions_data.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/user/questions/data/models/question_page_config.dart';
import 'package:tayseer/features/user/questions/presentation/widgets/custom_selectable_list.dart';
import 'package:tayseer/features/user/questions/presentation/widgets/multiselect_chips_widget.dart';
import 'package:tayseer/features/user/questions/presentation/widgets/custom_ios_picker.dart';

class FilterSelectionScreen extends StatefulWidget {
  final String fieldKey;
  final dynamic initialValue;

  const FilterSelectionScreen({
    super.key,
    required this.fieldKey,
    this.initialValue,
  });

  @override
  State<FilterSelectionScreen> createState() => _FilterSelectionScreenState();
}

class _FilterSelectionScreenState extends State<FilterSelectionScreen> {
  late dynamic tempValue;

  @override
  void initState() {
    super.initState();
    tempValue = widget.initialValue;

    // ✅ إصلاح الطول: لو الـ fieldKey هو height والقيمة null
    // نحط القيمة الافتراضية مباشرة عشان لو المستخدم ماحركش الـ picker يتحفظ
    if (widget.fieldKey == 'height' && tempValue == null) {
      tempValue = 170;
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(context);

    return Scaffold(
      body: CustomBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
              title: Text(
                context.tr(config.titleKey),
                style: Styles.textStyle18Bold,
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              floating: false,
              flexibleSpace: Container(
                decoration: const BoxDecoration(color: Colors.transparent),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.only(top: 16.h),
              sliver: SliverFillRemaining(
                hasScrollBody: true,
                child: Column(
                  children: [
                    Expanded(child: _buildContent(config, context)),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CustomBotton(
                        useGradient: true,
                        width: context.width,
                        title: context.tr('confirm'),
                        onPressed: () => Navigator.pop(context, tempValue),
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

  Widget _buildContent(QuestionPageConfig config, BuildContext context) {
    switch (config.type) {
      case QuestionType.selectableList:
        // ✅ displayKeyMapper للـ fields اللي محتاجة gendered keys
        String Function(String)? displayKeyMapper;
        if (widget.fieldKey == 'job' ||
            widget.fieldKey == 'religiousCommitment') {
          displayKeyMapper = QuestionsData.genderedKey;
        }
        return SelectableListWidget(
          items: config.items ?? [],
          selectedKey: tempValue,
          showSearch: config.showSearch,
          searchHintKey: config.searchHintKey,
          displayKeyMapper: displayKeyMapper,
          onChanged: (key, value) {
            setState(() => tempValue = key);
          },
        );

      case QuestionType.multiSelectChips:
        return MultiSelectChipsWidget(
          itemsWithEmoji: config.itemsWithIcons ?? {},
          initialSelected: tempValue is List<String>
              ? tempValue as List<String>
              : [],
          onChanged: (List<String> values) {
            setState(() => tempValue = values);
          },
        );

      case QuestionType.picker:
        return CustomIosPicker(
          initialValue: tempValue ?? config.initialValue ?? 170,
          minValue: config.minValue ?? 140,
          maxValue: config.maxValue ?? 220,
          unit: config.unit != null ? context.tr(config.unit!) : null,
          onSelectedItemChanged: (value) {
            // ✅ يتحدث في كل حركة بدون setState لأنه مش بيحتاج rebuild
            tempValue = value;
          },
        );

      default:
        return const SizedBox();
    }
  }

  QuestionPageConfig _getConfig(BuildContext context) {
    switch (widget.fieldKey) {
      // ============================================
      // البلد والجنسية — ✅ بدون no_preference
      // ============================================
      case 'country':
        return const QuestionPageConfig(
          titleKey: 'country',
          questionNumber: 1,
          questionCategoryEnum: 'location',
          type: QuestionType.selectableList,
          items: [
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
          showSearch: true,
        );

      case 'nationality':
        return const QuestionPageConfig(
          titleKey: 'nationality',
          questionNumber: 2,
          questionCategoryEnum: 'location',
          type: QuestionType.selectableList,
          items: [
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
          showSearch: true,
        );

      // ============================================
      // بيانات وأنشطة
      // ============================================
      case 'isVerified':
        return const QuestionPageConfig(
          titleKey: 'verified_id',
          questionNumber: 0,
          questionCategoryEnum: 'activity',
          type: QuestionType.selectableList,
          items: ['yes', 'no', 'no_preference'],
        );

      case 'isNew':
        return const QuestionPageConfig(
          titleKey: 'new_member',
          questionNumber: 0,
          questionCategoryEnum: 'activity',
          type: QuestionType.selectableList,
          items: ['recently_joined', 'no_preference'],
        );

      case 'imageBlur':
        return const QuestionPageConfig(
          titleKey: 'photo_status',
          questionNumber: 0,
          questionCategoryEnum: 'activity',
          type: QuestionType.selectableList,
          items: ['visible_photo', 'hidden_photo', 'no_preference'],
        );

      case 'goldAccount':
        return const QuestionPageConfig(
          titleKey: 'gold_members',
          questionNumber: 0,
          questionCategoryEnum: 'activity',
          type: QuestionType.selectableList,
          items: ['gold_account', 'no_preference'],
        );

      // ============================================
      // بيانات شخصية
      // ============================================
      case 'height':
        return const QuestionPageConfig(
          titleKey: 'height',
          questionNumber: 4,
          questionCategoryEnum: 'personal',
          type: QuestionType.picker,
          minValue: 140,
          maxValue: 220,
          initialValue: 170,
          unit: 'cm',
        );

      case 'maritalStatus':
        return const QuestionPageConfig(
          titleKey: 'marital_status',
          questionNumber: 3,
          questionCategoryEnum: 'personal',
          type: QuestionType.selectableList,
          items: [
            'social_single',
            'social_married',
            'social_divorced',
            'social_widowed',
            'no_preference',
          ],
        );

      case 'job':
        return const QuestionPageConfig(
          titleKey: 'job',
          questionNumber: 6,
          questionCategoryEnum: 'personal',
          type: QuestionType.selectableList,
          items: [
            'job_student',
            'job_teacher',
            'job_engineer',
            'job_doctor',
            'job_nurse',
            'job_driver',
            'job_business',
            'job_unemployed',
            'job_other',
            'no_preference',
          ],
          showSearch: true,
          searchHintKey: 'search_jobs',
        );

      case 'educationLevel':
        return const QuestionPageConfig(
          titleKey: 'education_level',
          questionNumber: 5,
          questionCategoryEnum: 'personal',
          type: QuestionType.selectableList,
          showSearch: true,
          items: [
            'education_primary',
            'education_secondary',
            'education_diploma',
            'education_bachelor',
            'education_master',
            'education_phd',
            'education_none',
            'no_preference',
          ],
        );

      case 'hobbies':
        return QuestionPageConfig(
          titleKey: 'hobbies',
          questionNumber: 19,
          questionCategoryEnum: 'personal',
          type: QuestionType.multiSelectChips,
          itemsWithIcons: MarriageConstants.hobbyEmojiMap,
        );

      // ============================================
      // الأهداف
      // ============================================
      case 'goalMarry':
        return const QuestionPageConfig(
          titleKey: 'marriage',
          questionNumber: 10,
          questionCategoryEnum: 'goals',
          type: QuestionType.selectableList,
          items: [
            'period_1_3_months',
            'period_4_7_months',
            'period_7_12_months',
            'period_1_2_years',
            'no_preference',
          ],
        );

      case 'goalEngagment':
        return const QuestionPageConfig(
          titleKey: 'engagement',
          questionNumber: 11,
          questionCategoryEnum: 'goals',
          type: QuestionType.selectableList,
          items: [
            'timeline_immediate',
            'timeline_three_months',
            'timeline_six_months',
            'timeline_year',
            'no_preference',
          ],
        );

      case 'goalTravel':
        return const QuestionPageConfig(
          titleKey: 'travel',
          questionNumber: 12,
          questionCategoryEnum: 'goals',
          type: QuestionType.selectableList,
          items: [
            'intend_travel_abroad',
            'do_not_intend_travel',
            'no_preference',
          ],
        );

      case 'goalChildren':
        return const QuestionPageConfig(
          titleKey: 'family',
          questionNumber: 13,
          questionCategoryEnum: 'goals',
          type: QuestionType.selectableList,
          items: [
            'no_problem_children',
            'do_not_want_children',
            'no_preference',
          ],
        );

      // ============================================
      // الدين والعادات
      // ============================================
      case 'religiousCommitment':
        return const QuestionPageConfig(
          titleKey: 'religious_commitment',
          questionNumber: 15,
          questionCategoryEnum: 'religion',
          type: QuestionType.selectableList,
          items: [
            'religion_full',
            'religion_partial',
            'religion_sometimes',
            'religion_none',
            'no_preference',
          ],
        );

      case 'smoker':
        return const QuestionPageConfig(
          titleKey: 'smoking',
          questionNumber: 17,
          questionCategoryEnum: 'religion',
          type: QuestionType.selectableList,
          items: ['yes', 'no', 'no_preference'],
        );

      case 'wearHijab':
        return const QuestionPageConfig(
          titleKey: 'hijab',
          questionNumber: 18,
          questionCategoryEnum: 'religion',
          type: QuestionType.selectableList,
          items: ['yes', 'no', 'no_preference'],
        );

      default:
        return const QuestionPageConfig(
          titleKey: 'select_option',
          questionNumber: 0,
          questionCategoryEnum: 'general',
          type: QuestionType.selectableList,
          items: ['no_preference'],
        );
    }
  }
}
