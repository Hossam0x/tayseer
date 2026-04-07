import 'package:tayseer/features/user/my_space/data/helper/rescheduleHelper.dart';
import 'package:tayseer/features/user/my_space/data/model/sessiondetailes/session_detailes_model.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/create_session/create_session_cubit.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/create_session/create_session_state.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/reschedule/month_navigator.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/reschedule/day_time_wheel_picker.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/reschedule/anonymous_toggle.dart';
import 'package:tayseer/my_import.dart';

class UserRescheduleViewBody extends StatefulWidget {
  final SessionDetailsDataResponse? oldBookingData;
  final String title;
  final String advisorId;
  final String duration;

  const UserRescheduleViewBody({
    super.key,
    this.oldBookingData,
    required this.title,
    required this.advisorId,
    required this.duration,
  });

  @override
  State<UserRescheduleViewBody> createState() => _UserRescheduleViewBodyState();
}

class _UserRescheduleViewBodyState extends State<UserRescheduleViewBody> {
  // ★ الاختيارات
  int? _selectedDayIndex;
  String? _selectedDate;
  String? _selectedTime;
  bool _isAnonymous = false;

  // ★ بيانات قديمة (للريسكيدول)
  bool _hasInitialized = false;

  bool get _isReschedule => widget.oldBookingData != null;
  String? get _oldSessionId => widget.oldBookingData?.sessionId;

  @override
  void initState() {
    super.initState();
    _initializeFromOldData();
  }

  void _initializeFromOldData() {
    if (!_isReschedule || _hasInitialized) return;
    final oldData = widget.oldBookingData!;
    _selectedDate = oldData.dateString;
    _hasInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return CustomBackground(
      child: SafeArea(
        // ════════════════════════════════════════
        // ★ BlocListener فقط للأحداث الجانبية
        //   (Toast / Navigation) - لا يعمل rebuild
        // ════════════════════════════════════════
        child: BlocListener<AvailableSlotsCubit, AvailableSlotsState>(
          listener: _blocListener,
          child: Column(
            children: [
              // ═══════════════════════════════════
              // 1. ★ Header - ثابت لا يتأثر بأي state
              // ═══════════════════════════════════
              _buildHeader(context),

              // ═══════════════════════════════════
              // 2. ★ MonthNavigator - يتغير فقط لما الشهر يتغير
              // ═══════════════════════════════════
              Padding(
                padding: EdgeInsets.only(top: 16.h),
                child:
                    BlocSelector<
                      AvailableSlotsCubit,
                      AvailableSlotsState,
                      ({int month, int year})
                    >(
                      selector: (state) => (
                        month: state.currentMonth ?? DateTime.now().month,
                        year: state.currentYear ?? DateTime.now().year,
                      ),
                      builder: (context, monthYear) {
                        return MonthNavigator(
                          month: monthYear.month,
                          year: monthYear.year,
                          onNext: () {
                            _resetSelections();
                            context.read<AvailableSlotsCubit>().getNextMonth();
                          },
                          onPrevious: () {
                            _resetSelections();
                            context
                                .read<AvailableSlotsCubit>()
                                .getPreviousMonth();
                          },
                        );
                      },
                    ),
              ),

              SizedBox(height: 16.h),

              // ═══════════════════════════════════
              // 3. ★ عناوين - ثابتة لا تتأثر
              // ═══════════════════════════════════
              _buildTitles(context),

              SizedBox(height: 8.h),

              // ═══════════════════════════════════
              // 4. ★ القائمة - تتغير فقط لما البيانات تتغير
              // ═══════════════════════════════════
              SizedBox(
                height: 320.h,
                child: BlocBuilder<AvailableSlotsCubit, AvailableSlotsState>(
                  buildWhen: (previous, current) {
                    // ★ يعيد البناء فقط لما:
                    // 1. حالة جلب البيانات تتغير
                    // 2. الأيام المتاحة تتغير
                    return previous.getAvailableSlotsState !=
                            current.getAvailableSlotsState ||
                        previous.allCalendarDays != current.allCalendarDays;
                  },
                  builder: (context, state) {
                    // ★ لودينج
                    if (state.getAvailableSlotsState == CubitStates.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // ★ خطأ
                    if (state.getAvailableSlotsState == CubitStates.failure) {
                      return _buildErrorWidget(context, state.errorMessage);
                    }

                    // ★ لا يوجد بيانات
                    if (state.getAvailableSlotsState == CubitStates.success &&
                        state.data == null) {
                      return _buildEmptyDays(context);
                    }

                    // ★ نجاح
                    final allDays = state.allCalendarDays;

                    if (allDays.isEmpty) {
                      return _buildEmptyDays(context);
                    }

                    return DayTimeWheelPicker(
                      key: ValueKey(
                        '${state.currentMonth}_${state.currentYear}',
                      ),
                      days: allDays,
                      selectedIndex: _selectedDayIndex,
                      onItemTapped: (index) {
                        final day = allDays[index];
                        setState(() {
                          _selectedDayIndex = index;
                          _selectedDate = day.date;
                          _selectedTime = day.firstAvailableTime;
                        });
                      },
                    );
                  },
                ),
              ),

              SizedBox(height: 20.h),

              // ═══════════════════════════════════
              // 5. ★ مجهول الهوية - يعتمد على local state فقط
              // ═══════════════════════════════════
              if (!_isReschedule)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: AnonymousToggle(
                    isAnonymous: _isAnonymous,
                    onChanged: (value) {
                      setState(() => _isAnonymous = value);
                    },
                  ),
                ),

              SizedBox(height: 12.h),

              const Spacer(),

              // ═══════════════════════════════════
              // 6. ★ زر التأكيد - يتغير فقط لما اللودينج يتغير
              // ═══════════════════════════════════
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child:
                    BlocSelector<
                      AvailableSlotsCubit,
                      AvailableSlotsState,
                      bool
                    >(
                      selector: (state) {
                        return _isReschedule
                            ? state.rescheduleSessionState ==
                                  CubitStates.loading
                            : state.createSessionState == CubitStates.loading;
                      },
                      builder: (context, isLoading) {
                        return CustomBotton(
                          width: double.infinity,
                          useGradient: _canSubmit(),
                          backGroundcolor: AppColors.kgreyColor,
                          title: _getButtonTitle(isLoading),
                          onPressed: (_canSubmit() && !isLoading)
                              ? () => _handleSubmit(context)
                              : null,
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════
  // ★ Header Widget - ثابت تماماً
  // ════════════════════════════════════════
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back, size: 25.sp),
          ),
          const Spacer(),
          Text(context.tr('reschedule'), style: Styles.textStyle18Bold),
          const Spacer(),
          SizedBox(width: 34.sp),
        ],
      ),
    );
  }

  // ════════════════════════════════════════
  // ★ Titles Widget - ثابت تماماً
  // ════════════════════════════════════════
  Widget _buildTitles(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.tr('select_time'),
            style: Styles.textStyle16Bold.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(context.tr('select_day'), style: Styles.textStyle16Bold),
        ],
      ),
    );
  }

  // ════════════════════════════════════════
  // ★ Bloc Listener - أحداث جانبية فقط
  // ════════════════════════════════════════
  void _blocListener(BuildContext context, AvailableSlotsState state) {
    if (state.createSessionState == CubitStates.success) {
      context.pushNamed(
        AppRouter.userticketSessionView,
        arguments: state.createdSession,
      );
    }
    if (state.createSessionState == CubitStates.failure) {
      AppToast.error(
        context,
        state.errorMessage ?? context.tr('session_creation_failed'),
      );
    }

    if (state.rescheduleSessionState == CubitStates.success) {
      AppToast.success(
        context,
        state.rescheduleSuccessMessage ?? context.tr('reschedule_success'),
      );
      Navigator.pop(context, true);
    }
    if (state.rescheduleSessionState == CubitStates.failure) {
      AppToast.error(
        context,
        state.errorMessage ?? context.tr('reschedule_failed'),
      );
    }

    if (state.getAvailableSlotsState == CubitStates.failure) {
      AppToast.error(
        context,
        state.errorMessage ?? context.tr('error_occurred'),
      );
    }
  }

  // ════════════════════════════════════════
  // ★ حالة فارغة
  // ════════════════════════════════════════
  Widget _buildEmptyDays(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 60.sp,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            context.tr('no_available_days'),
            style: Styles.textStyle14.copyWith(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════
  // ★ حالة الخطأ
  // ════════════════════════════════════════
  Widget _buildErrorWidget(BuildContext context, String? message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.shade50,
              ),
              child: Icon(
                Icons.error_outline,
                size: 50.sp,
                color: Colors.red.shade300,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              message ?? context.tr('error_occurred'),
              style: Styles.textStyle14.copyWith(color: Colors.red.shade400),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            CustomBotton(
              title: context.tr('retry'),
              useGradient: true,
              onPressed: () {
                context.read<AvailableSlotsCubit>().getAvailableSlots(
                  widget.advisorId,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════
  // ★ Helper Methods
  // ════════════════════════════════════════

  void _resetSelections() {
    setState(() {
      _selectedDayIndex = null;
      _selectedDate = null;
      _selectedTime = null;
    });
  }

  String _getButtonTitle(bool isLoading) {
    if (_isReschedule) {
      return isLoading ? context.tr('rescheduling') : context.tr('confirm');
    } else {
      return isLoading
          ? context.tr('booking_in_progress')
          : context.tr('confirm');
    }
  }

  bool _canSubmit() {
    return _selectedDate != null && _selectedTime != null;
  }

  void _handleSubmit(BuildContext context) {
    if (!_canSubmit()) {
      AppToast.error(context, context.tr('please_complete_all_fields'));
      return;
    }

    final dateTime = RescheduleHelper.formatDateTimeForApi(
      _selectedDate!,
      _selectedTime!,
    );

    if (_isReschedule) {
      _handleReschedule(context, dateTime);
    } else {
      _handleBooking(context, dateTime);
    }
  }

  void _handleReschedule(BuildContext context, String dateTime) {
    if (_oldSessionId == null) {
      AppToast.error(context, context.tr('cannot_identify_session'));
      return;
    }

    context.read<AvailableSlotsCubit>().rescheduleSession(
      sessionId: _oldSessionId!,
      date: dateTime,
      duration: widget.duration,
      time: _selectedTime!,
    );
  }

  void _handleBooking(BuildContext context, String dateTime) {
    context.read<AvailableSlotsCubit>().createSession(
      date: dateTime,
      advisorId: widget.advisorId,
      duration: widget.duration,
      time: _selectedTime!,
      paymentMethod: 'online',
    );
  }
}
