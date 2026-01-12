import 'package:tayseer/my_import.dart';

class CustomSliverAppBarSession extends StatelessWidget {
  const CustomSliverAppBarSession({
    super.key,
    required this.title,
    this.showBackButton = false,
  });
  final String title;
  final bool showBackButton;

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
        child: showBackButton == true
            ? Row(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(Icons.arrow_back),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: context.height * 0.1,
                          left: context.width * 0.1,
                        ),
                        child: Text(title, style: Styles.textStyle20Bold),
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Padding(
                  padding: EdgeInsets.only(top: context.height * 0.1),
                  child: Text(title, style: Styles.textStyle20Bold),
                ),
              ),
      ),
    );
  }
}
