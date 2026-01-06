import 'package:tayseer/my_import.dart';

class CustomSliverAppBarEvent extends StatelessWidget {
  const CustomSliverAppBarEvent({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: context.responsiveHeight(200),
        width: context.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetsData.homeBarBackgroundImage),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: context.height * 0.1),
            child: Text(title, style: Styles.textStyle20Bold),
          ),
        ),
      ),
    );
  }
}
