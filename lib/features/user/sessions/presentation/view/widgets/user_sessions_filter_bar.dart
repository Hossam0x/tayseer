import 'package:tayseer/features/user/sessions/presentation/cubit/user_sessions_cubit.dart';
import 'package:tayseer/features/user/sessions/presentation/cubit/user_sessions_state.dart';
import 'package:tayseer/my_import.dart';

class UserSessionsFilterBar extends StatelessWidget {
  const UserSessionsFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserSessionsCubit, UserSessionsState>(
      buildWhen: (p, c) =>
          p.selectedStatus != c.selectedStatus ||
          p.selectedPaymentStatus != c.selectedPaymentStatus,
      builder: (context, state) {
        return Container(
          color: Colors.transparent,
          padding: EdgeInsets.only(bottom: 8.h),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              spacing: 8.w,
              children: [
                // ── Payment Status Filters ───────────────────────────────
                _FilterChip(
                  label: context.tr('filter_payment_pending'),
                  isSelected: state.selectedPaymentStatus == 'pending',
                  onTap: () => context
                      .read<UserSessionsCubit>()
                      .selectPaymentStatus('pending'),
                  accentColor: const Color(0xFFF59E0B),
                ),
                _FilterChip(
                  label: context.tr('filter_paid'),
                  isSelected: state.selectedPaymentStatus == 'paid',
                  onTap: () => context
                      .read<UserSessionsCubit>()
                      .selectPaymentStatus('paid'),
                  accentColor: const Color(0xFF2E7D32),
                ),

                // ── Divider ─────────────────────────────────────────────
                Container(
                  width: 1,
                  height: 24.h,
                  color: AppColors.kGreyB3.withOpacity(0.4),
                ),

                // ── Session Status Filters ──────────────────────────────
                _FilterChip(
                  label: context.tr('filter_pending'),
                  isSelected: state.selectedStatus == 'pending',
                  onTap: () =>
                      context.read<UserSessionsCubit>().selectStatus('pending'),
                ),
                _FilterChip(
                  label: context.tr('filter_approved'),
                  isSelected: state.selectedStatus == 'approved',
                  onTap: () => context.read<UserSessionsCubit>().selectStatus(
                    'approved',
                  ),
                ),
                _FilterChip(
                  label: context.tr('filter_completed'),
                  isSelected: state.selectedStatus == 'completed',
                  onTap: () => context.read<UserSessionsCubit>().selectStatus(
                    'completed',
                  ),
                ),
                _FilterChip(
                  label: context.tr('filter_cancelled'),
                  isSelected: state.selectedStatus == 'cancelled',
                  onTap: () => context.read<UserSessionsCubit>().selectStatus(
                    'cancelled',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? accentColor;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.kprimaryColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : const Color(0xB8F9F8EC),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: isSelected ? color.withOpacity(0.6) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: Styles.textStyle14.copyWith(
            color: isSelected ? color : AppColors.kGreyB3,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
