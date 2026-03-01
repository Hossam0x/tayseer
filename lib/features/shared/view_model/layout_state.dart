// features/advisor/layout/view_model/a_layout_state.dart
import 'package:tayseer/core/enum/user_type.dart';

class LayoutState {
  final int currentIndex;
  final bool isNavVisible;
  final UserTypeEnum userType;
   final bool isMarriageVisible;
  final int
  scrollToTopTrigger; // يزيد كل ما المستخدم يضغط على الهوم وهو بالفعل في الهوم
  final bool isHomeAtTop; // هل الهوم فوق خالص
  final int refreshHomeTrigger; // يزيد لما نعايز نعمل ريفريش للهوم
final int marriageToggleTrigger; 
  LayoutState({
    this.currentIndex = 0,
    this.isNavVisible = true,
    this.userType = UserTypeEnum.asConsultant,
    this.scrollToTopTrigger = 0,
    this.isHomeAtTop = true,
    this.refreshHomeTrigger = 0,
    this.isMarriageVisible = true,
    this.marriageToggleTrigger = 0,
  });

  LayoutState copyWith({
    int? currentIndex,
    bool? isNavVisible,
    UserTypeEnum? userType,
    int? scrollToTopTrigger,
    bool? isHomeAtTop,
    int? refreshHomeTrigger,
     bool? isMarriageVisible, 
      int? marriageToggleTrigger,
     
  }) {
    return LayoutState(
      currentIndex: currentIndex ?? this.currentIndex,
      isNavVisible: isNavVisible ?? this.isNavVisible,
      userType: userType ?? this.userType,
      scrollToTopTrigger: scrollToTopTrigger ?? this.scrollToTopTrigger,
      isHomeAtTop: isHomeAtTop ?? this.isHomeAtTop,
      refreshHomeTrigger: refreshHomeTrigger ?? this.refreshHomeTrigger,
     isMarriageVisible: isMarriageVisible ?? this.isMarriageVisible,
      marriageToggleTrigger: marriageToggleTrigger ?? this.marriageToggleTrigger,
    );
  }
}
