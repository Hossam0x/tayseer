import 'package:tayseer/features/user/questions/refact_question/widget/question_page_config.dart';
import 'package:tayseer/features/user/questions/view/widget/custom_ios_picker.dart';
import 'package:tayseer/features/user/questions/view/widget/custom_selectable_list.dart';
import 'package:tayseer/features/user/questions/view_model/questions_cubit.dart';
import 'package:tayseer/features/user/questions/view_model/questions_state.dart';
import 'package:tayseer/my_import.dart';

class QuestionPage extends StatelessWidget {
  final QuestionPageConfig config;
  final ValueChanged<String> onAnswer;

  QuestionPage({super.key, required this.config, required this.onAnswer});

  final ValueNotifier<String?> _selectedValue = ValueNotifier<String?>(null);

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
            _selectedValue.value = value;
          },
        );

      case QuestionType.picker:
        // للـ Picker نحتاج نحدد القيمة الأولية
        _selectedValue.value = (config.initialValue ?? 0).toString();

        return Center(
          child: CustomIosPicker(
            initialValue: config.initialValue ?? 0,
            minValue: config.minValue ?? 0,
            maxValue: config.maxValue ?? 100,
            unit: config.unit != null ? context.tr(config.unit!) : null,
            primaryColor: AppColors.kprimaryColor,
            onSelectedItemChanged: (value) {
              _selectedValue.value = value.toString();
            },
          ),
        );
    }
  }

  Widget _buildNextButton(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: _selectedValue,
      builder: (context, selectedValue, _) {
        return BlocBuilder<QuestionsCubit, QuestionsState>(
          builder: (context, state) {
            final isLoading = state.answerQuestionsState == CubitStates.loading;
            final isEnabled = selectedValue != null && selectedValue.isNotEmpty;

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
