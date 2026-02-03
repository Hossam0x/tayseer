import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/user/questions/view/widget/question_page_config.dart';
import 'package:tayseer/features/user/questions/view/widget/custom_selectable_list.dart';
import 'package:tayseer/features/user/questions/view/widget/multiselect_chips_widget.dart';
import 'package:tayseer/features/user/questions/view/widget/custom_ios_picker.dart';

class FilterSelectionScreen extends StatelessWidget {
  final String fieldKey;
  final dynamic initialValue;

  const FilterSelectionScreen({
    super.key,
    required this.fieldKey,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(context);
    dynamic tempValue = initialValue;

    return Scaffold(
      body: CustomBackground(
        child: CustomScrollView(
          slivers: [
            // ===== AppBar =====
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

            // ===== Content =====
            SliverPadding(
              padding: EdgeInsets.only(top: 16.h),
              sliver: SliverFillRemaining(
                hasScrollBody: true,
                child: Column(
                  children: [
                    Expanded(
                      child: _buildContent(
                        config,
                        (val) => tempValue = val,
                        context,
                      ),
                    ),

                    // ===== Confirm Button =====
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CustomBotton(
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

  Widget _buildContent(
    QuestionPageConfig config,
    ValueChanged<dynamic> onChanged,
    BuildContext context,
  ) {
    switch (config.type) {
      case QuestionType.selectableList:
        return SelectableListWidget(
          items: config.items ?? [],
          showSearch: config.showSearch,
          searchHintKey: config.searchHintKey,
          onChanged: (key, value) => onChanged(value),
        );
      case QuestionType.multiSelectChips:
        return MultiSelectChipsWidget(
          itemsWithIcons: config.itemsWithIcons ?? {},
          onChanged: (List<String> values) => onChanged(values),
        );
      case QuestionType.picker:
        return CustomIosPicker(
          initialValue: config.initialValue ?? 160,
          minValue: config.minValue ?? 100,
          maxValue: config.maxValue ?? 220,
          unit: config.unit != null ? context.tr(config.unit!) : null,
          onSelectedItemChanged: (value) => onChanged(value),
        );
      default:
        return const SizedBox();
    }
  }

  // --- مخزن البيانات الشامل لجميع فلاتر التطبيق ---
  QuestionPageConfig _getConfig(BuildContext context) {
    switch (fieldKey) {
      // --- 1. قسم العمر والبلد ---
      case 'country':
        return const QuestionPageConfig(
          titleKey: 'country',
          questionNumber: 1,
          questionCategoryEnum: 'location',
          type: QuestionType.selectableList,
          items: ['egypt', 'saudi_arabia', 'emirates', 'kuwait', 'jordan'],
          showSearch: true,
        );
      case 'nationality':
        return const QuestionPageConfig(
          titleKey: 'nationality',
          questionNumber: 2,
          questionCategoryEnum: 'location',
          type: QuestionType.selectableList,
          items: [
            'nationality_egyptian',
            'nationality_saudi',
            'nationality_emirati',
          ],
          showSearch: true,
        );

      // --- 2. بيانات وأنشطة ---
      case 'cv':
        return const QuestionPageConfig(
          titleKey: 'cv_status',
          questionNumber: 0,
          questionCategoryEnum: 'activity',
          type: QuestionType.selectableList,
          items: ['no_preference', 'has_full_cv'],
        );
      case 'verified_id':
        return const QuestionPageConfig(
          titleKey: 'verified_id',
          questionNumber: 0,
          questionCategoryEnum: 'activity',
          type: QuestionType.selectableList,
          items: ['yes', 'no'],
        );
      case 'recently_online':
        return const QuestionPageConfig(
          titleKey: 'recently_online',
          questionNumber: 0,
          questionCategoryEnum: 'activity',
          type: QuestionType.selectableList,
          items: ['active_recently', 'no_preference'],
        );
      case 'gold_account':
        return const QuestionPageConfig(
          titleKey: 'gold_account',
          questionNumber: 0,
          questionCategoryEnum: 'activity',
          type: QuestionType.selectableList,
          items: ['gold_members', 'no_preference'],
        );
      case 'new_member':
        return const QuestionPageConfig(
          titleKey: 'new_member',
          questionNumber: 0,
          questionCategoryEnum: 'activity',
          type: QuestionType.selectableList,
          items: ['recently_joined', 'no_preference'],
        );
      case 'photo_status':
        return const QuestionPageConfig(
          titleKey: 'photo_status',
          questionNumber: 0,
          questionCategoryEnum: 'activity',
          type: QuestionType.selectableList,
          items: ['visible_photo', 'hidden_photo', 'no_preference'],
        );

      // --- 3. بيانات شخصية ---
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
      case 'marital_status':
        return const QuestionPageConfig(
          titleKey: 'marital_status',
          questionNumber: 3,
          questionCategoryEnum: 'personal',
          type: QuestionType.selectableList,
          items: ['single', 'married', 'divorced', 'no_preference'],
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
          ],
          showSearch: true,
          searchHintKey: 'search_jobs',
        );
      case 'education':
        return const QuestionPageConfig(
          showSearch: true,
          titleKey: 'education_level',
          questionNumber: 5,
          questionCategoryEnum: 'personal',
          type: QuestionType.selectableList,
          items: [
            'education_primary',
            'education_secondary',
            'education_diploma',
            'education_bachelor',
            'education_master',
            'education_phd',
            'education_none',
          ],
        );
      case 'hobbies':
        return QuestionPageConfig(
          titleKey: 'hobbies',
          questionNumber: 19,
          questionCategoryEnum: 'personal',
          type: QuestionType.multiSelectChips,
          itemsWithIcons: {
            'hobby_music': AssetsData.kmusicIcon,
            'hobby_sports': AssetsData.ksportsIcon,
            'hobby_travel': AssetsData.ktravelIcon,
            'hobby_reading': AssetsData.kreadingIcon,
            'hobby_cooking': AssetsData.kcookingIcon,
            'hobby_drawing': AssetsData.kdrawingIcon,
          },
        );

      // --- 4. الأهداف ---
      case 'marriage_goal':
        return const QuestionPageConfig(
          titleKey: 'marriage',
          questionNumber: 10,
          questionCategoryEnum: 'goals',
          type: QuestionType.selectableList,
          items: ['year', '2_years', '3_years', 'no_preference'],
        );
      case 'engagement_goal':
        return const QuestionPageConfig(
          titleKey: 'engagement',
          questionNumber: 11,
          questionCategoryEnum: 'goals',
          type: QuestionType.selectableList,
          items: ['year', '2_years', '3_years', 'no_preference'],
        );
      case 'travel_goal':
        return const QuestionPageConfig(
          titleKey: 'travel',
          questionNumber: 12,
          questionCategoryEnum: 'goals',
          type: QuestionType.selectableList,
          items: ['yes_travel', 'no_travel', '3_years', 'no_preference'],
        );
      case 'family_goal':
        return const QuestionPageConfig(
          titleKey: 'family',
          questionNumber: 13,
          questionCategoryEnum: 'goals',
          type: QuestionType.selectableList,
          items: ['yes_children', 'no_children', 'no_preference'],
        );

      // --- 5. الدين والعادات ---
      case 'religious_commitment':
        return const QuestionPageConfig(
          titleKey: 'religious_commitment',
          questionNumber: 15,
          questionCategoryEnum: 'religion',
          type: QuestionType.selectableList,
          items: [
            'religious_none',
            'religious_strict',
            'religious_practicing',
            'no_preference',
          ],
        );
      case 'alcohol':
        return const QuestionPageConfig(
          titleKey: 'alcohol',
          questionNumber: 16,
          questionCategoryEnum: 'religion',
          type: QuestionType.selectableList,
          items: ['alcohol_yes', 'alcohol_no', 'no_preference'],
        );
      case 'smoking':
        return const QuestionPageConfig(
          titleKey: 'smoking',
          questionNumber: 17,
          questionCategoryEnum: 'religion',
          type: QuestionType.selectableList,
          items: ['smoking_yes', 'smoking_no', 'no_preference'],
        );
      case 'hijab':
        return const QuestionPageConfig(
          titleKey: 'hijab',
          questionNumber: 18,
          questionCategoryEnum: 'religion',
          type: QuestionType.selectableList,
          items: ['hijab_yes', 'hijab_no', 'no_preference'],
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
