import 'package:tayseer/my_import.dart';

class OrderRequestCard extends StatelessWidget {
  final String name;
  final String handle;
  final String date;
  final String time;
  final String imgUrl;
  final String sessionId;
  final void Function()? accept;
  final void Function()? decline;

  const OrderRequestCard({
    super.key,
    required this.name,
    required this.handle,
    required this.date,
    required this.time,
    required this.imgUrl,
    required this.sessionId,
    this.accept,
    this.decline,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = width / 390;

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
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50 * scale,
                      height: 50 * scale,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Icon(Icons.person, size: 30 * scale),
                    );
                  },
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16 * scale,
                        color: Colors.black87,
                        fontFamily: 'Cairo',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      handle,
                      style: TextStyle(
                        fontSize: 12 * scale,
                        color: Colors.grey,
                        fontFamily: 'Cairo',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16 * scale),

          /// Date & Time row
          Container(
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
                // Date section
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
                // Divider
                Container(
                  height: 20 * scale,
                  width: 1,
                  color: Colors.grey.shade300,
                ),
                // Time section
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
          ),

          SizedBox(height: 16 * scale),

          /// Buttons
          Row(
            children: [
              // Accept Button
              Expanded(
                child: ElevatedButton(
                  onPressed: accept ?? () {},
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
              // Reject Button
              Expanded(
                child: OutlinedButton(
                  onPressed: decline ?? () {},
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
