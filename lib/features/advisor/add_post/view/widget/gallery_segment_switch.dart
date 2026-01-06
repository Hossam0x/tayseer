import 'package:tayseer/my_import.dart';

class GallerySegmentSwitch extends StatelessWidget {
  const GallerySegmentSwitch({
    super.key,
    required this.isAlbums,
    required this.onChanged,
  });

  final bool isAlbums;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.height * 0.06,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: HexColor('d2ced5').withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          /// 🔵 Sliding indicator
          AnimatedAlign(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: !isAlbums ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: context.width * 0.25,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),

          /// 📝 Labels
          Row(
            children: [
              _item(
                context: context,
                title: context.tr('all_images'),
                active: !isAlbums,
                onTap: () => onChanged(false),
              ),
              _item(
                context: context,
                title: context.tr('albums'),
                active: isAlbums,
                onTap: () => onChanged(true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _item({
    required BuildContext context,
    required String title,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: active ? Colors.black : Colors.black54,
            ),
            child: Text(title),
          ),
        ),
      ),
    );
  }
}
