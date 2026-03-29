/// Shared mixin for profile models that have professional info fields.
/// Both [ProfileModel] and [UserAdvisorProfileModel] use identical logic.
mixin ProfileProfessionalInfoMixin {
  String? get yearsOfExperience;
  String? get professionalSpecialization;
  String? get jobGrade;

  String _mapExperienceKey(String? value) {
    if (value == null || value.isEmpty) return '';
    if (value.startsWith('experience_')) return value;
    if (value == '2' || value == '0' || value == '0-2') return 'experience_0_2';
    if (value == '5' || value == '3' || value == '2-5') return 'experience_2_5';
    if (value == '10' || value == '5-10') return 'experience_5_10';
    if (value == '11' || value == '10+') return 'experience_10_plus';
    return value;
  }

  String? get displaySpecialization {
    if (professionalSpecialization == null ||
        professionalSpecialization!.isEmpty)
      return null;
    return professionalSpecialization;
  }

  String? get displayJobGrade {
    if (jobGrade == null || jobGrade!.isEmpty) return null;
    return jobGrade;
  }

  String? get displayYearsExperience {
    if (yearsOfExperience == null || yearsOfExperience!.isEmpty) return null;
    return _mapExperienceKey(yearsOfExperience);
  }

  bool get hasProfessionalInfo {
    return (displaySpecialization != null &&
            displaySpecialization!.isNotEmpty) ||
        (displayYearsExperience != null && displayYearsExperience!.isNotEmpty);
  }
}
