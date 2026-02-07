enum QuestionType { selectableList, picker, multiSelectChips, textInput }

class QuestionPageConfig {
  final String titleKey;
  final int questionNumber;
  final String questionCategoryEnum;
  final QuestionType type;

  final List<String>? items;
  final bool showSearch;
  final String? searchHintKey;

  final int? minValue;
  final int? maxValue;
  final int? initialValue;
  final String? unit;

  final Map<String, String>? itemsWithIcons;

  // ✅ إضافة خصائص الشرط
  final String? dependsOnQuestion; // اسم السؤال الذي يعتمد عليه
  final String? requiredAnswer; // الإجابة المطلوبة لعرض هذا السؤال

  const QuestionPageConfig({
    required this.titleKey,
    required this.questionNumber,
    required this.questionCategoryEnum,
    required this.type,
    this.items,
    this.showSearch = false,
    this.searchHintKey,
    this.minValue,
    this.maxValue,
    this.initialValue,
    this.unit,
    this.itemsWithIcons,
    this.dependsOnQuestion,
    this.requiredAnswer,
  });
}
