import 'package:tayseer/features/advisor/settings/view/cubit/offerings/update_offerings_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/offerings/update_offerings_state.dart';
import 'package:tayseer/features/shared/auth/model/localc_country_model.dart';
import 'package:tayseer/my_import.dart';

class UpdateSelectCountryBody extends StatefulWidget {
  const UpdateSelectCountryBody({super.key});

  @override
  State<UpdateSelectCountryBody> createState() =>
      _UpdateSelectCountryBodyState();
}

class _UpdateSelectCountryBodyState extends State<UpdateSelectCountryBody> {
  String? _selectedCountryKey;
  String? _selectedCountryFlag;
  String _searchQuery = '';

  final List<LocalCountryModel> _allCountries = [
    LocalCountryModel(
      translationKey: 'country_saudi',
      flagEmoji: '🇸🇦',
      isMostRequested: true,
    ),
    LocalCountryModel(
      translationKey: 'country_egypt',
      flagEmoji: '🇪🇬',
      isMostRequested: true,
    ),
    LocalCountryModel(
      translationKey: 'country_emirati',
      flagEmoji: '🇦🇪',
      isMostRequested: true,
    ),
    LocalCountryModel(
      translationKey: 'country_kuwait',
      flagEmoji: '🇰🇼',
      isMostRequested: true,
    ),
    LocalCountryModel(
      translationKey: 'country_qatar',
      flagEmoji: '🇶🇦',
      isMostRequested: true,
    ),
    LocalCountryModel(translationKey: 'country_bahrain', flagEmoji: '🇧🇭'),
    LocalCountryModel(translationKey: 'country_jordan', flagEmoji: '🇯🇴'),
    LocalCountryModel(translationKey: 'country_palestine', flagEmoji: '🇵🇸'),
    LocalCountryModel(translationKey: 'country_morocco', flagEmoji: '🇲🇦'),
    LocalCountryModel(translationKey: 'country_tunisia', flagEmoji: '🇹🇳'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UpdateOfferingsCubit, UpdateOfferingsState>(
      builder: (context, state) {
        final cubit = context.read<UpdateOfferingsCubit>();
        final addedKeys = state.addedCountryKeys;

        final mostRequested = _allCountries
            .where(
              (c) =>
                  c.isMostRequested &&
                  context
                      .tr(c.translationKey)
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()),
            )
            .toList();

        final others = _allCountries
            .where(
              (c) =>
                  !c.isMostRequested &&
                  context
                      .tr(c.translationKey)
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()),
            )
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // شريط البحث
            Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                decoration: InputDecoration(
                  hintText: context.tr('search_country_hint'),
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  prefixIcon: isArabic
                      ? null
                      : Icon(Icons.search, color: Colors.grey.shade400),
                  suffixIcon: isArabic
                      ? Icon(Icons.search, color: Colors.grey.shade400)
                      : null,
                ),
              ),
            ),

            Gap(16.h),

            // إحصائية
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('available_countries'),
                  style: Styles.textStyle12Bold.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
                Text(
                  '${mostRequested.length + others.length} ${context.tr('country_word')}',
                  style: Styles.textStyle12Bold.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),

            Gap(12.h),

            // القائمة
            Expanded(
              child: ListView(
                children: [
                  if (mostRequested.isNotEmpty) ...[
                    Align(
                      alignment: isArabic
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Text(
                        '⭐ ${context.tr('most_requested')}',
                        style: Styles.textStyle12.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Gap(12.h),
                    ...mostRequested.map(
                      (c) => _buildCountryCard(
                        c,
                        context,
                        isDisabled: addedKeys.contains(c.translationKey),
                      ),
                    ),
                    Gap(16.h),
                  ],
                  if (others.isNotEmpty) ...[
                    Align(
                      alignment: isArabic
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Text(
                        context.tr('all_countries'),
                        style: Styles.textStyle12.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Gap(12.h),
                    ...others.map(
                      (c) => _buildCountryCard(
                        c,
                        context,
                        isDisabled: addedKeys.contains(c.translationKey),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // زر التالي
            Gap(12.h),
            CustomBotton(
              width: double.infinity,
              title: context.tr('next'),
              useGradient: _selectedCountryKey != null,
              backGroundcolor: AppColors.kgreyColor,
              onPressed: _selectedCountryKey != null
                  ? () => cubit.selectCountry(
                      countryKey: _selectedCountryKey!,
                      flagEmoji: _selectedCountryFlag!,
                    )
                  : null,
            ),
            Gap(20.h),
          ],
        );
      },
    );
  }

  Widget _buildCountryCard(
    LocalCountryModel country,
    BuildContext context, {
    bool isDisabled = false,
  }) {
    final isSelected = _selectedCountryKey == country.translationKey;

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () => setState(() {
              _selectedCountryKey = country.translationKey;
              _selectedCountryFlag = country.flagEmoji;
            }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDisabled
              ? Colors.grey.shade100
              : isSelected
              ? AppColors.kprimaryColor.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isDisabled
                ? Colors.grey.shade200
                : isSelected
                ? AppColors.kprimaryColor
                : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDisabled ? Colors.grey.shade300 : Colors.transparent,
                border: Border.all(
                  color: isDisabled
                      ? Colors.grey.shade300
                      : isSelected
                      ? AppColors.kprimaryColor
                      : Colors.grey.shade300,
                  width: isDisabled
                      ? 0
                      : isSelected
                      ? 6
                      : 1.5,
                ),
              ),
              child: isDisabled
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(country.translationKey),
                    style: Styles.textStyle14.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isDisabled ? Colors.grey.shade400 : Colors.black87,
                    ),
                  ),
                  if (isDisabled)
                    Text(
                      context.tr('already_added'),
                      style: Styles.textStyle10.copyWith(
                        color: Colors.green.shade500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Opacity(
              opacity: isDisabled ? 0.4 : 1.0,
              child: Text(
                country.flagEmoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
