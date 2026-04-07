import 'package:flutter/services.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/offerings/update_offerings_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/update_offerings/shared/offerings_duration_radio.dart';
import 'package:tayseer/my_import.dart';

class AddSessionsForm extends StatelessWidget {
  const AddSessionsForm({
    super.key,
    required this.isPackage,
    required this.selectedDuration,
    required this.currencySymbol,
    required this.nameController,
    required this.priceController,
    required this.cubit,
    required this.countryKey,
    required this.onDurationSelected,
    required this.onAddPressed,
  });

  final bool isPackage;
  final String? selectedDuration;
  final String currencySymbol;
  final TextEditingController nameController;
  final TextEditingController priceController;
  final UpdateOfferingsCubit cubit;
  final String countryKey;
  final ValueChanged<String> onDurationSelected;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isArabic
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        CustomTextFormField(
          controller: nameController,
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
          isSelected: selectedDuration == '45',
          onTap: () => onDurationSelected('45'),
        ),
        Gap(8.h),
        OfferingsDurationRadio(
          title: '90 ${context.tr('minutes_word')}',
          subtitle: context.tr('long_session'),
          isSelected: selectedDuration == '90',
          onTap: () => onDurationSelected('90'),
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
                controller: priceController,
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
            onPressed: onAddPressed,
          ),
        ),
      ],
    );
  }
}
