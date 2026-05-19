import 'package:tayseer/features/advisor/layout/views/widgets/guest_lock_widget.dart';
import 'package:tayseer/features/user/interactions/data/Model/interaction_usermodel%20.dart';
import 'package:tayseer/features/user/marriage/view/widget/marriage_body.dart';
import 'package:tayseer/features/user/marriage/view/widget/marriage_location_guard.dart';
import 'package:tayseer/features/user/marriage/view_model/marriage_cubit.dart';
import 'package:tayseer/features/user/questions/presentation/manager/questions_cubit.dart';
import 'package:tayseer/features/user/questions/presentation/manager/questions_state.dart';
import 'package:tayseer/core/services/secure_window_service.dart';
import 'package:tayseer/core/utils/router/route_observers.dart';
import 'package:tayseer/my_import.dart';

class MarriageView extends StatefulWidget {
  const MarriageView({
    super.key,
    this.personId,
    this.fromInteractions = false,
    this.initialIsFavorite = false,
    this.interactionUser,
    this.onScroll,
  });

  final String? personId;
  final Function(bool isScrollingDown)? onScroll;
  final bool fromInteractions;
  final bool initialIsFavorite;
  final InteractionUserModel? interactionUser;

  @override
  State<MarriageView> createState() => _MarriageViewState();
}

class _MarriageViewState extends State<MarriageView> with RouteAware {
  @override
  void initState() {
    super.initState();
    SecureWindowService.enable();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) videoRouteObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    videoRouteObserver.unsubscribe(this);
    SecureWindowService.disable();
    super.dispose();
  }

  /// بيتنادى لما الـ user يرجع لهذه الصفحة من صفحة فوقيها
  @override
  void didPopNext() {
    // أعد بناء الـ widget عشان يقرأ kCurrentUserData من جديد
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final completed = kCurrentUserData?.compeletedData == true;
    final bool isDirectProfile = widget.personId != null;
    return PopScope(
      canPop: isDirectProfile,
      child: Scaffold(
        body: completed
            ? MarriageLocationGuard(
                child: BlocProvider(
                  create: (context) => MarriageCubit(
                    seedPersonId: widget.personId,
                    seedIsFavorite: widget.initialIsFavorite,
                    interactionUser: widget.interactionUser,
                  ),
                  child: SafeArea(
                    bottom: false,
                    top: false,
                    child: MarriageBody(
                      personId: widget.personId,
                      fromInteractions: widget.fromInteractions,
                      initialIsFavorite: widget.initialIsFavorite,
                      onScroll: widget.onScroll,
                    ),
                  ),
                ),
              )
            : BlocProvider.value(
                value: getIt<QuestionsCubit>(),
                child: BlocConsumer<QuestionsCubit, QuestionsState>(
                  listener: (context, state) {
                    if (state.lastQuestionNumberState == CubitStates.success) {
                      context.pop();
                      final lastQuestionNumber =
                          state
                              .lastQuestionNumberResponse
                              ?.lastQuestionNumber ??
                          0;
                      Future<void> navigate() async {
                        if (lastQuestionNumber >= 0 &&
                            lastQuestionNumber <= 25) {
                          await context.pushNamed(
                            AppRouter.kQuestionsPageView,
                            arguments: {
                              'lastQuestionNumber': lastQuestionNumber,
                            },
                          );
                        } else if (lastQuestionNumber <= 26) {
                          await context.pushNamed(AppRouter.kPersonalInfoView);
                        } else if (lastQuestionNumber <= 27) {
                          await context.pushNamed(AppRouter.kCommitmentView);
                        } else if (lastQuestionNumber >= 29) {
                          await context.pushNamed(
                            AppRouter.kUserPackagesView,
                            arguments: {'fromOnboarding': true},
                          );
                        }
                        // بعد ما الـ user يرجع من الـ survey، نعمل rebuild
                        // عشان نقرأ kCurrentUserData من جديد
                        if (mounted) setState(() {});
                      }

                      navigate();
                    } else if (state.lastQuestionNumberState ==
                        CubitStates.failure) {
                      context.pop();
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
                        builder: (_) => const Center(child: CustomloadingApp()),
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
      ),
    );
  }
}
