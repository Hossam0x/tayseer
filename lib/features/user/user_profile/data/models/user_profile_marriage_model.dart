import 'dart:io';

class MarriageUserProfileModel {
  final AboutMe? aboutMe;
  final ProfessionalLife? professionalLife;
  final Family? family;
  final List<String> hobbies;
  final UserMedia? userMedia;
  final YourGoals? yourGoals;
  final String? myDescription;
  final int? lastQuestionNumber;

  // Additional fields for the "view" format from API
  final ProfileHeader? header;
  final List<TimelineGoal>? timeline;
  final ReligiousInfo? religious;
  final BioInfo? bio;

  MarriageUserProfileModel({
    this.aboutMe,
    this.professionalLife,
    this.family,
    this.hobbies = const [],
    this.userMedia,
    this.yourGoals,
    this.myDescription,
    this.lastQuestionNumber,
    this.header,
    this.timeline,
    this.religious,
    this.bio,
  });

  factory MarriageUserProfileModel.fromJson(Map<String, dynamic> json) {
    // Check if this is the "view" format or "edit" format
    final bool isViewFormat = json.containsKey('header');
    
    if (isViewFormat) {
      return _fromViewFormat(json);
    } else {
      return _fromEditFormat(json);
    }
  }

  // Parse the VIEW format (what your current API returns)
  static MarriageUserProfileModel _fromViewFormat(Map<String, dynamic> json) {
    final header = json['header'] != null 
        ? ProfileHeader.fromJson(json['header'] as Map<String, dynamic>) 
        : null;

    // Extract data from the view format and map to edit format
    final aboutMeData = json['aboutMe'] as List<dynamic>? ?? [];
    final educationData = json['education'] as List<dynamic>? ?? [];
    final timelineData = json['timeline'] as List<dynamic>? ?? [];
    final interestsData = json['interests'] as List<dynamic>? ?? [];
    
    // Build AboutMe from tags and other data
    final aboutMe = AboutMe(
      country: header?.location,
      age: header?.age?.toString(),
      // Parse other fields from aboutMe array if needed
      // Example: aboutMeData might contain smoking, health status, etc.
    );

    // Extract images from header
    final images = header?.images ?? [];
    final userMedia = UserMedia(images: images);

    // Parse timeline into YourGoals
    YourGoals? yourGoals;
    if (timelineData.isNotEmpty) {
      String? marry, engagement, travel, children;
      for (var goal in timelineData) {
        final goalLabel = goal['goalLabel'] as String?;
        final timeLabel = goal['timeLabel'] as String?;
        if (goalLabel == 'زواج') marry = timeLabel;
        if (goalLabel == 'خطوبة') engagement = timeLabel;
        if (goalLabel == 'travel') travel = timeLabel;
        if (goalLabel == 'children') children = timeLabel;
      }
      yourGoals = YourGoals(
        marry: marry,
        engagement: engagement,
        travel: travel,
        children: children,
      );
    }

    // Parse hobbies/interests
    final hobbies = interestsData
        .map((e) => (e as Map<String, dynamic>)['label'] as String?)
        .whereType<String>()
        .toList();

    // Parse bio
    final bioText = json['bio'] != null 
        ? (json['bio'] as Map<String, dynamic>)['text'] as String?
        : null;

    return MarriageUserProfileModel(
      aboutMe: aboutMe,
      userMedia: userMedia,
      yourGoals: yourGoals,
      hobbies: hobbies,
      myDescription: bioText,
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

  // Parse the EDIT format (what you expect to receive/send)
  static MarriageUserProfileModel _fromEditFormat(Map<String, dynamic> json) {
    return MarriageUserProfileModel(
      aboutMe: json['aboutMe'] != null 
          ? AboutMe.fromJson(json['aboutMe'] as Map<String, dynamic>) 
          : null,
      professionalLife: json['professionalLife'] != null 
          ? ProfessionalLife.fromJson(json['professionalLife'] as Map<String, dynamic>) 
          : null,
      family: json['family'] != null 
          ? Family.fromJson(json['family'] as Map<String, dynamic>) 
          : null,
      hobbies: json['hobbies'] != null 
          ? List<String>.from(json['hobbies'] as List) 
          : [],
      userMedia: json['userMedia'] != null 
          ? UserMedia.fromJson(json['userMedia'] as Map<String, dynamic>) 
          : null,
      yourGoals: json['yourGoals'] != null 
          ? YourGoals.fromJson(json['yourGoals'] as Map<String, dynamic>) 
          : null,
      myDescription: json['myDescription'] as String?,
      lastQuestionNumber: json['lastQuestionNumber']?['questionNumber'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    // Always send in EDIT format for updates
    return {
      'aboutMe': aboutMe?.toJson(),
      'professionalLife': professionalLife?.toJson(),
      'family': family?.toJson(),
      'hobbies': hobbies,
      'userMedia': userMedia?.toJson(),
      'yourGoals': yourGoals?.toJson(),
      'myDescription': myDescription,
    };
  }

  MarriageUserProfileModel copyWith({
    AboutMe? aboutMe,
    ProfessionalLife? professionalLife,
    Family? family,
    List<String>? hobbies,
    UserMedia? userMedia,
    YourGoals? yourGoals,
    String? myDescription,
    int? lastQuestionNumber,
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
      userMedia: userMedia ?? this.userMedia,
      yourGoals: yourGoals ?? this.yourGoals,
      myDescription: myDescription ?? this.myDescription,
      lastQuestionNumber: lastQuestionNumber ?? this.lastQuestionNumber,
      header: header ?? this.header,
      timeline: timeline ?? this.timeline,
      religious: religious ?? this.religious,
      bio: bio ?? this.bio,
    );
  }
}

// ════════════════════════════════════════════════════════════════
// ProfileHeader (for view format)
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

  factory TagLabel.fromJson(Map<String, dynamic> json) {
    return TagLabel(
      label: json['label']?.toString() ?? '',
    );
  }
}

class TimelineGoal {
  final String? timeLabel;
  final String? goalLabel;
  final bool? isActive;

  TimelineGoal({this.timeLabel, this.goalLabel, this.isActive});

  factory TimelineGoal.fromJson(Map<String, dynamic> json) {
    return TimelineGoal(
      timeLabel: json['timeLabel'] as String?,
      goalLabel: json['goalLabel'] as String?,
      isActive: json['isActive'] as bool?,
    );
  }
}

class ReligiousInfo {
  final String? title;
  final List<TagLabel> tags;

  ReligiousInfo({this.title, this.tags = const []});

  factory ReligiousInfo.fromJson(Map<String, dynamic> json) {
    return ReligiousInfo(
      title: json['title'] as String?,
      tags: json['tags'] != null
          ? (json['tags'] as List)
              .map((e) => TagLabel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

class BioInfo {
  final String? text;

  BioInfo({this.text});

  factory BioInfo.fromJson(Map<String, dynamic> json) {
    return BioInfo(text: json['text'] as String?);
  }
}

// ════════════════════════════════════════════════════════════════
// AboutMe Model (edit format)
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
    );
  }
}

// ════════════════════════════════════════════════════════════════
// ProfessionalLife Model
// ════════════════════════════════════════════════════════════════
class ProfessionalLife {
  final String? job;
  final String? educationLevel;
  final String? chooseEmployer;

  ProfessionalLife({
    this.job,
    this.educationLevel,
    this.chooseEmployer,
  });

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
// Family Model
// ════════════════════════════════════════════════════════════════
class Family {
  final String? hasChildren;
  final String? childrenNumber;
  final String? childrenLivingStatus;

  Family({
    this.hasChildren,
    this.childrenNumber,
    this.childrenLivingStatus,
  });

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
// UserMedia Model
// ════════════════════════════════════════════════════════════════
class UserMedia {
  final List<String> images;
  final String? video;
  final String? audio;

  UserMedia({
    this.images = const [],
    this.video,
    this.audio,
  });

  factory UserMedia.fromJson(Map<String, dynamic> json) => UserMedia(
        images: json['image'] != null 
            ? List<String>.from(json['image'] as List) 
            : [],
        video: json['video'] as String?,
        audio: json['audio'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'image': images,
        'video': video,
        'audio': audio,
      };

  UserMedia copyWith({
    List<String>? images,
    String? video,
    String? audio,
  }) {
    return UserMedia(
      images: images ?? this.images,
      video: video ?? this.video,
      audio: audio ?? this.audio,
    );
  }
}

// ════════════════════════════════════════════════════════════════
// YourGoals Model
// ════════════════════════════════════════════════════════════════
class YourGoals {
  final String? travel;
  final String? children;
  final String? marry;
  final String? engagement;

  YourGoals({
    this.travel,
    this.children,
    this.marry,
    this.engagement,
  });

  factory YourGoals.fromJson(Map<String, dynamic> json) => YourGoals(
        travel: json['travel'] as String?,
        children: json['children'] as String?,
        marry: json['marry'] as String?,
        engagement: json['engagment'] as String?, // Note: typo in API
      );

  Map<String, dynamic> toJson() => {
        'travel': travel,
        'children': children,
        'marry': marry,
        'engagment': engagement, // Note: typo in API
      };

  YourGoals copyWith({
    String? travel,
    String? children,
    String? marry,
    String? engagement,
  }) {
    return YourGoals(
      travel: travel ?? this.travel,
      children: children ?? this.children,
      marry: marry ?? this.marry,
      engagement: engagement ?? this.engagement,
    );
  }
}