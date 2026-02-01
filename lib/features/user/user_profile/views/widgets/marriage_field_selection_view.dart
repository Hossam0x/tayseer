// features/user/user_profile/views/widgets/marriage_field_selection_view.dart

import 'package:tayseer/features/user/questions/view/widget/custom_ios_picker.dart';
import 'package:tayseer/features/user/questions/view/widget/custom_selectable_list.dart';
import 'package:tayseer/my_import.dart';

class MarriageFieldSelectionView extends StatefulWidget {
  final String fieldName;
  final String? currentValue;
  final Function(String) onValueSelected;

  const MarriageFieldSelectionView({
    super.key,
    required this.fieldName,
    required this.currentValue,
    required this.onValueSelected,
  });

  @override
  State<MarriageFieldSelectionView> createState() =>
      _MarriageFieldSelectionViewState();
}

class _MarriageFieldSelectionViewState
    extends State<MarriageFieldSelectionView> {
  String? _selectedValue;
  int? _selectedPickerValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.currentValue;

    debugPrint('═══════════════════════════════════════');
    debugPrint('🎯 MarriageFieldSelectionView INIT');
    debugPrint('Field: ${widget.fieldName}');
    debugPrint('Current Value: ${widget.currentValue}');
    debugPrint('═══════════════════════════════════════');
  }

  @override
  Widget build(BuildContext context) {
    final fieldData = _getFieldData(widget.fieldName, widget.currentValue);
    final type = fieldData['type'] as String?;

    return Scaffold(
      backgroundColor: AppColors.kWhiteColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10.h),

            // ⭐ Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 40.w),

                  // Title
                  Text(
                    context.tr(fieldData['titleKey'] as String),
                    style: Styles.textStyle18.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary800,
                    ),
                  ),

                  // Close button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: AppColors.secondary800,
                      size: 24.w,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ⭐ Content based on type
            if (type == 'picker')
              _buildPickerContent(context, fieldData)
            else if (type == 'textarea')
              _buildTextAreaContent(context, fieldData)
            else if (type == 'multiselect')
              _buildMultiSelectContent(context, fieldData)
            else
              _buildListContent(context, fieldData),

            // ⭐ Save Button
            _buildSaveButton(context, type, fieldData),
          ],
        ),
      ),
    );
  }

  // ⭐ بناء محتوى Picker
  Widget _buildPickerContent(
    BuildContext context,
    Map<String, dynamic> fieldData,
  ) {
    final initialValue = fieldData['currentValue'] as int;

    if (_selectedPickerValue == null) {
      _selectedPickerValue = initialValue;
    }

    return Expanded(
      child: Center(
        child: CustomIosPicker(
          initialValue: initialValue,
          minValue: fieldData['minValue'] as int,
          maxValue: fieldData['maxValue'] as int,
          unit: fieldData['unit'] as String?,
          primaryColor: AppColors.kprimaryColor,
          onSelectedItemChanged: (value) {
            setState(() {
              _selectedPickerValue = value;
            });
          },
        ),
      ),
    );
  }

  // ⭐⭐⭐ بناء محتوى TextArea (للسيرة الذاتية)
  Widget _buildTextAreaContent(
    BuildContext context,
    Map<String, dynamic> fieldData,
  ) {
    final maxLength = fieldData['maxLength'] as int? ?? 500;
    final controller = TextEditingController(text: widget.currentValue);

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            TextField(
              controller: controller,
              maxLines: 10,
              maxLength: maxLength,
              decoration: InputDecoration(
                hintText: context.tr('tell_us_more_about_yourself'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: AppColors.kprimaryColor,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _selectedValue = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // ⭐⭐⭐ بناء محتوى MultiSelect (للاهتمامات والهوايات) - FIXED
  Widget _buildMultiSelectContent(
    BuildContext context,
    Map<String, dynamic> fieldData,
  ) {
    final List<String> items = List<String>.from(fieldData['items']);
    final List<String> selectedItems = [];

    // Parse current value if it's a comma-separated string
    if (widget.currentValue != null && widget.currentValue!.isNotEmpty) {
      selectedItems.addAll(widget.currentValue!.split(', '));
    }

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: _MultiSelectChips(
          items: items,
          initialSelected: selectedItems,
          primaryColor: AppColors.kprimaryColor,
          onChanged: (selected) {
            setState(() {
              _selectedValue = selected.join(', ');
            });
          },
        ),
      ),
    );
  }

  // ⭐ بناء محتوى القائمة - بدون translationMap
  Widget _buildListContent(
    BuildContext context,
    Map<String, dynamic> fieldData,
  ) {
    final List<String> items = List<String>.from(fieldData['items']);

    // ⭐ البحث عن الـ key المناسب للقيمة الحالية باستخدام context.tr
    String? initialSelectedKey;
    if (widget.currentValue != null &&
        widget.currentValue != 'اختر' &&
        widget.currentValue!.isNotEmpty) {
      for (var key in items) {
        if (context.tr(key) == widget.currentValue) {
          initialSelectedKey = key;
          break;
        }
      }
    }

    debugPrint('🔍 Initial Selected Key: $initialSelectedKey');
    debugPrint('🔍 Items count: ${items.length}');

    return Expanded(
      child: Container(
        color: AppColors.kWhiteColor,
        child: SelectableListWidget(
          items: items,
          showSearch: fieldData['showSearch'] as bool,
          searchHintKey: fieldData['searchHint'] as String?,
          initialSelectedKey: initialSelectedKey,
          primaryColor: AppColors.kprimaryColor,
          onChanged: (key, translatedValue) {
            setState(() {
              // ⭐ احفظ الترجمة العربية مباشرة
              _selectedValue = translatedValue;

              debugPrint('💾 Selected Key: $key');
              debugPrint('💾 Selected Value: $_selectedValue');
            });
          },
        ),
      ),
    );
  }

  // ⭐ زر الحفظ
  Widget _buildSaveButton(
    BuildContext context,
    String? type,
    Map<String, dynamic> fieldData,
  ) {
    final isEnabled = type == 'picker'
        ? _selectedPickerValue != null
        : _selectedValue != null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      child: CustomBotton(
        width: context.width,
        title: context.tr('save'),
        useGradient: isEnabled,
        backGroundcolor: AppColors.kgreyColor,
        onPressed: isEnabled
            ? () {
                String valueToSave;

                if (type == 'picker') {
                  valueToSave = fieldData['unit'] != null
                      ? '$_selectedPickerValue ${fieldData['unit']}'
                      : _selectedPickerValue.toString();
                } else {
                  valueToSave = _selectedValue!;
                }

                debugPrint('💾 Saving value: "$valueToSave"');
                widget.onValueSelected(valueToSave);
                Navigator.pop(context);
              }
            : null,
      ),
    );
  }

  // ⭐⭐⭐ الحصول على بيانات الحقل - بدون translationMap
  Map<String, dynamic> _getFieldData(String fieldKey, String? currentValue) {
    switch (fieldKey) {
      case 'country':
        return {
          'titleKey': 'select_country_title',
          'items': [
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
          'showSearch': true,
          'searchHint': 'search_country',
        };

      case 'nationality':
        return {
          'titleKey': 'select_nationality_title',
          'items': [
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
          'showSearch': true,
          'searchHint': 'search_nationality',
        };

      case 'religion':
        return {
          'titleKey': 'select_religion_title',
          'items': ['religion_muslim', 'religion_christian'],
          'showSearch': false,
        };

      case 'age':
        return {
          'titleKey': 'select_age_title',
          'type': 'picker',
          'minValue': 18,
          'maxValue': 70,
          'currentValue': int.tryParse(currentValue ?? '25') ?? 25,
        };

      case 'height':
        return {
          'titleKey': 'select_height_title',
          'type': 'picker',
          'minValue': 140,
          'maxValue': 220,
          'unit': 'cm',
          'currentValue':
              int.tryParse(
                currentValue
                        ?.replaceAll(' سم', '')
                        .replaceAll('cm', '')
                        .trim() ??
                    '170',
              ) ??
              170,
        };

      case 'weight':
        return {
          'titleKey': 'select_weight_title',
          'type': 'picker',
          'minValue': 40,
          'maxValue': 150,
          'unit': 'kg',
          'currentValue':
              int.tryParse(
                currentValue
                        ?.replaceAll(' كجم', '')
                        .replaceAll('kg', '')
                        .trim() ??
                    '70',
              ) ??
              70,
        };

      case 'skinColor':
      case 'ethnicity':
        return {
          'titleKey': 'select_skin_color_title',
          'items': [
            'skin_very_light',
            'skin_light',
            'skin_medium',
            'skin_dark',
            'skin_very_dark',
          ],
          'showSearch': false,
        };

      case 'healthStatus':
        return {
          'titleKey': 'select_health_status_title',
          'items': [
            'health_excellent',
            'health_good',
            'health_followup',
            'health_chronic',
            'health_unstable',
          ],
          'showSearch': false,
        };

      case 'religiousCommitment':
      case 'religiosity':
        return {
          'titleKey': 'select_religiosity_title',
          'items': [
            'religion_full',
            'religion_partial',
            'religion_sometimes',
            'religion_none',
          ],
          'showSearch': false,
        };

      case 'smoker':
      case 'smoking':
        return {
          'titleKey': 'select_smoking_title',
          'items': ['yes', 'no'],
          'showSearch': false,
        };

      case 'choose_job':
      case 'occupation':
        return {
          'titleKey': 'select_occupation_title',
          'items': [
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
          'showSearch': true,
          'searchHint': 'search_occupation',
        };

      // case 'jobTitle':
      case 'education_level':
        return {
          'titleKey': 'education_level',
          'items': [
            'education_primary',
            'education_secondary',
            'education_diploma',
            'education_bachelor',
            'education_master',
            'education_phd',
            'education_none',
          ],
          'showSearch': false,
        };

      // case 'professionalLevel':
      case 'choose_employer':
        return {
          'titleKey': 'select_employer',
          'items': [
            'employer_government',
            'employer_private',
            'employer_institution',
            'employer_freelance',
            'employer_unemployed',
          ],
          'showSearch': false,
        };

      case 'socialStatus':
      case 'maritalStatus':
        return {
          'titleKey': 'select_marital_status_title',
          'items': [
            'social_single',
            'social_married',
            'social_divorced',
            'social_widowed',
          ],
          'showSearch': false,
        };

      case 'previouslyMarried':
        return {
          'titleKey': 'select_previously_married_title',
          'items': ['yes', 'no'],
          'showSearch': false,
        };

      case 'hasChildren':
        return {
          'titleKey': 'select_has_children_title',
          'items': ['yes', 'no'],
          'showSearch': false,
        };

      case 'childrenNumber':
        return {
          'titleKey': 'select_children_number_title',
          'items': ['child_1', 'child_2', 'child_3', 'child_4', 'child_5'],
          'showSearch': false,
        };

      case 'childrenLiveWithYou':
      case 'childrenLivingStatus':
        return {
          'titleKey': 'select_children_live_with_you_title',
          'items': ['yes', 'no', 'not_applicable'],
          'showSearch': false,
        };

      // ═══════════════════════════════════════════════════════════════
      // ⭐⭐⭐ قسم الأهداف (Goals)
      // ═══════════════════════════════════════════════════════════════

      case 'communicationTimeline':
      case 'marry':
        return {
          'titleKey': 'select_communication_timeline_title',
          'items': ['timeline_immediate', 'timeline_week', 'timeline_month'],
          'showSearch': false,
        };

      case 'engagementTimeline':
      case 'engagement':
        return {
          'titleKey': 'select_engagement_timeline_title',
          'items': [
            'timeline_immediate',
            'timeline_three_months',
            'timeline_six_months',
            'timeline_year',
          ],
          'showSearch': false,
        };

      case 'marriageTimeline':
        return {
          'titleKey': 'select_marriage_timeline_title',
          'items': [
            'timeline_immediate',
            'timeline_three_months',
            'timeline_six_months',
            'timeline_year',
          ],
          'showSearch': false,
        };

      case 'dowry':
      case 'children':
        return {
          'titleKey': 'select_dowry_title',
          'items': [
            'dowry_flexible',
            'dowry_under_10k',
            'dowry_10k_30k',
            'dowry_30k_50k',
            'dowry_over_50k',
          ],
          'showSearch': false,
        };

      case 'travelPreference':
      case 'travel':
        return {
          'titleKey': 'select_travel_preference_title',
          'items': [
            'travel_willing',
            'travel_not_willing',
            'travel_maybe',
            'travel_after_marriage',
          ],
          'showSearch': false,
        };

      // ═══════════════════════════════════════════════════════════════
      // ⭐⭐⭐ قسم تعرف عليّ أكثر (Get to Know Me)
      // ═══════════════════════════════════════════════════════════════

      case 'bio':
      case 'myDescription':
        return {
          'titleKey': 'select_bio_title',
          'type': 'textarea',
          'maxLength': 500,
        };

      case 'interests':
        return {
          'titleKey': 'select_interests_title',
          'type': 'multiselect',
          'items': [
            'hobby_music',
            'hobby_sports',
            'hobby_travel',
            'hobby_reading',
            'hobby_cooking',
            'hobby_drawing',
            'hobby_mountain_climbing',
            'hobby_meditation',
            'hobby_photography',
            'hobby_sewing',
            'hobby_writing',
            'hobby_cycling',
            'hobby_tourism',
          ],
        };

      case 'hobbies':
        return {
          'titleKey': 'select_hobbies_title',
          'type': 'multiselect',
          'items': [
            'hobby_music',
            'hobby_sports',
            'hobby_travel',
            'hobby_reading',
            'hobby_cooking',
            'hobby_drawing',
            'hobby_mountain_climbing',
            'hobby_meditation',
            'hobby_photography',
            'hobby_sewing',
            'hobby_writing',
            'hobby_cycling',
            'hobby_tourism',
          ],
        };

      default:
        return {'titleKey': fieldKey, 'items': <String>[], 'showSearch': false};
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// ⭐ MultiSelect Chips Widget (للاهتمامات والهوايات) - FIXED
// ═══════════════════════════════════════════════════════════════

class _MultiSelectChips extends StatefulWidget {
  final List<String> items;
  final List<String> initialSelected;
  final Color primaryColor;
  final ValueChanged<List<String>> onChanged;

  const _MultiSelectChips({
    required this.items,
    required this.initialSelected,
    required this.primaryColor,
    required this.onChanged,
  });

  @override
  State<_MultiSelectChips> createState() => _MultiSelectChipsState();
}

class _MultiSelectChipsState extends State<_MultiSelectChips> {
  final Set<String> _selectedKeys = {};

  @override
  void initState() {
    super.initState();
    // ⭐ DON'T use context.tr() here - move it to didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ⭐ NOW it's safe to use context.tr()
    if (_selectedKeys.isEmpty) {
      for (var item in widget.items) {
        final translated = context.tr(item);
        if (widget.initialSelected.contains(translated)) {
          _selectedKeys.add(item);
        }
      }
      debugPrint('🎯 Initialized selected keys: $_selectedKeys');
    }
  }

  void _toggleSelection(String key) {
    setState(() {
      if (_selectedKeys.contains(key)) {
        _selectedKeys.remove(key);
      } else {
        _selectedKeys.add(key);
      }
    });

    final translatedValues = _selectedKeys
        .map((key) => context.tr(key))
        .toList();
    widget.onChanged(translatedValues);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 12.w,
        runSpacing: 12.h,
        children: widget.items.map((key) {
          final isSelected = _selectedKeys.contains(key);
          final translatedText = context.tr(key);

          return GestureDetector(
            onTap: () => _toggleSelection(key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected ? widget.primaryColor : AppColors.kWhiteColor,
                border: Border.all(
                  color: isSelected
                      ? widget.primaryColor
                      : AppColors.secondary200,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                translatedText,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.secondary800,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
