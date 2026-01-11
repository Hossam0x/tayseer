import 'package:tayseer/my_import.dart';

class ToggleTabs extends StatelessWidget {
  final bool isChatsSelected;
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
    // نستخدم LayoutBuilder للحصول على أبعاد العنصر الأب بشكل دقيق
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;

        // حساب الارتفاع بشكل نسبي (مثلاً 12% من العرض) مع وضع حد أقصى وأدنى
        // هذا يمنع الأوفرفلو لأن الارتفاع أصبح محسوباً وليس معتمداً على المحتوى
        double tabHeight = isMobile ? 45.0 : 55.0;

        return Container(
          // تقليل البادينج الخارجي قليلاً لتوفير مساحة
          padding: const EdgeInsets.all(4.0),
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
                    height: tabHeight,
                    isMobile: isMobile,
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
                    height: tabHeight,
                    isMobile: isMobile,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabItem({
    required String title,
    required bool isActive,
    required double height,
    required bool isMobile,
  }) {
    return Container(
      // التغيير الجوهري هنا: استخدام height بدلاً من padding عمودي
      // هذا يضمن عدم تجاوز المساحة المحددة وحل مشكلة الـ Overflow
      height: height,
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

      // محاذاة النص في المنتصف
      alignment: Alignment.center,

      // استخدام FittedBox لضمان أن النص لا يخرج عن الإطار
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 14.0 : 16.0,
          ),
        ),
      ),
    );
  }
}
