import 'package:tayseer/features/user/questions/presentation/widgets/categorized_multi_select_widget.dart';
import 'package:tayseer/features/user/questions/presentation/widgets/categorized_single_select_widget.dart';
import 'package:tayseer/features/user/questions/presentation/widgets/custom_ios_picker.dart';
import 'package:tayseer/features/user/questions/presentation/widgets/custom_selectable_list.dart';
import 'package:tayseer/features/user/questions/presentation/widgets/multiselect_chips_widget.dart';
import 'package:tayseer/features/user/questions/data/models/question_page_config.dart';
import 'package:tayseer/features/user/questions/presentation/widgets/text_input_question.dart';
import 'package:tayseer/features/user/questions/presentation/manager/questions_cubit.dart';
import 'package:tayseer/features/user/questions/presentation/manager/questions_state.dart';

import 'package:tayseer/my_import.dart';

class QuestionPage extends StatefulWidget {
  final QuestionPageConfig config;
  final ValueChanged<dynamic> onAnswer;

  const QuestionPage({super.key, required this.config, required this.onAnswer});

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  late final ValueNotifier<dynamic> _selectedValue;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _selectedValue = ValueNotifier<dynamic>(null);
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _selectedValue.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          if (widget.config.subtitleKey != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                context.tr(widget.config.subtitleKey!),
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
    switch (widget.config.type) {
      case QuestionType.selectableList:
        return ValueListenableBuilder(
          valueListenable: _selectedValue,
          builder: (context, selectedValue, _) {
            return SelectableListWidget(
              items: widget.config.items ?? [],
              selectedKey: selectedValue?['key'],
              showSearch: widget.config.showSearch,
              searchHintKey: widget.config.searchHintKey,
              primaryColor: AppColors.kprimaryColor,
              onChanged: (key, value) {
                _selectedValue.value = {'key': key, 'value': value};
              },
            );
          },
        );

      case QuestionType.picker:
        final initialVal = (widget.config.initialValue ?? 0).toString();
        _selectedValue.value = {'key': initialVal, 'value': initialVal};
        return Center(
          child: CustomIosPicker(
            initialValue: widget.config.initialValue ?? 0,
            minValue: widget.config.minValue ?? 0,
            maxValue: widget.config.maxValue ?? 100,
            unit: widget.config.unit != null
                ? context.tr(widget.config.unit!)
                : null,
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
          itemsWithEmoji: widget.config.itemsWithIcons ?? {},
          primaryColor: AppColors.kprimaryColor,
          onChanged: (List<String> selectedKeys) {
            final translatedValuesWithEmoji = selectedKeys.map((key) {
              final emoji = widget.config.itemsWithIcons?[key] ?? '';
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
            controller: _textController,
            onChanged: (value) {
              _selectedValue.value = {'key': value, 'value': value};
            },
          ),
        );

      case QuestionType.categorizedMultiSelectChips:
        return CategorizedMultiSelectWidget(
          initialSelected: [],
          categorizedItems: widget.config.categorizedItems ?? {},
          onChanged: (selectedKeys) {
            final translatedValuesWithEmoji = selectedKeys.map((key) {
              String emoji = '';
              for (var category
                  in (widget.config.categorizedItems ?? {}).values) {
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
          categorizedItems: widget.config.categorizedItems ?? {},
          onChanged: (selectedItems) {
            // selectedItems هنا Map<String, String>
            // ✅ تأكد إنك بتبعت الـ keys مش الترجمة
            _selectedValue.value = {
              'key':
                  selectedItems, // Map<String, String> {categoryKey: itemKey}
              'value': selectedItems, // نفس الـ key
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
                final requiredCategories =
                    widget.config.categorizedItems?.keys.length ?? 0;
                isEnabled = key.length == requiredCategories;
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: CustomBotton(
                width: context.width * 0.9,
                title: isLoading ? context.tr('sending') : context.tr('next'),
                useGradient: isEnabled,
                backGroundcolor: AppColors.kgreyColor,
                onPressed: isEnabled && !isLoading
                    ? () {
                        FocusScope.of(context).unfocus();
                        widget.onAnswer(selectedValue);
                      }
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}
