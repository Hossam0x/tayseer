// features/advisor/layout/view_model/a_layout_state.dart
import 'package:tayseer/core/enum/user_type.dart';

class LayoutState {
  final int currentIndex;
  final bool isNavVisible;
  final UserTypeEnum userType;
  final int
  scrollToTopTrigger; // يزيد كل ما المستخدم يضغط على الهوم وهو بالفعل في الهوم

  LayoutState({
    this.currentIndex = 0,
    this.isNavVisible = true,
    this.userType = UserTypeEnum.asConsultant,
    this.scrollToTopTrigger = 0,
  });

  LayoutState copyWith({
    int? currentIndex,
    bool? isNavVisible,
    UserTypeEnum? userType,
    int? scrollToTopTrigger,
  }) {
    return LayoutState(
      currentIndex: currentIndex ?? this.currentIndex,
      isNavVisible: isNavVisible ?? this.isNavVisible,
      userType: userType ?? this.userType,
      scrollToTopTrigger: scrollToTopTrigger ?? this.scrollToTopTrigger,
    );
  }
}
