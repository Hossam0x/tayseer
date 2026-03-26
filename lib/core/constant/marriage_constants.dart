
class MarriageConstants {

  // ════════════════════════════════════════════
  // 🎯 Emoji Maps
  // ════════════════════════════════════════════

  static const Map<String, String> hobbyEmojiMap = {
    // Sports
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
    // Arts & Culture
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
    // Community
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
    // Technology
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
    // Outdoors
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
    // Food & Drinks
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
    // Extra Arts
    'interest_singing': '🎤',
    'interest_dancing_ballroom': '💃',
    'interest_opera': '🎭',
    'interest_ballet': '🩰',
    'interest_acting': '🎬',
    'interest_filmmaking': '🎥',
    'interest_journalism': '📰',
    'interest_blogging': '✍️',
    'interest_podcasting': '🎙️',
    'interest_storytelling': '📖',
    'interest_archeology': '🏺',
    'interest_astronomy': '🔭',
    'interest_philosophy': '🤔',
    'interest_literature': '📚',
    'interest_crafts': '✂️',
    'interest_knitting': '🧶',
    'interest_sewing': '🧵',
    'interest_pottery': '🏺',
    'interest_woodworking': '🪵',
    'interest_origami': '📄',
  };

  static const Map<String, String> faithEmojiMap = {
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

  /// Combined map (hobby + faith) - for cases needing both
  static Map<String, String> get allEmojiMap => {
        ...hobbyEmojiMap,
        ...faithEmojiMap,
      };

  // ════════════════════════════════════════════
  // 📦 Categorized Items (for MultiSelect widgets)
  // ════════════════════════════════════════════

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

  static const Map<String, Map<String, String>> faithWithCategories = {
    'faith': {
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
    },
  };

  // ════════════════════════════════════════════
  // 🛠️ Helper Methods
  // ════════════════════════════════════════════

  /// يجيب emoji للـ key، fallback حسب النوع
  static String getEmoji(String key) {
    if (hobbyEmojiMap.containsKey(key)) return hobbyEmojiMap[key]!;
    if (faithEmojiMap.containsKey(key)) return faithEmojiMap[key]!;
    return key.startsWith('faith_') ? '☪️' : '🎵';
  }

  /// يفحص لو الـ key ده interest أو faith
  static bool isValidKey(String key) =>
      key.startsWith('interest_') || key.startsWith('faith_');

  /// يحول list أو String لـ List<String> نظيفة من الـ keys
  static List<String> parseKeysFromRaw(dynamic raw) {
    List<String> result = [];

    if (raw is List) {
      for (var item in raw) {
        final itemStr = item.toString().trim();
        if (itemStr.isEmpty) continue;
        if (itemStr.contains(',')) {
          result.addAll(
            itemStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty),
          );
        } else {
          result.add(itemStr);
        }
      }
    } else if (raw is String && raw.isNotEmpty) {
      result = raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }

    return result.where(isValidKey).toList();
  }
}
// lib/core/utils/country_flag_utils.dart
class CountryFlagUtils {
  static String getFlag(String country) {
    final c = country.toLowerCase();
    if (c.contains('saudi') || c.contains('سعودي')) return '🇸🇦';
    if (c.contains('egypt') || c.contains('مصر')) return '🇪🇬';
    if (c.contains('emirati') || c.contains('امارات')) return '🇦🇪';
    if (c.contains('kuwait') || c.contains('كويت')) return '🇰🇼';
    if (c.contains('qatar') || c.contains('قطر')) return '🇶🇦';
    if (c.contains('bahrain') || c.contains('بحرين')) return '🇧🇭';
    if (c.contains('jordan') || c.contains('أردن')) return '🇯🇴';
    if (c.contains('palestin') || c.contains('فلسطين')) return '🇵🇸';
    if (c.contains('morocco') || c.contains('مغرب')) return '🇲🇦';
    if (c.contains('tunisia') || c.contains('تونس')) return '🇹🇳';
    if (c.contains('syria') || c.contains('سوريا')) return '🇸🇾';
    if (c.contains('iraq') || c.contains('عراق')) return '🇮🇶';
    if (c.contains('libya') || c.contains('ليبيا')) return '🇱🇾';
    if (c.contains('algeria') || c.contains('الجزائر')) return '🇩🇿';
    if (c.contains('sudan') || c.contains('السودان')) return '🇸🇩';
    if (c.contains('yemen') || c.contains('اليمن')) return '🇾🇪';
    if (c.contains('oman') || c.contains('عمان')) return '🇴🇲';
    if (c.contains('lebanon') || c.contains('لبنان')) return '🇱🇧';
    return '🌍';
  }
}