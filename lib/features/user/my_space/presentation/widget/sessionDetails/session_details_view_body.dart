import 'dart:developer';
import 'package:tayseer/features/advisor/chat/presentation/widget/show_confirmation_dialog.dart';
import 'package:tayseer/features/user/my_space/data/helper/session_detailes_helper.dart';
import 'package:tayseer/features/user/my_space/data/model/sessiondetailes/session_detailes_model.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/session_detailes/sesion_detailes_cubit.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/session_detailes/session_detailes_state.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/reschedule/section_lable.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/sessionDetails/action_button.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/sessionDetails/cancel_search_listener.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/sessionDetails/card_wipper_widget.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/sessionDetails/error_state_widget.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/sessionDetails/payment_card_widget.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/sessionDetails/person_info_card.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/sessionDetails/price_detailes_card_widget.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/sessionDetails/session_data_card_widget.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/sessionDetails/session_detailes_app_bar.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/sessionDetails/session_detailes_shimmer.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/sessionDetails/status_card_widget.dart';
import 'package:tayseer/my_import.dart';

class UserSessionDetailsViewBody extends StatefulWidget {
  const UserSessionDetailsViewBody({super.key, required this.sessionId});

  final String sessionId;

  @override
  State<UserSessionDetailsViewBody> createState() =>
      _UserSessionDetailsViewBodyState();
}

class _UserSessionDetailsViewBodyState extends State<UserSessionDetailsViewBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _animationStarted = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SessionDetailsAppBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return BlocConsumer<SesionDetailesCubit, SessionDetailesState>(
      // ✅ تعديل الـ buildWhen لتشمل تغييرات البيانات
      buildWhen: (previous, current) {
        final stateChanged =
            previous.getSessionDetailesState != current.getSessionDetailesState;
        final dataChanged =
            previous.sessionDetailsData != current.sessionDetailsData;

        log('BuildWhen: stateChanged=$stateChanged, dataChanged=$dataChanged');

        return stateChanged || dataChanged;
      },
      listenWhen: (previous, current) {
        return previous.getSessionDetailesState !=
                current.getSessionDetailesState ||
            previous.sessionDetailsData != current.sessionDetailsData;
      },
      listener: _handleStateChanges,
      builder: (context, state) {
        log(
          'Builder: state=${state.getSessionDetailesState}, hasData=${state.sessionDetailsData != null}',
        );

        if (state.getSessionDetailesState == CubitStates.loading) {
          return const SessionDetailsShimmer();
        }

        if (state.getSessionDetailesState == CubitStates.failure) {
          return ErrorStateWidget(
            errorMessage: state.errorMessage,
            onRetry: _retryLoading,
          );
        }

        if (state.sessionDetailsData != null) {
          // ✅ شغل الـ animation مرة واحدة بس
          if (!_animationStarted) {
            _animationStarted = true;
            _animationController.forward();
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: _SuccessContent(
              key: ValueKey(
                state.sessionDetailsData!.date.toString() +
                    state.sessionDetailsData!.timeRange.from,
              ),
              data: state.sessionDetailsData!,
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  void _handleStateChanges(BuildContext context, SessionDetailesState state) {
    log('Listener: state changed to ${state.getSessionDetailesState}');

    if (state.sessionDetailsData != null) {
      log(
        'Listener: Session data updated - date: ${state.sessionDetailsData!.date}, time: ${state.sessionDetailsData!.timeRange.from}',
      );
    }
  }

  void _retryLoading() {
    context.read<SesionDetailesCubit>().getSessionDetailes(widget.sessionId);
  }
}

/// Success Content Widget
class _SuccessContent extends StatelessWidget {
  final SessionDetailsDataResponse data;

  const _SuccessContent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final status = SessionDetailsHelper.parseStatus(data.status);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Person Info Section
              const SectionLabel(title: "بيانات الشخص"),
              CardWrapper(
                child: PersonInfoCard(
                  name: data.advisor.name,
                  handle: data.advisor.userName ?? "@${data.advisor.name}",
                  imageUrl: data.advisor.image,
                ),
              ),
              SizedBox(height: 20.h),

              // Status Section
              const SectionLabel(title: "حالة الحجز"),
              CardWrapper(child: StatusCard(status: status)),
              SizedBox(height: 20.h),

              // Session Data Section
              const SectionLabel(title: "بيانات الجلسة"),
              CardWrapper(
                child: SessionDataCard(
                  date: SessionDetailsHelper.formatDateArabic(data.date),
                  time: "${data.timeRange.from} - ${data.timeRange.to}",
                  duration: "${data.duration} دقيقة",
                  isAnonymous: data.isAnonymous,
                ),
              ),
              SizedBox(height: 20.h),

              // Price Section
              const SectionLabel(title: "بيانات السعر"),
              CardWrapper(child: PriceDetailsCard(pricing: data.pricing)),
              SizedBox(height: 20.h),

              // Payment Method Section
              const SectionLabel(title: "وسيلة الدفع"),
              CardWrapper(
                child: PaymentMethodCard(paymentMethod: data.paymentMethods),
              ),
              SizedBox(height: 30.h),

              // Action Buttons
              ActionButtons(
                status: status,
                sessionData: data,
                onReschedule: () {
                  context.pushNamed(
                    AppRouter.kChooseSessionView,
                    arguments: {
                      "oldBookingData": data,
                      "advisorId": data.advisor.id,
                    },
                  );
                },
                onCancel: () {
                  showConfirmationDialog(
                    context: context,
                    imagePath: AssetsData.cancelDialogIcon,
                    title: "هل تريد إلغاء الحجز ؟",
                    subtitle:
                        "هل انت متأكد انك تريد إلغاء حجز الجلسه مع المستشار لحل مشاكل علاقاتك التي تواجهها !",
                    onConfirm: () {
                      context.read<SesionDetailesCubit>().cancelSession(
                        data.sessionId,
                      );
                    },
                  );
                },
                onRateAdvisor: () {
                  context.pushNamed(
                    AppRouter.userRatingAdvisor,
                    arguments: {"sessiondata": data},
                  );
                },
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
        CancelSearchListener(),
      ],
    );
  }
}
