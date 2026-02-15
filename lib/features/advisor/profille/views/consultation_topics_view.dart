import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/consultation_topics_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/boost/consultation_topic_item.dart';
import 'package:tayseer/my_import.dart';

class ConsultationTopicsView extends StatelessWidget {
  const ConsultationTopicsView({super.key});

  @override
  Widget build(BuildContext context) {
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

    return BlocProvider(
      create: (context) => ConsultationTopicsCubit(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // --- Header ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: SimpleAppBar(
                  title: 'مواضيع الاستشارات',
                  icon: Icons.close,
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
                child: BlocBuilder<ConsultationTopicsCubit, Set<String>>(
                  builder: (context, selectedTopics) {
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 25.w),
                      itemCount: topics.length,
                      itemBuilder: (context, index) {
                        final topic = topics[index];
                        return ConsultationTopicItem(
                          title: topic,
                          isSelected: selectedTopics.contains(topic),
                          onTap: () => context
                              .read<ConsultationTopicsCubit>()
                              .toggleTopic(topic),
                        );
                      },
                    );
                  },
                ),
              ),

              // --- Confirm Button ---
              Padding(
                padding: EdgeInsets.only(left: 40.w, right: 40.w, bottom: 20.h),
                child: BlocBuilder<ConsultationTopicsCubit, Set<String>>(
                  builder: (context, selectedTopics) {
                    return CustomBotton(
                      height: 54.h,
                      width: double.infinity,
                      title: 'تأكيد',
                      onPressed: () {
                        print("Selected: $selectedTopics");
                      },
                      useGradient: true,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
