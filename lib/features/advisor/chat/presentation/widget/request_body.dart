import 'package:tayseer/features/advisor/chat/data/model/chatView/request_item_model.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/request/custome_request_appbar.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/request/request_list.dart';
import 'package:tayseer/my_import.dart';

class RequestBody extends StatelessWidget {
  const RequestBody({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final paddingH = isMobile ? 16.0 : 20.0;
    final paddingV = isMobile ? 8.0 : 10.0;

    // قائمة وهمية بالبيانات (يمكنك جلبها من API لاحقاً)
    final List<RequestItemModel> requests = [
      RequestItemModel(
        name: "ارسال اليك احمد منصور رسالة",
        imageUrl: 'https://i.pravatar.cc/150?img=3',
      ),
      RequestItemModel(
        name: "ارسال اليك سارة محمد رسالة",
        imageUrl: 'https://i.pravatar.cc/150?img=5',
      ),
      RequestItemModel(
        name: "ارسال اليك محمود علي رسالة",
        imageUrl: 'https://i.pravatar.cc/150?img=11',
      ),
      RequestItemModel(
        name: "ارسال اليك يارا حسن رسالة",
        imageUrl: 'https://i.pravatar.cc/150?img=9',
      ),
    ];

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetsData.homeBackgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          // استدعاء البار العلوي المخصص
          const CustomRequestsAppBar(),

          // القائمة
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: paddingH,
                  vertical: paddingV,
                ),
                itemCount: requests.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey[300],
                  thickness: isMobile ? 0.5 : 0.8,
                ),
                itemBuilder: (context, index) {
                  return RequestListTile(item: requests[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
