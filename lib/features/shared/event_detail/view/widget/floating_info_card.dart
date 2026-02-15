import 'package:tayseer/my_import.dart';

class FloatingInfoCard extends StatelessWidget {
  final String title;
  final String location;
  final String consultant;
  final String dateTime;
  final String attendeesLabel;
  final int attendeesCount;
  final VoidCallback? onShowDetails;

  final List<String>? attendeesImages;

  final bool showAttendeesImages;

  const FloatingInfoCard({
    super.key,
    required this.title,
    required this.location,
    required this.consultant,
    required this.dateTime,
    required this.attendeesLabel,
    required this.attendeesCount,
    this.onShowDetails,
    this.attendeesImages,
    this.showAttendeesImages = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Styles.textStyle14Bold.copyWith(color: Colors.black87),
          ),

          const Gap(12),

          _infoRow(icon: Icons.location_on_outlined, text: location),
          const Gap(8),
          _infoRow(icon: Icons.person_outline, text: consultant),
          const Gap(8),
          _infoRow(icon: Icons.calendar_today_outlined, text: dateTime),

          const Gap(16),

          if (showAttendeesImages && attendeesImages != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildStackedImages(),
                    const Gap(6),

                    Text(
                      "$attendeesCount $attendeesLabel",
                      style: Styles.textStyle10,
                    ),
                  ],
                ),

                /// زر عرض التفاصيل
                GestureDetector(
                  onTap: onShowDetails,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xffE91E8C), Color(0xffB91372)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "عرض التفاصيل",
                      style: Styles.textStyle10Bold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                /// عداد + صور
              ],
            ),
        ],
      ),
    );
  }

  Widget _infoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const Gap(6),
        Expanded(
          child: Text(
            text,
            style: Styles.textStyle10.copyWith(color: const Color(0xff6B6B6B)),
          ),
        ),
      ],
    );
  }

  Widget _buildStackedImages() {
    return SizedBox(
      width: 60,
      height: 26,
      child: Stack(
        children: List.generate(
          attendeesImages!.length.clamp(0, 3),
          (index) => Positioned(
            left: index * 18,
            child: CircleAvatar(
              radius: 13,
              backgroundImage: NetworkImage(attendeesImages![index]),
            ),
          ),
        ),
      ),
    );
  }
}
