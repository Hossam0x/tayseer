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
    final isTablet = screenSize.width >= 600 && screenSize.width < 1200;

    return Container(
      padding: EdgeInsets.only(
        top: isMobile ? 50 : 30,
        bottom: 10,
        left: 16,
        right: 16,
      ),
      color: const Color(0xFFF9EEFA),
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
          SizedBox(width: isMobile ? 10 : 15),
          CircleAvatar(
            radius: isMobile ? 20 : 24,
            backgroundImage: NetworkImage(
              userimage ?? 'https://i.pravatar.cc/150?img=5',
            ),
          ),
          SizedBox(width: isMobile ? 10 : 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          username ?? "Anna Mary",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 16 : 18,
                            color: Colors.blue,
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
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              videoIcon,
              width: isMobile ? 20 : 24,
              height: isMobile ? 20 : 24,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              phoneIcon,
              width: isMobile ? 20 : 24,
              height: isMobile ? 20 : 24,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.black87, size: 24),
          ),
        ],
      ),
    );
  }
}
