// ===============================
// verification_screen.dart
// ===============================

import 'package:flutter/material.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/user/verification/data/models/Verification_result_model.dart';
import 'package:tayseer/my_import.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key, required this.result});

  final VerificationResult result;

  @override
  Widget build(BuildContext context) {
    final isApproved = result.isVerified;
    final rejectReasons = result.rejectReasons;

    return Scaffold(
      body: Stack(
        children: [
          // ── Background ──────────────────────────────
          Positioned.fill(
            child: Image.asset(AssetsData.userBGImage, fit: BoxFit.cover),
          ),

          // ── Content ─────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: const SimpleAppBar(title: ''),
                ),

                SizedBox(height: 30.h),

                // ── Status Title ────────────────────────
                Text(
                  isApproved
                      ? '✅ ${context.tr('verification_done')}'
                      : '❌ ${context.tr('verification_failed')}',
                  style: Styles.textStyle18.copyWith(
                    color: isApproved ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 20.h),

                // ── Approved UI ─────────────────────────
                if (isApproved)
                  Column(
                    children: [
                      Icon(Icons.verified, color: Colors.blue, size: 80.sp),
                      SizedBox(height: 12.h),
                      Text(
                        context.tr('your_account_verified'),
                        style: Styles.textStyle16Meduim,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                // ── Rejected UI ─────────────────────────
                if (!isApproved)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 24.w),
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('rejection_reasons'),
                          style: Styles.textStyle16Meduim.copyWith(
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Reasons list
                        if (rejectReasons.isNotEmpty)
                          ...rejectReasons.map(
                            (reason) => Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• '),
                                  Expanded(
                                    child: Text(
                                      reason,
                                      style: Styles.textStyle12.copyWith(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Fallback — no reasons provided
                        if (rejectReasons.isEmpty)
                          Text(
                            context.tr('verification_failed'),
                            style: Styles.textStyle12.copyWith(
                              color: Colors.red,
                            ),
                          ),
                      ],
                    ),
                  ),

                const Spacer(),

                // ── Action Buttons ───────────────────────
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      // Retry button — shown only when rejected
                      if (!isApproved) ...[
                        CustomBotton(
                          title: context.tr('retry'),
                          onPressed: () =>
                              Navigator.pop(context, true), // true = retry
                        ),
                        SizedBox(height: 10.h),
                      ],

                      // OK button
                      CustomBotton(
                        title: context.tr('okay_understood'),
                        onPressed: () =>
                            Navigator.pop(context, false), // false = dismiss
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
