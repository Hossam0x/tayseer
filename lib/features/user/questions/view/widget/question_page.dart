// lib/features/user/questions/view/widget/question_page.dart

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
            // ✅ تخزين كلاهما: key للمنطق الشرطي، value للإرسال للـ Backend
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
          itemsWithIcons: config.itemsWithIcons ?? {},
          primaryColor: AppColors.kprimaryColor,
          onChanged: (List<String> selectedValues) {
            _selectedValue.value = {
              'key': selectedValues,
              'value': selectedValues,
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
              if (val is String) {
                isEnabled = val.trim().isNotEmpty;
              } else if (val is List) {
                isEnabled = val.isNotEmpty;
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: CustomBotton(
                width: context.width,
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
