import 'dart:convert';
import 'package:tayseer/core/constant/constans.dart';
import 'package:tayseer/core/constant/constans_keys.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
import 'package:tayseer/features/user/questions/data/models/questions_data.dart';
import 'package:tayseer/my_import.dart';

class ChooseSocialStatusView extends StatelessWidget {
  const ChooseSocialStatusView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ChooseSocialStatusBody();
  }
}

class _ChooseSocialStatusBody extends StatefulWidget {
  const _ChooseSocialStatusBody();

  @override
  State<_ChooseSocialStatusBody> createState() =>
      _ChooseSocialStatusBodyState();
}

class _ChooseSocialStatusBodyState extends State<_ChooseSocialStatusBody> {
  String? _selectedKey;

  List<String> get _statuses => QuestionsData.socialStatuses;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: context.height * 0.03),

              // ── Back button ──
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 25,
                    ),
                  ),
                ),
              ),

              SizedBox(height: context.height * 0.02),

              // ── Title ──
              Text(
                context.tr('choose_social_status'),
                style: Styles.textStyle20Bold.copyWith(
                  color: AppColors.kscandryTextColor,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: context.height * 0.05),

              // ── Status cards ──
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: ListView.separated(
                    itemCount: _statuses.length,
                    separatorBuilder: (_, __) => SizedBox(height: 14.h),
                    itemBuilder: (context, index) {
                      final key = _statuses[index];
                      final isSelected = _selectedKey == key;
                      return _StatusCard(
                        labelKey: key,
                        isSelected: isSelected,
                        onTap: () => setState(() => _selectedKey = key),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // ── Next button ──
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: _buildNextButton(context),
              ),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (prev, curr) =>
          prev.setSocialStatusState != curr.setSocialStatusState,
      listener: (context, state) async {
        if (state.setSocialStatusState == CubitStates.success) {
          // ✅ حفظ الـ social status محلياً
          kCurrentUserData = kCurrentUserData?.copyWith(
            socialStatus: _selectedKey,
          );
          CachNetwork.setData(
            key: kuserData,
            value: jsonEncode(kCurrentUserData?.toJson() ?? {}),
          );

          // ✅ لو أنثى ومتزوجة → تخطى PurposeSelectionView وروح للـ layout مباشرة
          final isFemaleMarried =
              kCurrentUserData?.gender == 'female' &&
              _selectedKey == 'F_social_married';

          if (isFemaleMarried) {
            // ✅ أخفي قسم الزواج تلقائياً وحفظ flag دائم
            await CachNetwork.setBool(
              key: kMarriageSectionDeactivatedKey,
              value: true,
            );
            await CachNetwork.setBool(
              key: kIsFemaleMarriedKey,
              value: true,
            );
            if (!mounted) return;
            context.pushNamedAndRemoveUntil(
              AppRouter.kUserLayoutView,
              predicate: (route) => false,
            );
          } else {
            // ✅ مش أنثى متزوجة — امسح الـ flag لو كان موجود
            await CachNetwork.setBool(
              key: kIsFemaleMarriedKey,
              value: false,
            );
            context.pushReplacementNamed(AppRouter.kPurposeSelectionView);
          }
        } else if (state.setSocialStatusState == CubitStates.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: state.errorMessage ?? context.tr('error_occurred'),
              isError: true,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.setSocialStatusState == CubitStates.loading;
        final isEnabled = _selectedKey != null;
        return CustomBotton(
          width: context.width,
          useGradient: isEnabled,
          backGroundcolor: AppColors.kgreyColor,
          title: isLoading ? context.tr('sending') : context.tr('next'),
          isLoading: isLoading,
          onPressed: isEnabled && !isLoading
              ? () => context.read<AuthCubit>().setSocialStatus(
                    socialStatus: _selectedKey!,
                  )
              : null,
        );
      },
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String labelKey;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusCard({
    required this.labelKey,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFemale = kCurrentUserData?.gender == 'female';
    final displayKey = QuestionsData.genderedKey(labelKey);

    // اختار الأيقونة حسب الـ key
    final emoji = switch (labelKey) {
      'social_single' || 'F_social_single' => '💍',
      'social_married' || 'F_social_married' => '👫',
      'social_divorced' || 'F_social_divorced' => '📝',
      'social_widowed' || 'F_social_widowed' => '🕊️',
      _ => '👤',
    };

    final activeColor = isFemale ? HexColor('f6579b') : AppColors.kprimaryColor;
    final activeBg = isFemale ? HexColor('ffeef6') : AppColors.primary50;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.secondary100,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? activeColor.withOpacity(0.12)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(emoji, style: TextStyle(fontSize: 24.sp)),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                context.tr(displayKey),
                style: Styles.textStyle16SemiBold.copyWith(
                  color: isSelected ? activeColor : AppColors.secondary700,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeColor,
                ),
                child: Icon(Icons.check, size: 14.w, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
