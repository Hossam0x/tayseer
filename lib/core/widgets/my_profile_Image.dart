import 'package:tayseer/core/constant/constans_keys.dart';
import 'package:tayseer/my_import.dart';

class MyProfileImage extends StatelessWidget {
  final int size;
  final double? width;
  final String? imageUrl;
  const MyProfileImage({super.key, this.width, this.size = 45, this.imageUrl});
  @override
  Widget build(BuildContext context) {
    String image = imageUrl ?? CachNetwork.getStringData(key: kMyProfileImage);
    if (image.isEmpty) {
      return SizedBox();
    }
    return SizedBox(
      height: width ?? size.r,
      width: width ?? size.r,
      child: ClipOval(child: AppImage(image, fit: BoxFit.cover)),
    );
  }
}
