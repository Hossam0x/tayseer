import 'dart:ui';
import 'package:tayseer/my_import.dart';

class SectionToggle extends StatelessWidget {
  final bool isMarriage;
  final ValueChanged<bool> onChanged;

  const SectionToggle({
    super.key,
    required this.isMarriage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.25 / 2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(50.r),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTab(
                context,
                label: context.tr('marriage_tab'), // "الزواج"
                isActive: isMarriage,
                onTap: () => onChanged(true),
              ),

              _buildTab(
                context,
                label: context.tr('interactions_tab'), // "التفاعلات"
                isActive: !isMarriage,
                onTap: () => onChanged(false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context, {
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.r),

          gradient: isActive ? AppColors.defaultGradient : null,
          color: isActive ? null : Colors.transparent,
        ),
        child: Text(
          label,
          style: Styles.textStyle12Bold.copyWith(
            color: isActive ? Colors.white : const Color(0xFF4A4A4A),
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
