import 'package:tayseer/features/shared/auth/view/widget/custom_switch_tile.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
import 'package:tayseer/my_import.dart';

class SelectDaysBody extends StatelessWidget {
  const SelectDaysBody({super.key});

  @override
  Widget build(BuildContext context) {
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
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
              ),

              Gap(context.responsiveHeight(10)),

              /// Title
              Text(
                context.tr('selectAvailableDays'),
                style: Styles.textStyle18.copyWith(
                  fontWeight: FontWeight.bold,
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

              /// Button
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  final hasSelection = state.availableDays.isNotEmpty;

                  return CustomBotton(
                    width: context.width * .9,
                    title: context.tr('next'),
                    useGradient: hasSelection,
                    backGroundcolor: AppColors.kgreyColor,
                    onPressed: hasSelection
                        ? () {
                            // authCubit.addServiceProvider();
                            context.pushNamed(
                              AppRouter.kSelectSessionDurationView,
                            );
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
