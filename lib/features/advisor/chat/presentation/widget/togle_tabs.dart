import 'package:tayseer/my_import.dart';

class ToggleTabs extends StatelessWidget {
  // 1. نضيف متغير لمعرفة أي تاب هو المختار حالياً
  final bool isChatsSelected;

  // 2. كول باك عند الضغط على كل زر
  final VoidCallback onChatTap;
  final VoidCallback onSessionTap;

  const ToggleTabs({
    super.key,
    required this.isChatsSelected,
    required this.onChatTap,
    required this.onSessionTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final padding = isMobile ? 4.0 : 5.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE96E88).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onSessionTap,
              borderRadius: BorderRadius.circular(12),
              child: _buildTabItem(
                title: "الجلسات",
                isActive: !isChatsSelected,
              ),
            ),
          ),

          Expanded(
            child: InkWell(
              onTap: onChatTap,
              borderRadius: BorderRadius.circular(12),
              child: _buildTabItem(
                title: "المحادثات",
                isActive: isChatsSelected,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({required String title, required bool isActive}) {
    return Builder(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;
        final paddingV = isMobile ? 12.0 : 14.0;
        final fontSize = isMobile ? 14.0 : 16.0;

        return Container(
          padding: EdgeInsets.symmetric(vertical: paddingV),
          decoration: isActive
              ? BoxDecoration(
                  color: const Color(0xFFE96E88),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                )
              : BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
          ),
        );
      },
    );
  }
}
