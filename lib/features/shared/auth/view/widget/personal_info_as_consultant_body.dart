import 'package:flutter/cupertino.dart';
import 'package:tayseer/features/shared/auth/view/widget/custom_upload_image.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/my_import.dart';

class PersonalInfoAsConsultantBody extends StatefulWidget {
  const PersonalInfoAsConsultantBody({super.key});

  @override
  State<PersonalInfoAsConsultantBody> createState() =>
      _PersonalInfoAsConsultantBodyState();
}

class _PersonalInfoAsConsultantBodyState
    extends State<PersonalInfoAsConsultantBody> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedDay;
  int? _selectedMonth;
  int? _selectedYear;
  String? _selectedNationality;
  String? _selectedCountry;

  // ثوابت للقوائم المنسدلة
  static const List<String> _nationalityKeys = [
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
    'nationality_algerian',
    'nationality_american',
    'nationality_british',
    'nationality_canadian',
    'nationality_australian',
  ];

  static const List<String> _countryKeys = [
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
    'country_algeria',
    'country_usa',
    'country_uk',
    'country_canada',
    'country_australia',
  ];

  @override
  Widget build(BuildContext context) {
    final authCubit = getIt<AuthCubit>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: CustomBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // ── المحتوى القابل للتمرير ──
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                child: AutofillGroup(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: isArabic
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back),
                          ),
                        ),

                        Text(
                          context.tr('enterPersonalInfo'),
                          style: Styles.textStyle20Bold.copyWith(
                            color: AppColors.kscandryTextColor,
                          ),
                        ),

                        SizedBox(height: context.height * 0.009),

                        Text(
                          textAlign: TextAlign.center,
                          context.tr('personalInfoHint'),
                          style: Styles.textStyle12,
                        ),
                        SizedBox(height: context.height * 0.02),
                        Text(
                          context.tr('upload_Photo'),
                          style: Styles.textStyle14,
                        ),
                        SizedBox(height: context.height * 0.02),
                        Center(
                          child: UploadImageFormField(
                            initialValue: authCubit.pickedImage,
                            isShowImage: true,
                            onImagePicked: (image) {
                              authCubit.pickedImage = image;
                            },
                            validator: (v) => v == null
                                ? context.tr('required_images')
                                : null,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Center(
                          child: Text(
                            textAlign: TextAlign.center,
                            context.tr('uploadClearPhoto'),
                            style: Styles.textStyle12.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        CustomTextFormField(
                          controller: authCubit.nameAsConsultantController,
                          isName: true,
                        ),

                        const SizedBox(height: 16),

                        CustomDropdownFormField<String>(
                          hint: context.tr('gender'),
                          value: authCubit.selectedGender,
                          items: [
                            DropdownMenuItem(
                              value: 'male',
                              child: Text(
                                context.tr('male'),
                                style: Styles.textStyle12,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'female',
                              child: Text(
                                context.tr('female'),
                                style: Styles.textStyle12,
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            authCubit.selectedGender = value;
                          },
                          validator: (value) {
                            if (value == null) {
                              return context.tr('completeAllData');
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Date of Birth Field with iOS Pickers
                        FormField<DateTime>(
                          initialValue: null,
                          validator: (value) {
                            if (_selectedDay == null ||
                                _selectedMonth == null ||
                                _selectedYear == null) {
                              return context.tr('required');
                            }
                            return null;
                          },
                          builder: (field) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _showDatePickerModal(context, field);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.kWhiteColor,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: field.hasError
                                            ? Colors.red
                                            : AppColors.kprimaryColor
                                                  .withValues(alpha: 0.5),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _selectedDay != null &&
                                                  _selectedMonth != null &&
                                                  _selectedYear != null
                                              ? '$_selectedDay / $_selectedMonth / $_selectedYear'
                                              : context.tr('birthDate'),
                                          style: Styles.textStyle12.copyWith(
                                            color: _selectedDay != null
                                                ? AppColors.blackColor
                                                : AppColors.kprimaryColor
                                                      .withValues(alpha: 0.5),
                                          ),
                                        ),
                                        Icon(
                                          Icons.calendar_today,
                                          color: AppColors.kprimaryColor
                                              .withValues(alpha: 0.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (field.hasError)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 4,
                                      right: 12,
                                    ),
                                    child: Text(
                                      field.errorText!,
                                      style: Styles.textStyle10.copyWith(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),

                        SizedBox(height: context.height * 0.02),

                        // Nationality Dropdown
                        CustomDropdownFormField<String>(
                          hint: context.tr('choose_nationality'),
                          value: _selectedNationality,
                          items: _nationalityKeys
                              .map(
                                (key) => DropdownMenuItem(
                                  value: key,
                                  child: Text(
                                    context.tr(key),
                                    style: Styles.textStyle12,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedNationality = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return context.tr('completeAllData');
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Country Dropdown
                        CustomDropdownFormField<String>(
                          hint: context.tr('choose_country'),
                          value: _selectedCountry,
                          items: _countryKeys
                              .map(
                                (key) => DropdownMenuItem(
                                  value: key,
                                  child: Text(
                                    context.tr(key),
                                    style: Styles.textStyle12,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCountry = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return context.tr('completeAllData');
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: context.height * 0.03),
                      ],
                    ),
                  ),
                ),
              ),

              // ── زرار Next ثابت في الأسفل ──
              Positioned(
                bottom: 10,
                left: 20,
                right: 20,
                child: CustomBotton(
                  width: context.width,
                  useGradient: true,
                  title: context.tr('next'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (authCubit.selectedGender == null ||
                          _selectedDay == null ||
                          _selectedMonth == null ||
                          _selectedYear == null ||
                          _selectedNationality == null ||
                          _selectedCountry == null ||
                          authCubit.pickedImage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          CustomSnackBar(
                            context,
                            text: context.tr('completeAllData'),
                            isError: true,
                          ),
                        );
                        return;
                      }

                      // حفظ تاريخ الميلاد
                      authCubit.birthDate = DateTime(
                        _selectedYear!,
                        _selectedMonth!,
                        _selectedDay!,
                      );

                      // حفظ الجنسية والبلد
                      authCubit.selectedNationality = _selectedNationality;
                      authCubit.selectedCountry = _selectedCountry;

                      context.pushNamed(AppRouter.kConsultantInfoView);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Date Picker Modal (iOS Cupertino wheels + Android Material fallback) ──
  void _showDatePickerModal(
    BuildContext context,
    FormFieldState<DateTime> field,
  ) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      _showCupertinoDatePicker(context, field);
    } else {
      _showMaterialDatePicker(context, field);
    }
  }

  // ── iOS: three-wheel Cupertino bottom sheet ──
  void _showCupertinoDatePicker(
    BuildContext context,
    FormFieldState<DateTime> field,
  ) {
    int tempDay = _selectedDay ?? 1;
    int tempMonth = _selectedMonth ?? 1;
    int tempYear = _selectedYear ?? (DateTime.now().year - 18);

    // Year list: current-18 down to current-100 (most recent first)
    final int maxYear = DateTime.now().year - 18;
    final int minYear = DateTime.now().year - 100;
    final int yearCount = maxYear - minYear + 1; // 83 items
    final int initialYearIndex = maxYear - tempYear;

    showCupertinoModalPopup(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
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
                        color: AppColors.secondary200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // ── header ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Cancel
                          GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                context.tr('cancel'),
                                style: Styles.textStyle12.copyWith(
                                  color: AppColors.error600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          // Title
                          Text(
                            context.tr('birthDate'),
                            style: Styles.textStyle16Bold.copyWith(
                              color: AppColors.kscandryTextColor,
                            ),
                          ),

                          // Confirm
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDay = tempDay;
                                _selectedMonth = tempMonth;
                                _selectedYear = tempYear;
                              });
                              field.didChange(
                                DateTime(tempYear, tempMonth, tempDay),
                              );
                              Navigator.pop(ctx);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.kprimaryColor,
                                    AppColors.kprimaryTextColor,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                context.tr('save'),
                                style: Styles.textStyle12.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── divider ──
                    Divider(height: 1, color: AppColors.secondary100),

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
                              onChanged: (i) => tempDay = i + 1,
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
                              onChanged: (i) => tempMonth = i + 1,
                              hasDividerRight: true,
                            ),
                          ),
                          // Year
                          Expanded(
                            child: _buildCupertinoWheel(
                              initialItem: initialYearIndex,
                              itemCount: yearCount,
                              labelBuilder: (i) => '${maxYear - i}',
                              onChanged: (i) => tempYear = maxYear - i,
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
    );
  }

  // ── Android: Material date picker ──
  Future<void> _showMaterialDatePicker(
    BuildContext context,
    FormFieldState<DateTime> field,
  ) async {
    final now = DateTime.now();
    final initialDate =
        (_selectedYear != null &&
            _selectedMonth != null &&
            _selectedDay != null)
        ? DateTime(_selectedYear!, _selectedMonth!, _selectedDay!)
        : DateTime(now.year - 30, now.month, now.day);

    final lastDate = DateTime(now.year - 30, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(lastDate) ? lastDate : initialDate,
      firstDate: DateTime(now.year - 100),
      lastDate: lastDate,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.kprimaryColor,
              onPrimary: Colors.white,
              onSurface: AppColors.secondary800,
              surface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.kprimaryColor,
              ),
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDay = picked.day;
        _selectedMonth = picked.month;
        _selectedYear = picked.year;
      });
      field.didChange(picked);
    }
  }

  // ── helper: column label ──
  Widget _pickerLabel(String text) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Styles.textStyle12.copyWith(
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
                right: BorderSide(color: AppColors.secondary100, width: 1),
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
            color: AppColors.kprimaryColor.withValues(alpha: 0.07),
            border: Border(
              top: BorderSide(
                color: AppColors.kprimaryColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
              bottom: BorderSide(
                color: AppColors.kprimaryColor.withValues(alpha: 0.3),
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
              style: Styles.textStyle16Bold.copyWith(
                color: AppColors.secondary800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
