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
            // AppBar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => cubit.goBackToCountrySelection(),
                  ),
                  const Spacer(),
                  Text(
                    context.tr('add_sessions_title'),
                    style: Styles.textStyle16.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // كارد الدولة
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
                  border: Border.all(color: Colors.grey.shade200, width: 2),
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
                    Text(countryFlag, style: const TextStyle(fontSize: 26)),
                  ],
                ),
              ),
            ),

            Gap(context.responsiveHeight(24)),

            // العناوين
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
                style: Styles.textStyle12Bold.copyWith(color: Colors.grey),
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

            // المحتوى
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
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

                  Gap(context.responsiveHeight(20)),

                  // الفورم أو الحالة الفارغة
                  Center(
                    child: AnimatedCrossFade(
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
                  ),

                  Gap(context.responsiveHeight(16)),

                  // قائمة المضافة
                  if (addedList.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${addedList.length} ${context.tr('added_items_count')}',
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
                    ...List.generate(
                      addedList.length,
                      (i) => _buildAddedCard(addedList[i], i, context, cubit),
                    ),
                  ],
                ],
              ),
            ),

            // زر الحفظ والانتقال للملخص
            CustomBotton(
              width: context.width * .9,
              title:
                  '${context.tr('done_save')} ${addedList.length} ${context.tr('added_items_count')} ${context.tr('for_country')} $countryFlag',
              useGradient: addedList.isNotEmpty,
              backGroundcolor: AppColors.kgreyColor,
              onPressed: addedList.isNotEmpty
                  ? () => cubit.saveCurrentOfferingsToSummary()
                  : null,
            ),

            Gap(context.responsiveHeight(20)),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
        Gap(context.responsiveHeight(16)),
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
        OfferingsDurationRadio(
          title: '45 ${context.tr('minutes_word')}',
          subtitle: context.tr('medium_session'),
          isSelected: _selectedDuration == '45',
          onTap: () => setState(() => _selectedDuration = '45'),
        ),
        const SizedBox(height: 12),
        OfferingsDurationRadio(
          title: '90 ${context.tr('minutes_word')}',
          subtitle: context.tr('long_session'),
          isSelected: _selectedDuration == '90',
          onTap: () => setState(() => _selectedDuration = '90'),
        ),
        Gap(context.responsiveHeight(16)),
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
        Gap(context.responsiveHeight(16)),
        Center(
          child: CustomBotton(
            useGradient: true,
            width: context.width * .9,
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
    BuildContext context,
    UpdateOfferingsCubit cubit,
  ) {
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
            onTap: () => cubit.removeOffering(index),
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
                OfferingsItemChip(
                  text: '${item.price} ${item.currency}',
                  isGreen: true,
                ),
                const SizedBox(width: 4),
                OfferingsItemChip(
                  text: '${item.duration}${context.tr('minute_shortcut')}',
                ),
                const SizedBox(width: 4),
                OfferingsItemChip(
                  text: item.type == 'package'
                      ? context.tr('package_type')
                      : context.tr('individual_type'),
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
}
