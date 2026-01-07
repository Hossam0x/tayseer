import 'package:tayseer/my_import.dart';

class LocationBottomSheet extends StatelessWidget {
  const LocationBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.height * 0.6,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [HexColor('f9eaf1'), HexColor('f1f4fb')],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 16),

          // العنوان
          Text(
            context.tr('select_location'),
            style: Styles.textStyle16.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          Gap(context.responsiveHeight(16)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: context.tr('closest_to_my_location'),
                hintStyle: Styles.textStyle12.copyWith(
                  color: AppColors.kgreyColor.withOpacity(0.5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.kgreyColor.withOpacity(0.5),
                  size: 20,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          SizedBox(height: 10),

          // قائمة المواقع
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: 4,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  trailing: Icon(
                    Icons.location_on_outlined,
                    color: AppColors.kgreyColor,
                    size: 20,
                  ),
                  title: Text(
                    context.tr('egypt'),
                    textAlign: TextAlign.right,
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.kscandryTextColor,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
