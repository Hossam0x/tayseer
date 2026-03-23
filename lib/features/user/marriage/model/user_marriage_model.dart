class UsersMarriageResponse {
  bool? success;
  String? message;
  UsersData? data;

  UsersMarriageResponse({this.success, this.message, this.data});

  factory UsersMarriageResponse.fromJson(Map<String, dynamic> json) =>
      UsersMarriageResponse(
        success: json["success"],
        message: json["message"],
        data: json["data"] != null ? UsersData.fromJson(json["data"]) : null,
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class UsersData {
  List<UserItem>? users;
  Pagination? pagination;

  UsersData({this.users, this.pagination});

  factory UsersData.fromJson(Map<String, dynamic> json) => UsersData(
    users: json["users"] != null
        ? List<UserItem>.from(json["users"].map((x) => UserItem.fromJson(x)))
        : null,
    pagination: json["pagination"] != null
        ? Pagination.fromJson(json["pagination"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "users": users?.map((x) => x.toJson()).toList(),
    "pagination": pagination?.toJson(),
  };
}

class UserItem {
  User? user;
  Answers? answers;
 bool? allowInteractions;
  UserItem({this.user, this.answers, this.allowInteractions});

  factory UserItem.fromJson(Map<String, dynamic> json) => UserItem(
    user: json["user"] != null ? User.fromJson(json["user"]) : null,
    answers:
        json["answers"] != null ? Answers.fromJson(json["answers"]) : null,
   allowInteractions: json["allowInteractions"],      
  );

  Map<String, dynamic> toJson() => {
    "user": user?.toJson(),
    "answers": answers?.toJson(),
    "allowInteractions": allowInteractions,
  };
}

class User {
  String? id;
  bool? imageBlur;
  String? name;
  bool? isLiked;
  bool? isVerified;
  String? country;
  String? image;
  int? similarity;
  List<MatchingTag>? matchingTags;
  bool? isNew;
  int? age;
  UserAbout? about;
  bool? isFavorite;
  bool? isBlocked;

  User({
    this.id,
    this.imageBlur,
    this.name,
    this.isLiked,
    this.isVerified,
    this.country,
    this.image,
    this.similarity,
    this.matchingTags,
    this.isNew,
    this.age,
    this.about,
    this.isFavorite,
    this.isBlocked,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    imageBlur: json["imageBlur"],
    name: json["name"],
    isLiked: json["isLiked"],
    isVerified: json["isVerified"],
    country: json["country"],
    image: json["image"],
    similarity: json["similarity"],
    matchingTags: json["matchingTags"] != null
        ? List<MatchingTag>.from(
            json["matchingTags"].map((x) => MatchingTag.fromJson(x)),
          )
        : null,
    isNew: json["isNew"],
    age: json["age"],
    about: json["about"] != null ? UserAbout.fromJson(json["about"]) : null,
    isFavorite: json["isFavorite"],
    isBlocked: json["isBlocked"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "isLiked": isLiked,
    "isVerified": isVerified,
    "country": country,
    "image": image,
    "similarity": similarity,
    "matchingTags": matchingTags?.map((x) => x.toJson()).toList(),
    "isNew": isNew,
    "age": age,
    "about": about?.toJson(),
    "isFavorite": isFavorite,
    "isBlocked": isBlocked,
    "imageBlur": imageBlur,
  };
}

class UserAbout {
  String? job;
  String? educationLevel;
  String? religiousCommitment;
  String? nationality;
  String? height;

  UserAbout({
    this.job,
    this.educationLevel,
    this.religiousCommitment,
    this.nationality,
    this.height,
  });

  factory UserAbout.fromJson(Map<String, dynamic> json) => UserAbout(
    job: json["job"],
    educationLevel: json["educationLevel"],
    religiousCommitment: json["religiousCommitment"],
    nationality: json["nationality"],
    height: json["height"],
  );

  Map<String, dynamic> toJson() => {
    "job": job,
    "educationLevel": educationLevel,
    "religiousCommitment": religiousCommitment,
    "nationality": nationality,
    "height": height,
  };
}

class MatchingTag {
  String? category;
  String? value;

  MatchingTag({this.category, this.value});

  factory MatchingTag.fromJson(Map<String, dynamic> json) =>
      MatchingTag(category: json["category"], value: json["value"]);

  Map<String, dynamic> toJson() => {"category": category, "value": value};
}

class Answers {
  AboutMe? aboutMe;
  ProfessionalLife? professionalLife;
  Family? family;
  List<String>? hobbies;
  UserMedia? userMedia;
  YourGoals? yourGoals;
  String? myDescription;
  int? lastQuestionNumber;

  Answers({
    this.aboutMe,
    this.professionalLife,
    this.family,
    this.hobbies,
    this.userMedia,
    this.yourGoals,
    this.myDescription,
    this.lastQuestionNumber,
  });

  factory Answers.fromJson(Map<String, dynamic> json) => Answers(
    aboutMe:
        json["aboutMe"] != null ? AboutMe.fromJson(json["aboutMe"]) : null,
    professionalLife: json["professionalLife"] != null
        ? ProfessionalLife.fromJson(json["professionalLife"])
        : null,
    family: json["family"] != null ? Family.fromJson(json["family"]) : null,
    hobbies: json["hobbies"] != null
        ? List<String>.from(json["hobbies"])
        : null,
    userMedia: json["userMedia"] != null
        ? UserMedia.fromJson(json["userMedia"])
        : null,
    yourGoals: json["yourGoals"] != null
        ? YourGoals.fromJson(json["yourGoals"])
        : null,
    myDescription: json["myDescription"],
    lastQuestionNumber: json["lastQuestionNumber"],
  );

  Map<String, dynamic> toJson() => {
    "aboutMe": aboutMe?.toJson(),
    "professionalLife": professionalLife?.toJson(),
    "family": family?.toJson(),
    "hobbies": hobbies,
    "userMedia": userMedia?.toJson(),
    "yourGoals": yourGoals?.toJson(),
    "myDescription": myDescription,
    "lastQuestionNumber": lastQuestionNumber,
  };
}

class AboutMe {
  String? weight;
  String? height;
  String? age;
  String? socialStatus;
  String? nationality;
  String? country;
  String? skinColor;
  String? healthStatus;
  String? smoker;
  String? religiousCommitment;
  String? drinkAlcohol;
  String? wearHijab;
  String? eatHalalOnly;

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
    this.wearHijab,
    this.eatHalalOnly,
  });

  factory AboutMe.fromJson(Map<String, dynamic> json) => AboutMe(
    weight: json["weight"],
    height: json["height"],
    age: json["age"],
    socialStatus: json["socialStatus"],
    nationality: json["nationality"],
    country: json["country"],
    skinColor: json["skinColor"],
    healthStatus: json["healthStatus"],
    smoker: json["smoker"],
    religiousCommitment: json["religiousCommitment"],
    drinkAlcohol: json["drinkAlcohol"],
    wearHijab: json["wearHijab"],
    eatHalalOnly: json["eatHalalOnly"],
  );

  Map<String, dynamic> toJson() => {
    "weight": weight,
    "height": height,
    "age": age,
    "socialStatus": socialStatus,
    "nationality": nationality,
    "country": country,
    "skinColor": skinColor,
    "healthStatus": healthStatus,
    "smoker": smoker,
    "religiousCommitment": religiousCommitment,
    "drinkAlcohol": drinkAlcohol,
    "wearHijab": wearHijab,
    "eatHalalOnly": eatHalalOnly,
  };
}

class ProfessionalLife {
  String? job;
  String? educationLevel;
  String? chooseEmployer;

  ProfessionalLife({this.job, this.educationLevel, this.chooseEmployer});

  factory ProfessionalLife.fromJson(Map<String, dynamic> json) =>
      ProfessionalLife(
        job: json["job"],
        educationLevel: json["educationLevel"],
        chooseEmployer: json["chooseEmployer"],
      );

  Map<String, dynamic> toJson() => {
    "job": job,
    "educationLevel": educationLevel,
    "chooseEmployer": chooseEmployer,
  };
}

class Family {
  String? hasChildren;
  String? childrenNumber;
  String? childrenLivingStatus;

  Family({this.hasChildren, this.childrenNumber, this.childrenLivingStatus});

  factory Family.fromJson(Map<String, dynamic> json) => Family(
    hasChildren: json["hasChildren"],
    childrenNumber: json["childrenNumber"],
    childrenLivingStatus: json["childrenLivingStatus"],
  );

  Map<String, dynamic> toJson() => {
    "hasChildren": hasChildren,
    "childrenNumber": childrenNumber,
    "childrenLivingStatus": childrenLivingStatus,
  };
}

class UserMedia {
  List<String>? image;
  String? video;
  String? audio;

  UserMedia({this.image, this.video, this.audio});

  factory UserMedia.fromJson(Map<String, dynamic> json) => UserMedia(
    image: json["image"] != null ? List<String>.from(json["image"]) : null,
    video: json["video"],
    audio: json["audio"],
  );

  Map<String, dynamic> toJson() => {
    "image": image,
    "video": video,
    "audio": audio,
  };
}

// ✅ UPDATED: يدعم كل الـ fields الجاية من الـ API
class YourGoals {
  dynamic travel;
  dynamic children;
  dynamic marry;
  dynamic engagment;
  dynamic marriageIntentions; // ✅ الـ field الصح للزواج من الـ API
  dynamic familyAcceptance;   // ✅ الـ field الصح للأسرة من الـ API

  YourGoals({
    this.travel,
    this.children,
    this.marry,
    this.engagment,
    this.marriageIntentions,
    this.familyAcceptance,
  });

  factory YourGoals.fromJson(Map<String, dynamic> json) => YourGoals(
    travel: json["travel"],
    children: json["children"],
    marry: json["marry"],
    engagment: json["engagment"],
    marriageIntentions: json["marriageIntentions"], // ✅
    familyAcceptance: json["familyAcceptance"],     // ✅
  );

  Map<String, dynamic> toJson() => {
    "travel": travel,
    "children": children,
    "marry": marry,
    "engagment": engagment,
    "marriageIntentions": marriageIntentions, // ✅
    "familyAcceptance": familyAcceptance,     // ✅
  };
}

class Pagination {
  int? totalCount;
  int? totalPages;
  int? currentPage;
  int? pageSize;

  Pagination({
    this.totalCount,
    this.totalPages,
    this.currentPage,
    this.pageSize,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    totalCount: json["totalCount"],
    totalPages: json["totalPages"],
    currentPage: json["currentPage"],
    pageSize: json["pageSize"],
  );

  Map<String, dynamic> toJson() => {
    "totalCount": totalCount,
    "totalPages": totalPages,
    "currentPage": currentPage,
    "pageSize": pageSize,
  };
}