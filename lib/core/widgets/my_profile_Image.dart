import 'package:tayseer/my_import.dart';

class MyProfileImage extends StatelessWidget {
  final int size;
  const MyProfileImage({super.key, this.size = 45});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.r,
      width: size.r,
      child: ClipOval(
        child: AppImage(AssetsData.avatarImage, fit: BoxFit.cover),
      ),
    );
  }
}
