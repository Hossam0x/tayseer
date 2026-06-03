import 'dart:ui';
import 'package:tayseer/features/advisor/chat/data/model/chat_requests/chat_request_model.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_requests_cubit.dart';
import 'package:tayseer/my_import.dart';

/// Shared helper — single source of truth for the subscription-required dialog.
///
/// [pendingRequestsCount] — when provided, shows the pending-requests copy with
/// the count injected; omit to fall back to the generic subscription copy.
///
/// [onAfterSubscribe] — optional callback invoked (if the context is still
/// mounted) after returning from the packages screen. Callers that own a
/// specific cubit (e.g. RequestListTile → ChatRequestsCubit) pass a reload
/// here. Callers that don't have that cubit in their tree (e.g.
/// NewChatFloatingButton) simply omit it.
void showSubscriptionRequiredDialog(
  BuildContext context, {
  int? pendingRequestsCount,
  void Function(BuildContext ctx)? onAfterSubscribe,
}) {
  final subtitle = pendingRequestsCount != null
      ? context
            .tr('pending_chat_requests_desc')
            .replaceAll('{count}', '$pendingRequestsCount')
      : context.tr('subscription_required_desc');

  showLimitReachedDialog(
    context,
    title: context.tr('pending_requests_dialog_title'),
    subtitle: subtitle,
    subscribeText: context.tr('subscribe_now'),
    laterText: context.tr('cancel'),
    onSubscribe: () async {
      await Navigator.pushNamed(context, AppRouter.kPackagesView);
      if (context.mounted) {
        onAfterSubscribe?.call(context);
      }
    },
    onLater: () {},
  );
}

class RequestListTile extends StatelessWidget {
  final ChatRequestModel item;

  const RequestListTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          // الصورة المشوشة أو العادية
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: item.imageBlur
                  ? ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Image.network(
                        item.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildFallbackImage(),
                      ),
                    )
                  : Image.network(
                      item.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildFallbackImage(),
                    ),
            ),
          ),

          SizedBox(width: 12.w),

          // الاسم
          Expanded(
            child: Text(
              item.name,
              style: Styles.textStyle16Bold.copyWith(color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(width: 8.w),

          // زر العرض — ChatRequestsCubit is always in the tree here
          // because RequestListTile is only rendered inside requests.dart
          // which provides ChatRequestsCubit via BlocProvider.
          GestureDetector(
            onTap: () => showSubscriptionRequiredDialog(
              context,
              onAfterSubscribe: (ctx) =>
                  ctx.read<ChatRequestsCubit>().loadChatRequests(),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFF80AB)),
              ),
              child: Row(
                children: [
                  Text(
                    context.tr('view'),
                    style: Styles.textStyle12Bold.copyWith(
                      color: const Color(0xFFFF80AB),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.diamond, color: Colors.amber, size: 16.sp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Image.network(
      item.socialImage,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey,
        child: const Icon(Icons.person, color: Colors.white),
      ),
    );
  }
}
