import 'package:tayseer/features/shared/auth/model/summar_session_model.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
import 'package:tayseer/my_import.dart';

class SetupSummaryBody extends StatelessWidget {
  const SetupSummaryBody({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = getIt<AuthCubit>();

    return CustomBackground(
      child: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          // ★★★ أضف listenWhen ★★★
          listenWhen: (previous, current) =>
              previous.setOfferingsState != current.setOfferingsState,
          listener: (context, state) {
            if (state.setOfferingsState == CubitStates.success) {
              // ★★★ Reset أولاً ★★★
              authCubit.resetSetOfferingsState();
              context.pushNamed(AppRouter.kAccountReviewScreen);
            } else if (state.setOfferingsState == CubitStates.failure) {
              authCubit.resetSetOfferingsState();
              ScaffoldMessenger.of(context).showSnackBar(
                CustomSnackBar(
                  context,
                  isError: true,
                  text: state.errorMessage ?? '',
                ),
              );
            }
          },
          builder: (context, state) {
            final summaryData = state.summaryList;
            final totalCountries = state.totalSummaryCountriesCount;
            final totalSessions = state.totalSummarySessionsCount;

            return Column(
              children: [
                // --- 1. App Bar ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // IconButton(
                      //   icon: Icon(
                      //     isArabic ? Icons.arrow_back : Icons.arrow_forward,
                      //   ),
                      //   onPressed: () => context.pop(),
                      // ),
                      Text(
                        context.tr('setup_summary_title'),
                        style: Styles.textStyle16.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      // const SizedBox(width: 48),
                    ],
                  ),
                ),

                // --- 2. المحتوى ---
                Expanded(
                  child: summaryData.isEmpty
                      ? _buildEmptyState(context)
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            Gap(context.responsiveHeight(16)),
                            _buildSuccessBanner(
                              totalCountries,
                              totalSessions,
                              context,
                            ),
                            Gap(context.responsiveHeight(24)),
                            ...List.generate(summaryData.length, (index) {
                              return _buildCountryCard(
                                summaryData[index],
                                index,
                                context,
                                authCubit,
                              );
                            }),
                          ],
                        ),
                ),

                // --- 3. الأزرار ---
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // زر إضافة دولة أخرى
                      GestureDetector(
                        onTap: () {
                          context.pushNamed(AppRouter.kSelectCountryView);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.kprimaryColor,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '+ ${context.tr('add_another_country')}',
                              style: Styles.textStyle16.copyWith(
                                color: AppColors.kprimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      Gap(context.responsiveHeight(12)),

                      // ★★★ زر إرسال الـ offerings ★★★
                      CustomBotton(
                        width: double.infinity,
                        title: state.setOfferingsState == CubitStates.loading
                            ? context.tr('sending')
                            : '${context.tr('finish_and_save')} ✓',
                        useGradient: summaryData.isNotEmpty,
                        backGroundcolor: AppColors.kgreyColor,
                        onPressed:
                            summaryData.isNotEmpty &&
                                state.setOfferingsState != CubitStates.loading
                            ? () {
                                // ★ إرسال offerings
                                authCubit.submitOfferings();
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // باقي الدوال (بدون تغيير)
  // ==========================================

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.pink.shade100, width: 2),
            ),
            child: Icon(
              Icons.assignment_outlined,
              color: Colors.pink.shade200,
              size: 50,
            ),
          ),
          Gap(context.responsiveHeight(16)),
          Text(
            context.tr('no_sessions_added_yet'),
            style: Styles.textStyle16.copyWith(
              color: AppColors.kprimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Gap(context.responsiveHeight(8)),
          Text(
            context.tr('add_country_and_sessions_hint'),
            style: Styles.textStyle12.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner(
    int countriesCount,
    int sessionsCount,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.pink.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFA62A3B),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                context.tr('sessions_ready'),
                style: Styles.textStyle18.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFA62A3B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$countriesCount ${context.tr('countries_word')} · $sessionsCount ${context.tr('session_word')}',
                style: Styles.textStyle12.copyWith(color: Colors.pink.shade300),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.pink.shade100, width: 2),
            ),
            child: const Icon(
              Icons.assignment_turned_in,
              color: Color(0xFFA62A3B),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryCard(
    SummaryCountryModel country,
    int index,
    BuildContext context,
    AuthCubit authCubit,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => authCubit.removeCountryFromSummary(index),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.red.shade400,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: isArabic
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(country.countryKey),
                        style: Styles.textStyle14.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      ),
                      Text(
                        '${country.sessions.length} ${context.tr('added_sessions_subtitle')}',
                        style: Styles.textStyle10.copyWith(
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    country.flagEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey.shade100, height: 1, thickness: 1.5),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              children: List.generate(country.sessions.length, (sessionIndex) {
                return _buildSessionItem(
                  country.sessions[sessionIndex],
                  context,
                  onDelete: () => authCubit.removeSessionFromSummary(
                    countryIndex: index,
                    sessionIndex: sessionIndex,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionItem(
    SessionItemModel session,
    BuildContext context, {
    VoidCallback? onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isArabic
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red.shade300,
                      size: 16,
                    ),
                  ),
                ),
              Text(
                session.name,
                style: Styles.textStyle14.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.pink.shade400,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: isArabic ? WrapAlignment.end : WrapAlignment.start,
            children: [
              // ★ السعر + العملة
              _buildSmallChip(
                '${session.price} ${session.currency}',
                isGreen: true,
              ),
              // المدة
              _buildSmallChip(
                '${session.duration}${context.tr('minute_shortcut')}',
                isGray: true,
              ),
              // ★ النوع بالعربي للعرض
              _buildSmallChip(
                session.type == 'package'
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

  Widget _buildSmallChip(
    String text, {
    bool isPink = false,
    bool isGreen = false,
    bool isGray = false,
  }) {
    Color bgColor = Colors.transparent;
    Color textColor = Colors.black;

    if (isPink) {
      bgColor = Colors.pink.shade50;
      textColor = Colors.pink.shade400;
    } else if (isGreen) {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade600;
    } else if (isGray) {
      bgColor = Colors.grey.shade100;
      textColor = Colors.grey.shade600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
