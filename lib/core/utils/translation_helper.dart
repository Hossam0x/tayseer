import 'package:tayseer/my_import.dart';

class TranslationHelper {
  /// Translates a key if it exists in translation files, otherwise returns the original text
  static String translateIfExists(BuildContext context, String? text) {
    if (text == null || text.isEmpty) return '';

    // Check if the text is a translation key by trying to translate it
    try {
      final translated = context.tr(text);
      // If translation exists and is different from the key, return translated text
      if (translated != text) {
        return translated;
      }
    } catch (e) {
      // If translation fails, return original text
    }

    // Return original text if no translation found
    return text;
  }

  /// Translates advisor subtitle specifically
  static String translateAdvisorSubtitle(
    BuildContext context,
    String? subtitle,
  ) {
    if (subtitle == null || subtitle.isEmpty) return '';

    // Common advisor subtitle keys that might come from backend
    final Map<String, String> commonSubtitleKeys = {
      'family_counselor': 'family_counselor',
      'marriage_counselor': 'marriage_counselor',
      'relationship_expert': 'relationship_expert',
      'life_coach': 'life_coach',
      'psychological_counselor': 'psychological_counselor',
      'social_counselor': 'social_counselor',
      'family_therapist': 'family_therapist',
      'couples_therapist': 'couples_therapist',
      'premarital_counselor': 'premarital_counselor',
      'islamic_counselor': 'islamic_counselor',
    };

    // Check if subtitle matches any known key
    if (commonSubtitleKeys.containsKey(subtitle)) {
      try {
        return context.tr(commonSubtitleKeys[subtitle]!);
      } catch (e) {
        return subtitle;
      }
    }

    // Try direct translation
    return translateIfExists(context, subtitle);
  }

  /// Translates years of experience text
  static String translateYearsExperience(BuildContext context, int? years) {
    if (years == null) return '';

    return '$years ${context.tr('years_experience')}';
  }

  /// Translates years of experience from string keys (like "experience_5_10")
  static String translateYearsExperienceFromString(BuildContext context, String? experienceKey) {
    if (experienceKey == null || experienceKey.isEmpty) return '';

    // Try to translate the key directly first
    try {
      final translated = context.tr(experienceKey);
      if (translated != experienceKey) {
        return translated;
      }
    } catch (e) {
      // If translation fails, continue with fallback
    }

    // Fallback: extract numbers from the key and format manually
    switch (experienceKey) {
      case 'experience_0_2':
        return context.tr('experience_0_2');
      case 'experience_2_5':
        return context.tr('experience_2_5');
      case 'experience_5_10':
        return context.tr('experience_5_10');
      case 'experience_10_plus':
        return context.tr('experience_10_plus');
      default:
        return experienceKey; // Return original if no match
    }
  }
}
