// features/user/user_profile/views/widgets/marriage_field_selection_view.dart
// ⭐⭐⭐ COMPLETE FIXED VERSION WITH FULL TRANSLATION SUPPORT

import 'package:tayseer/features/user/questions/view/widget/categorized_multi_select_widget.dart';
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

    _selectedPickerValue ??= initialValue;

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

  // ⭐⭐⭐ بناء محتوى MultiSelect - WITH KEY-BASED SAVING
  Widget _buildMultiSelectContent(
    BuildContext context,
    Map<String, dynamic> fieldData,
  ) {
    // ⭐ Parse current selected KEYS (not translated values)
    final List<String> selectedKeys = [];

    if (widget.currentValue != null && widget.currentValue!.isNotEmpty) {
      selectedKeys.addAll(widget.currentValue!.split(', '));
    }

    debugPrint('🎯 MultiSelect - Current Keys: $selectedKeys');

    // ⭐ Check if categorized items exist
    final categorizedItems =
        fieldData['categorizedItems'] as Map<String, Map<String, String>>?;

    if (categorizedItems != null) {
      debugPrint('✅ Using CategorizedMultiSelectWidget');

      // ⭐⭐⭐ Use CategorizedMultiSelectWidget
      return Expanded(
        child: CategorizedMultiSelectWidget(
          categorizedItems: categorizedItems,
          initialSelected: selectedKeys, // ⭐ Pass keys directly
          primaryColor: AppColors.kprimaryColor,
          onChanged: (selectedKeys) {
            setState(() {
              // ⭐⭐⭐ Save as comma-separated KEYS (not translated text)
              _selectedValue = selectedKeys.join(', ');
            });
            debugPrint('💾 Selected Keys: $_selectedValue');
          },
        ),
      );
    } else {
      debugPrint('⚠️ Using fallback _MultiSelectChips');

      // ⭐ Fallback: Use old multi-select chips
      final List<String> items = List<String>.from(fieldData['items'] ?? []);
      return Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: _MultiSelectChips(
            items: items,
            initialSelected: selectedKeys,
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
  }

  // ⭐⭐⭐ بناء محتوى القائمة - يحفظ الـ key بدل الترجمة
  Widget _buildListContent(
    BuildContext context,
    Map<String, dynamic> fieldData,
  ) {
    final List<String> items = List<String>.from(fieldData['items']);

    // ⭐ البحث عن الـ key المناسب للقيمة الحالية
    String? initialSelectedKey;

    if (widget.currentValue != null &&
        widget.currentValue != 'اختر' &&
        widget.currentValue != 'select' &&
        widget.currentValue!.isNotEmpty) {
      // أولاً: جرب مطابقة مباشرة (إذا كانت القيمة key فعلاً)
      if (items.contains(widget.currentValue)) {
        initialSelectedKey = widget.currentValue;
      } else {
        // ثانياً: ابحث عن key يطابق الترجمة
        for (var key in items) {
          if (context.tr(key) == widget.currentValue) {
            initialSelectedKey = key;
            break;
          }
        }
      }
    }

    debugPrint('🔍 Initial Selected Key: $initialSelectedKey');
    debugPrint('🔍 Items count: ${items.length}');

    return Expanded(
      child:  Container(
      color: AppColors.kWhiteColor,
      child: SelectableListWidget(
        key: ValueKey(_selectedValue),  // ✅ هنا الحل - يعمل rebuild لما تتغير القيمة
        items: items,
        showSearch: fieldData['showSearch'] as bool,
        searchHintKey: fieldData['searchHint'] as String?,
        initialSelectedKey: _selectedValue ?? initialSelectedKey, // ✅ يعكس الاختيار الحالي
        primaryColor: AppColors.kprimaryColor,
        onChanged: (key, translatedValue) {
          setState(() {
            _selectedValue = key;
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
        : _selectedValue != null && _selectedValue!.isNotEmpty;

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

  // ⭐⭐⭐ الحصول على بيانات الحقل - SAME AS BEFORE
  Map<String, dynamic> _getFieldData(String fieldKey, String? currentValue) {
    // ⭐⭐⭐ خريطة الاهتمامات المقسمة حسب الفئات
    final Map<String, Map<String, String>> _interestsWithCategories = {
      // =============== الرياضة ===============
      'category_sports': {
        'interest_baseball': '⚾',
        'interest_running': '🏃',
        'interest_weightlifting': '🏋️',
        'interest_gymnastics': '🤸',
        'interest_golf': '⛳',
        'interest_tennis': '🎾',
        'interest_swimming': '🏊',
        'interest_dancing': '💃',
        'interest_skating': '⛸️',
        'interest_yoga': '🧘',
        'interest_flying_disc': '🥏',
        'interest_badminton': '🏸',
        'interest_skiing': '⛷️',
        'interest_cycling': '🚴',
        'interest_basketball': '🏀',
        'interest_football': '⚽',
        'interest_karate': '🥋',
        'interest_boxing': '🥊',
        'interest_archery': '🏹',
        'interest_horse_riding': '🏇',
      },

      // =============== فنون وثقافة ===============
      'category_arts_culture': {
        'interest_theater': '🎭',
        'interest_magic': '🪄',
        'interest_music': '🎵',
        'interest_painting': '🎨',
        'interest_photography': '📷',
        'interest_cinema': '🎬',
        'interest_reading': '📚',
        'interest_writing': '✍️',
        'interest_poetry': '📝',
        'interest_history': '🏛️',
        'interest_languages': '🗣️',
        'interest_museums': '🖼️',
        'interest_calligraphy': '🖋️',
        'interest_sculpture': '🗿',
        'interest_design': '🎯',
        'interest_fashion': '👗',
      },

      // =============== المجتمع ===============
      'category_community': {
        'interest_volunteering': '🤝',
        'interest_charity': '💝',
        'interest_teaching': '👨‍🏫',
        'interest_mentoring': '🧑‍🤝‍🧑',
        'interest_elderly_care': '👴',
        'interest_children_care': '👶',
        'interest_environment': '🌱',
        'interest_animal_care': '🐾',
        'interest_blood_donation': '🩸',
        'interest_community_events': '🎉',
        'interest_social_work': '💼',
        'interest_human_rights': '⚖️',
      },

      // =============== التكنولوجيا ===============
      'category_technology': {
        'interest_programming': '💻',
        'interest_gaming': '🎮',
        'interest_ai': '🤖',
        'interest_web_dev': '🌐',
        'interest_mobile_apps': '📱',
        'interest_cybersecurity': '🔒',
        'interest_data_science': '📊',
        'interest_electronics': '🔌',
        'interest_robotics': '🦾',
        'interest_vr_ar': '🥽',
        'interest_3d_printing': '🖨️',
        'interest_drones': '🚁',
        'interest_smart_home': '🏠',
        'interest_blockchain': '⛓️',
      },

      // =============== النزهات ===============
      'category_outdoors': {
        'interest_hiking': '🥾',
        'interest_camping': '🏕️',
        'interest_fishing': '🎣',
        'interest_beach': '🏖️',
        'interest_mountain_climbing': '🏔️',
        'interest_gardening': '🌻',
        'interest_picnic': '🧺',
        'interest_bird_watching': '🦅',
        'interest_stargazing': '🌟',
        'interest_road_trips': '🚗',
        'interest_sailing': '⛵',
        'interest_diving': '🤿',
        'interest_surfing': '🏄',
        'interest_kayaking': '🛶',
        'interest_rock_climbing': '🧗',
        'interest_paragliding': '🪂',
      },

      // =============== الطعام والمشروبات ===============
      'category_food_drinks': {
        'interest_cooking': '👨‍🍳',
        'interest_baking': '🧁',
        'interest_grilling': '🍖',
        'interest_coffee': '☕',
        'interest_tea': '🍵',
        'interest_smoothies': '🥤',
        'interest_sushi': '🍣',
        'interest_pizza': '🍕',
        'interest_desserts': '🍰',
        'interest_healthy_food': '🥗',
        'interest_street_food': '🌮',
        'interest_fine_dining': '🍽️',
        'interest_food_photography': '📸',
        'interest_chocolate': '🍫',
        'interest_ice_cream': '🍦',
      },
    };

    // ⭐⭐⭐ NEW: خريطة الإيمان منفصلة
    final Map<String, Map<String, String>> _faithWithCategories = {
      // =============== الإيمان ===============
      'category_faith': {
        'faith_dua': '🙏',
        'faith_umrah': '🕋',
        'faith_charity_work': '💼',
        'faith_dawah': '📢',
        'faith_sadaqah': '🤝',
        'faith_hadith': '📖',
        'faith_tahajjud': '😊',
        'faith_dhikr': '📿',
        'faith_multiple_prayers': '🕌',
        'faith_sunnah_prayer': '🙏',
        'faith_nafila_prayer': '🕯️',
        'faith_hajj': '🕋',
        'faith_five_prayers': '☪️',
        'faith_fiqh': '📚',
        'faith_fasting': '🌙',
        'faith_tasawwuf': '😇',
        'faith_good_manners': '🤲',
        'faith_friday_prayer': '🕌',
      },
    };

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
      case 'drinkAlcohol':
        return {
          'titleKey': 'drink_alcohol',
          'items': ['yes', 'no'],
          'showSearch': false,
        };

      case 'eatHalalOnly':
        return {
          'titleKey': 'eat_halal_only',
          'items': ['yes', 'no'],
          'showSearch': false,
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

      case 'choose_employer':
        return {
          'titleKey': 'employer',
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
          'titleKey': 'has_childrens',
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
          'titleKey': 'children_live_with_you',
          'items': ['yes', 'no', 'not_applicable'],
          'showSearch': false,
        };

      case 'communicationTimeline':
      case 'marriage_intentions':
      case 'marry': // ⭐ Add this alias
        return {
          'titleKey': 'marriage_intentions',
          'items': [
            'period_1_3_months',
            'period_4_7_months',
            'period_7_12_months',
            'period_1_2_years',
          ],
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

      case 'familyAcceptance':
        return {
          'titleKey': 'family', // أو 'select_family_acceptance_title'
          'items': [
            'no_problem_children', // 'لا مانع لدي من إنجاب أطفال'
            'do_not_want_children', // 'لا أرغب في إنجاب أطفال'
          ],
          'showSearch': false,
        };

      // ✅ السفر (intendTravelAbroad بدلاً من travel/travelPreference)
      case 'intendTravelAbroad':
        return {
          'titleKey': 'select_travel_preference_title', // أو 'السفر'
          'items': [
            'intend_travel_abroad', // 'بعد الزواج' أو 'أنوي السفر للخارج'
            'do_not_intend_travel', // 'لا أنوي السفر'
          ],
          'showSearch': false,
        };

      case 'bio':
      case 'myDescription':
        return {
          'titleKey': 'select_bio_title',
          'type': 'textarea',
          'maxLength': 500,
        };
      case 'faith':
        return {
          'titleKey': 'select_faith_title',
          'type': 'multiselect',
          'categorizedItems': _faithWithCategories, // ⭐ الإيمان فقط
        };

      // ⭐⭐⭐ HOBBIES & INTERESTS - NOW WITH CATEGORIZED ITEMS
      case 'interests':
      case 'hobbies':
        return {
          'titleKey': fieldKey == 'interests'
              ? 'select_interests_title'
              : 'select_hobbies_title',
          'type': 'multiselect',
          'categorizedItems':
              _interestsWithCategories, // ⭐ USE CATEGORIZED WIDGET
        };

      default:
        return {'titleKey': fieldKey, 'items': <String>[], 'showSearch': false};
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// ⭐ MultiSelect Chips Widget (Fallback for non-categorized items)
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

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

    // ⭐⭐⭐ CRITICAL: أرسل الـ keys مش الترجمة
    widget.onChanged(_selectedKeys.toList());
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
