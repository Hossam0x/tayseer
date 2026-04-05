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
      result = raw
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return result.where(isValidKey).toList();
  }
}

class CountryFlagUtils {
static const Map<String, String> _flagMap = {
  // Keys
  'nationality_saudi': '🇸🇦',
  'nationality_egyptian': '🇪🇬',
  'nationality_emirati': '🇦🇪',
  'nationality_kuwaiti': '🇰🇼',
  'nationality_qatari': '🇶🇦',
  'nationality_bahraini': '🇧🇭',
  'nationality_jordanian': '🇯🇴',
  'nationality_palestinian': '🇵🇸',
  'nationality_moroccan': '🇲🇦',
  'nationality_tunisian': '🇹🇳',
  'country_saudi': '🇸🇦',
  'country_egypt': '🇪🇬',
  'country_emirati': '🇦🇪',
  'country_kuwait': '🇰🇼',
  'country_qatar': '🇶🇦',
  'country_bahrain': '🇧🇭',
  'country_jordan': '🇯🇴',
  'country_palestine': '🇵🇸',
  'country_morocco': '🇲🇦',
  'country_tunisia': '🇹🇳',

  // ✅ العربية
  'السعودية': '🇸🇦',
  'مصر': '🇪🇬',
  'الإمارات': '🇦🇪',
  'الكويت': '🇰🇼',
  'قطر': '🇶🇦',
  'البحرين': '🇧🇭',
  'الأردن': '🇯🇴',
  'فلسطين': '🇵🇸',
  'المغرب': '🇲🇦',
  'تونس': '🇹🇳',
  'سعودي': '🇸🇦',
  'مصري': '🇪🇬',
  'إماراتي': '🇦🇪',
  'كويتي': '🇰🇼',
  'قطري': '🇶🇦',
  'بحريني': '🇧🇭',
  'أردني': '🇯🇴',
  'فلسطيني': '🇵🇸',
  'مغربي': '🇲🇦',
  'تونسي': '🇹🇳',

  // ✅ الإنجليزية — الناقصة هي السبب في المشكلة
  'Saudi Arabia': '🇸🇦',
  'Egypt': '🇪🇬',
  'UAE': '🇦🇪',
  'United Arab Emirates': '🇦🇪',
  'Kuwait': '🇰🇼',
  'Qatar': '🇶🇦',
  'Bahrain': '🇧🇭',
  'Jordan': '🇯🇴',
  'Palestine': '🇵🇸',
  'Morocco': '🇲🇦',
  'Tunisia': '🇹🇳',
  'Libya': '🇱🇾',
  'Algeria': '🇩🇿',
  'Iraq': '🇮🇶',
  'Syria': '🇸🇾',
  'Lebanon': '🇱🇧',
  'Yemen': '🇾🇪',
  'Oman': '🇴🇲',
  'Sudan': '🇸🇩',

  // ✅ الجنسيات بالإنجليزي
  'Saudi': '🇸🇦',
  'Egyptian': '🇪🇬',
  'Emirati': '🇦🇪',
  'Kuwaiti': '🇰🇼',
  'Qatari': '🇶🇦',
  'Bahraini': '🇧🇭',
  'Jordanian': '🇯🇴',
  'Palestinian': '🇵🇸',
  'Moroccan': '🇲🇦',
  'Tunisian': '🇹🇳',
  'Libyan': '🇱🇾',
  'Algerian': '🇩🇿',
  'Iraqi': '🇮🇶',
  'Syrian': '🇸🇾',
  'Lebanese': '🇱🇧',
  'Yemeni': '🇾🇪',
  'Omani': '🇴🇲',
  'Sudanese': '🇸🇩',
};
static String getFlag(String countryKey) {
  final trimmed = countryKey.trim();
  // ✅ جرب مباشرة
  if (_flagMap.containsKey(trimmed)) return _flagMap[trimmed]!;
  
  // ✅ جرب lowercase كـ fallback
  final lower = trimmed.toLowerCase();
  for (final entry in _flagMap.entries) {
    if (entry.key.toLowerCase() == lower) return entry.value;
  }
  
  return '🌍';
}
}