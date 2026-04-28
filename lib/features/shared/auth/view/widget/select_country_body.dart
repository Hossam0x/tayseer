import 'package:tayseer/features/shared/auth/model/localc_country_model.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
import 'package:tayseer/my_import.dart';

class SelectCountryBody extends StatefulWidget {
  const SelectCountryBody({super.key});

  @override
  State<SelectCountryBody> createState() => _SelectCountryBodyState();
}

class _SelectCountryBodyState extends State<SelectCountryBody> {
  String? selectedCountryKey;
  String? selectedCountryFlag;
  String searchQuery = '';

  final List<LocalCountryModel> allCountries = [
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
    final authCubit = getIt<AuthCubit>();

    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- زر الرجوع ---
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

              // --- العنوان ---
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
                context.tr('select_one_country_max'),
                textAlign: TextAlign.center,
                style: Styles.textStyle12.copyWith(color: Colors.grey.shade600),
              ),

              Gap(context.responsiveHeight(24)),

              // --- شريط البحث ---
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
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
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

              // --- إحصائية ---
              // ★ BlocBuilder يلف بس القائمة مش كل الشاشة
              Expanded(
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final alreadyAddedCountryKeys = state.summaryList
                        .map((c) => c.countryKey)
                        .toSet();

                    final filteredMostRequested = allCountries
                        .where(
                          (c) =>
                              c.isMostRequested &&
                              context
                                  .tr(c.translationKey)
                                  .toLowerCase()
                                  .contains(searchQuery.toLowerCase()),
                        )
                        .toList();

                    final filteredOtherCountries = allCountries
                        .where(
                          (c) =>
                              !c.isMostRequested &&
                              context
                                  .tr(c.translationKey)
                                  .toLowerCase()
                                  .contains(searchQuery.toLowerCase()),
                        )
                        .toList();

                    final totalVisible =
                        filteredMostRequested.length +
                        filteredOtherCountries.length;

                    return Column(
                      children: [
                        // --- إحصائية ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.tr('available_countries'),
                                style: Styles.textStyle12Bold.copyWith(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              Text(
                                '$totalVisible ${context.tr('country_word')}',
                                style: Styles.textStyle12Bold.copyWith(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Gap(context.responsiveHeight(16)),

                        // --- قائمة الدول ---
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: [
                              if (filteredMostRequested.isNotEmpty) ...[
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
                                ...filteredMostRequested
                                    .map(
                                      (c) => _buildCountryCard(
                                        c,
                                        context,
                                        isDisabled: alreadyAddedCountryKeys
                                            .contains(c.translationKey),
                                      ),
                                    )
                                    .toList(),
                                Gap(context.responsiveHeight(16)),
                              ],
                              if (filteredOtherCountries.isNotEmpty) ...[
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
                                ...filteredOtherCountries
                                    .map(
                                      (c) => _buildCountryCard(
                                        c,
                                        context,
                                        isDisabled: alreadyAddedCountryKeys
                                            .contains(c.translationKey),
                                      ),
                                    )
                                    .toList(),
                              ],
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // ★★★ زر التالي بره الـ BlocBuilder ★★★
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: CustomBotton(
                  width: double.infinity,
                  title: context.tr('next'),
                  useGradient: selectedCountryKey != null,
                  backGroundcolor: AppColors.kgreyColor,
                  onPressed: selectedCountryKey != null
                      ? () {
                          final key = selectedCountryKey!;
                          final flag = selectedCountryFlag!;

                          // ★★★ حدث الكيوبت أولاً (قبل الـ navigate) ★★★
                          authCubit.selectCountry(
                            countryKey: key,
                            flagEmoji: flag,
                          );

                          // ★★★ بعدين انتقل ★★★
                          Navigator.of(
                            context,
                          ).pushNamed(AppRouter.kSelectSessionDurationView);
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ★ تعديل: إضافة بارامتر isDisabled
  Widget _buildCountryCard(
    LocalCountryModel country,
    BuildContext context, {
    bool isDisabled = false,
  }) {
    bool isSelected = selectedCountryKey == country.translationKey;
    String countryName = context.tr(country.translationKey);

    return GestureDetector(
      // ★ لو disabled → مفيش أكشن
      onTap: isDisabled
          ? null
          : () {
              setState(() {
                selectedCountryKey = country.translationKey;
                selectedCountryFlag = country.flagEmoji;
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          // ★ لون مختلف لو disabled
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
              ? [] // بدون ظل لو disabled
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
            // الراديو بوتن
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // ★ لو disabled → لون رمادي مع علامة صح
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
              // ★ أيقونة صح للدول المضافة
              child: isDisabled
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),

            const SizedBox(width: 12),

            // اسم الدولة
            Expanded(
              child: Column(
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    countryName,
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    style: Styles.textStyle14.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      // ★ لون رمادي لو disabled
                      color: isDisabled ? Colors.grey.shade400 : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  // ★ نص "تم إضافتها" تحت اسم الدولة
                  if (isDisabled)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        context.tr('already_added'),
                        style: Styles.textStyle10.copyWith(
                          color: Colors.green.shade400,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // العلم
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Opacity(
                // ★ شفافية أقل لو disabled
                opacity: isDisabled ? 0.4 : 1.0,
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
