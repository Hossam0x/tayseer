import '../../my_import.dart';

class ServiceHeader extends StatelessWidget {
  final String title;
  final String icon;

  const ServiceHeader({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      margin: const EdgeInsets.symmetric(horizontal: 70),
      decoration: BoxDecoration(
        gradient: AppColors.defaultGradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(child: AppImage(icon)),
          SizedBox(width: context.width * 0.02),
          Text(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            title,
            style: Styles.textStyle16.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
