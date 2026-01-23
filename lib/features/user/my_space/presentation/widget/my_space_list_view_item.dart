import 'dart:ui';

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tayseer/my_import.dart';
import 'package:intl/intl.dart';

class MySpaceListItem extends StatelessWidget {
  final int index;
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final DateTime? lastUpdate;
  final int unreadCount;
  final VoidCallback? onTap;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;
  final VoidCallback? onReport;

  const MySpaceListItem({
    super.key,
    required this.index,
    required this.id,
    required this.title,
    this.subtitle = '',
    this.imageUrl,
    this.lastUpdate,
    this.unreadCount = 0,
    this.onTap,
    this.onArchive,
    this.onDelete,
    this.onReport,
  });

  static const String chatArchiveIcon = "assets/icons/chat_archive.svg";
  static const String deleteIcon = "assets/icons/delete_icon.svg";
  static const String reportIcon = "assets/icons/report_icon.svg";

  @override
  Widget build(BuildContext context) {
    const Color dividerColor = Color(0xFFD9D9D9);
    const Color archiveColor = Color(0xFFA12042);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final leftPadding = isMobile ? 12.0 : 16.0;
    final containerPadding = isMobile ? 14.0 : 16.0;
    final avatarRadius = isMobile ? 25.0 : 30.0;
    final spacing1 = isMobile ? 14.0 : 18.0;
    final spacing2 = isMobile ? 5.0 : 6.0;
    final spacing3 = isMobile ? 5.0 : 7.0;
    final titleFontSize = isMobile ? 15.0 : 17.0;
    final subtitleFontSize = isMobile ? 13.0 : 15.0;
    final timeFontSize = isMobile ? 11.0 : 13.0;
    final badgeSize = isMobile ? 22.0 : 24.0;
    final badgeFontSize = isMobile ? 11.0 : 13.0;

    return Padding(
      padding: EdgeInsets.only(left: leftPadding, top: 6, bottom: 6),
      child: Slidable(
        key: ValueKey(id),

        // Archive Action
        startActionPane: onArchive != null
            ? ActionPane(
                motion: const ScrollMotion(),
                extentRatio: 0.22,
                children: [
                  CustomSlidableAction(
                    onPressed: (_) => onArchive?.call(),
                    backgroundColor: Colors.transparent,
                    foregroundColor: archiveColor,
                    autoClose: true,
                    padding: EdgeInsets.zero,
                    child: _buildArchiveButton(isMobile, archiveColor),
                  ),
                ],
              )
            : null,

        // Delete & Report Actions
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.45,
          children: [
            CustomSlidableAction(
              onPressed: (_) {},
              autoClose: false,
              backgroundColor: Colors.transparent,
              padding: EdgeInsets.zero,
              child: _buildEndActions(context, isMobile, dividerColor),
            ),
          ],
        ),

        child: GestureDetector(
          onTap: onTap,
          child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.only(
              left: isMobile ? 4 : 6,
              right: 20,
              top: containerPadding,
              bottom: containerPadding,
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: avatarRadius * 2,
                  height: avatarRadius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(
                        imageUrl ?? 'https://i.pravatar.cc/150?img=12',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: spacing1),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: titleFontSize,
                        ),
                      ),
                      SizedBox(height: spacing2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: subtitleFontSize,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Time & Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (lastUpdate != null)
                      Text(
                        _formatTime(lastUpdate!),
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: timeFontSize,
                        ),
                      ),
                    SizedBox(height: spacing3),
                    if (unreadCount > 0)
                      Container(
                        width: badgeSize,
                        height: badgeSize,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE96E88),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "$unreadCount",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: badgeFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArchiveButton(bool isMobile, Color archiveColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          width: isMobile ? 60 : 70,
          height: isMobile ? 60 : 66,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF).withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          padding: EdgeInsets.symmetric(vertical: isMobile ? 4 : 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                chatArchiveIcon,
                height: isMobile ? 28 : 32,
                width: isMobile ? 28 : 32,
              ),
              SizedBox(height: isMobile ? 0 : 1),
              Text(
                'أرشيف',
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  color: archiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEndActions(
    BuildContext context,
    bool isMobile,
    Color dividerColor,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          width: isMobile ? 120 : 140,
          height: isMobile ? 60 : 66,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF).withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                svgIcon: deleteIcon,
                label: 'حذف',
                color: Colors.red,
                onTap: () {
                  Slidable.of(context)?.close();
                  onDelete?.call();
                },
                isMobile: isMobile,
              ),
              Container(
                width: 1,
                height: isMobile ? 20 : 25,
                color: dividerColor,
              ),
              _buildActionButton(
                svgIcon: reportIcon,
                label: 'ابلاغ',
                color: Colors.orange,
                onTap: () {
                  Slidable.of(context)?.close();
                  onReport?.call();
                },
                isMobile: isMobile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('h:mm a', 'ar').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE', 'ar').format(dateTime);
    } else {
      return DateFormat('d/M/yyyy', 'ar').format(dateTime);
    }
  }

  Widget _buildActionButton({
    IconData? icon,
    String? svgIcon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isMobile,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (svgIcon != null)
              SvgPicture.asset(
                svgIcon,
                height: isMobile ? 18 : 22,
                width: isMobile ? 18 : 22,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              )
            else if (icon != null)
              Icon(icon, size: isMobile ? 18 : 22, color: color),
            Text(
              label,
              style: TextStyle(fontSize: isMobile ? 9 : 11, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
