import 'package:tayseer/features/advisor/settings/view/cubit/offerings/update_offerings_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/offerings/update_offerings_state.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/update_offerings/steps/widgets/select_country_card.dart';
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
            // Search bar
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
                      (c) => SelectCountryCard(
                        country: c,
                        isSelected: _selectedCountryKey == c.translationKey,
                        isDisabled: addedKeys.contains(c.translationKey),
                        onTap: () => setState(() {
                          _selectedCountryKey = c.translationKey;
                          _selectedCountryFlag = c.flagEmoji;
                        }),
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
                      (c) => SelectCountryCard(
                        country: c,
                        isSelected: _selectedCountryKey == c.translationKey,
                        isDisabled: addedKeys.contains(c.translationKey),
                        onTap: () => setState(() {
                          _selectedCountryKey = c.translationKey;
                          _selectedCountryFlag = c.flagEmoji;
                        }),
                      ),
                    ),
                  ],
                ],
              ),
            ),

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
}
