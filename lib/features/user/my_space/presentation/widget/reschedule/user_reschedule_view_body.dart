import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/user/my_space/data/helper/rescheduleHelper.dart';
import 'package:tayseer/features/user/my_space/data/model/create_session/get_available_day.dart';
import 'package:tayseer/features/user/my_space/data/model/sessiondetailes/session_detailes_model.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/create_session/create_session_cubit.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/create_session/create_session_state.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/reschedule/bank_account_filed.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/reschedule/rechedule_calender.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/reschedule/reschedule_duration.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/reschedule/reschedule_header.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/reschedule/reschedule_payment_method.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/reschedule/reschedule_timer_selector.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/reschedule/section_lable.dart';
import 'package:tayseer/my_import.dart';

class UserRescheduleViewBody extends StatefulWidget {
  final SessionDetailsDataResponse? oldBookingData;
  final String title;
  final String advisorId;

  const UserRescheduleViewBody({
    super.key,
    this.oldBookingData,
    required this.title,
    required this.advisorId,
  });

  @override
  State<UserRescheduleViewBody> createState() => _UserRescheduleViewBodyState();
}

class _UserRescheduleViewBodyState extends State<UserRescheduleViewBody> {
  String? _selectedDate;
  int? _selectedDay;
  DurationOption? _selectedDuration;
  TimeSlot? _selectedTimeSlot;
  int _selectedPaymentMethod = 0;

  bool _hasInitializedDuration = false;
  bool _hasInitializedTimeSlot = false;

  bool get _isReschedule => widget.oldBookingData != null;

  String? get _oldSessionId => widget.oldBookingData?.sessionId;

  final TextEditingController _bankAccountController = TextEditingController();

  @override
  void dispose() {
    _bankAccountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeFromOldData();
  }

  void _initializeFromOldData() {
    if (!_isReschedule) return;

    final oldData = widget.oldBookingData!;

    _selectedDay = oldData.dayOfMonth;
    _selectedDate = oldData.dateString;
    _selectedPaymentMethod = oldData.paymentMethodIndex;
  }

  void _initializeDurationFromOldData(List<DurationOption> availableDurations) {
    if (!_isReschedule || _hasInitializedDuration) return;

    final matchedDuration = RescheduleHelper.findMatchingDuration(
      availableDurations: availableDurations,
      oldDuration: widget.oldBookingData!.duration,
    );

    if (matchedDuration != null) {
      setState(() {
        _selectedDuration = matchedDuration;
      });
    }

    _hasInitializedDuration = true;
  }

  void _initializeTimeSlotFromOldData(List<TimeSlot> availableTimeSlots) {
    if (!_isReschedule || _hasInitializedTimeSlot) return;

    final matchedSlot = RescheduleHelper.findMatchingTimeSlot(
      availableTimeSlots: availableTimeSlots,
      oldStartTime: widget.oldBookingData!.startTime,
    );

    if (matchedSlot != null) {
      setState(() {
        _selectedTimeSlot = matchedSlot;
      });
    }

    _hasInitializedTimeSlot = true;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: BlocConsumer<AvailableSlotsCubit, AvailableSlotsState>(
          listener: (context, state) {
            if (state.getAvailableSlotsState == CubitStates.failure) {
              _showErrorSnackBar(context, state.errorMessage ?? 'حدث خطأ');
            }

            if (state.createSessionState == CubitStates.success) {
              context.pushNamed(
                AppRouter.userticketSessionView,
                arguments: state.createdSession,
              );
            }

            if (state.createSessionState == CubitStates.failure) {
              _showErrorSnackBar(
                context,
                state.errorMessage ?? 'فشل في إنشاء الجلسة',
              );
            }

            if (state.rescheduleSessionState == CubitStates.success) {
              _showSuccessSnackBar(
                context,
                state.rescheduleSuccessMessage ?? 'تم إعادة جدولة الجلسة بنجاح',
              );
              Navigator.pop(context, true);
            }

            if (state.rescheduleSessionState == CubitStates.failure) {
              _showErrorSnackBar(
                context,
                state.errorMessage ?? 'فشل في إعادة جدولة الجلسة',
              );
            }
          },
          builder: (context, state) {
            if (state.getAvailableSlotsState == CubitStates.failure) {
              return _buildErrorWidget(context, state.errorMessage);
            }

            if (state.getAvailableSlotsState == CubitStates.success) {
              if (state.data == null) {
                return _buildErrorWidget(context, 'لا توجد بيانات');
              }
              return _buildContent(context, state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    AppToast.error(context, message);
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    AppToast.success(context, message);
  }

  Widget _buildErrorWidget(BuildContext context, String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60.sp, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            message ?? 'حدث خطأ',
            style: TextStyle(fontSize: 16.sp, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              context.read<AvailableSlotsCubit>().getAvailableSlots(
                widget.advisorId,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE85F78),
            ),
            child: const Text(
              'إعادة المحاولة',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AvailableSlotsState state) {
    final cubit = context.read<AvailableSlotsCubit>();

    final isLoading = _isReschedule
        ? state.rescheduleSessionState == CubitStates.loading
        : state.createSessionState == CubitStates.loading;

    if (_isReschedule &&
        !_hasInitializedDuration &&
        state.availableDurations.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeDurationFromOldData(state.availableDurations);
      });
    }

    List<TimeSlot> availableTimeSlots = [];
    if (_selectedDate != null && _selectedDuration != null) {
      availableTimeSlots = cubit.getTimeSlotsForDay(
        _selectedDate!,
        _selectedDuration!.duration,
      );

      if (_isReschedule &&
          !_hasInitializedTimeSlot &&
          availableTimeSlots.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _initializeTimeSlotFromOldData(availableTimeSlots);
        });
      }
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. الهيدر
              RescheduleHeader(
                title: _isReschedule ? "إعادة جدولة" : "حجز استشارة",
              ),
              SizedBox(height: 20.h),

              // 2. التقويم
              const SectionLabel(title: "التاريخ"),
              RescheduleCalendar(
                selectedDay: _selectedDay,
                month: state.currentMonth ?? DateTime.now().month,
                year: state.currentYear ?? DateTime.now().year,
                calendarDays: state.allCalendarDays,
                onDaySelected: (day, date) {
                  setState(() {
                    _selectedDay = day;
                    _selectedDate = date;
                    _selectedTimeSlot = null;
                    _hasInitializedTimeSlot = false;
                  });
                },
              ),
              SizedBox(height: 20.h),

              // 3. المدة
              const SectionLabel(title: "مدة الجلسة"),
              RescheduleDurationSelector(
                durations: state.availableDurations,
                selectedDuration: _selectedDuration,
                onDurationChanged: (duration) {
                  setState(() {
                    _selectedDuration = duration;
                    _selectedTimeSlot = null;
                    _hasInitializedTimeSlot = false;
                  });
                },
              ),
              SizedBox(height: 20.h),

              // 4. الوقت
              const SectionLabel(title: "الوقت"),
              RescheduleTimeSelector(
                timeSlots: availableTimeSlots,
                selectedTimeSlot: _selectedTimeSlot,
                onTimeSelected: (slot) {
                  setState(() {
                    _selectedTimeSlot = slot;
                  });
                },
              ),
              SizedBox(height: 20.h),

              if (!_isReschedule) ...[
                const SectionLabel(title: "طريقة الدفع"),
                ReschedulePaymentMethods(
                  selectedMethodIndex: _selectedPaymentMethod,
                  onMethodChanged: (index) {
                    setState(() {
                      _selectedPaymentMethod = index;
                    });
                  },
                ),
                SizedBox(height: 15.h),

                if (_selectedPaymentMethod == 0) ...[
                  const SectionLabel(title: "رقم الحساب البنكي"),
                  BankAccountField(
                    accountNumber: "SAXXXXXXXXXXXXXXXXXXXX",
                    controller: _bankAccountController,
                  ),
                  SizedBox(height: 30.h),
                ],
              ],

              Center(
                child: CustomBotton(
                  useGradient: true,
                  title: _getButtonTitle(isLoading),
                  onPressed: (_canSubmit() && !isLoading)
                      ? () => _handleSubmit(context)
                      : null,
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),

        // Loading overlay
      ],
    );
  }

  String _getButtonTitle(bool isLoading) {
    if (_isReschedule) {
      return isLoading ? "جاري إعادة الجدولة..." : "إعادة الجدولة";
    } else {
      return isLoading ? "جاري الحجز..." : "حجز";
    }
  }

  /// التحقق من إمكانية الإرسال
  bool _canSubmit() {
    return _selectedDate != null &&
        _selectedDuration != null &&
        _selectedTimeSlot != null;
  }

  /// معالجة الإرسال بناءً على نوع العملية
  void _handleSubmit(BuildContext context) {
    if (!_canSubmit()) {
      _showErrorSnackBar(context, 'يرجى إكمال جميع الحقول المطلوبة');
      return;
    }

    final dateTime = RescheduleHelper.formatDateTimeForApi(
      _selectedDate!,
      _selectedTimeSlot!.time,
    );

    if (_isReschedule) {
      // إعادة جدولة
      _handleReschedule(context, dateTime);
    } else {
      // حجز جديد
      _handleBooking(context, dateTime);
    }
  }

  /// معالجة إعادة الجدولة
  void _handleReschedule(BuildContext context, String dateTime) {
    if (_oldSessionId == null) {
      _showErrorSnackBar(context, 'لا يمكن تحديد الجلسة');
      return;
    }

    context.read<AvailableSlotsCubit>().rescheduleSession(
      sessionId: _oldSessionId!,
      date: dateTime,
      duration: _selectedDuration!.duration.toString(),
      time: _selectedTimeSlot!.time,
    );
  }

  /// معالجة الحجز الجديد
  void _handleBooking(BuildContext context, String dateTime) {
    context.read<AvailableSlotsCubit>().createSession(
      date: dateTime,
      advisorId: widget.advisorId,
      duration: _selectedDuration!.duration.toString(),
      time: _selectedTimeSlot!.time,
      paymentMethod: RescheduleHelper.getPaymentMethodString(
        _selectedPaymentMethod,
      ),
    );
  }
}
