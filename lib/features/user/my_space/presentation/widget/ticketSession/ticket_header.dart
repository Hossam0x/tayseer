import '../../../../../../my_import.dart';

class TicketHeader extends StatelessWidget {
  final String title;
  final bool showicon;

  const TicketHeader({
    super.key,
    required this.title,
    this.showicon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(width: 24.w),

        Text(
          title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        showicon
            ? IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_forward,
            color: Colors.black87,
            size: 24.sp,
          ),
        )
            : SizedBox(width: 48.w), // يحافظ على المسافة
      ],
    );
  }
}
