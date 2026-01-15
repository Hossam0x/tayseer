// features/advisor/layout/view_model/a_layout_cubit.dart
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/my_import.dart';

class LayoutCubit extends Cubit<LayoutState> {
  LayoutCubit({UserTypeEnum userType = UserTypeEnum.asConsultant})
    : super(LayoutState(userType: userType));

  void changeIndex(int index) {
    // لو المستخدم بالفعل في نفس الصفحة وضغط عليها تاني (زي فيسبوك)
    if (state.currentIndex == index && index == 0) {
      // Home index = 0
      scrollToTop();
    } else {
      emit(state.copyWith(currentIndex: index));
    }
  }

  void scrollToTop() {
    // نزود الـ trigger عشان الـ HomeViewBody يعرف إنه لازم يطلع لفوق
    emit(state.copyWith(scrollToTopTrigger: state.scrollToTopTrigger + 1));
  }

  void setNavVisibility(bool isVisible) {
    if (state.isNavVisible != isVisible) {
      emit(state.copyWith(isNavVisible: isVisible));
    }
  }

  void onScroll(bool isScrollingDown) {
    if (isScrollingDown && state.isNavVisible) {
      setNavVisibility(false);
    } else if (!isScrollingDown && !state.isNavVisible) {
      setNavVisibility(true);
    }
  }

  void changeUserType(UserTypeEnum userType) {
    emit(state.copyWith(userType: userType, currentIndex: 0));
  }
}
