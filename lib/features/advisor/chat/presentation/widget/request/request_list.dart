import 'dart:ui';
import 'package:tayseer/features/advisor/chat/data/model/chat_requests/chat_request_model.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_requests_cubit.dart';
import 'package:tayseer/my_import.dart';

class RequestListTile extends StatelessWidget {
  final ChatRequestModel item;

  const RequestListTile({super.key, required this.item});

  void _showSubscriptionDialog(BuildContext context) {
    showLimitReachedDialog(
      context,
      title: context.tr('subscription_required_title'),
      subtitle: context.tr('subscription_required_desc'),
      subscribeText: context.tr('subscribe_now'),
      laterText: context.tr('cancel'),
      onSubscribe: () async {
        await Navigator.pushNamed(context, AppRouter.kPackagesView);
        if (context.mounted) {
          context.read<ChatRequestsCubit>().loadChatRequests();
        }
      },
      onLater: () {},
    );
  }

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

          // زر العرض
          GestureDetector(
            onTap: () => _showSubscriptionDialog(context),
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
