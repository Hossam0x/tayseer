import 'package:tayseer/my_import.dart';

class MarriageUserProfileModel {
  final AboutMe? aboutMe;
  final ProfessionalLife? professionalLife;
  final Family? family;
  final List<String> hobbies;
  final List<String> faith;
  final UserMedia? userMedia;
  final YourGoals? yourGoals;
  final String? myDescription;
  final int? lastQuestionNumber;
  final num? answerCompletedPercentage;
  final int? interactionCount;
  final int? regredsCount;
  final bool? inReview;
  final bool? isVerified;
  final ProfileHeader? header;
  final List<TimelineGoal>? timeline;
  final ReligiousInfo? religious;
  final BioInfo? bio;

  MarriageUserProfileModel({
    this.aboutMe,
    this.professionalLife,
    this.family,
    this.hobbies = const [],
    this.faith = const [],
    this.userMedia,
    this.yourGoals,
    this.myDescription,
    this.lastQuestionNumber,
    this.answerCompletedPercentage,
    this.interactionCount,
    this.regredsCount,
    this.inReview,
    this.isVerified,
    this.header,
    this.timeline,
    this.religious,
    this.bio,
  });

  factory MarriageUserProfileModel.fromJson(Map<String, dynamic> json) {
    final bool isViewFormat = json.containsKey('header');
    if (isViewFormat) {
      return _fromViewFormat(json);
    } else {
      return _fromEditFormat(json);
    }
  }

  static MarriageUserProfileModel _fromViewFormat(Map<String, dynamic> json) {
    final header = json['header'] != null
        ? ProfileHeader.fromJson(json['header'] as Map<String, dynamic>)
        : null;

    final timelineData = json['timeline'] as List<dynamic>? ?? [];

    final aboutMe = AboutMe(
      country: header?.location,
      age: header?.age?.toString(),
    );

    final images = header?.images ?? [];
    final userMedia = UserMedia(images: images);

    YourGoals? yourGoals;
    if (timelineData.isNotEmpty) {
      String? marry, engagement, intendTravelAbroad, familyAcceptance;
      for (var goal in timelineData) {
        final goalLabel = goal['goalLabel'] as String?;
        final timeLabel = goal['timeLabel'] as String?;
        if (goalLabel == 'زواج') marry = timeLabel;
        if (goalLabel == 'خطوبة') engagement = timeLabel;
        if (goalLabel == 'intendTravelAbroad') intendTravelAbroad = timeLabel;
        if (goalLabel == 'familyAcceptance') familyAcceptance = timeLabel;
      }
      yourGoals = YourGoals(
        marry: marry,
        engagement: engagement,
        intendTravelAbroad: intendTravelAbroad,
        familyAcceptance: familyAcceptance,
      );
    }

    List<String> parsedHobbies = [];
    if (json['hobbies'] is String && json['hobbies'] != null) {
      final hobbiesStr = json['hobbies'] as String;
      parsedHobbies = hobbiesStr
          .split(',')
          .map((h) => h.trim())
          .where((h) => h.isNotEmpty)
          .toList();
    } else if (json['hobbies'] is List) {
      parsedHobbies = List<String>.from(json['hobbies']);
    }

    final bioText = json['bio'] != null
        ? (json['bio'] as Map<String, dynamic>)['text'] as String?
        : null;

    return MarriageUserProfileModel(
      aboutMe: aboutMe,
      userMedia: userMedia,
      yourGoals: yourGoals,
      hobbies: parsedHobbies,
      myDescription: bioText,
      answerCompletedPercentage: json['answerCompletedPercentage'] as num?,
      header: header,
      timeline: timelineData
          .map((e) => TimelineGoal.fromJson(e as Map<String, dynamic>))
          .toList(),
      religious: json['religious'] != null
          ? ReligiousInfo.fromJson(json['religious'] as Map<String, dynamic>)
          : null,
      bio: json['bio'] != null
          ? BioInfo.fromJson(json['bio'] as Map<String, dynamic>)
          : null,
    );
  }

  static MarriageUserProfileModel _fromEditFormat(Map<String, dynamic> json) {
    // ✅ Parse HOBBIES
    List<String> parsedHobbies = [];
    if (json['hobbies'] != null) {
      if (json['hobbies'] is String) {
        parsedHobbies = (json['hobbies'] as String)
            .split(',')
            .map((h) => h.trim())
            .where((h) => h.isNotEmpty && h.startsWith('interest_'))
            .toList();
      } else if (json['hobbies'] is List) {
        for (var item in json['hobbies'] as List) {
          if (item is String) {
            if (item.contains(',')) {
              parsedHobbies.addAll(
                item
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty && s.startsWith('interest_')),
              );
            } else if (item.trim().startsWith('interest_')) {
              parsedHobbies.add(item.trim());
            }
          }
        }
      }
    }

    // ✅ Parse FAITH
    List<String> parsedFaith = [];
    if (json['faith'] != null) {
      if (json['faith'] is List) {
        for (var item in json['faith'] as List) {
          final itemStr = item.toString().trim();
          if (itemStr.startsWith('faith_')) {
            parsedFaith.add(itemStr);
          } else if (itemStr.contains(',')) {
            // ✅ لو في فواصل داخل عنصر واحد
            parsedFaith.addAll(
              itemStr
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.startsWith('faith_')),
            );
          }
        }
      } else if (json['faith'] is String) {
        final faithStr = json['faith'] as String;
        if (faithStr.contains(',')) {
          parsedFaith = faithStr
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.startsWith('faith_'))
              .toList();
        } else if (faithStr.startsWith('faith_')) {
          parsedFaith.add(faithStr);
        }
      }
    }

    return MarriageUserProfileModel(
      aboutMe: json['aboutMe'] != null
          ? AboutMe.fromJson(json['aboutMe'] as Map<String, dynamic>)
          : null,
      professionalLife: json['professionalLife'] != null
          ? ProfessionalLife.fromJson(
              json['professionalLife'] as Map<String, dynamic>,
            )
          : null,
      family: json['family'] != null
          ? Family.fromJson(json['family'] as Map<String, dynamic>)
          : null,
      hobbies: parsedHobbies,
      faith: parsedFaith,
      userMedia: json['userMedia'] != null
          ? UserMedia.fromJson(json['userMedia'] as Map<String, dynamic>)
          : null,
      yourGoals: json['yourGoals'] != null
          ? YourGoals.fromJson(json['yourGoals'] as Map<String, dynamic>)
          : null,
      myDescription: json['myDescription'] as String?,
      lastQuestionNumber: json['lastQuestionNumber']?['questionNumber'] as int?,
      answerCompletedPercentage: json['answerCompletedPercentage'] as num?,
      interactionCount: json['interactionCount'] as int?,
      regredsCount: json['regredsCount'] as int?,
      inReview: json['inReview'] as bool?,
      isVerified: json['isVerified'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    'aboutMe': aboutMe?.toJson(),
    'professionalLife': professionalLife?.toJson(),
    'family': family?.toJson(),
    'hobbies': hobbies,
    'faith': faith,
    'userMedia': userMedia?.toJson(),
    'yourGoals': yourGoals?.toJson(),
    'myDescription': myDescription,
    'answerCompletedPercentage': answerCompletedPercentage,
  };

  MarriageUserProfileModel copyWith({
    AboutMe? aboutMe,
    ProfessionalLife? professionalLife,
    Family? family,
    List<String>? hobbies,
    List<String>? faith,
    UserMedia? userMedia,
    YourGoals? yourGoals,
    String? myDescription,
    int? lastQuestionNumber,
    num? answerCompletedPercentage,
    int? interactionCount,
    int? regredsCount,
    bool? inReview,
    bool? isVerified,
    ProfileHeader? header,
    List<TimelineGoal>? timeline,
    ReligiousInfo? religious,
    BioInfo? bio,
  }) {
    return MarriageUserProfileModel(
      aboutMe: aboutMe ?? this.aboutMe,
      professionalLife: professionalLife ?? this.professionalLife,
      family: family ?? this.family,
      hobbies: hobbies ?? this.hobbies,
      faith: faith ?? this.faith,
      userMedia: userMedia ?? this.userMedia,
      yourGoals: yourGoals ?? this.yourGoals,
      myDescription: myDescription ?? this.myDescription,
      lastQuestionNumber: lastQuestionNumber ?? this.lastQuestionNumber,
      answerCompletedPercentage:
          answerCompletedPercentage ?? this.answerCompletedPercentage,
      interactionCount: interactionCount ?? this.interactionCount,
      regredsCount: regredsCount ?? this.regredsCount,
      inReview: inReview ?? this.inReview,
      isVerified: isVerified ?? this.isVerified,
      header: header ?? this.header,
      timeline: timeline ?? this.timeline,
      religious: religious ?? this.religious,
      bio: bio ?? this.bio,
    );
  }
}

// ════════════════════════════════════════════════════════════════
// ProfileHeader
// ════════════════════════════════════════════════════════════════
class ProfileHeader {
  final String? name;
  final int? age;
  final String? location;
  final List<String> images;
  final List<TagLabel> tags;

  ProfileHeader({
    this.name,
    this.age,
    this.location,
    this.images = const [],
    this.tags = const [],
  });

  factory ProfileHeader.fromJson(Map<String, dynamic> json) {
    return ProfileHeader(
      name: json['name'] as String?,
      age: json['age'] as int?,
      location: json['location'] as String?,
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : [],
      tags: json['tags'] != null
          ? (json['tags'] as List)
                .map((e) => TagLabel.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
    );
  }
}

class TagLabel {
  final String label;
  TagLabel({required this.label});
  factory TagLabel.fromJson(Map<String, dynamic> json) =>
      TagLabel(label: json['label']?.toString() ?? '');
}

class TimelineGoal {
  final String? timeLabel;
  final String? goalLabel;
  final bool? isActive;

  TimelineGoal({this.timeLabel, this.goalLabel, this.isActive});

  factory TimelineGoal.fromJson(Map<String, dynamic> json) => TimelineGoal(
    timeLabel: json['timeLabel'] as String?,
    goalLabel: json['goalLabel'] as String?,
    isActive: json['isActive'] as bool?,
  );
}

class ReligiousInfo {
  final String? title;
  final List<TagLabel> tags;

  ReligiousInfo({this.title, this.tags = const []});

  factory ReligiousInfo.fromJson(Map<String, dynamic> json) => ReligiousInfo(
    title: json['title'] as String?,
    tags: json['tags'] != null
        ? (json['tags'] as List)
              .map((e) => TagLabel.fromJson(e as Map<String, dynamic>))
              .toList()
        : [],
  );
}

class BioInfo {
  final String? text;
  BioInfo({this.text});
  factory BioInfo.fromJson(Map<String, dynamic> json) =>
      BioInfo(text: json['text'] as String?);
}

// ════════════════════════════════════════════════════════════════
// AboutMe
// ════════════════════════════════════════════════════════════════
class AboutMe {
  final String? weight;
  final String? height;
  final String? age;
  final String? socialStatus;
  final String? nationality;
  final String? country;
  final String? skinColor;
  final String? healthStatus;
  final String? smoker;
  final String? religiousCommitment;
  final String? drinkAlcohol;
  final String? eatHalalOnly;

  AboutMe({
    this.weight,
    this.height,
    this.age,
    this.socialStatus,
    this.nationality,
    this.country,
    this.skinColor,
    this.healthStatus,
    this.smoker,
    this.religiousCommitment,
    this.drinkAlcohol,
    this.eatHalalOnly,
  });

  factory AboutMe.fromJson(Map<String, dynamic> json) => AboutMe(
    weight: json['weight'] as String?,
    height: json['height'] as String?,
    age: json['age'] as String?,
    socialStatus: json['socialStatus'] as String?,
    nationality: json['nationality'] as String?,
    country: json['country'] as String?,
    skinColor: json['skinColor'] as String?,
    healthStatus: json['healthStatus'] as String?,
    smoker: json['smoker'] as String?,
    religiousCommitment: json['religiousCommitment'] as String?,
    drinkAlcohol: json['drinkAlcohol'] as String?,
    eatHalalOnly: json['eatHalalOnly'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'weight': weight,
    'height': height,
    'age': age,
    'socialStatus': socialStatus,
    'nationality': nationality,
    'country': country,
    'skinColor': skinColor,
    'healthStatus': healthStatus,
    'smoker': smoker,
    'religiousCommitment': religiousCommitment,
    'drinkAlcohol': drinkAlcohol,
    'eatHalalOnly': eatHalalOnly,
  };

  AboutMe copyWith({
    String? weight,
    String? height,
    String? age,
    String? socialStatus,
    String? nationality,
    String? country,
    String? skinColor,
    String? healthStatus,
    String? smoker,
    String? religiousCommitment,
    String? drinkAlcohol,
    String? eatHalalOnly,
  }) {
    return AboutMe(
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,
      socialStatus: socialStatus ?? this.socialStatus,
      nationality: nationality ?? this.nationality,
      country: country ?? this.country,
      skinColor: skinColor ?? this.skinColor,
      healthStatus: healthStatus ?? this.healthStatus,
      smoker: smoker ?? this.smoker,
      religiousCommitment: religiousCommitment ?? this.religiousCommitment,
      drinkAlcohol: drinkAlcohol ?? this.drinkAlcohol,
      eatHalalOnly: eatHalalOnly ?? this.eatHalalOnly,
    );
  }
}

// ════════════════════════════════════════════════════════════════
// ProfessionalLife
// ════════════════════════════════════════════════════════════════
class ProfessionalLife {
  final String? job;
  final String? educationLevel;
  final String? chooseEmployer;

  ProfessionalLife({this.job, this.educationLevel, this.chooseEmployer});

  factory ProfessionalLife.fromJson(Map<String, dynamic> json) =>
      ProfessionalLife(
        job: json['job'] as String?,
        educationLevel: json['educationLevel'] as String?,
        chooseEmployer: json['chooseEmployer'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'job': job,
    'educationLevel': educationLevel,
    'chooseEmployer': chooseEmployer,
  };

  ProfessionalLife copyWith({
    String? job,
    String? educationLevel,
    String? chooseEmployer,
  }) {
    return ProfessionalLife(
      job: job ?? this.job,
      educationLevel: educationLevel ?? this.educationLevel,
      chooseEmployer: chooseEmployer ?? this.chooseEmployer,
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Family
// ════════════════════════════════════════════════════════════════
class Family {
  final String? hasChildren;
  final String? childrenNumber;
  final String? childrenLivingStatus;

  Family({this.hasChildren, this.childrenNumber, this.childrenLivingStatus});

  factory Family.fromJson(Map<String, dynamic> json) => Family(
    hasChildren: json['hasChildren'] as String?,
    childrenNumber: json['childrenNumber'] as String?,
    childrenLivingStatus: json['childrenLivingStatus'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'hasChildren': hasChildren,
    'childrenNumber': childrenNumber,
    'childrenLivingStatus': childrenLivingStatus,
  };

  Family copyWith({
    String? hasChildren,
    String? childrenNumber,
    String? childrenLivingStatus,
  }) {
    return Family(
      hasChildren: hasChildren ?? this.hasChildren,
      childrenNumber: childrenNumber ?? this.childrenNumber,
      childrenLivingStatus: childrenLivingStatus ?? this.childrenLivingStatus,
    );
  }
}

// ════════════════════════════════════════════════════════════════
// UserMedia
// ════════════════════════════════════════════════════════════════
class UserMedia {
  final List<String> images;
  final String? video;
  final String? audio;
  final String? singleImage;
  final Map<String, String> imagesIndex;

  UserMedia({
    this.singleImage,
    this.images = const [],
    this.video,
    this.audio,
    this.imagesIndex = const {},
  });

  factory UserMedia.fromJson(Map<String, dynamic> json) {
    final rawSingleImage = json['singleImage'] as String?;
    final filteredSingleImage = _filterDefaultImage(rawSingleImage);

    // ✅ image ممكن يكون Map أو List
    List<String> orderedImages = [];
    final rawImage = json['image'];

    if (rawImage is Map) {
      // ✅ {"0": "url1", "1": "url2"}
      final imageMap = Map<String, dynamic>.from(rawImage);
      final sortedKeys = imageMap.keys.toList()
        ..sort(
          (a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0),
        );
      orderedImages = sortedKeys
          .map((k) => imageMap[k]?.toString() ?? '')
          .where((url) => url.isNotEmpty)
          .toList();
    } else if (rawImage is List) {
      // ✅ ["url1", "url2"]
      orderedImages = List<String>.from(rawImage);
    }

    // ✅ بناء imagesIndex من الـ images المرتبة
    final imagesIndex = orderedImages.asMap().map(
      (i, url) => MapEntry(i.toString(), url),
    );

    return UserMedia(
      singleImage: filteredSingleImage,
      images: orderedImages,
      video: json['video'] as String?,
      audio: json['audio'] as String?,
      imagesIndex: imagesIndex,
    );
  }

  Map<String, dynamic> toJson() => {
    // ✅ احفظ كـ Map دايماً للـ consistency
    'image': imagesIndex.isNotEmpty
        ? imagesIndex
        : images.asMap().map((i, url) => MapEntry(i.toString(), url)),
    'video': video,
    'audio': audio,
    'singleImage': singleImage,
    'imagesIndex': imagesIndex,
  };

  UserMedia copyWith({
    List<String>? images,
    String? singleImage,
    String? video,
    String? audio,
    Map<String, String>? imagesIndex,
  }) {
    return UserMedia(
      images: images ?? this.images,
      singleImage: singleImage ?? this.singleImage,
      video: video ?? this.video,
      audio: audio ?? this.audio,
      imagesIndex: imagesIndex ?? this.imagesIndex,
    );
  }

  static String? _filterDefaultImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return null;
    const defaultImages = [
      'https://cdn-icons-png.flaticon.com/512/149/149071.png',
    ];
    for (final defaultImg in defaultImages) {
      if (imageUrl.contains(defaultImg)) return null;
    }
    return imageUrl;
  }
}

// ════════════════════════════════════════════════════════════════
// YourGoals
// ════════════════════════════════════════════════════════════════
class YourGoals {
  final String? intendTravelAbroad;
  final String? familyAcceptance;
  final String? marry;
  final String? engagement;

  YourGoals({
    this.intendTravelAbroad,
    this.familyAcceptance,
    this.marry,
    this.engagement,
  });

  String? get children => familyAcceptance;

  factory YourGoals.fromJson(Map<String, dynamic> json) => YourGoals(
    intendTravelAbroad: json['intendTravelAbroad'] as String?,
    familyAcceptance: json['familyAcceptance'] as String?,
    marry: json['marriageIntentions'] as String?,
    engagement: json['engagment'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'intendTravelAbroad': intendTravelAbroad,
    'familyAcceptance': familyAcceptance,
    'marriageIntentions': marry,
    'engagment': engagement,
  };

  YourGoals copyWith({
    String? intendTravelAbroad,
    String? familyAcceptance,
    String? marry,
    String? engagement,
  }) {
    return YourGoals(
      intendTravelAbroad: intendTravelAbroad ?? this.intendTravelAbroad,
      familyAcceptance: familyAcceptance ?? this.familyAcceptance,
      marry: marry ?? this.marry,
      engagement: engagement ?? this.engagement,
    );
  }
}