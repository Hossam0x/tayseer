import 'dart:io';
import '../../my_import.dart';

class PickImageWidget<C extends Cubit<S>, S> extends StatelessWidget {
  const PickImageWidget({
    super.key,
    required this.onTap,
    required this.cubit,
    required this.pickImage,
    required this.pathPic,
  });
  final Function()? onTap;
  final C cubit;
  final XFile? pickImage;
  final String? pathPic;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<C, S>(
      bloc: cubit,
      listener: (context, state) {},
      builder: (context, state) {
        return SizedBox(
          width: 130,
          height: 130,
          child: Stack(
            children: [
              pickImage == null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(70),
                    child: AppImage(
                      '  kCurrentUserData?.image',
                      placeholderImage: "AssetsData.kUserPlaceholderImage",
                      height: 130,
                      width: 130,
                      fit: BoxFit.cover,
                    ),
                  )
                  : CircleAvatar(
                    radius: 60,
                    backgroundImage: FileImage(File(pathPic!)),
                  ),
              Positioned(
                bottom: 5,
                right: -1,
                child: GestureDetector(
                  onTap: () async {},
                  child: GestureDetector(
                    onTap: onTap,
                    child: const AppImage("AssetsData.kpencilOutlineIcon"),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
