import 'package:flutter/material.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/my_import.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({
    super.key,
    this.verificationItems,
  });

  final List<Map<String, dynamic>>? verificationItems;

  @override
  Widget build(BuildContext context) {
    // Define verification items or use passed ones
  
    // Calculate verification percentage
    int totalItems = verificationItems!.length;
    int completedItems = verificationItems!.where((item) => item['isVerified'] as bool).length;
    int verificationPercentage = totalItems > 0 ? ((completedItems / totalItems) * 100).round() : 0;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AssetsData.userBGImage, fit: BoxFit.cover),
          ),
      
          SafeArea(
            child: Column(
              children: [
                // Back button at the top
                Padding(
                  padding: EdgeInsets.only(
                    right: 24.h,
                    left: 24.h,
                    top: 10.h,
                  ),
                  child: SimpleAppBar(title: "", isLargeTitle: true),
                ),

                // Main title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    context.tr('verify_all_profiles_real'),
                    style: Styles.textStyle28.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 6.h),

                // Subtitle
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    context.tr('verify_all_data_accuracy'),
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.secondary700,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 50.h),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                  
                      children: [
                      
                        SizedBox(height: 20.h),

                        // White card containing verification items
                        Container(
                          padding: EdgeInsets.all(24.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Column(
                            children: verificationItems!.asMap().entries.map((entry) {
                              int index = entry.key;
                              Map<String, dynamic> item = entry.value;
                              
                              return Column(
                                children: [
                                  if (index > 0) 
                                    Divider(height: 32.h, color: Colors.transparent),
                                  _buildVerificationItem(
                                    context,
                                    title: item['title'] as String,
                                    description: item['description'] as String,
                                    isVerified: item['isVerified'] as bool,
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Button at the bottom
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
                  child: CustomBotton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    title: context.tr('okay_understood'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // Widget to build individual verification item
  Widget _buildVerificationItem(
    BuildContext context, {
    required String title,
    required String description,
    required bool isVerified,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isVerified
            ? AppImage(AssetsData.verifiedIcon, width: 28, height: 28)
            : AppImage(AssetsData.verified2Icon, width: 28, height: 28),
        SizedBox(width: 16.w),
        // Texts (title and description)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Styles.textStyle16Meduim.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondary800,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                style: Styles.textStyle12.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondary700,
                ),
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
      ],
    );
  }
}