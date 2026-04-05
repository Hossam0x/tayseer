import 'package:tayseer/core/functions/country_helper.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/shared/packages/domain/entities/package_type.dart';
import 'package:tayseer/my_import.dart';

class UserPackageDetailsView extends StatelessWidget {
  final PackageType packageType;

  const UserPackageDetailsView({super.key, required this.packageType});

  @override
  Widget build(BuildContext context) {
    return _UserPackageDetailsViewContent(packageType: packageType);
  }
}

class _UserPackageDetailsViewContent extends StatelessWidget {
  final PackageType packageType;

  const _UserPackageDetailsViewContent({required this.packageType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    Gap(20.h),
                    _buildSubtitle(context),
                    Gap(40.h),
                    _buildFeaturesList(context),
                    Gap(40.h),
                    _buildBottomButton(context),
                    Gap(40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final title = packageType == PackageType.elite
        ? 'اشترك معنا في نظام Elite'
        : packageType == PackageType.pro
        ? 'اشترك معنا في نظام Pro'
        : 'اشترك معنا في نظام Basic';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: SimpleAppBar(title: title, isLargeTitle: true),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(
      'واستمتع بالمزايا التحررية',
      textAlign: TextAlign.center,
      style: Styles.textStyle14.copyWith(color: AppColors.secondary600),
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final features = _getFeatures();

    return Column(
      children: features
          .map(
            (feature) => Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: _buildFeatureItem(context, feature),
            ),
          )
          .toList(),
    );
  }

  Widget _buildFeatureItem(BuildContext context, Map<String, String> feature) {
    final checkColors = _getCheckColors();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: checkColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: SvgPicture.asset(
            AssetsData.checkPackageItems,
            width: 24.w,
            height: 24.h,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
        Gap(12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature['title']!,
                style: Styles.textStyle16.copyWith(
                  color: AppColors.secondary800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (feature['description']!.isNotEmpty) ...[
                Gap(4.h),
                Text(
                  feature['description']!,
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.secondary600,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<Color> _getCheckColors() {
    if (packageType == PackageType.elite) {
      return const [Color(0xFFFFBA40), Color(0xFFFF009F)];
    } else {
      return const [Color(0xFFBD8F14), Color(0xFFF5C003)];
    }
  }

  Widget _buildBottomButton(BuildContext context) {
    final gradientColors = _getButtonGradientColors();
    final isVertical = packageType == PackageType.elite;
    final buttonText = _getButtonText(context);

    return Center(
      child: Container(
        width: 360.w,
        height: 55.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11.r),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: isVertical ? Alignment.topCenter : Alignment.centerLeft,
            end: isVertical ? Alignment.bottomCenter : Alignment.centerRight,
          ),
          border: packageType == PackageType.elite
              ? Border.all(color: Colors.white, width: 1.5)
              : null,
          boxShadow: packageType == PackageType.elite
              ? [
                  BoxShadow(
                    color: const Color(0xFF6284FF).withOpacity(0.45),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: () {
            // TODO: Implement subscription logic
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11.r),
            ),
          ),
          child: Text(
            buttonText,
            style: Styles.textStyle18SemiBold.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  String _getButtonText(BuildContext context) {
    final gulf = isGulfGroup();
    final currency = getCurrency();

    if (packageType == PackageType.pro) {
      final price = gulf ? "200" : "40";
      return context
          .tr('get_all_benefits_for')
          .replaceFirst('{}', price)
          .replaceFirst('{currency}', currency);
    } else {
      // Elite
      final price = gulf ? "399" : "80";
      return context
          .tr('subscribe_vip_for')
          .replaceFirst('{}', price)
          .replaceFirst('{currency}', currency);
    }
  }

  List<Color> _getButtonGradientColors() {
    if (packageType == PackageType.elite) {
      return const [Color(0xFFFFBA40), Color(0xFFFF009F)];
    } else {
      return const [Color(0xFFBD8F14), Color(0xFFF5C003)];
    }
  }

  List<Map<String, String>> _getFeatures() {
    if (packageType == PackageType.elite) {
      return [
        {
          'title': 'عدد لا محدود من الإعجابات',
          'description':
              'استمتع بعدد لا محدود من الإعجابات والتواصل مع مستخدمين جدد بدون حدود.',
        },
        {
          'title': 'شاهد من يعجب بك',
          'description':
              'اكتشف الأشخاص الذين يعجبون بملفك ويحبون بك وتعرف على من يهتم بإعجاباتك ويحب شخصيتك.',
        },
        {
          'title': '5 خالات للشراكة لك',
          'description':
              'احصل على خالات مميزة لتوسيع شبكة التواصل والتواصل مع الأشخاص المناسبين.',
        },
        {
          'title': '2 تجربة إضافية مجاناً شهرياً',
          'description':
              'جرب خدمات جديدة مجاناً كل شهر، مما يتيح لك فرصة من التفاعل والتواصل بشكل مستمر دون أي تكلفة إضافية.',
        },
        {
          'title': 'تعرفين مجاناً أسبوعياً',
          'description':
              'احصل على تعريفين مجانيين كل أسبوع لزيادة فرصة يتطلعك بشكل مستمر دون أي تكلفة.',
        },
        {
          'title': 'بمكانك تصفح الموافق دون واحدة مجاناً',
          'description':
              'بمكانك تصفح الموافق دون واحدة مجاناً مما يتيح لك الاستفادة من القدرة على التصفح دون أي تكلفة.',
        },
        {
          'title': 'عرفك في إعجابات الآخرين',
          'description':
              'عرفك في الإعجابات والتواصل مع الآخرين، وتعرف على من يهتم بك بطريقة جديدة.',
        },
        {
          'title': 'الوضع غير اللائق',
          'description':
              'الوضع غير اللائق يسمح لك بالتصفح أو التفاعل بشكل مجهول دون أن يظهر اسمك للآخرين.',
        },
        {
          'title': 'عوامل تصفية إضافية',
          'description':
              'عوامل تصفية إضافية تساعدك على تخصيص البحث أو التفاعل بشكل أفضل، مما يتيح لك الوصول إلى النتائج أو الخيارات الأنسب لك.',
        },
        {
          'title': 'شارة Elite',
          'description':
              'احصل على شارة Gold كمكافأة على عدد كبير من الأعضاء المميزين، تمكنك وتميزك عن باقي من التفاعل والوصول.',
        },
      ];
    } else if (packageType == PackageType.pro) {
      return [
        {
          'title': 'عدد لا محدود من الإعجابات',
          'description':
              'استمتع بعدد لا محدود من الإعجابات والتواصل مع مستخدمين جدد بدون حدود.',
        },
        {
          'title': 'شاهد من يعجب بك',
          'description':
              'اكتشف الأشخاص الذين يعجبون بملفك ويحبون بك وتعرف على من يهتم بإعجاباتك ويحب شخصيتك.',
        },
        {
          'title': '5 خالات للشراكة لك',
          'description':
              'احصل على خالات مميزة لتوسيع شبكة التواصل والتواصل مع الأشخاص المناسبين.',
        },
        {
          'title': '2 تجربة إضافية مجاناً شهرياً',
          'description':
              'جرب خدمات جديدة مجاناً كل شهر، مما يتيح لك فرصة من التفاعل والتواصل بشكل مستمر دون أي تكلفة إضافية.',
        },
        {
          'title': 'تعرفين مجاناً أسبوعياً',
          'description':
              'احصل على تعريفين مجانيين كل أسبوع لزيادة فرصة يتطلعك بشكل مستمر دون أي تكلفة.',
        },
        {
          'title': 'بمكانك تصفح الموافق دون واحدة مجاناً',
          'description':
              'بمكانك تصفح الموافق دون واحدة مجاناً مما يتيح لك الاستفادة من القدرة على التصفح دون أي تكلفة.',
        },
        {
          'title': 'عرفك في إعجابات الآخرين',
          'description':
              'عرفك في الإعجابات والتواصل مع الآخرين، وتعرف على من يهتم بك بطريقة جديدة.',
        },
        {
          'title': 'الوضع غير اللائق',
          'description':
              'الوضع غير اللائق يسمح لك بالتصفح أو التفاعل بشكل مجهول دون أن يظهر اسمك للآخرين.',
        },
        {
          'title': 'عوامل تصفية إضافية',
          'description':
              'عوامل تصفية إضافية تساعدك على تخصيص البحث أو التفاعل بشكل أفضل، مما يتيح لك الوصول إلى النتائج أو الخيارات الأنسب لك.',
        },
      ];
    } else {
      return [
        {
          'title': 'عدد محدود من الإعجابات',
          'description': 'استمتع بعدد محدود من الإعجابات يومياً.',
        },
        {
          'title': 'تصفح الملفات الشخصية',
          'description': 'تصفح الملفات الشخصية للمستخدمين الآخرين.',
        },
        {
          'title': 'إرسال الرسائل',
          'description': 'إرسال الرسائل للمستخدمين الذين تتطابق معهم.',
        },
      ];
    }
  }
}
