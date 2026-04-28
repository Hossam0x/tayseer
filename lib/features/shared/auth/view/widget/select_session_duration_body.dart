import 'package:flutter/services.dart';
import 'package:tayseer/core/utils/helper/currency_helper.dart';
import 'package:tayseer/features/shared/auth/model/summar_session_model.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
import 'package:tayseer/my_import.dart';

class SelectSessionDurationBody extends StatefulWidget {
  const SelectSessionDurationBody({super.key});

  @override
  State<SelectSessionDurationBody> createState() =>
      _SelectSessionDurationBodyState();
}

class _SelectSessionDurationBodyState extends State<SelectSessionDurationBody> {
  // --- متغيرات محلية فقط (مش محتاجة تكون في الكيوبت) ---
  bool isIndividualSelected = false;
  bool isPackageSelected = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? selectedDuration;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(CustomSnackBar(context, isError: true, text: message));
  }
  // ★ في دالة _addToList()

  void _addToList() {
    final authCubit = getIt<AuthCubit>();
    bool isPackage = isPackageSelected;

    if (_nameController.text.isEmpty) {
      _showError(
        isPackage
            ? context.tr('please_enter_package_name')
            : context.tr('please_enter_session_name'),
      );
      return;
    }

    if (selectedDuration == null) {
      _showError(context.tr('please_select_duration_single'));
      return;
    }

    if (_priceController.text.isEmpty) {
      _showError(
        isPackage
            ? context.tr('please_enter_package_price')
            : context.tr('please_enter_session_price'),
      );
      return;
    }

    // ★ النوع بالإنجليزي للـ API (session أو package)
    String itemType = isPackage ? 'package' : 'session';

    // ★ العملة تلقائية بناءً على الدولة المختارة
    final authState = authCubit.state;
    String currency = CurrencyHelper.getCurrencyCodeByCountryKey(
      authState.selectedCountryKey ?? '',
    );

    authCubit.addSessionToCurrentList(
      SessionItemModel(
        name: _nameController.text,
        type: itemType,
        duration: selectedDuration!,
        price: _priceController.text,
        currency: currency, // ★ جديد
      ),
    );

    _nameController.clear();
    _priceController.clear();
    setState(() => selectedDuration = null);
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = getIt<AuthCubit>();
    bool showForm = isIndividualSelected || isPackageSelected;

    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          // ★ BlocBuilder يلف كل الشاشة
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {},
            builder: (context, state) {
              // ★ قراءة الداتا من الكيوبت
              final addedItemsList = state.currentSessionsList;
              final selectedCountryKey = state.selectedCountryKey ?? '';
              final selectedCountryFlag = state.selectedCountryFlag ?? '';
              final selectedCurrencySymbol = selectedCountryKey.isNotEmpty
                  ? CurrencyHelper.getCurrencySymbolByCountryKey(
                      selectedCountryKey,
                    )
                  : CurrencyHelper.getCurrencySymbolFromContext(context);

              return Column(
                children: [
                  // --- 1. الـ App Bar العلوي ---
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => context.pop(),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          context.tr('add_sessions_title'),
                          textAlign: TextAlign.center,
                          style: Styles.textStyle16.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),

                  // --- 2. كارد الدولة (★ ديناميكي من الكيوبت) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.kprimaryColor.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.language,
                              color: AppColors.kprimaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: isArabic
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('adding_sessions_for'),
                                style: Styles.textStyle10.copyWith(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              // ★ اسم الدولة ديناميكي من الكيوبت
                              Text(
                                context.tr(selectedCountryKey),
                                style: Styles.textStyle12.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // ★ العلم ديناميكي من الكيوبت
                          Text(
                            selectedCountryFlag,
                            style: const TextStyle(fontSize: 26),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Gap(context.responsiveHeight(24)),

                  // --- 3. العناوين ---
                  Text(
                    context.tr('select_session_package'),
                    style: Styles.textStyle22Bold.copyWith(
                      color: AppColors.kscandryTextColor,
                    ),
                  ),
                  Gap(context.responsiveHeight(6)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      context.tr('share_availability_hint'),
                      textAlign: TextAlign.center,
                      style: Styles.textStyle12Bold.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Gap(context.responsiveHeight(6)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      context.tr('share_availability_hint2'),
                      textAlign: TextAlign.center,
                      style: Styles.textStyle12Bold.copyWith(color: Colors.red),
                    ),
                  ),
                  Gap(context.responsiveHeight(20)),

                  // --- 4. محتوى الشاشة (قابل للتمرير) ---
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        // -- الكروت (جلسة فردية / باقة) --
                        Row(
                          children: [
                            Expanded(
                              child: _SessionTypeCard(
                                title: context.tr('individual_session'),
                                icon: AssetsData.kpersonOutlineIcon,
                                isSelected: isIndividualSelected,
                                onTap: () {
                                  setState(() {
                                    isIndividualSelected = true;
                                    isPackageSelected = false;
                                    selectedDuration = null;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SessionTypeCard(
                                title: context.tr('package_sessions'),
                                icon: AssetsData.kSinventoryOutlinedIcon,
                                isSelected: isPackageSelected,
                                onTap: () {
                                  setState(() {
                                    isPackageSelected = true;
                                    isIndividualSelected = false;
                                    selectedDuration = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        Gap(context.responsiveHeight(20)),

                        // -- إظهار الفورم أو الشكل الفارغ --
                        Center(
                          child: AnimatedCrossFade(
                            crossFadeState: showForm
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 300),
                            firstChild: _buildEmptyStateSelection(context),
                            secondChild: _buildSessionForm(
                              context,
                              selectedCurrencySymbol,
                            ),
                          ),
                        ),

                        Gap(context.responsiveHeight(16)),

                        // -- ★ قائمة العناصر المضافة (من الكيوبت) --
                        if (addedItemsList.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${addedItemsList.length} ${context.tr('added_items_count')}',
                                style: Styles.textStyle10.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                context.tr('added_sessions'),
                                style: Styles.textStyle12.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...List.generate(addedItemsList.length, (index) {
                            return _buildAddedItemCard(
                              addedItemsList[index],
                              index,
                              context,
                              authCubit,
                              selectedCurrencySymbol,
                            );
                          }),
                        ],
                      ],
                    ),
                  ),

                  // --- 5. ★ زر "حفظ والانتقال للملخص" ---
                  CustomBotton(
                    width: context.width * .9,
                    title:
                        '${context.tr('done_save')} ${addedItemsList.length} ${context.tr('added_items_count')} ${context.tr('for_country')} $selectedCountryFlag',
                    useGradient: addedItemsList.isNotEmpty,
                    backGroundcolor: AppColors.kgreyColor,
                    onPressed: addedItemsList.isNotEmpty
                        ? () {
                            // ★ حفظ الجلسات في الملخص
                            authCubit.saveCurrentSessionsToSummary();

                            // ★ الانتقال لشاشة الملخص
                            context.pushReplacementNamed(
                              AppRouter.kSetupSummaryView,
                            );
                          }
                        : null,
                  ),

                  Gap(context.responsiveHeight(20)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ==== دوال مساعدة ====

  Widget _buildEmptyStateSelection(BuildContext context) {
    return Column(
      children: [
        Gap(context.responsiveHeight(40)),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.pink.shade100, width: 2),
          ),
          child: Icon(
            Icons.check_box_outlined,
            color: Colors.pink.shade200,
            size: 40,
          ),
        ),
        Gap(context.responsiveHeight(12)),
        Text(
          context.tr('choose_session_type_first'),
          style: Styles.textStyle14.copyWith(color: AppColors.kprimaryColor),
        ),
        Text(
          context.tr('can_choose_one_or_both'),
          style: Styles.textStyle10.copyWith(color: Colors.grey),
        ),
        Gap(context.responsiveHeight(40)),
      ],
    );
  }

  Widget _buildSessionForm(
    BuildContext context,
    String selectedCurrencySymbol,
  ) {
    bool isPackage = isPackageSelected;

    return Column(
      crossAxisAlignment: isArabic
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        // 1. اسم الجلسة / الباقة
        CustomTextFormField(
          controller: _nameController,
          hintText: isPackage
              ? context.tr('enter_package_name')
              : context.tr('enter_session_name'),
        ),

        Gap(context.responsiveHeight(16)),

        // 2. عنوان مدة الجلسة / الباقة
        Row(
          mainAxisAlignment: !isArabic
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Text(
              isPackage
                  ? context.tr('package_duration')
                  : context.tr('session_duration'),
              style: Styles.textStyle12,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 3. خيارات المدة - 45 دقيقة
        _DurationCardRadio(
          title: '45 ${context.tr('minutes_word')}',
          subtitle: context.tr('medium_session'),
          isSelected: selectedDuration == '45',
          onTap: () {
            setState(() {
              selectedDuration = '45';
            });
          },
        ),

        const SizedBox(height: 12),

        // 90 دقيقة
        _DurationCardRadio(
          title: '90 ${context.tr('minutes_word')}',
          subtitle: context.tr('long_session'),
          isSelected: selectedDuration == '90',
          onTap: () {
            setState(() {
              selectedDuration = '90';
            });
          },
        ),

        Gap(context.responsiveHeight(16)),

        // 4. السعر
        Row(
          children: [
            Text(
              isPackage
                  ? context.tr('package_price')
                  : context.tr('session_price'),
              style: Styles.textStyle14,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextFormField(
                controller: _priceController,
                hintText: '0',
                isNumber: true,
                maxLength: 5,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    selectedCurrencySymbol,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AppImage(
                    AssetsData.kWalletIcon,
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),

        Gap(context.responsiveHeight(16)),

        // 5. زر إضافة للقائمة
        Center(
          child: CustomBotton(
            useGradient: true,
            width: context.width * .9,
            title: isPackage
                ? context.tr('add_package_to_list')
                : context.tr('add_session_to_list'),
            onPressed: _addToList,
          ),
        ),
      ],
    );
  }

  // ★ كارد العنصر المضاف (الحذف عبر الكيوبت)
  Widget _buildAddedItemCard(
    SessionItemModel item,
    int index,
    BuildContext context,
    AuthCubit authCubit,
    String currencySymbol,
  ) {
    double parsedPrice = double.tryParse(item.price) ?? 0.0;
    String formattedPrice = '$parsedPrice $currencySymbol';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            // ★ حذف عبر الكيوبت
            onTap: () => authCubit.removeSessionFromCurrentList(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 16, color: Colors.red.shade400),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: isArabic
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                _buildSmallChip(formattedPrice, isGreen: true),
                const SizedBox(width: 4),
                _buildSmallChip(
                  '${item.duration}${context.tr('minute_shortcut')}',
                ),
                const SizedBox(width: 4),
                _buildSmallChip(
                  context.tr('session_type_${item.type}'),
                  isPink: true,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            item.name,
            style: Styles.textStyle14.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallChip(
    String text, {
    bool isPink = false,
    bool isGreen = false,
  }) {
    Color bgColor = Colors.grey.shade100;
    Color textColor = Colors.grey.shade700;
    if (isPink) {
      bgColor = Colors.pink.shade50;
      textColor = AppColors.kprimaryColor;
    } else if (isGreen) {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ==========================================
// Widgets مخصصة للشاشة (بدون تغيير)
// ==========================================

class _DurationCardRadio extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _DurationCardRadio({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.pink.shade50.withOpacity(0.2)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.kprimaryColor : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: Styles.textStyle14.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? AppColors.kprimaryColor
                        : Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: Styles.textStyle10.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: 22,
              height: 22,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.kprimaryColor
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Container(
                      decoration: BoxDecoration(
                        color: AppColors.kprimaryColor,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionTypeCard extends StatelessWidget {
  final String title;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SessionTypeCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: context.height * .15,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.pink.shade50.withOpacity(0.3)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.kprimaryColor : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 8,
              right: 8,
              child: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected
                    ? AppColors.kprimaryColor
                    : Colors.grey.shade400,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppImage(
                    icon,
                    width: context.width * 0.1,
                    height: context.height * 0.05,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: Styles.textStyle14.copyWith(
                      color: isSelected
                          ? AppColors.kprimaryColor
                          : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
