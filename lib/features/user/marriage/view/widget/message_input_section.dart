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
          "$name ${context.tr('messge_profil_title')}",
          style: Styles.textStyle14Bold,
        ),
        Text(
          context.tr('messge_profil_sub_title'),
          style: Styles.textStyle10.copyWith(color: Colors.grey),
        ),
        Gap(10.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  fillColor: HexColor('f9f8ec'),
                  filled: true,
                  hintText: context.tr('type_your_message'),
                  hintStyle: Styles.textStyle12.copyWith(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.r),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 4,
              ),
              Gap(20.h),
              CustomBotton(
                backGroundcolor: AppColors.kgreyColor,
                title: context.tr('send_reply'),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
