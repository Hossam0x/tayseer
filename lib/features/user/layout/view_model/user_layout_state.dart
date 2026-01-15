// features/advisor/layout/view_model/a_layout_state.dart

class UserLayoutState {
  final int currentIndex;
  final bool isNavVisible;
  final int
  scrollToTopTrigger; // يزيد كل ما المستخدم يضغط على الهوم وهو بالفعل في الهوم

  UserLayoutState({
    this.currentIndex = 0,
    this.isNavVisible = true,
    this.scrollToTopTrigger = 0,
  });

  UserLayoutState copyWith({
    int? currentIndex,
    bool? isNavVisible,
    int? scrollToTopTrigger,
  }) {
    return UserLayoutState(
      currentIndex: currentIndex ?? this.currentIndex,
      isNavVisible: isNavVisible ?? this.isNavVisible,
      scrollToTopTrigger: scrollToTopTrigger ?? this.scrollToTopTrigger,
    );
  }
}
