// lib/features/user/my_space/presentation/widget/ticketSession/ticket_promo_code.dart

import 'package:tayseer/features/user/my_space/presentation/manager/ticket_session/ticket_session_cubit.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/ticket_session/ticket_session_state.dart';
import 'package:tayseer/my_import.dart';

class TicketPromoCode extends StatefulWidget {
  const TicketPromoCode({super.key});

  @override
  State<TicketPromoCode> createState() => _TicketPromoCodeState();
}

class _TicketPromoCodeState extends State<TicketPromoCode> {
  final TextEditingController _controller = TextEditingController();
  bool hasText = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryPink = Color(0xFFD3556E);

    return BlocConsumer<TicketSessionCubit, TicketSessionState>(
      listenWhen: (previous, current) =>
          previous.validateDiscountState != current.validateDiscountState,
      listener: (context, state) {
        if (state.validateDiscountState == CubitStates.failure &&
            state.errorMessage != null) {
          AppToast.warning(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        final isLoading = state.validateDiscountState == CubitStates.loading;
        final isApplied = state.isDiscountApplied;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isApplied
                      ? Colors.green.shade300
                      : Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  AppImage(
                    AssetsData.cuponCodeIcon,
                    color: isApplied
                        ? Colors.green
                        : (hasText ? primaryPink : Colors.grey.shade400),
                    width: 20.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !isApplied && !isLoading,
                      onChanged: (value) {
                        setState(() {
                          hasText = value.trim().isNotEmpty;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: isApplied
                            ? state.appliedCode
                            : context.tr('enter_discount_code'),
                        hintStyle: TextStyle(
                          fontSize: 12.sp,
                          color: isApplied
                              ? Colors.green
                              : Colors.grey.shade400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                    ),
                  ),

                  // زر التطبيق/الإزالة أو Loading
                  SizedBox(
                    width: 70.w,
                    height: 40.h,
                    child: Center(
                      child: isLoading
                          ? SizedBox(
                              width: 20.sp,
                              height: 20.sp,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: primaryPink,
                              ),
                            )
                          : TextButton(
                              onPressed: () {
                                if (isApplied) {
                                  context
                                      .read<TicketSessionCubit>()
                                      .removeDiscountCode();
                                  _controller.clear();
                                  setState(() => hasText = false);
                                } else if (hasText) {
                                  context
                                      .read<TicketSessionCubit>()
                                      .validateDiscountCode(
                                        _controller.text.trim(),
                                      );
                                }
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                isApplied
                                    ? context.tr('remove_code')
                                    : context.tr('apply_code'),
                                style: TextStyle(
                                  color: isApplied
                                      ? Colors.red
                                      : (hasText
                                            ? primaryPink
                                            : Colors.grey.shade400),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            // عرض نسبة الخصم المطبقة
            if (isApplied) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16.sp),
                  SizedBox(width: 6.w),
                  Text(
                    context
                        .tr('discount_applied')
                        .replaceAll('%s', '${state.discountPercentage}'),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
