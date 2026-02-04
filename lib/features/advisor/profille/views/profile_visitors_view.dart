import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/profille/data/models/visitor_itemm.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/boost_button_sliver.dart';
import 'package:tayseer/my_import.dart';

class ProfileVisitorsView extends StatelessWidget {
  const ProfileVisitorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 110.h,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AssetsData.homeBarBackgroundImage),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Gap(10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: const SimpleAppBar(
                      title: 'من زار ملفك الشخصي',
                      isLargeTitle: true,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 10.h,
                      ),
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return const VisitorItem(
                          name: 'احمد منصور',
                          imageUrl: '',
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 30.h,
                      left: 50.w,
                      right: 50.w,
                    ),
                    child: BoostButton(text: 'عرض المزيد', onPressed: () {}),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
