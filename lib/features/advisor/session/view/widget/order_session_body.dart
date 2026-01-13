import 'package:tayseer/my_import.dart';

class OrderSessionBody extends StatelessWidget {
  const OrderSessionBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // ضبط الاتجاه لليمين
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5F9), // لون خلفية الصفحة
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return const OrderRequestCard(
                    name: "أحمد منصور",
                    handle: "@fdtgsyhujkl",
                    date: "الثلاثاء، 7 فبراير",
                    time: "01:00 م - 02:00 م",
                    imgUrl: "https://i.pravatar.cc/150?img=12",
                  );
                }, childCount: 5),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderRequestCard extends StatelessWidget {
  final String name;
  final String handle;
  final String date;
  final String time;
  final String imgUrl;

  const OrderRequestCard({
    super.key,
    required this.name,
    required this.handle,
    required this.date,
    required this.time,
    required this.imgUrl,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = width / 390; // لتكبير/تصغير العناصر حسب الشاشه

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: const Color(0xFFFFE5E8)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Column(
        children: [
          /// User row
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(
                  imgUrl,
                  width: 50 * scale,
                  height: 50 * scale,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16 * scale,
                          color: Colors.black87,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    FittedBox(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        handle,
                        style: TextStyle(
                          fontSize: 12 * scale,
                          color: Colors.grey,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16 * scale),

          /// Date & Time row
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                padding: EdgeInsets.symmetric(
                  vertical: 12 * scale,
                  horizontal: 16 * scale,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(12 * scale),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 18 * scale,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: 6 * scale),
                          Flexible(
                            child: Text(
                              date,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12 * scale,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 20 * scale,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 18 * scale,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: 6 * scale),
                          Flexible(
                            child: Text(
                              time,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12 * scale,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          SizedBox(height: 16 * scale),

          /// Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD64D65),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12 * scale),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12 * scale),
                  ),
                  child: Text(
                    "قبول",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16 * scale,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2CBD0).withOpacity(0.5),
                    side: const BorderSide(color: Color(0xFFD64D65)),
                    foregroundColor: const Color(0xFFD64D65),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12 * scale),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12 * scale),
                  ),
                  child: Text(
                    "رفض",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16 * scale,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
