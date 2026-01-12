import 'package:tayseer/features/advisor/profille/views/widgets/boost/consultation_topic_item.dart';
import 'package:tayseer/my_import.dart';

class ConsultationTopicsView extends StatefulWidget {
  const ConsultationTopicsView({super.key});

  @override
  State<ConsultationTopicsView> createState() => _ConsultationTopicsViewState();
}

class _ConsultationTopicsViewState extends State<ConsultationTopicsView> {
  // Logic: List of all topics
  final List<String> topics = [
    'التواصل الفعّال في الزواج',
    'حلول الخلافات الزوجية',
    'إدارة التوقعات في العلاقة',
    'التوازن بين الحياة الشخصية والزوجية',
    'التوجيه الشخصي والنمو الذاتي',
    'الدعم النفسي للأفراد في مراحل الحياة المختلفة',
    'الاستشارات في تربية الأطفال',
    'التوجيه المهني وإدارة الحياة العملية',
    'التعامل مع القلق والاكتئاب',
    'إدارة الضغوط النفسية والتوتر',
    'التعامل مع الضغوط الزوجية',
  ];

  // Logic: State for Multiple Selection
  final Set<String> selectedTopics = {};

  // Logic: State for Single Selection (if you ever need to switch)
  String? selectedSingleTopic;

  void toggleSelection(String topic) {
    setState(() {
      if (selectedTopics.contains(topic)) {
        selectedTopics.remove(topic);
      } else {
        selectedTopics.add(topic);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- Header ---
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.close, color: AppColors.secondary600),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Text(
                    'مواضيع الاستشارات',
                    style: Styles.textStyle24Meduim.copyWith(
                      color: AppColors.secondary700,
                    ),
                  ),
                ],
              ),
            ),

            // --- Search Bar ---
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: TextField(
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'ابحث عن موقعك',
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
              ),
            ),

            Gap(10.h),

            // --- Topics List ---
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 25.w),
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  final topic = topics[index];
                  return ConsultationTopicItem(
                    title: topic,
                    isSelected: selectedTopics.contains(topic),
                    onTap: () => toggleSelection(topic),
                  );
                },
              ),
            ),

            // --- Confirm Button ---
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: CustomBotton(
                title: 'تأكيد',
                onPressed: () {
                  print("Selected: $selectedTopics");
                },
                useGradient: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
