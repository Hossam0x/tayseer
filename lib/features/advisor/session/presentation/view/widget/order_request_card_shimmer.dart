import 'package:tayseer/my_import.dart';

class OrderRequestShimmerCard extends StatelessWidget {
  const OrderRequestShimmerCard({super.key});

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
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          children: [
            /// User row Shimmer
            Row(
              children: [
                // Avatar Placeholder
                Container(
                  width: 50 * scale,
                  height: 50 * scale,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name Placeholder
                      Container(
                        width: 120 * scale,
                        height: 16 * scale,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 8 * scale),
                      // Handle Placeholder
                      Container(
                        width: 80 * scale,
                        height: 12 * scale,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16 * scale),

            /// Date & Time row Shimmer
            Container(
              height: 48 * scale,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12 * scale),
              ),
            ),

            SizedBox(height: 16 * scale),

            /// Buttons Shimmer
            Row(
              children: [
                // Accept Button Placeholder
                Expanded(
                  child: Container(
                    height: 45 * scale,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12 * scale),
                    ),
                  ),
                ),
                SizedBox(width: 12 * scale),
                // Reject Button Placeholder
                Expanded(
                  child: Container(
                    height: 45 * scale,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12 * scale),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
