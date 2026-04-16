// notification_item.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/widgets/custom_button.dart';
import 'package:tayseer/core/widgets/custom_outline_button.dart';
import 'package:tayseer/features/advisor/notification/data/enum/notification_type_enum.dart';
import 'package:tayseer/features/advisor/notification/data/models/notification_model.dart';
import 'package:tayseer/core/utils/app_strings.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';

class NotificationItem extends StatefulWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onSubscribe;
  final VoidCallback? onDelete;
  final VoidCallback? onAcceptRegard;
  final VoidCallback? onRejectRegard;
  final bool hideRegardButtons;
  final Animation<double>? buttonFadeAnimation;
  final Animation<double>? buttonScaleAnimation;

  /// Shared notifier — holds the id of the currently open slidable.
  final ValueNotifier<String?>? openItemNotifier;

  const NotificationItem({
    super.key,
    required this.notification,
    this.onTap,
    this.onAccept,
    this.onReject,
    this.onSubscribe,
    this.onDelete,
    this.onAcceptRegard,
    this.onRejectRegard,
    this.openItemNotifier,
    this.hideRegardButtons = false,
    this.buttonFadeAnimation,
    this.buttonScaleAnimation,
  });

  @override
  State<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem>
    with TickerProviderStateMixin {
  late final SlidableController _slidableController;

  String get _itemId => widget.notification.id ?? widget.notification.key ?? '';

  @override
  void initState() {
    super.initState();
    _slidableController = SlidableController(this);
    widget.openItemNotifier?.addListener(_onOpenItemChanged);
  }

  @override
  void dispose() {
    widget.openItemNotifier?.removeListener(_onOpenItemChanged);
    _slidableController.dispose();
    super.dispose();
  }

  void _onOpenItemChanged() {
    final openId = widget.openItemNotifier?.value;
    if (openId != _itemId) _slidableController.close();
  }

  void _handleDragStart() {
    widget.openItemNotifier?.value = _itemId;
  }

  void _handleTap() {
    _slidableController.close();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !(widget.notification.isRead ?? false);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GestureDetector(
        onHorizontalDragStart: (_) => _handleDragStart(),
        behavior: HitTestBehavior.translucent,
        child: Slidable(
          key: ValueKey(_itemId),
          controller: _slidableController,
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.22,
            openThreshold: 0.15,
            closeThreshold: 0.15,
            children: [
              CustomSlidableAction(
                onPressed: (_) {
                  _slidableController.close();
                  widget.onDelete?.call();
                },
                backgroundColor: Colors.transparent,
                padding: EdgeInsets.zero,
                autoClose: false,
                child: _buildDeletePanel(context),
              ),
            ],
          ),
          child: InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUnread ? Colors.white : Colors.transparent,
                borderRadius: isUnread ? BorderRadius.circular(12) : null,
                boxShadow: isUnread
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatarArea(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.notification.title ?? "",
                                style: TextStyle(
                                  fontWeight: isUnread
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                Text(
                                  _formatTime(
                                    context,
                                    widget.notification.dateTime,
                                  ),
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                                if (isUnread) ...[
                                  const SizedBox(width: 5),
                                  const CircleAvatar(
                                    radius: 4,
                                    backgroundColor: Colors.red,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.notification.description ?? "",
                          style: TextStyle(
                            color: isUnread ? Colors.black87 : Colors.grey[600],
                            fontSize: 13,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_hasActionButtons()) ...[
                          const SizedBox(height: 12),
                          _buildActionButtons(context),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Delete panel (slidable) ───────────────────────────────
  Widget _buildDeletePanel(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          width: 62.w,
          height: 66.h,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.red.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_outline_rounded, color: Colors.red, size: 26.h),
              SizedBox(height: 2.h),
              Text(
                context.tr(AppStrings.delete),
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Avatar + type icon ────────────────────────────────────
  Widget _buildAvatarArea() {
    return SizedBox(
      width: 55,
      height: 55,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[200],
              backgroundImage: widget.notification.senderImage != null
                  ? NetworkImage(widget.notification.senderImage!)
                  : const AssetImage(AssetsData.kUserImage) as ImageProvider,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: SvgPicture.asset(_getIconByType(), width: 24, height: 24),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Icon per type ─────────────────────────────────────────
  String _getIconByType() {
    switch (widget.notification.type) {
      case NotificationType.commentLike:
      case NotificationType.commentReply:
        return AssetsData.commentIcon;
      case NotificationType.storyLike:
      case NotificationType.postLike:
      case NotificationType.replyLike:
        if (widget.notification.likeType == "dislike") {
          return AssetsData.disLikeIcon;
        }
        return AssetsData.loveIcon;
      case NotificationType.postShare:
      case NotificationType.eventShare:
        return AssetsData.shareIcon;
      case NotificationType.newFollower:
        return AssetsData.followNotify;
      case NotificationType.newMessage:
      case NotificationType.newChat:
        return AssetsData.messageNotify;
      case NotificationType.sessionPaid:
        return AssetsData.messageNotify;
      case NotificationType.eventReservation:
        return AssetsData.ticketEventNotify;
      case NotificationType.regardRequest:
        return AssetsData.heartLockIcon;
      default:
        return AssetsData.careIcon;
    }
  }

  // ─── Time formatter ────────────────────────────────────────
  String _formatTime(BuildContext context, DateTime? dateTime) {
    if (dateTime == null) return "";
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return context.tr(AppStrings.now);
    final prefix = context.tr(AppStrings.agoPrefix);
    if (diff.inMinutes < 60) {
      return prefix.isEmpty
          ? "${diff.inMinutes} ${context.tr(AppStrings.agoMinutes)}"
          : "$prefix ${diff.inMinutes} ${context.tr(AppStrings.agoMinutes)}";
    }
    if (diff.inHours < 24) {
      return prefix.isEmpty
          ? "${diff.inHours} ${context.tr(AppStrings.agoHours)}"
          : "$prefix ${diff.inHours} ${context.tr(AppStrings.agoHours)}";
    }
    if (diff.inDays < 7) {
      return prefix.isEmpty
          ? "${diff.inDays} ${context.tr(AppStrings.agoDays)}"
          : "$prefix ${diff.inDays} ${context.tr(AppStrings.agoDays)}";
    }
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  // ─── Action buttons ────────────────────────────────────────
  bool _hasActionButtons() {
    if (widget.hideRegardButtons &&
        widget.notification.type == NotificationType.regardRequest) {
      return false;
    }
    return widget.notification.type == NotificationType.newChat ||
        widget.notification.type == NotificationType.regardRequest;
  }

  Widget _buildActionButtons(BuildContext context) {
    if (widget.notification.type == NotificationType.newChat) {
      return Row(
        children: [
          Expanded(
            child: CustomBotton(
              height: 40,
              useGradient: true,
              title: context.tr(AppStrings.accept),
              onPressed: widget.onAccept,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomOutlineButton(
              height: 40,
              width: double.infinity,
              text: context.tr(AppStrings.reject),
              onTap: widget.onReject,
            ),
          ),
        ],
      );
    }

    if (widget.notification.type == NotificationType.regardRequest) {
      return _buildRegardButtons(context);
    }

    return const SizedBox.shrink();
  }

  // ─── Regard request buttons (matches screenshot UI) ───────
  Widget _buildRegardButtons(BuildContext context) {
    Widget buttons = Row(
      children: [
        // رفض — outline style
        Expanded(
          child: CustomOutlineButton(
            height: 44.h,
            width: double.infinity,
            text: context.tr(AppStrings.reject),
            onTap: widget.onRejectRegard,
          ),
        ),
        SizedBox(width: 10.w),
        // قبول — gradient style
        Expanded(
          child: CustomBotton(
            height: 44.h,
            useGradient: true,
            title: context.tr(AppStrings.accept),
            onPressed: widget.onAcceptRegard,
          ),
        ),
      ],
    );

    // Apply animation if provided
    if (widget.buttonFadeAnimation != null &&
        widget.buttonScaleAnimation != null) {
      return AnimatedBuilder(
        animation: Listenable.merge([
          widget.buttonFadeAnimation!,
          widget.buttonScaleAnimation!,
        ]),
        builder: (context, child) {
          return FadeTransition(
            opacity: widget.buttonFadeAnimation!,
            child: ScaleTransition(
              scale: widget.buttonScaleAnimation!,
              child: buttons,
            ),
          );
        },
      );
    }

    return buttons;
  }
}
