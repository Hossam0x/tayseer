import 'package:tayseer/core/constant/constans.dart';

/// Static data constants for the questions feature.
///
/// Contains all the predefined data maps (interests, faith, marriage intentions)
/// and the question list builder, extracted from the view layer for maintainability.
class QuestionsData {
  QuestionsData._();

  // ─────────────────────────────────────────────────────
  // Interests (categorized with emoji)
  // ─────────────────────────────────────────────────────

  static const Map<String, Map<String, String>> interestsWithCategories = {
    'category_sports': {
      'interest_baseball': '⚾',
      'interest_running': '🏃',
      'interest_weightlifting': '🏋️',
      'interest_gymnastics': '🤸',
      'interest_golf': '⛳',
      'interest_tennis': '🎾',
      'interest_swimming': '🏊',
      'interest_dancing': '💃',
      'interest_skating': '⛸️',
      'interest_yoga': '🧘',
      'interest_flying_disc': '🥏',
      'interest_badminton': '🏸',
      'interest_skiing': '⛷️',
      'interest_cycling': '🚴',
      'interest_basketball': '🏀',
      'interest_football': '⚽',
      'interest_karate': '🥋',
      'interest_boxing': '🥊',
      'interest_archery': '🏹',
      'interest_horse_riding': '🏇',
    },
    'category_arts_culture': {
      'interest_theater': '🎭',
      'interest_magic': '🪄',
      'interest_music': '🎵',
      'interest_painting': '🎨',
      'interest_photography': '📷',
      'interest_cinema': '🎬',
      'interest_reading': '📚',
      'interest_writing': '✍️',
      'interest_poetry': '📝',
      'interest_history': '🏛️',
      'interest_languages': '🗣️',
      'interest_museums': '🖼️',
      'interest_calligraphy': '🖋️',
      'interest_sculpture': '🗿',
      'interest_design': '🎯',
      'interest_fashion': '👗',
    },
    'category_community': {
      'interest_volunteering': '🤝',
      'interest_charity': '💝',
      'interest_teaching': '👨‍🏫',
      'interest_mentoring': '🧑‍🤝‍🧑',
      'interest_elderly_care': '👴',
      'interest_children_care': '👶',
      'interest_environment': '🌱',
      'interest_animal_care': '🐾',
      'interest_blood_donation': '🩸',
      'interest_community_events': '🎉',
      'interest_social_work': '💼',
      'interest_human_rights': '⚖️',
    },
    'category_technology': {
      'interest_programming': '💻',
      'interest_gaming': '🎮',
      'interest_ai': '🤖',
      'interest_web_dev': '🌐',
      'interest_mobile_apps': '📱',
      'interest_cybersecurity': '🔒',
      'interest_data_science': '📊',
      'interest_electronics': '🔌',
      'interest_robotics': '🦾',
      'interest_vr_ar': '🥽',
      'interest_3d_printing': '🖨️',
      'interest_drones': '🚁',
      'interest_smart_home': '🏠',
      'interest_blockchain': '⛓️',
    },
    'category_outdoors': {
      'interest_hiking': '🥾',
      'interest_camping': '🏕️',
      'interest_fishing': '🎣',
      'interest_beach': '🏖️',
      'interest_mountain_climbing': '🏔️',
      'interest_gardening': '🌻',
      'interest_picnic': '🧺',
      'interest_bird_watching': '🦅',
      'interest_stargazing': '🌟',
      'interest_road_trips': '🚗',
      'interest_sailing': '⛵',
      'interest_diving': '🤿',
      'interest_surfing': '🏄',
      'interest_kayaking': '🛶',
      'interest_rock_climbing': '🧗',
      'interest_paragliding': '🪂',
    },
    'category_food_drinks': {
      'interest_cooking': '👨‍🍳',
      'interest_baking': '🧁',
      'interest_grilling': '🍖',
      'interest_coffee': '☕',
      'interest_tea': '🍵',
      'interest_smoothies': '🥤',
      'interest_sushi': '🍣',
      'interest_pizza': '🍕',
      'interest_desserts': '🍰',
      'interest_healthy_food': '🥗',
      'interest_street_food': '🌮',
      'interest_fine_dining': '🍽️',
      'interest_food_photography': '📸',
      'interest_chocolate': '🍫',
      'interest_ice_cream': '🍦',
    },
  };

  // ─────────────────────────────────────────────────────
  // Faith (with emoji)
  // ─────────────────────────────────────────────────────

  static const Map<String, String> faithWithEmoji = {
    'faith_dua': '🙏',
    'faith_umrah': '🕋',
    'faith_charity_work': '💼',
    'faith_dawah': '📢',
    'faith_sadaqah': '🤝',
    'faith_hadith': '📖',
    'faith_tahajjud': '😊',
    'faith_dhikr': '📿',
    'faith_multiple_prayers': '🕌',
    'faith_sunnah_prayer': '🙏',
    'faith_nafila_prayer': '🕯️',
    'faith_hajj': '🕋',
    'faith_five_prayers': '☪️',
    'faith_fiqh': '📚',
    'faith_fasting': '🌙',
    'faith_tasawwuf': '😇',
    'faith_good_manners': '🤲',
    'faith_friday_prayer': '🕌',
  };

  // ─────────────────────────────────────────────────────
  // Marriage Intentions
  // ─────────────────────────────────────────────────────

  static const Map<String, Map<String, String>> marriageIntentions = {
    'intention_contact_period': {
      'period_1_3_months': '',
      'period_4_7_months': '',
      'period_7_12_months': '',
      'period_1_2_years': '',
    },
    'intention_engagement_period': {
      'period_1_3_months': '',
      'period_4_7_months': '',
      'period_7_12_months': '',
      'period_1_2_years': '',
    },
    'intention_marriage_period': {
      'period_1_3_months': '',
      'period_4_7_months': '',
      'period_7_12_months': '',
      'period_1_2_years': '',
    },
  };

  // ─────────────────────────────────────────────────────
  // Nationalities
  // ─────────────────────────────────────────────────────

  static const List<String> nationalities = [
    'nationality_saudi',
    'nationality_egyptian',
    'nationality_emirati',
    'nationality_kuwaiti',
    'nationality_qatari',
    'nationality_bahraini',
    'nationality_jordanian',
    'nationality_palestinian',
    'nationality_moroccan',
    'nationality_tunisian',
  ];

  // ─────────────────────────────────────────────────────
  // Countries
  // ─────────────────────────────────────────────────────

  static const List<String> countries = [
    'country_saudi',
    'country_egypt',
    'country_emirati',
    'country_kuwait',
    'country_qatar',
    'country_bahrain',
    'country_jordan',
    'country_palestine',
    'country_morocco',
    'country_tunisia',
  ];

  // ─────────────────────────────────────────────────────
  // Social Status
  // ─────────────────────────────────────────────────────

  static List<String> get socialStatuses => kCurrentUserData?.gender == 'male'
      ? const [
          'social_single',
          'social_married',
          'social_divorced',
          'social_widowed',
        ]
      : const ['F_social_single', 'F_social_divorced', 'F_social_widowed'];

  // ─────────────────────────────────────────────────────
  // Skin Colors
  // ─────────────────────────────────────────────────────

  static const List<String> skinColors = [
    'skin_very_light',
    'skin_light',
    'skin_medium',
    'skin_dark',
    'skin_very_dark',
  ];

  // ─────────────────────────────────────────────────────
  // Religious Commitment
  // ─────────────────────────────────────────────────────

  static const List<String> religiousCommitments = [
    'religion_full',
    'religion_partial',
    'religion_sometimes',
    'religion_none',
  ];

  // ─────────────────────────────────────────────────────
  // Children Numbers
  // ─────────────────────────────────────────────────────

  static const List<String> childrenNumbers = [
    'child_1',
    'child_2',
    'child_3',
    'child_4',
    'child_5',
    'child_6_plus',
  ];

  // ─────────────────────────────────────────────────────
  // Children Living Status
  // ─────────────────────────────────────────────────────

  static const List<String> childrenLivingStatuses = [
    'living_currently',
    'living_future',
    'living_current_future',
    'living_no',
  ];

  // ─────────────────────────────────────────────────────
  // Education Levels
  // ─────────────────────────────────────────────────────

  static const List<String> educationLevels = [
    'education_primary',
    'education_secondary',
    'education_diploma',
    'education_bachelor',
    'education_master',
    'education_phd',
    'education_none',
  ];

  // ─────────────────────────────────────────────────────
  // Jobs
  // ─────────────────────────────────────────────────────

  static const List<String> jobs = [
    'job_student',
    'job_teacher',
    'job_engineer',
    'job_doctor',
    'job_nurse',
    'job_driver',
    'job_business',
    'job_unemployed',
    'job_other',
  ];

  // ─────────────────────────────────────────────────────
  // Employers
  // ─────────────────────────────────────────────────────

  static const List<String> employers = [
    'employer_government',
    'employer_private',
    'employer_institution',
    'employer_freelance',
    'employer_unemployed',
  ];

  // ─────────────────────────────────────────────────────
  // Health Statuses
  // ─────────────────────────────────────────────────────

  static const List<String> healthStatuses = [
    'health_excellent',
    'health_good',
    'health_followup',
    'health_chronic',
    'health_unstable',
  ];

  // ─────────────────────────────────────────────────────
  // Yes/No Options
  // ─────────────────────────────────────────────────────

  static const List<String> yesNo = ['yes', 'no'];

  // ─────────────────────────────────────────────────────
  // Family Options
  // ─────────────────────────────────────────────────────

  static const List<String> familyOptions = [
    'no_problem_children',
    'do_not_want_children',
  ];

  // ─────────────────────────────────────────────────────
  // Travel Options
  // ─────────────────────────────────────────────────────

  static const List<String> travelOptions = [
    'intend_travel_abroad',
    'do_not_intend_travel',
  ];
}
