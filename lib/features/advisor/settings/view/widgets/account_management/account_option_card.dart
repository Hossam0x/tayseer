import 'package:tayseer/features/advisor/settings/view/account_management_view.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/account_management/account_action_cubit.dart';
import 'package:tayseer/my_import.dart';

class AccountOptionCard extends StatelessWidget {
  final String title;
  final AccountAction action;

  const AccountOptionCard({
    super.key,
    required this.title,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountActionCubit, AccountAction?>(
      builder: (context, selectedAction) {
        final isSelected = selectedAction == action;
        return GestureDetector(
          onTap: () => context.read<AccountActionCubit>().selectAction(action),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary100 : Colors.transparent,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected ? AppColors.primary400 : Colors.transparent,
                width: 1,
              ),
            ),
            child: Text(
              title,
              style: Styles.textStyle18Meduim.copyWith(
                color: AppColors.secondary800,
              ),
            ),
          ),
        );
      },
    );
  }
}
