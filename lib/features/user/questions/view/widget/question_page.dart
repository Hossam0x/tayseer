// lib/features/user/questions/view/widget/question_page.dart

import 'package:tayseer/features/user/questions/view/widget/categorized_multi_select_widget.dart';
import 'package:tayseer/features/user/questions/view/widget/categorized_single_select_widget.dart';
import 'package:tayseer/features/user/questions/view/widget/custom_ios_picker.dart';
import 'package:tayseer/features/user/questions/view/widget/custom_selectable_list.dart';
import 'package:tayseer/features/user/questions/view/widget/multiselect_chips_widget.dart';
import 'package:tayseer/features/user/questions/view/widget/question_page_config.dart';
import 'package:tayseer/features/user/questions/view/widget/text_input_question.dart';
import 'package:tayseer/features/user/questions/view_model/questions_cubit.dart';
import 'package:tayseer/features/user/questions/view_model/questions_state.dart';

import '../../../../../my_import.dart';

class QuestionPage extends StatelessWidget {
  final QuestionPageConfig config;
  final ValueChanged<dynamic> onAnswer;

  QuestionPage({super.key, required this.config, required this.onAnswer});

  final ValueNotifier<dynamic> _selectedValue = ValueNotifier<dynamic>(null);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // ✅ عرض الـ Subtitle إذا كان موجوداً
          if (config.subtitleKey != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                context.tr(config.subtitleKey!),
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.kgreyColor,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],

          /// CONTENT
          Expanded(child: _buildContent(context)),

          /// NEXT BUTTON
          _buildNextButton(context),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (config.type) {
      case QuestionType.selectableList:
        return SelectableListWidget(
          items: config.items ?? [],
          showSearch: config.showSearch,
          searchHintKey: config.searchHintKey,
          primaryColor: AppColors.kprimaryColor,
          onChanged: (key, value) {
            _selectedValue.value = {'key': key, 'value': value};
          },
        );

      case QuestionType.picker:
        final initialVal = (config.initialValue ?? 0).toString();
        _selectedValue.value = {'key': initialVal, 'value': initialVal};
        return Center(
          child: CustomIosPicker(
            initialValue: config.initialValue ?? 0,
            minValue: config.minValue ?? 0,
            maxValue: config.maxValue ?? 100,
            unit: config.unit != null ? context.tr(config.unit!) : null,
            primaryColor: AppColors.kprimaryColor,
            onSelectedItemChanged: (value) {
              _selectedValue.value = {
                'key': value.toString(),
                'value': value.toString(),
              };
            },
          ),
        );

      case QuestionType.multiSelectChips:
        return MultiSelectChipsWidget(
          itemsWithEmoji: config.itemsWithIcons ?? {},
          primaryColor: AppColors.kprimaryColor,
          onChanged: (List<String> selectedKeys) {
            // ✅ إضافة الإيموجي مع النص المترجم
            final translatedValuesWithEmoji = selectedKeys.map((key) {
              final emoji = config.itemsWithIcons?[key] ?? '';
              return '$emoji ${context.tr(key)}';
            }).toList();

            _selectedValue.value = {
              'key': selectedKeys,
              'value': translatedValuesWithEmoji,
            };
          },
        );

      case QuestionType.textInput:
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: TextInputQuestion(
            onChanged: (value) {
              _selectedValue.value = {'key': value, 'value': value};
            },
          ),
        );

      case QuestionType.categorizedMultiSelectChips:
        return CategorizedMultiSelectWidget(
          initialSelected:  [],
          categorizedItems: config.categorizedItems ?? {},
          onChanged: (selectedKeys) {
            // ✅ إضافة الإيموجي مع النص المترجم
            final translatedValuesWithEmoji = selectedKeys.map((key) {
              // البحث عن الإيموجي في جميع الفئات
              String emoji = '';
              for (var category in (config.categorizedItems ?? {}).values) {
                if (category.containsKey(key)) {
                  emoji = category[key] ?? '';
                  break;
                }
              }
              return '$emoji ${context.tr(key)}';
            }).toList();

            _selectedValue.value = {
              'key': selectedKeys,
              'value': translatedValuesWithEmoji,
            };
          },
          primaryColor: AppColors.kprimaryColor,
        );

      case QuestionType.categorizedSingleSelectChips:
        return CategorizedSingleSelectWidget(
          categorizedItems: config.categorizedItems ?? {},
          onChanged: (selectedItems) {
            // ✅ إضافة الإيموجي مع النص المترجم لكل فئة
            final valuesWithEmoji = selectedItems.entries.map((entry) {
              final categoryKey = entry.key;
              final itemKey = entry.value;
              final emoji =
                  config.categorizedItems?[categoryKey]?[itemKey] ?? '';
              return '${context.tr(categoryKey)}: $emoji ${context.tr(itemKey)}';
            }).toList();

            _selectedValue.value = {
              'key': selectedItems,
              'value': valuesWithEmoji,
            };
          },
          primaryColor: AppColors.kprimaryColor,
        );
    }
  }

  Widget _buildNextButton(BuildContext context) {
    return ValueListenableBuilder<dynamic>(
      valueListenable: _selectedValue,
      builder: (context, selectedValue, _) {
        return BlocBuilder<QuestionsCubit, QuestionsState>(
          builder: (context, state) {
            final isLoading = state.answerQuestionsState == CubitStates.loading;

            bool isEnabled = false;
            if (selectedValue is Map) {
              final val = selectedValue['value'];
              final key = selectedValue['key'];

              if (val is String) {
                isEnabled = val.trim().isNotEmpty;
              } else if (val is List) {
                isEnabled = val.isNotEmpty;
              } else if (key is Map) {
                // ✅ للـ categorizedSingleSelectChips
                final requiredCategories =
                    config.categorizedItems?.keys.length ?? 0;
                isEnabled = key.length == requiredCategories;
              }
            }

            return Padding(
              padding:  EdgeInsets.only(bottom: 30),
              child: CustomBotton(
                width: context.width*0.9,
                title: isLoading ? context.tr('sending') : context.tr('next'),
                useGradient: isEnabled,
                backGroundcolor: AppColors.kgreyColor,
                onPressed: isEnabled && !isLoading
                    ? () => onAnswer(selectedValue)
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}
