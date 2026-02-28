
import 'package:tayseer/features/user/interactions/presentation/view/widget/interaction_ProfileCard.dart';
import 'package:tayseer/my_import.dart';

class historyGridView extends StatelessWidget {
  const historyGridView({
    super.key,
    required this.data,
  });

  final List<dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: GridView.builder(
        padding: EdgeInsets.only(top: 16.h, bottom: 20.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.7, // Adjust this for card height
        ),
        itemCount: data.length,
        itemBuilder: (context, index) {
          return InteractionProfileCard(item:  data[index]);
        },
      ),
    );
  }
}