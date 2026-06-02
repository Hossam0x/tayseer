import '../../../../../../my_import.dart';

class TicketHeader extends StatelessWidget {
  final String title;
  final bool showicon;
  final VoidCallback? onBackPressed;

  const TicketHeader({
    super.key,
    required this.title,
    this.showicon = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // السهم دايماً على الشمال — Flutter بيقلبه تلقائياً في RTL
        showicon
            ? IconButton(
                onPressed: onBackPressed ?? () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black87,
                  size: 24.sp,
                ),
              )
            : SizedBox(width: 48.w),

        const Spacer(),

        Text(
          title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        const Spacer(),

        // فراغ موازي للأيقونة عشان العنوان يبقى في المنتصف
        SizedBox(width: 48.w),
      ],
    );
  }
}
