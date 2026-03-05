import 'package:tayseer/my_import.dart';

class CustomSliverAppBarEvent extends StatelessWidget {
  const CustomSliverAppBarEvent({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.isUserTicket = false,
  });
  final String title;
  final bool showBackButton;
  final bool isUserTicket;
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
            ? Stack(
                children: [
                  Positioned(
                    top: context.responsiveHeight(50),
                    bottom: 0,
                    right: isArabic ? 1 : 0,
                    left: isArabic ? null : 1,
                    child: Center(
                      child: IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(Icons.arrow_back),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: context.height * 0.1),
                      child: Text(title, style: Styles.textStyle20Bold),
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  if (isUserTicket == true)
                    Positioned(
                      right: context.responsiveWidth(12),
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () {
                          context.pushNamed(AppRouter.kMyTicketsView);
                        },
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.all(
                              context.responsiveWidth(12),
                            ),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary100,
                            ),
                            child: AppImage(AssetsData.kTicketIcon),
                          ),
                        ),
                      ),
                    ),

                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: context.height * 0.01),
                      child: Text(title, style: Styles.textStyle20Bold),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
