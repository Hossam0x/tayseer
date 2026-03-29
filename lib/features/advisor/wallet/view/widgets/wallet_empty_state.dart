import 'package:tayseer/my_import.dart';

class WalletEmptyState extends StatelessWidget {
  final String label;

  const WalletEmptyState({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Center(
        child: Text(
          label,
          style: Styles.textStyle16.copyWith(color: AppColors.secondary600),
        ),
      ),
    );
  }
}
