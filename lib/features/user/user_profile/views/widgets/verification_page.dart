import 'package:flutter/material.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/my_import.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key, required this.verificationItems});

  final List<Map<String, dynamic>> verificationItems;

  @override
  Widget build(BuildContext context) {
    debugPrint('🛡️ [VerificationScreen] build() called');
    debugPrint(
      '🛡️ [VerificationScreen] verificationItems count: ${verificationItems.length}',
    );
    debugPrint(
      '🛡️ [VerificationScreen] verificationItems: $verificationItems',
    );

    int totalItems = verificationItems.length;
    int completedItems = verificationItems
        .where((item) => item['isVerified'] as bool)
        .length;
    int verificationPercentage = totalItems > 0
        ? ((completedItems / totalItems) * 100).round()
        : 0;

    debugPrint('🛡️ [VerificationScreen] totalItems: $totalItems');
    debugPrint('🛡️ [VerificationScreen] completedItems: $completedItems');
    debugPrint(
      '🛡️ [VerificationScreen] verificationPercentage: $verificationPercentage%',
    );

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AssetsData.userBGImage, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: SimpleAppBar(title: ""),
                ),
                SizedBox(height: 20.h),
                Text(
                  "⏳ ${context.tr('verifying')}",
                  style: Styles.textStyle18.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                SizedBox(height: 30.h),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24.w),
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    children: verificationItems.map((item) {
                      debugPrint(
                        '🛡️ [VerificationScreen] Rendering item: title="${item['title']}" isVerified=${item['isVerified']}',
                      );
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Row(
                          children: [
                            AppImage(
                              item['isVerified']
                                  ? AssetsData.verifiedIcon
                                  : AssetsData.verified2Icon,
                              width: 28,
                              height: 28,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'],
                                    style: Styles.textStyle16Meduim,
                                  ),
                                  Text(
                                    item['description'],
                                    style: Styles.textStyle12,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: CustomBotton(
                    title: context.tr('okay_understood'),
                    onPressed: () {
                      debugPrint(
                        '🛡️ [VerificationScreen] Okay button tapped → popping',
                      );
                      Navigator.pop(context);
                    },
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

enum VerificationStatus { approved, inReview, rejected }
