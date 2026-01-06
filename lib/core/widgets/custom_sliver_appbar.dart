import '../../my_import.dart';

class CustomSliverAppBar extends StatelessWidget {
  const CustomSliverAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.white.withOpacity(0.95),
      automaticallyImplyLeading: false,
      pinned: true,
      centerTitle: false,
      toolbarHeight: 70,
      actions: [
        GestureDetector(
          onTap: () {
           context.pushNamed('AppRouter.kChatTypesScreen');
          },
          child: AppImage('AssetsData.kChatIcon', width: 40, height: 40),
        ),
        GestureDetector(
          onTap: () {
            Scaffold.of(context).openEndDrawer();
          },
          child: AppImage(AssetsData.kArroBackIcon, width: 40, height: 40),
        ),
      ],
      title: _buildTitle(context),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: AppColors.kprimaryColor,
          child: AppImage('AssetsData.kuserImage'),
        ),
        SizedBox(width: context.width * 0.04),
        Expanded(
          child: Text(
            'Eng khaled',
            style: Styles.textStyle16,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
