import 'package:tayseer/features/settings/view/widgets/session_price_item.dart';
import 'package:tayseer/my_import.dart';

class SessionPricingView extends StatelessWidget {
  const SessionPricingView({super.key});

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
              height: 120.h,
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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    Gap(16.h),
                    _buildHeader(context),
                    Gap(30.h),
                    Expanded(child: _buildPricingList()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back, color: AppColors.blackColor),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Text(
            'مدة واسعار الجلسات',
            style: Styles.textStyle20Bold.copyWith(
              color: AppColors.secondary800,
            ),
          ),
        ),
        const SizedBox(width: 24),
      ],
    );
  }

  Widget _buildPricingList() {
    final sessions = [
      {'duration': '30 دقيقة', 'price': '120', 'isActive': true},
      {'duration': '60 دقيقة', 'price': '210', 'isActive': true},
    ];

    return ListView.separated(
      itemCount: sessions.length,
      separatorBuilder: (context, index) => Gap(20.h),
      itemBuilder: (context, index) {
        return SessionPriceItem(
          duration: sessions[index]['duration'] as String,
          initialPrice: sessions[index]['price'] as String,
          initialStatus: sessions[index]['isActive'] as bool,
        );
      },
    );
  }
}
