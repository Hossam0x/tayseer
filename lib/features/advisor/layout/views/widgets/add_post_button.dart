import 'package:tayseer/my_import.dart';

class AddPostButton extends StatelessWidget {
  const AddPostButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(AppRouter.kAddPostView, arguments: {"isEdit": false});
      },
      child: Container(
        width: 80.r,
        height: 80.r,
        decoration: BoxDecoration(
          gradient: AppColors.defaultGradient,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 10.r),
        ),
        child: Icon(Icons.add, color: Colors.white, size: 32.r),
      ),
    );
  }
}
