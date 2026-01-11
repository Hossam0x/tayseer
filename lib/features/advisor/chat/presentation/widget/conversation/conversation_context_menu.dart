import 'package:flutter/material.dart';

class ContextMenuOption {
  final IconData icon;
  final String label;
  final Color color;
  final bool hasBorder;
  final VoidCallback? onTap;

  ContextMenuOption({
    required this.icon,
    required this.label,
    this.color = Colors.black87,
    required this.hasBorder,
    this.onTap,
  });
}

class ConversationContextMenu extends StatelessWidget {
  final bool isMyMessage;
  final VoidCallback? onReply;
  final VoidCallback? onDetails;
  final VoidCallback? onSelect;
  final VoidCallback? onDeleteForMe; // ✅ حذف لدي
  final VoidCallback? onDeleteForAll; // ✅ حذف لدى الجميع

  const ConversationContextMenu({
    super.key,
    required this.isMyMessage,
    this.onReply,
    this.onDetails,
    this.onSelect,
    this.onDeleteForMe,
    this.onDeleteForAll,
  });

  List<ContextMenuOption> _getMenuOptions() {
    return [
      ContextMenuOption(
        icon: Icons.reply,
        label: "رد",
        hasBorder: true,
        onTap: onReply,
      ),
      if (isMyMessage)
        ContextMenuOption(
          icon: Icons.info_outline,
          label: "التفاصيل",
          hasBorder: true,
          onTap: onDetails,
        ),
      ContextMenuOption(
        icon: Icons.check_box_outlined,
        label: "تحديد",
        hasBorder: true,
        onTap: onSelect,
      ),
      // ✅ حذف لدي (للجميع)
      ContextMenuOption(
        icon: Icons.delete_outline,
        label: "حذف لديّ",
        color: Colors.red,
        hasBorder: isMyMessage, // ✅ لو رسالتي، في border لأن في خيار تاني
        onTap: onDeleteForMe,
      ),
      // ✅ حذف لدى الجميع (فقط لرسائلي)
      if (isMyMessage)
        ContextMenuOption(
          icon: Icons.delete_forever_outlined,
          label: "حذف لدى الجميع",
          color: Colors.red,
          hasBorder: false,
          onTap: onDeleteForAll,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final containerWidth = isMobile ? 180.0 : 220.0; // ✅ زودنا العرض شوية

    final options = _getMenuOptions();

    return Container(
      width: containerWidth,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: options
            .asMap()
            .entries
            .map(
              (entry) => _buildMenuItem(
                entry.value.icon,
                entry.value.label,
                color: entry.value.color,
                hasBorder: entry.value.hasBorder,
                isMobile: isMobile,
                onTap: entry.value.onTap,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String text, {
    Color color = Colors.black87,
    required bool hasBorder,
    required bool isMobile,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 10.0 : 14.0,
          horizontal: isMobile ? 12.0 : 16.0,
        ),
        decoration: BoxDecoration(
          border: hasBorder
              ? Border(bottom: BorderSide(color: Colors.grey.shade200))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Cairo',
                  fontSize: isMobile ? 13.0 : 15.0, // ✅ صغرنا شوية للنص الطويل
                ),
              ),
            ),
            SizedBox(width: isMobile ? 8.0 : 12.0),
            Icon(icon, color: color, size: isMobile ? 20.0 : 24.0),
          ],
        ),
      ),
    );
  }
}
