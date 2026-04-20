// مثال على كيفية استخدام TranslationHelper في أماكن مختلفة

import 'package:tayseer/core/utils/translation_helper.dart';
import 'package:tayseer/my_import.dart';

class TranslationHelperExample extends StatelessWidget {
  const TranslationHelperExample({super.key});

  @override
  Widget build(BuildContext context) {
    // مثال على بيانات تأتي من الباك إند
    final advisorData = {
      'name': 'أحمد محمد',
      'subtitle': 'family_counselor', // هذا key يأتي من الباك إند
      'yearsOfExperience': '5',
      'description': 'relationship_expert', // key آخر من الباك إند
    };

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('advisors'))),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عرض اسم المستشار
            Text(
              advisorData['name'] ?? '',
              style: Styles.textStyle18.copyWith(fontWeight: FontWeight.bold),
            ),
            Gap(8.h),

            // ترجمة التخصص باستخدام TranslationHelper
            Text(
              TranslationHelper.translateAdvisorSubtitle(
                context,
                advisorData['subtitle'],
              ),
              style: Styles.textStyle14.copyWith(
                color: AppColors.kprimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap(8.h),

            // ترجمة سنوات الخبرة
            Text(
              TranslationHelper.translateYearsExperience(
                context,
                int.tryParse(advisorData['yearsOfExperience'] ?? '0'),
              ),
              style: Styles.textStyle12.copyWith(color: Colors.grey.shade600),
            ),
            Gap(16.h),

            // ترجمة أي نص آخر قد يأتي من الباك إند
            Text(
              TranslationHelper.translateIfExists(
                context,
                advisorData['description'],
              ),
              style: Styles.textStyle12.copyWith(color: Colors.grey.shade600),
            ),

            Gap(24.h),

            // مثال على قائمة من التخصصات
            Text(
              context.tr('available_specializations'),
              style: Styles.textStyle16.copyWith(fontWeight: FontWeight.bold),
            ),
            Gap(12.h),

            // قائمة التخصصات التي قد تأتي من الباك إند
            ...[
                  'family_counselor',
                  'marriage_counselor',
                  'life_coach',
                  'psychological_counselor',
                ]
                .map(
                  (specialization) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.kprimaryColor,
                          size: 16.sp,
                        ),
                        Gap(8.w),
                        Text(
                          TranslationHelper.translateAdvisorSubtitle(
                            context,
                            specialization,
                          ),
                          style: Styles.textStyle14,
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }
}

// مثال على كيفية استخدام TranslationHelper في ListView
class AdvisorsList extends StatelessWidget {
  final List<Map<String, dynamic>> advisors;

  const AdvisorsList({super.key, required this.advisors});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: advisors.length,
      itemBuilder: (context, index) {
        final advisor = advisors[index];

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: advisor['image'] != null
                  ? NetworkImage(advisor['image'])
                  : null,
              child: advisor['image'] == null ? Icon(Icons.person) : null,
            ),
            title: Text(advisor['name'] ?? ''),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ترجمة التخصص
                Text(
                  TranslationHelper.translateAdvisorSubtitle(
                    context,
                    advisor['subtitle'],
                  ),
                  style: TextStyle(
                    color: AppColors.kprimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // ترجمة سنوات الخبرة
                Text(
                  TranslationHelper.translateYearsExperience(
                    context,
                    int.tryParse(
                      advisor['yearsOfExperience']?.toString() ?? '0',
                    ),
                  ),
                ),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // الانتقال لصفحة تفاصيل المستشار
            },
          ),
        );
      },
    );
  }
}
