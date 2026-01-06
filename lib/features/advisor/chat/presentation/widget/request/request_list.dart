import 'dart:ui';

import 'package:tayseer/features/advisor/chat/data/model/chatView/request_item_model.dart';
import 'package:tayseer/my_import.dart';

class RequestListTile extends StatelessWidget {
  final RequestItemModel item;

  const RequestListTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final avatarSize = isMobile ? 48.0 : 55.0;
    final spacing1 = isMobile ? 10.0 : 12.0;
    final spacing2 = isMobile ? 6.0 : 8.0;
    final nameFontSize = isMobile ? 12.0 : 14.0;
    final buttonPaddingH = isMobile ? 10.0 : 12.0;
    final buttonPaddingV = isMobile ? 4.0 : 6.0;
    final buttonFontSize = isMobile ? 10.0 : 12.0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 6.0 : 8.0),
      child: Row(
        children: [
          // الصورة المشوشة
          Container(
            width: avatarSize,
            height: avatarSize,
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
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.grey), // في حالة فشل التحميل
                ),
              ),
            ),
          ),

          SizedBox(width: spacing1),

          // الاسم والرسالة
          Expanded(
            child: Text(
              item.name,
              style: TextStyle(
                fontSize: nameFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'Cairo',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(width: spacing2),

          // زر العرض
          GestureDetector(
            onTap: () {
              // أكشن عند الضغط على زر عرض
              print("عرض الطلب: ${item.name}");
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: buttonPaddingH,
                vertical: buttonPaddingV,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFF80AB)),
              ),
              child: Row(
                children: [
                  Text(
                    "عرض",
                    style: TextStyle(
                      color: const Color(0xFFFF80AB),
                      fontWeight: FontWeight.bold,
                      fontSize: buttonFontSize,
                    ),
                  ),
                  SizedBox(width: isMobile ? 2.0 : 4.0),
                  Icon(
                    Icons.diamond,
                    color: Colors.amber,
                    size: isMobile ? 14 : 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
