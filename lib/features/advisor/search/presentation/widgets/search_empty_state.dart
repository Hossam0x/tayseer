// features/shared/search/presentation/widgets/search_empty_state.dart
import 'package:tayseer/my_import.dart';

class SearchEmptyState extends StatelessWidget {
  final String message;
  final String iconPath;

  const SearchEmptyState({
    super.key,
    required this.message,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 150.h),
          AppImage(iconPath),
          SizedBox(height: 30.h),
          Text(
            message,
            style: Styles.textStyle16.copyWith(color: AppColors.secondary400),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}
