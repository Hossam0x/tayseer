// ===============================
// complete_marriage_file.dart
// ===============================

import 'package:flutter/material.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_marriage_model.dart';
import 'package:tayseer/features/user/verification/data/models/Verification_result_model.dart';
import 'package:tayseer/features/user/verification/data/verification_service.dart';
import 'package:tayseer/features/user/verification/presentation/view/verification_screen.dart';
import 'package:tayseer/features/user/verification/presentation/view/verification_webview_screen.dart';
import 'package:tayseer/my_import.dart';

class CompleteMarriageFile extends StatefulWidget {
  const CompleteMarriageFile({
    super.key,
    required this.progress,
    required this.profile,
    required this.onNavigateToEdit,
    /// Callback to reload the profile from the parent (cubit / bloc / provider).
    /// Called after successful verification so the UI stays in sync.
    required this.onProfileRefresh,
  });

  final double progress;
  final MarriageUserProfileModel profile;
  final Function(String section) onNavigateToEdit;
  final Future<MarriageUserProfileModel> Function() onProfileRefresh;

  @override
  State<CompleteMarriageFile> createState() => _CompleteMarriageFileState();
}

class _CompleteMarriageFileState extends State<CompleteMarriageFile>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  /// Local copy of the profile so we can update it without waiting for
  /// the parent to rebuild.
  late MarriageUserProfileModel _profile;

  @override
  void initState() {
    super.initState();

    _profile = widget.profile;

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Full Verification Flow
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _startVerificationFlow() async {
    // ── Step 1: Check current status from backend ────────────────────────
    final currentStatus =
        await VerificationService.getUserVerificationStatus();

    if (!mounted) return;

    // Already verified → show result screen directly
    if (currentStatus?.isVerified == true) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerificationScreen(result: currentStatus!),
        ),
      );
      return;
    }

    // ── Step 2: Fetch WebView URL ─────────────────────────────────────────
    final url = await VerificationService.getVerificationUrl();

    if (!mounted || url == null) return;

    // ── Step 3: Open WebView ──────────────────────────────────────────────
    await Navigator.push<VerificationStatus>(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationWebViewScreen(webviewUrl: url),
      ),
    );

    if (!mounted) return;

    // ── Step 4: Re-fetch status after webview closes ──────────────────────
    final result = await VerificationService.getUserVerificationStatus();

    if (!mounted || result == null) return;

    // ── Step 5: Handle result ─────────────────────────────────────────────
    if (result.isVerified) {
      // ✅ Approved — show snackbar and refresh profile
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          context,
          text: context.tr('verification_done'),
          isSuccess: true,
        ),
      );

      final updatedProfile = await widget.onProfileRefresh();

      if (!mounted) return;

      setState(() => _profile = updatedProfile);
    } else {
      // ❌ Rejected — navigate to result screen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerificationScreen(result: result),
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isVerified = _profile.isVerified == true;

    final verificationItems = [
      {
        'title': context.tr('photo_verification'),
        'description': context.tr('photo_verification_desc'),
        'isVerified': isVerified,
      },
      {
        'title': context.tr('age_verification'),
        'description': context.tr('age_verification_desc'),
        'isVerified': isVerified,
      },
      {
        'title': context.tr('identity_verification'),
        'description': context.tr('identity_verification_desc'),
        'isVerified': isVerified,
      },
    ];

    final totalItems = verificationItems.length;
    final completedItems =
        verificationItems.where((e) => e['isVerified'] == true).length;
    final percentage =
        totalItems > 0 ? ((completedItems / totalItems) * 100).round() : 0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.h, vertical: 10.h),
              child: SimpleAppBar(
                title: context.tr('complete_data'),
                isLargeTitle: true,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    SizedBox(height: 11.h),
                    _buildEnhancedTimeline(progress: widget.progress),
                    SizedBox(height: 20.h),

                    // Only show the card when the user is not yet verified
                    if (!isVerified)
                      _buildVerificationCard(
                        context,
                        percentage,
                        verificationItems,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Verification Card Widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildVerificationCard(
    BuildContext context,
    int percentage,
    List<Map<String, dynamic>> items,
  ) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -_floatAnimation.value),
        child: child,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_user, size: 40),
            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('get_verified'),
                    style: Styles.textStyle14,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '$percentage%',
                    style: Styles.textStyle12.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),

            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: _startVerificationFlow,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Timeline (placeholder — fill with real implementation)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildEnhancedTimeline({required double progress}) {
    return Container(
      height: 100,
      // TODO: replace with your real timeline widget
    );
  }
}