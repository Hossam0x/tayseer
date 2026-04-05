import 'package:tayseer/core/enum/verification_type.dart';
import 'package:tayseer/my_import.dart';

/// Name + verification badge — works with any profile that has [name] and [verificationType].
class SharedBioNameSection extends StatelessWidget {
  final String name;
  final VerificationType verificationType;

  const SharedBioNameSection({
    super.key,
    required this.name,
    this.verificationType = VerificationType.none,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            name,
            style: Styles.textStyle20SemiBold.copyWith(
              color: AppColors.blueText,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (verificationType == VerificationType.full) ...[
          Gap(8.w),
          Icon(Icons.verified, color: Colors.blue, size: 20.w),
        ] else if (verificationType == VerificationType.basic) ...[
          Gap(8.w),
          Icon(Icons.verified, color: Colors.grey, size: 20.w),
        ],
      ],
    );
  }
}

/// Specialization + years of experience — pure display widget, no cubit dependency.
class SharedBioProfessionalInfo extends StatelessWidget {
  final String? displaySpecialization;
  final String? displayYearsExperience;

  const SharedBioProfessionalInfo({
    super.key,
    this.displaySpecialization,
    this.displayYearsExperience,
  });

  @override
  Widget build(BuildContext context) {
    final hasSpec =
        displaySpecialization != null && displaySpecialization!.isNotEmpty;
    final hasExp =
        displayYearsExperience != null && displayYearsExperience!.isNotEmpty;

    if (!hasSpec && !hasExp) return const SizedBox.shrink();

    String specText = '';
    if (hasSpec) {
      specText = context.tr(displaySpecialization!);
      if (!context.isArabicLang) {
        specText = specText
            .split(' ')
            .map(
              (w) =>
                  w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '',
            )
            .join(' ');
      }
    }

    String expText = '';
    if (hasExp) {
      expText = context.tr(displayYearsExperience!);
      expText = context.isArabicLang
          ? '${expText.replaceAll('-', 'الي')} ${context.tr('years_experience')}'
          : '${expText.replaceAll('-', 'to')} ${context.tr('years_experience')}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasSpec)
          Text(
            specText,
            style: Styles.textStyle14.copyWith(
              color: AppColors.secondary800,
              fontWeight: FontWeight.w600,
            ),
          ),
        if (hasSpec && hasExp) Gap(4.h),
        if (hasExp)
          Text(
            expText,
            style: Styles.textStyle14Meduim.copyWith(
              color: AppColors.secondary800,
            ),
          ),
        Gap(8.h),
      ],
    );
  }
}

/// Location row — shows nothing if [location] is null/empty.
class SharedBioLocationSection extends StatelessWidget {
  final String? location;

  const SharedBioLocationSection({super.key, this.location});

  @override
  Widget build(BuildContext context) {
    if (location == null || location!.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          AppImage(AssetsData.locationIcon, width: 12.w),
          Gap(4.w),
          Expanded(
            child: Text(
              location!,
              style: Styles.textStyle14.copyWith(color: AppColors.secondary800),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// About you text — shows nothing if [aboutYou] is empty.
class SharedBioAboutSection extends StatelessWidget {
  final String aboutYou;

  const SharedBioAboutSection({super.key, required this.aboutYou});

  @override
  Widget build(BuildContext context) {
    if (aboutYou.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
      child: Text(
        aboutYou,
        style: Styles.textStyle14.copyWith(
          color: AppColors.infoText,
          height: 1.5,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }
}
