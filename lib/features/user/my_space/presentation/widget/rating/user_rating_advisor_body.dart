// lib/features/user/my_space/presentation/widget/rating/user_rating_advisor_body.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/user/my_space/data/model/sessiondetailes/session_detailes_model.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/user_rate_advisor/user_rate_advisor_cubit.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/user_rate_advisor/user_rate_advisor_state.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/rating/consultanAvatar.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/rating/feedback_text_field.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/rating/interactivestar.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/rating/success_rating_dialog.dart';
import 'package:tayseer/my_import.dart';

class RatingViewBody extends StatefulWidget {
  const RatingViewBody({super.key, required this.data});
  final SessionDetailsDataResponse data;

  @override
  State<RatingViewBody> createState() => _RatingViewBodyState();
}

class _RatingViewBodyState extends State<RatingViewBody> {
  int _currentRating = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RateAdvisorCubit, RateAdvisorState>(
      listenWhen: (previous, current) =>
          previous.rateAdvisorState != current.rateAdvisorState,
      listener: (context, state) {
        if (state.rateAdvisorState == CubitStates.success) {
          SuccessRatingDialog.show(context);
        }

        if (state.rateAdvisorState == CubitStates.failure) {
          AppToast.error(context, state.errorMessage.toString());
        }
      },
      child: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 10.h),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 24.w),
                        Text(
                          "تقييم الاستشاري",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            context.pop();
                          },
                          icon: Icon(
                            Icons.arrow_forward,
                            color: Colors.black87,
                            size: 24.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30.h),

                    // Avatar
                    ConsultantAvatar(imageUrl: widget.data.advisor.image),
                    SizedBox(height: 12.h),

                    // Name
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.blue,
                          size: 18.sp,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          widget.data.advisor.name,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Rating Stars
                    InteractiveRatingStars(
                      rating: _currentRating,
                      onRatingChanged: (rating) {
                        setState(() {
                          _currentRating = rating;
                        });
                      },
                    ),
                    SizedBox(height: 30.h),

                    // Review Label
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "شاركنا رأيك",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // Review TextField
                    FeedbackTextField(controller: _reviewController),
                    SizedBox(height: 60.h),

                    // Submit Button
                    BlocSelector<RateAdvisorCubit, RateAdvisorState, bool>(
                      selector: (state) =>
                          state.rateAdvisorState == CubitStates.loading,
                      builder: (context, isLoading) {
                        return CustomBotton(
                          useGradient: true,
                          width: 339.w,
                          title: isLoading
                              ? 'جاري الإرسال...'
                              : 'ارسال التقييم',
                          onPressed: isLoading
                              ? null
                              : () => _submitRating(context),
                        );
                      },
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),

            // Loading Overlay
            BlocSelector<RateAdvisorCubit, RateAdvisorState, bool>(
              selector: (state) =>
                  state.rateAdvisorState == CubitStates.loading,
              builder: (context, isLoading) {
                if (!isLoading) return const SizedBox.shrink();
                return Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD3556E)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submitRating(BuildContext context) {
    // التحقق من التقييم
    if (_currentRating == 0) {
      AppToast.error(context, "يرجى اختيار تقييم من النجوم");
      return;
    }

    // إرسال التقييم
    context.read<RateAdvisorCubit>().rateAdvisor(
      rating: _currentRating,
      review: _reviewController.text.trim(),
      sessionId: widget.data.sessionId,
    );
  }
}
