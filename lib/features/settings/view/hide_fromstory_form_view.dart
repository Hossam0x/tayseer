import 'package:tayseer/my_import.dart';

class HideStoryFromView extends StatefulWidget {
  const HideStoryFromView({super.key});

  @override
  State<HideStoryFromView> createState() => _HideStoryFromViewState();
}

class _HideStoryFromViewState extends State<HideStoryFromView> {
  // قائمة الأشخاص (مثال – في الواقع تأتي من API أو cubit)
  final List<Map<String, dynamic>> _users = [
    {
      'name': 'احمد منصور',
      'username': '@fdtgsyhuikl',
      'image': 'https://example.com/p1.jpg',
      'isSelected': false,
    },
    {
      'name': 'احمد منصور',
      'username': '@gtsysyhujkl',
      'image': 'https://example.com/p2.jpg',
      'isSelected': false,
    },
    {
      'name': 'سارة محمد',
      'username': '@sarah_moh',
      'image': 'https://example.com/p3.jpg',
      'isSelected': false,
    },
    // أضف المزيد...
  ];

  final Set<int> _selectedIndices = {}; // لتتبع الاختيارات المتعددة

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100.h,
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
                // Header مع زر إغلاق
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(
                            Icons.close,
                            color: AppColors.blackColor,
                            size: 24.w,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'إخفاء القصة من',
                          style: Styles.textStyle24Meduim.copyWith(
                            color: AppColors.secondary700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // حقل البحث
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: TextField(
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'بحث',
                      hintStyle: Styles.textStyle16.copyWith(
                        color: AppColors.gray2,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.gray2,
                        size: 20.sp,
                      ),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 40.w,
                        minHeight: 20.h,
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onChanged: (value) {
                      // TODO: فلترة القائمة هنا لاحقاً
                    },
                  ),
                ),

                Gap(16.h),

                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      final isSelected = _selectedIndices.contains(index);

                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedIndices.remove(index);
                                } else {
                                  _selectedIndices.add(index);
                                }
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Row(
                                children: [
                                  // الدائرة الاختيار (checkmark)

                                  // الصورة
                                  CircleAvatar(
                                    radius: 26.r,
                                    backgroundColor: Colors.grey.shade200,
                                    backgroundImage: AssetImage(
                                      AssetsData.avatarImage,
                                    ),
                                    onBackgroundImageError: (_, __) {
                                      // fallback إذا فشل تحميل الصورة
                                    },
                                  ),

                                  Gap(12.w),

                                  // الاسم + اليوزرنيم
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user['name']!,
                                          style: Styles.textStyle16.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.secondary800,
                                          ),
                                        ),
                                        Text(
                                          user['username']!,
                                          style: Styles.textStyle14.copyWith(
                                            color: AppColors.gray2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  Container(
                                    width: 24.w,
                                    height: 24.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? const Color(0xFFD65670)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFFD65670)
                                            : Colors.grey.shade300,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16.sp,
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(color: Colors.grey.shade100, height: 1),
                        ],
                      );
                    },
                  ),
                ),

                // زر التأكيد في الأسفل
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.w,
                    vertical: 16.h,
                  ),
                  child: CustomBotton(
                    title: 'تأكيد',
                    onPressed: () {
                      // هنا يمكنك حفظ الاختيارات في SharedPreferences أو إرسالها للـ backend
                      final selectedUsers = _users
                          .asMap()
                          .entries
                          .where(
                            (entry) => _selectedIndices.contains(entry.key),
                          )
                          .map((entry) => entry.value['username'])
                          .toList();

                      print(
                        'المستخدمون المختارون لإخفاء القصة منهم: $selectedUsers',
                      );
                      Navigator.pop(context);
                    },
                    useGradient: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
