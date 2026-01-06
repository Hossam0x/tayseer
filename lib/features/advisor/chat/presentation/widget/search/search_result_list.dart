import 'package:tayseer/my_import.dart';

class SearchResultsList extends StatelessWidget {
  const SearchResultsList({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final padding = isMobile ? 16.0 : 20.0;
    final avatarRadius = isMobile ? 24.0 : 28.0;
    final spacing1 = isMobile ? 10.0 : 12.0;
    final spacing2 = isMobile ? 2.0 : 4.0;
    final nameFontSize = isMobile ? 14.0 : 16.0;
    final messageFontSize = isMobile ? 10.0 : 12.0;
    final timeFontSize = isMobile ? 10.0 : 12.0;

    return ListView.separated(
      padding: EdgeInsets.all(padding),
      itemCount: 3, // عدد العناصر الوهمية
      separatorBuilder: (context, index) => Divider(color: Colors.grey[300]),
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: isMobile ? 6.0 : 8.0),
          child: Row(
            children: [
              // الصورة الشخصية
              CircleAvatar(
                radius: avatarRadius,
                backgroundImage: const NetworkImage(
                  'https://i.pravatar.cc/150?img=12',
                ), // صورة وهمية
                backgroundColor: Colors.grey,
              ),

              SizedBox(width: spacing1),

              // الاسم والرسالة
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "احمد منصور",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: nameFontSize,
                        color: Colors.black87,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    SizedBox(height: spacing2),
                    Text(
                      "مرحبا بك",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: messageFontSize,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),

              // الوقت (على اليسار)
              Text(
                "9:41 AM",
                style: TextStyle(color: Colors.grey, fontSize: timeFontSize),
              ),
            ],
          ),
        );
      },
    );
  }
}
