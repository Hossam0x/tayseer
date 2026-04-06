import 'package:flutter/services.dart';
import 'package:tayseer/core/utils/helper/currency_helper.dart';
import 'package:tayseer/features/advisor/settings/data/models/offerings_model.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/offerings/update_offerings_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/offerings/update_offerings_state.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/update_offerings/shared/offerings_duration_radio.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/update_offerings/shared/offerings_item_chip.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/update_offerings/shared/offerings_session_type_card.dart';
import 'package:tayseer/my_import.dart';

class UpdateAddSessionsBody extends StatefulWidget {
  const UpdateAddSessionsBody({super.key});

  @override
  State<UpdateAddSessionsBody> createState() => _UpdateAddSessionsBodyState();
}

class _UpdateAddSessionsBodyState extends State<UpdateAddSessionsBody> {
  bool _isIndividualSelected = false;
  bool _isPackageSelected = false;
  String? _selectedDuration;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

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

  void _addToList(UpdateOfferingsCubit cubit, String countryKey) {
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

    cubit.addOffering(
      OfferingItemModel(
        name: _nameController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0,
        currency: CurrencyHelper.getCurrencyCodeByCountryKey(countryKey),
        duration: _selectedDuration!,
        type: isPackage ? 'package' : 'session',
      ),
    );

    _nameController.clear();
    _priceController.clear();
    setState(() => _selectedDuration = null);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UpdateOfferingsCubit, UpdateOfferingsState>(
      builder: (context, state) {
        final cubit = context.read<UpdateOfferingsCubit>();
        final countryKey = state.selectedCountryKey ?? '';
        final countryFlag = state.selectedCountryFlag ?? '';
        final addedList = state.currentOfferings;
        final bool showForm = _isIndividualSelected || _isPackageSelected;

        final currencySymbol = countryKey.isNotEmpty
            ? CurrencyHelper.getCurrencySymbolByCountryKey(countryKey)
            : CurrencyHelper.getCurrencySymbolFromContext(context);

        return Column(
          children: [
            // كارد الدولة المختارة
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
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
                      color: AppColors.kprimaryColor.withOpacity(0.08),
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
                  Text(countryFlag, style: const TextStyle(fontSize: 24)),
                ],
              ),
            ),

            Gap(16.h),

            // المحتوى القابل للتمرير
            Expanded(
              child: ListView(
                children: [
                  // عنوان
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
                  Gap(16.h),

                  // كروت النوع
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

                  Gap(16.h),

                  // الفورم أو الحالة الفارغة
                  AnimatedCrossFade(
                    crossFadeState: showForm
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                    firstChild: _buildEmptyState(context),
                    secondChild: _buildForm(
                      context,
                      currencySymbol,
                      cubit,
                      countryKey,
                    ),
                  ),

                  Gap(16.h),

                  // قائمة المضافة
                  if (addedList.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      (i) => _buildAddedCard(addedList[i], i, cubit),
                    ),
                  ],
                ],
              ),
            ),

            // زر الحفظ
            Gap(12.h),
            CustomBotton(
              width: double.infinity,
              title:
                  '${context.tr('done_save')} ${addedList.length} ${context.tr('added_items_count')} ${context.tr('for_country')} $countryFlag',
              useGradient: addedList.isNotEmpty,
              backGroundcolor: AppColors.kgreyColor,
              onPressed: addedList.isNotEmpty
                  ? () => cubit.saveCurrentOfferingsToSummary()
                  : null,
            ),
            Gap(20.h),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.pink.shade100, width: 2),
              ),
              child: Icon(
                Icons.check_box_outlined,
                color: Colors.pink.shade200,
                size: 36,
              ),
            ),
            Gap(10.h),
            Text(
              context.tr('choose_session_type_first'),
              style: Styles.textStyle14.copyWith(
                color: AppColors.kprimaryColor,
              ),
            ),
            Text(
              context.tr('can_choose_one_or_both'),
              style: Styles.textStyle10.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    String currencySymbol,
    UpdateOfferingsCubit cubit,
    String countryKey,
  ) {
    final isPackage = _isPackageSelected;
    return Column(
      crossAxisAlignment: isArabic
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        CustomTextFormField(
          controller: _nameController,
          hintText: isPackage
              ? context.tr('enter_package_name')
              : context.tr('enter_session_name'),
        ),
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
            onPressed: () => _addToList(cubit, countryKey),
          ),
        ),
      ],
    );
  }

  Widget _buildAddedCard(
    OfferingItemModel item,
    int index,
    UpdateOfferingsCubit cubit,
  ) {
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
            onTap: () => cubit.removeOffering(index),
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
              OfferingsItemChip(
                text: '${item.price} ${item.currency}',
                isGreen: true,
              ),
              OfferingsItemChip(
                text: '${item.duration}${context.tr('minute_shortcut')}',
              ),
              OfferingsItemChip(
                text: item.type == 'package'
                    ? context.tr('package_type')
                    : context.tr('individual_type'),
                isPink: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
