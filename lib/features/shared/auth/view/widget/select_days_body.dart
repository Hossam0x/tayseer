import 'package:tayseer/features/shared/auth/view/widget/custom_switch_tile.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
import 'package:tayseer/my_import.dart';

class SelectDaysBody extends StatelessWidget {
  const SelectDaysBody({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = getIt<AuthCubit>();

    final daysKeys = [
      'saturday',
      'sunday',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
    ];

    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: Column(
            children: [
              /// Back
              Align(
                alignment: isArabic
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
              ),

              Gap(context.responsiveHeight(10)),

              /// Title
              Text(
                context.tr('selectAvailableDays'),
                style: Styles.textStyle20Bold.copyWith(
                  color: AppColors.kscandryTextColor,
                ),
              ),

              Gap(context.responsiveHeight(8)),

              /// Hint
              Text(
                context.tr('selectAvailableDaysHint'),
                textAlign: TextAlign.center,
                style: Styles.textStyle12,
              ),

              Gap(context.responsiveHeight(24)),

              /// Days List
              Expanded(
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    return ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.responsiveWidth(20),
                      ),
                      children: daysKeys.map((dayKey) {
                        return CustomSwitchTile(
                          title: context.tr(dayKey),
                          dayKey: dayKey,
                        );
                      }).toList(),
                    );
                  },
                ),
              ),

              /// ★ Button مربوط بالفانكشن
              BlocConsumer<AuthCubit, AuthState>(
                // ★★★ أضف listenWhen ★★★
                listenWhen: (previous, current) =>
                    previous.addDayProviderState != current.addDayProviderState,
                listener: (context, state) {
                  if (state.addDayProviderState == CubitStates.success) {
                    // ★★★ Reset أولاً ★★★
                    authCubit.resetAddDayProviderState();
                    context.pushNamed(AppRouter.kSelectCountryView);
                  } else if (state.addDayProviderState == CubitStates.failure) {
                    // ★★★ Reset كمان هنا ★★★
                    authCubit.resetAddDayProviderState();
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
                  final hasSelection = state.availableDays.isNotEmpty;
                  final isLoading =
                      state.addDayProviderState == CubitStates.loading;

                  return CustomBotton(
                    width: context.width * .9,
                    title: isLoading
                        ? context.tr('sending')
                        : context.tr('next'),
                    useGradient: hasSelection && !isLoading,
                    backGroundcolor: AppColors.kgreyColor,
                    onPressed: hasSelection && !isLoading
                        ? () {
                            authCubit.addDayProvider();
                          }
                        : null,
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
