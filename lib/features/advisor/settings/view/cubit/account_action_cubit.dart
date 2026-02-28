import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/advisor/settings/view/account_management_view.dart';

class AccountActionCubit extends Cubit<AccountAction?> {
  AccountActionCubit() : super(null);

  void selectAction(AccountAction action) {
    emit(action);
  }

  void clearSelection() {
    emit(null);
  }
}
