import 'package:flutter/cupertino.dart';
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
              displayKeyMapper: widget.config.displayKeyMapper,
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
            showAiButton: widget.config.questionCategoryEnum != 'name',
            hintKey: widget.config.questionCategoryEnum == 'name'
                ? 'enter_first_name_hint'
                : null,
            maxLines: widget.config.questionCategoryEnum == 'name' ? 1 : null,
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

      case QuestionType.datePicker:
        return _BirthDatePickerWidget(
          onChanged: (date) {
            // ✅ نبعت التاريخ كـ ISO string (yyyy-MM-dd)
            final formatted =
                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            _selectedValue.value = {'key': formatted, 'value': formatted};
          },
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

// ─────────────────────────────────────────────────────
// ✅ Birth Date Picker Widget (Cupertino Three-Wheel Picker)
// ─────────────────────────────────────────────────────

class _BirthDatePickerWidget extends StatefulWidget {
  final ValueChanged<DateTime> onChanged;

  const _BirthDatePickerWidget({required this.onChanged});

  @override
  State<_BirthDatePickerWidget> createState() => _BirthDatePickerWidgetState();
}

class _BirthDatePickerWidgetState extends State<_BirthDatePickerWidget> {
  // ✅ القيمة الافتراضية: 25 سنة من اليوم
  late int _selectedDay;
  late int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final defaultDate = DateTime(now.year - 25, now.month, now.day);
    _selectedDay = defaultDate.day;
    _selectedMonth = defaultDate.month;
    _selectedYear = defaultDate.year;
    
    // ✅ أبلّغ الـ parent بالقيمة الافتراضية فوراً عشان الزر يتفعّل
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChanged(DateTime(_selectedYear, _selectedMonth, _selectedDay));
    });
  }

  void _showDatePickerModal(BuildContext context) {
    int tempDay = _selectedDay;
    int tempMonth = _selectedMonth;
    int tempYear = _selectedYear;

    // Year list: current-18 down to current-100 (most recent first)
    final int maxYear = DateTime.now().year - 18;
    final int minYear = DateTime.now().year - 100;
    final int yearCount = maxYear - minYear + 1;
    final int initialYearIndex = maxYear - tempYear;

    showCupertinoModalPopup(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return DefaultTextStyle(
              style: const TextStyle(
                decoration: TextDecoration.none,
                fontFamily: 'IBMPlexSansArabic',
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── drag handle ──
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 4),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // ── header with title only (no Save/Cancel buttons) ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Text(
                        context.tr('choose_birth_date'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.kscandryTextColor,
                        ),
                      ),
                    ),

                    // ── divider ──
                    Divider(height: 1, color: const Color(0xFFE0E0E0)),

                    // ── column labels ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                      child: Row(
                        children: [
                          _pickerLabel(context.tr('day')),
                          _pickerLabel(context.tr('month')),
                          _pickerLabel(context.tr('year')),
                        ],
                      ),
                    ),

                    // ── three wheels ──
                    SizedBox(
                      height: 200,
                      child: Row(
                        children: [
                          // Day
                          Expanded(
                            child: _buildCupertinoWheel(
                              initialItem: tempDay - 1,
                              itemCount: 31,
                              labelBuilder: (i) =>
                                  (i + 1).toString().padLeft(2, '0'),
                              onChanged: (i) {
                                tempDay = i + 1;
                              },
                              hasDividerRight: true,
                            ),
                          ),
                          // Month
                          Expanded(
                            child: _buildCupertinoWheel(
                              initialItem: tempMonth - 1,
                              itemCount: 12,
                              labelBuilder: (i) =>
                                  (i + 1).toString().padLeft(2, '0'),
                              onChanged: (i) {
                                tempMonth = i + 1;
                              },
                              hasDividerRight: true,
                            ),
                          ),
                          // Year
                          Expanded(
                            child: _buildCupertinoWheel(
                              initialItem: initialYearIndex,
                              itemCount: yearCount,
                              labelBuilder: (i) => '${maxYear - i}',
                              onChanged: (i) {
                                tempYear = maxYear - i;
                              },
                              hasDividerRight: false,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // safe-area bottom padding
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 16,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      // عند الإغلاق، حفظ التاريخ المختار
      setState(() {
        _selectedDay = tempDay;
        _selectedMonth = tempMonth;
        _selectedYear = tempYear;
      });
      widget.onChanged(DateTime(_selectedYear, _selectedMonth, _selectedDay));
    });
  }

  // ── helper: column label ──
  Widget _pickerLabel(String text) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.kprimaryColor,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  // ── helper: single Cupertino wheel ──
  Widget _buildCupertinoWheel({
    required int initialItem,
    required int itemCount,
    required String Function(int) labelBuilder,
    required ValueChanged<int> onChanged,
    required bool hasDividerRight,
  }) {
    return Container(
      decoration: hasDividerRight
          ? BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: const Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
            )
          : null,
      child: CupertinoPicker(
        scrollController: FixedExtentScrollController(initialItem: initialItem),
        itemExtent: 48,
        diameterRatio: 1.4,
        useMagnifier: true,
        magnification: 1.25,
        squeeze: 1.0,
        selectionOverlay: Container(
          decoration: BoxDecoration(
            color: AppColors.kprimaryColor.withOpacity(0.07),
            border: Border(
              top: BorderSide(
                color: AppColors.kprimaryColor.withOpacity(0.3),
                width: 1.5,
              ),
              bottom: BorderSide(
                color: AppColors.kprimaryColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
          ),
        ),
        onSelectedItemChanged: onChanged,
        children: List.generate(
          itemCount,
          (i) => Center(
            child: Text(
              labelBuilder(i),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.kscandryTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final day = _selectedDay.toString().padLeft(2, '0');
    final month = _selectedMonth.toString().padLeft(2, '0');
    final year = _selectedYear.toString();
    final formatted = isArabic ? '$day/$month/$year' : '$month/$day/$year';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ✅ عرض التاريخ المختار
          GestureDetector(
            onTap: () => _showDatePickerModal(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                formatted,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kscandryTextColor,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
