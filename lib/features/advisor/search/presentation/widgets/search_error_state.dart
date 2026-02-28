// features/shared/search/presentation/widgets/search_error_state.dart
import 'package:tayseer/my_import.dart';

class SearchErrorState extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const SearchErrorState({super.key, this.errorMessage, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60.w, color: Colors.red.shade400),
          SizedBox(height: 16.h),
          Text(
            errorMessage ?? 'حدث خطأ أثناء البحث',
            style: Styles.textStyle16.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kprimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
            ),
            child: Text(
              'إعادة المحاولة',
              style: Styles.textStyle14.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
