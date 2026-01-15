import 'package:tayseer/my_import.dart';

class MessageInputSection extends StatelessWidget {
  final String name;
  const MessageInputSection({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "عبر عن اعجابك بـ$name وابدأ بالدردشة معه",
          style: Styles.textStyle14Bold,
        ),
        Text(
          "لن يتم خصم رصيد إلى عند أول رد",
          style: Styles.textStyle10.copyWith(color: Colors.grey),
        ),
        Gap(10.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF9E8),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.amber.shade100),
          ),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: "اكتب رسالتك...",
                  hintStyle: Styles.textStyle12.copyWith(color: Colors.grey),
                  border: InputBorder.none,
                ),
                maxLines: 3,
                minLines: 2,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    "إرسال",
                    style: Styles.textStyle14Bold.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
