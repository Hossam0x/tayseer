// features/advisor/layout/view_model/a_layout_state.dart
import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/user_type.dart';

class LayoutState extends Equatable {
  final int currentIndex;
  final bool isNavVisible;
  final UserTypeEnum userType;
  final bool isMarriageVisible;
  final int scrollToTopTrigger;
  final bool isHomeAtTop;
  final int refreshHomeTrigger;
  final int marriageToggleTrigger;

  const LayoutState({
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

  @override
  List<Object?> get props => [
    currentIndex,
    isNavVisible,
    userType,
    isMarriageVisible,
    scrollToTopTrigger,
    isHomeAtTop,
    refreshHomeTrigger,
    marriageToggleTrigger,
  ];
}
