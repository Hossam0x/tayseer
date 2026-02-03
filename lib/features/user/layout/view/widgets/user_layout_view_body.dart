import 'package:tayseer/core/constant/constans_keys.dart';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/features/shared/home/views/home_view.dart';
import 'package:tayseer/features/advisor/layout/views/widgets/guest_lock_widget.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_cubit.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/interaction_body.dart'; // ✅ إضافة هذا
import 'package:tayseer/features/user/layout/view/widgets/user_nav_bar.dart';
import 'package:tayseer/features/user/marriage/view/marriage_view.dart';
import 'package:tayseer/features/user/my_space/presentation/view/my_space_view.dart';
import 'package:tayseer/features/user/questions/view_model/questions_cubit.dart';
import 'package:tayseer/features/user/questions/view_model/questions_state.dart';
import 'package:tayseer/features/user/user_profile/views/user_profile_view.dart';
import 'package:tayseer/my_import.dart';

class UserLayOutViewBody extends StatefulWidget {
  const UserLayOutViewBody({super.key});

  @override
  State<UserLayOutViewBody> createState() => _UserLayOutViewBodyState();
}

class _UserLayOutViewBodyState extends State<UserLayOutViewBody> {
  // ✅ Now using the public InteractionBodyState class
  final GlobalKey<InteractionBodyState> _interactionsKey =
      GlobalKey<InteractionBodyState>();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LayoutCubit>();

    return BlocBuilder<LayoutCubit, LayoutState>(
      builder: (context, state) {
        final pages = _getPages(context, cubit);

        final cachedCompleted = CachNetwork.getBoolData(
          key: kIsCompletedQuestions,
        );
        debugPrint('kIsCompletedQuestions cached value: $cachedCompleted');

        return Scaffold(
          body: Stack(
            children: [
              IndexedStack(index: state.currentIndex, children: pages),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 300),
                  offset: state.isNavVisible ? Offset.zero : const Offset(0, 1),
                  child: UserNavBar(
                    onTabReselect: (index) {
                      // ✅ التحقق من التاب المختار (Interactions في index 3)
                      if (index == 3 && state.currentIndex == 3) {
                        _interactionsKey.currentState?.handleTabReselect();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _getPages(BuildContext context, LayoutCubit cubit) {
    switch (selectedUserType) {
      case UserTypeEnum.user:
        return [
          HomeView(onScroll: cubit.onScroll),
          CachNetwork.getBoolData(key: kIsCompletedQuestions) == true
              ? MarriageView()
              : BlocProvider.value(
                  value: getIt<QuestionsCubit>(),
                  child: BlocConsumer<QuestionsCubit, QuestionsState>(
                    listener: (context, state) {
                      if (state.lastQuestionNumberState ==
                          CubitStates.success) {
                        context.pop(); // Close loading dialog if open
                        final lastQuestionNumber =
                            state
                                .lastQuestionNumberResponse
                                ?.lastQuestionNumber ??
                            0;
                        debugPrint('Last Question Number: $lastQuestionNumber');
                        if (lastQuestionNumber == 0) {
                          context.pushNamed(AppRouter.kChooseGenderView);
                        } else if (lastQuestionNumber >= 1 &&
                            lastQuestionNumber < 20) {
                          context.pushNamed(
                            AppRouter.kQuestionsPageView,
                            arguments: {
                              'lastQuestionNumber': lastQuestionNumber,
                            },
                          );
                        } else if (lastQuestionNumber >= 20) {
                          context.pushNamed(AppRouter.kPersonalInfoView);
                        }
                        // else if (lastQuestionNumber == 23) {
                        //   context.pushNamed(
                        //     AppRouter.kBlockedContactsSuccessScreen,
                        //   );
                        // }
                      } else if (state.lastQuestionNumberState ==
                          CubitStates.failure) {
                        context.pop(); // Close loading dialog if open
                        ScaffoldMessenger.of(context).showSnackBar(
                          CustomSnackBar(
                            context,
                            text:
                                state.errorMessage ??
                                context.tr('failed_to_fetch_data'),
                            isSuccess: false,
                          ),
                        );
                      } else if (state.lastQuestionNumberState ==
                          CubitStates.loading) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              const Center(child: CustomloadingApp()),
                        );
                      }
                    },
                    builder: (context, state) {
                      final cubit = getIt<QuestionsCubit>();
                      return GuestLockWidget(
                        titleBott: context.tr('complete_your_profile_bott'),
                        message: context.tr('complete_your_profile'),
                        description: context.tr(
                          'complete_your_profile_description',
                        ),
                        onTap: () {
                          cubit.fetchLastQuestionNumber();
                        },
                      );
                    },
                  ),
                ),
          MySpaceView(),
          BlocProvider(
            create: (context) => getIt<InteractionsCubit>(),
            child: InteractionBody(
              key: _interactionsKey,
            ), // ✅ تمرير الـ Key مباشرة
          ),
          const UserProfileView(),
        ];

      case UserTypeEnum.guest:
        return [
          HomeView(onScroll: cubit.onScroll),
          GuestLockWidget(
            onTap: () {
              context.pushNamedAndRemoveUntil(
                AppRouter.kRegisrationView,
                predicate: (_) => false,
              );
            },
            message: 'فرص التوافق تبدأ بعد التسجيل',
            description:
                'أنشئ حسابك عشان تقدر تتعرف على أشخاص مناسبين ليك بطريقة آمنة ومُنظمة.',
          ),
          GuestLockWidget(
            message: 'تواصل مباشر مع الاشخاص و مستشار علاقات ',
            description:
                'التسجيل يتيح لك مراسلة المستشارين وحجز جلسات خاصة تناسب حالتك.',
            onTap: () {
              context.pushNamedAndRemoveUntil(
                AppRouter.kRegisrationView,
                predicate: (_) => false,
              );
            },
          ),
          GuestLockWidget(
            message: 'تواصل مباشر مع الاشخاص و مستشار علاقات ',
            description:
                'التسجيل يتيح لك مراسلة المستشارين وحجز جلسات خاصة تناسب حالتك.',
            onTap: () {
              context.pushNamedAndRemoveUntil(
                AppRouter.kRegisrationView,
                predicate: (_) => false,
              );
            },
          ),
          const UserProfileView(),
        ];

      case UserTypeEnum.asConsultant:
        return [];
      default:
        return [];
    }
  }
}
