import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/shared/force_update/data/repo/force_update_repo.dart';

part 'force_update_state.dart';

class ForceUpdateCubit extends Cubit<ForceUpdateState> {
  final ForceUpdateRepo _repo;

  ForceUpdateCubit(this._repo) : super(const ForceUpdateInitial());

  Future<void> checkForUpdate() async {
    emit(const ForceUpdateChecking());

    final required = await _repo.isUpdateRequired();

    if (required) {
      final storeUrl = await _repo.getStoreUrl();
      emit(ForceUpdateRequired(storeUrl: storeUrl));
    } else {
      emit(const ForceUpdateNotRequired());
    }
  }
}
