import 'package:tayseer/features/advisor/add_post/view_model/upload_post/upload_post_cubit.dart';
import 'package:tayseer/features/advisor/add_post/view_model/upload_post/upload_post_state.dart';
import 'package:tayseer/my_import.dart';

class UploadPostBanner extends StatelessWidget {
  const UploadPostBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UploadPostCubit, UploadPostProgressState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, -1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
          child: _buildBanner(context, state),
        );
      },
    );
  }

  Widget _buildBanner(BuildContext context, UploadPostProgressState state) {
    switch (state.status) {
      case UploadPostStatus.idle:
        return const SizedBox.shrink(key: ValueKey('idle'));

      case UploadPostStatus.uploading:
        return const _UploadingBanner(key: ValueKey('uploading'));

      case UploadPostStatus.success:
        return const _SuccessBanner(key: ValueKey('success'));

      case UploadPostStatus.failure:
        return _FailureBanner(
          key: const ValueKey('failure'),
          errorMessage: state.errorMessage,
          onRetry: () => context.read<UploadPostCubit>().retry(),
          onDismiss: () => context.read<UploadPostCubit>().dismiss(),
        );
    }
  }
}

/// ─── بانر التحميل (جاري الرفع) ───
class _UploadingBanner extends StatelessWidget {
  const _UploadingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1877F2)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr("publishing_post"),
                  style: Styles.textStyle12SemiBold.copyWith(
                    color: AppColors.kgreyColor,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF1877F2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ─── بانر النجاح ───
class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            context.tr("post_published_successfully"),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

/// ─── بانر الفشل مع إعادة المحاولة ───
class _FailureBanner extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  const _FailureBanner({
    super.key,
    this.errorMessage,
    required this.onRetry,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFF44336),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'فشل نشر المنشور',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade800,
                  ),
                ),
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      errorMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          // زرار إعادة المحاولة
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 0),
            ),
            child: Text(
              'إعادة',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
          ),
          // زرار الإغلاق
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Icons.close, size: 18, color: Colors.red.shade400),
          ),
        ],
      ),
    );
  }
}
