import 'package:tayseer/my_import.dart';

class StoryAvatarTile extends StatelessWidget {
  final Widget avatar;
  final String name;

  const StoryAvatarTile({super.key, required this.avatar, required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        avatar,
        Gap(context.responsiveHeight(6)),
        SizedBox(
          width: context.responsiveWidth(76),
          child: Text(
            name,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            style: Styles.textStyle10.copyWith(color: AppColors.kGreyB3),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
