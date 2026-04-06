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
            // زر الرجوع
            Align(
              alignment: isArabic
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
              ),
            ),

            // العنوان
            Text(
              '🌍 ${context.tr('choose_country_title')}',
              textAlign: TextAlign.center,
              style: Styles.textStyle24.copyWith(
                color: AppColors.kscandryTextColor,
                fontWeight: FontWeight.w900,
              ),
            ),
            Gap(context.responsiveHeight(6)),
            Text(
              context.tr('choose_country_subtitle'),
              textAlign: TextAlign.center,
              style: Styles.textStyle12.copyWith(color: Colors.grey.shade600),
            ),

            Gap(context.responsiveHeight(24)),

            // شريط البحث
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
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
            ),

            Gap(context.responsiveHeight(16)),

            // القائمة
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    Gap(context.responsiveHeight(12)),
                    ...mostRequested.map(
                      (c) => _buildCountryCard(
                        c,
                        context,
                        isDisabled: addedKeys.contains(c.translationKey),
                      ),
                    ),
                    Gap(context.responsiveHeight(16)),
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
                    Gap(context.responsiveHeight(12)),
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
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: CustomBotton(
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
            ),
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
    final countryName = context.tr(country.translationKey);

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () => setState(() {
              _selectedCountryKey = country.translationKey;
              _selectedCountryFlag = country.flagEmoji;
            }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDisabled
                ? Colors.grey.shade200
                : isSelected
                ? AppColors.kprimaryColor
                : Colors.white,
            width: 1.5,
          ),
          boxShadow: isDisabled
              ? []
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                    countryName,
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
                        color: Colors.green.shade400,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Opacity(
              opacity: isDisabled ? 0.4 : 1.0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  country.flagEmoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
