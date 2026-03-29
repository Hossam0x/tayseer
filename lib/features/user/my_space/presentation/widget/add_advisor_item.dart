import 'package:flutter/material.dart';
import 'package:tayseer/core/utils/colors.dart';
import 'package:tayseer/core/utils/router/app_router.dart';
import 'package:tayseer/core/utils/styles.dart';

/// Widget لعرض زرار "مستشار جديد" في قائمة المحادثات
class AddAdvisorItem extends StatelessWidget {
  const AddAdvisorItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, AppRouter.kAdvisorSearchView);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
          child: Row(
            children: [
              _buildPlusIcon(),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'مستشار جديد',
                  style: Styles.textStyle16SemiBold.copyWith(
                    color: AppColors.secondary600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlusIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.secondary100,
        border: Border.all(color: AppColors.secondary200, width: 1),
      ),
      child: Center(
        child: Icon(
          Icons.add,
          color: AppColors.secondary600,
          size: 28,
        ),
      ),
    );
  }
}
