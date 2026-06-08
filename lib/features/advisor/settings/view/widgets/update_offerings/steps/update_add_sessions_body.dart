import 'package:tayseer/core/utils/helper/currency_helper.dart';
import 'package:tayseer/features/advisor/settings/data/models/offerings_model.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/offerings/update_offerings_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/offerings/update_offerings_state.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/update_offerings/shared/offerings_session_type_card.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/update_offerings/steps/widgets/add_sessions_added_card.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/update_offerings/steps/widgets/add_sessions_empty_state.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/update_offerings/steps/widgets/add_sessions_form.dart';
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
    if (isPackage && _numberOfSessionsController.text.isEmpty) {
      _showError(context.tr('please_enter_number_of_sessions'));
      return;
    }

    cubit.addOffering(
      OfferingItemModel(
        name: _nameController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0,
        currency: CurrencyHelper.getCurrencyCodeByCountryKey(countryKey),
        duration: _selectedDuration!,
        type: isPackage ? 'package' : 'session',
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
    return BlocBuilder<UpdateOfferingsCubit, UpdateOfferingsState>(
      builder: (context, state) {
        final cubit = context.read<UpdateOfferingsCubit>();
        final countryKey = state.selectedCountryKey ?? '';
        final countryFlag = state.selectedCountryFlag ?? '';
        final addedList = state.currentOfferings;
        final bool showForm = _isIndividualSelected || _isPackageSelected;

        final currencySymbol = countryKey.isNotEmpty
            ? CurrencyHelper.getCurrencySymbolLocalized(countryKey)
            : CurrencyHelper.getCurrencySymbolFromContext(context);

        return Column(
          children: [
            // Selected country card
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

                  AnimatedCrossFade(
                    crossFadeState: showForm
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                    firstChild: const AddSessionsEmptyState(),
                    secondChild: AddSessionsForm(
                      isPackage: _isPackageSelected,
                      selectedDuration: _selectedDuration,
                      currencySymbol: currencySymbol,
                      nameController: _nameController,
                      priceController: _priceController,
                      numberOfSessionsController: _numberOfSessionsController,
                      cubit: cubit,
                      countryKey: countryKey,
                      onDurationSelected: (d) =>
                          setState(() => _selectedDuration = d),
                      onAddPressed: () => _addToList(cubit, countryKey),
                    ),
                  ),

                  Gap(16.h),

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
                      (i) => AddSessionsAddedCard(
                        item: addedList[i],
                        index: i,
                        cubit: cubit,
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
                  ? () => cubit.saveCurrentOfferingsToSummary()
                  : null,
            ),
            Gap(20.h),
          ],
        );
      },
    );
  }
}
