import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/utils/colors.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';
import 'package:tayseer/core/widgets/chat_room_list_item/widgets/glass_panel.dart';
import 'package:tayseer/core/widgets/chat_room_list_item/widgets/slidable_action_button.dart';

/// Slidable actions للـ chat room item
class ChatRoomSlidableActions {
  /// Archive action (start pane)
  static ActionPane buildArchiveAction({
    required BuildContext context,
    required VoidCallback onArchive,
  }) {
    return ActionPane(
      motion: const ScrollMotion(),
      extentRatio: 0.22,
      children: [
        CustomSlidableAction(
          onPressed: (_) => onArchive(),
          backgroundColor: Colors.transparent,
          autoClose: true,
          padding: EdgeInsets.zero,
          child: GlassPanel(
            width: 65,
            height: 66,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SlidableActionButton.buildIcon(
                  svgIcon: AssetsData.chatArchiveIcon,
                  color: AppColors.kprimaryColor,
                  size: 28,
                ),
                const SizedBox(height: 2),
                SlidableActionButton.buildLabel(
                  label: context.tr('archive'),
                  color: AppColors.kprimaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Delete, Report, Block actions (end pane)
  static ActionPane buildEndActions({
    required BuildContext context,
    VoidCallback? onDelete,
    VoidCallback? onReport,
    VoidCallback? onBlock,
    String? blockLabel,
  }) {
    final showReport = onReport != null;
    final showBlock = onBlock != null;

    // Width: Delete (always) + Report (optional) + Block (optional)
    // Each button ≈ 55px, dividers ≈ negligible
    double endPanelWidth;
    double endExtentRatio;
    if (showReport && showBlock) {
      endPanelWidth = 175.0;
      endExtentRatio = 0.62;
    } else if (showReport || showBlock) {
      endPanelWidth = 120.0;
      endExtentRatio = 0.42;
    } else {
      endPanelWidth = 65.0;
      endExtentRatio = 0.22;
    }

    return ActionPane(
      motion: const ScrollMotion(),
      extentRatio: endExtentRatio,
      children: [
        CustomSlidableAction(
          onPressed: (_) {},
          autoClose: false,
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
          child: GlassPanel(
            width: endPanelWidth,
            height: 66,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SlidableActionButton(
                  svgIcon: AssetsData.deleteIcon,
                  label: context.tr('delete'),
                  color: AppColors.kRedColor,
                  onTap: () {
                    Slidable.of(context)?.close();
                    onDelete?.call();
                  },
                ),
                if (showReport) ...[
                  const _VerticalDivider(),
                  SlidableActionButton(
                    svgIcon: AssetsData.reportIcon,
                    label: context.tr('report'),
                    color: Colors.orange,
                    onTap: () {
                      Slidable.of(context)?.close();
                      onReport.call();
                    },
                  ),
                ],
                if (showBlock) ...[
                  const _VerticalDivider(),
                  SlidableActionButton(
                    icon: Icons.block,
                    label: blockLabel ?? 'حظر',
                    color: const Color(0xFF581C25),
                    onTap: () {
                      Slidable.of(context)?.close();
                      onBlock.call();
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// الفاصل بين الأكشنز
class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 25, color: AppColors.secondary200);
  }
}
