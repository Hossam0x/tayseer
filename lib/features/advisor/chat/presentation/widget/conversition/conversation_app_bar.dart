import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ConversationAppBar extends StatelessWidget {
  final String videoIcon;
  final String phoneIcon;
  final String? username;
  final String? userimage;

  const ConversationAppBar({
    super.key,
    required this.videoIcon,
    required this.phoneIcon,
    this.username,
    this.userimage,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return Container(
      padding: EdgeInsets.only(
        top: isMobile ? 50 : 30,
        bottom: 10,
        left: 16,
        right: 8,
      ),
      color: const Color(0xFFF9EEFA),
      child: Row(
        children: [
          // ✅ الجزء الأيسر (كما هو)
          Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black87,
                    size: 24,
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 12),
                CircleAvatar(
                  radius: isMobile ? 20 : 24,
                  backgroundImage: NetworkImage(
                    userimage ?? 'https://i.pravatar.cc/150?img=5',
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          username ?? "Anna Mary",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 16 : 18,
                            color: Colors.blue, // أو اللون المخصص
                          ),
                        ),
                      ),
                      SizedBox(width: isMobile ? 4 : 6),
                      Icon(
                        Icons.verified,
                        color: Colors.blue,
                        size: isMobile ? 14 : 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ✅ الجزء الأيمن (تم التعديل لإضافة القائمة)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {},
                icon: SvgPicture.asset(videoIcon, width: isMobile ? 20 : 24),
              ),
              IconButton(
                onPressed: () {},
                icon: SvgPicture.asset(phoneIcon, width: isMobile ? 20 : 24),
              ),

              // 👇 هنا تم التعديل لعمل القائمة المنبثقة
              // 👇 تعديل الإزاحة هنا
              Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: PopupMenuButton<String>(
                  // ✅ التعديل هنا: غيرنا 0 إلى 20 لزقه ناحية اليمين
                  // يمكنك زيادة الرقم (مثلاً 30 أو 40) إذا أردت إزاحته أكثر
                  offset: const Offset(20, 50),

                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.black87,
                    size: 24,
                  ),
                  color: const Color(0xFFF5F6F8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: (value) {
                    if (value == 'report') {
                      print("تم اختيار ابلاغ");
                    } else if (value == 'block') {
                      print("تم اختيار حظر");
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'report',
                          height: 45,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: const [
                              Text(
                                "ابلاغ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.info_outline,
                                color: Colors.black,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          enabled: false,
                          height: 10,
                          child: Divider(
                            color: Colors.black12,
                            thickness: 1,
                            indent: 10,
                            endIndent: 10,
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'block',
                          height: 45,
                          child: Row(
                            children: const [
                              Text(
                                "حظر",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              Spacer(),
                              Icon(Icons.block, color: Colors.black, size: 22),
                            ],
                          ),
                        ),
                      ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
