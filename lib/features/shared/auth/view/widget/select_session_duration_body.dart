import 'package:flutter/services.dart';
import 'package:tayseer/core/utils/helper/currency_helper.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/update_offerings/shared/offerings_duration_radio.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/update_offerings/shared/offerings_session_type_card.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/update_offerings/steps/widgets/add_sessions_empty_state.dart';
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
  bool _isIndividualSelected = false;
  bool _isPackageSelected = false;
  String? _selectedDuration;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _numberOfSessionsController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _numberOfSessionsController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(CustomSnackBar(context, isError: true, text: message));
  }

  void _addToList(AuthCubit authCubit, String countryKey) {
    final isPackage = _isPackageSelected;

    if (_nameController.text.isEmpty) {
      _showError(
        isPackage
            ? context.tr('please_enter_package_name')
            : context.tr('please_enter_session_name'),
      );
      return;
    }
    if (_selectedDuration == null) {
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
    if (isPackage && _numberOfSessionsController.text.isEmpty) {
      _showError(context.tr('please_enter_number_of_sessions'));
      return;
    }

    final currency = CurrencyHelper.getCurrencyCodeByCountryKey(countryKey);

    authCubit.addSessionToCurrentList(
      SessionItemModel(
        name: _nameController.text.trim(),
        type: isPackage ? 'package' : 'session',
        duration: _selectedDuration!,
        price: _priceController.text,
        currency: currency,
        numberOfSessions: isPackage
            ? int.tryParse(_numberOfSessionsController.text)
            : null,
      ),
    );

    _nameController.clear();
    _priceController.clear();
    _numberOfSessionsController.clear();
    setState(() => _selectedDuration = null);
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = getIt<AuthCubit>();

    return Scaffold(
      body: AdvisorBackground(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 105.h,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AssetsData.homeBarBackgroundImage),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final addedList = state.currentSessionsList;
                    final countryKey = state.selectedCountryKey ?? '';
                    final countryFlag = state.selectedCountryFlag ?? '';
                    final currencySymbol = countryKey.isNotEmpty
                        ? CurrencyHelper.getCurrencySymbolLocalized(countryKey)
                        : CurrencyHelper.getCurrencySymbolFromContext(context);
                    final bool showForm =
                        _isIndividualSelected || _isPackageSelected;

                    return Column(
                      children: [
                        Gap(16.h),
                        SimpleAppBar(
                          title: context.tr('add_sessions_title'),
                          onBack: () => context.pop(),
                        ),
                        Gap(16.h),

                        // كارد الدولة
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.kprimaryColor.withOpacity(
                                    0.08,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.language,
                                  color: AppColors.kprimaryColor,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
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
                                  Text(
                                    context.tr(countryKey),
                                    style: Styles.textStyle12.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                countryFlag,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ],
                          ),
                        ),

                        Gap(16.h),

                        Expanded(
                          child: ListView(
                            children: [
                              Center(
                                child: Text(
                                  context.tr('select_type'),
                                  style: Styles.textStyle18.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.kscandryTextColor,
                                  ),
                                ),
                              ),
                              Gap(16.h),

                              // كروت نوع الجلسة
                              Row(
                                children: [
                                  Expanded(
                                    child: OfferingsSessionTypeCard(
                                      title: context.tr('individual_session'),
                                      icon: AssetsData.kpersonOutlineIcon,
                                      isSelected: _isIndividualSelected,
                                      onTap: () => setState(() {
                                        _isIndividualSelected = true;
                                        _isPackageSelected = false;
                                        _selectedDuration = null;
                                      }),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OfferingsSessionTypeCard(
                                      title: context.tr('package_sessions'),
                                      icon: AssetsData.kSinventoryOutlinedIcon,
                                      isSelected: _isPackageSelected,
                                      onTap: () => setState(() {
                                        _isPackageSelected = true;
                                        _isIndividualSelected = false;
                                        _selectedDuration = null;
                                      }),
                                    ),
                                  ),
                                ],
                              ),

                              if (_isPackageSelected) ...[
                                Gap(8.h),
                                Center(
                                  child: Text(
                                    context.tr('select_session_package'),
                                    style: Styles.textStyle18.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.kscandryTextColor,
                                    ),
                                  ),
                                ),
                                Gap(4.h),
                                Center(
                                  child: Text(
                                    context.tr('share_availability_hint'),
                                    textAlign: TextAlign.center,
                                    style: Styles.textStyle12.copyWith(
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                                Gap(4.h),
                                Center(
                                  child: Text(
                                    context.tr('share_availability_hint2'),
                                    textAlign: TextAlign.center,
                                    style: Styles.textStyle12Bold.copyWith(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],

                              Gap(16.h),

                              // الفورم أو الـ empty state
                              AnimatedCrossFade(
                                crossFadeState: showForm
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                                duration: const Duration(milliseconds: 300),
                                firstChild: const AddSessionsEmptyState(),
                                secondChild: _buildForm(
                                  context,
                                  currencySymbol,
                                  authCubit,
                                  countryKey,
                                ),
                              ),

                              Gap(16.h),

                              // قائمة العناصر المضافة
                              if (addedList.isNotEmpty) ...[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${addedList.length} ${context.tr('added_items_count')}',
                                      style: Styles.textStyle10.copyWith(
                                        color: Colors.grey.shade500,
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
                                Gap(8.h),
                                ...List.generate(
                                  addedList.length,
                                  (i) => _AuthAddedCard(
                                    item: addedList[i],
                                    index: i,
                                    authCubit: authCubit,
                                    currencySymbol: currencySymbol,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        Gap(12.h),
                        CustomBotton(
                          width: double.infinity,
                          title:
                              '${context.tr('done_save')} ${addedList.length} ${context.tr('added_items_count')} ${context.tr('for_country')} $countryFlag',
                          useGradient: addedList.isNotEmpty,
                          backGroundcolor: AppColors.kgreyColor,
                          onPressed: addedList.isNotEmpty
                              ? () {
                                  authCubit.saveCurrentSessionsToSummary();
                                  context.pushReplacementNamed(
                                    AppRouter.kSetupSummaryView,
                                  );
                                }
                              : null,
                        ),
                        Gap(20.h),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    String currencySymbol,
    AuthCubit authCubit,
    String countryKey,
  ) {
    final isPackage = _isPackageSelected;

    return Column(
      crossAxisAlignment: isArabic
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        // اسم الجلسة / الباقة
        CustomTextFormField(
          controller: _nameController,
          hintText: isPackage
              ? context.tr('enter_package_name')
              : context.tr('enter_session_name'),
        ),

        // عدد الجلسات (للباقة فقط)
        if (isPackage) ...[
          Gap(14.h),
          Row(
            children: [
              Text(context.tr('number_of_sessions'), style: Styles.textStyle14),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextFormField(
                  controller: _numberOfSessionsController,
                  hintText: '0',
                  isNumber: true,
                  maxLength: 3,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
        ],

        Gap(14.h),
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
        Gap(10.h),
        OfferingsDurationRadio(
          title: '45 ${context.tr('minutes_word')}',
          subtitle: context.tr('medium_session'),
          isSelected: _selectedDuration == '45',
          onTap: () => setState(() => _selectedDuration = '45'),
        ),
        Gap(8.h),
        OfferingsDurationRadio(
          title: '90 ${context.tr('minutes_word')}',
          subtitle: context.tr('long_session'),
          isSelected: _selectedDuration == '90',
          onTap: () => setState(() => _selectedDuration = '90'),
        ),

        Gap(14.h),
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
                    currencySymbol,
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

        Gap(14.h),
        Center(
          child: CustomBotton(
            useGradient: true,
            width: double.infinity,
            title: isPackage
                ? context.tr('add_package_to_list')
                : context.tr('add_session_to_list'),
            onPressed: () => _addToList(authCubit, countryKey),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// كارد العنصر المضاف (auth flow)
// ─────────────────────────────────────────────
class _AuthAddedCard extends StatelessWidget {
  const _AuthAddedCard({
    required this.item,
    required this.index,
    required this.authCubit,
    required this.currencySymbol,
  });

  final SessionItemModel item;
  final int index;
  final AuthCubit authCubit;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => authCubit.removeSessionFromCurrentList(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 14, color: Colors.red.shade400),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.name,
              style: Styles.textStyle14.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Wrap(
            spacing: 4,
            children: [
              _Chip(text: '${item.price} $currencySymbol', isGreen: true),
              _Chip(text: '${item.duration}${context.tr('minute_shortcut')}'),
              if (item.type == 'package' && item.numberOfSessions != null)
                _Chip(
                  text:
                      '${item.numberOfSessions} ${context.tr('sessions_count')}',
                ),
              _Chip(
                text: context.tr('session_type_${item.type}'),
                isPink: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, this.isPink = false, this.isGreen = false});

  final String text;
  final bool isPink;
  final bool isGreen;

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.grey.shade100;
    Color fg = Colors.grey.shade700;
    if (isPink) {
      bg = Colors.pink.shade50;
      fg = AppColors.kprimaryColor;
    } else if (isGreen) {
      bg = Colors.green.shade50;
      fg = Colors.green.shade700;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.bold),
      ),
    );
  }
}
