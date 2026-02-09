import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/advisor/profille/data/repo/profile_visitors_repo.dart';
import 'profile_visitors_state.dart';

class ProfileVisitorsCubit extends Cubit<ProfileVisitorsState> {
  final ProfileVisitorsRepo repo;

  ProfileVisitorsCubit(this.repo) : super(ProfileVisitorsInitial());

  Future<void> fetchVisitors() async {
    emit(ProfileVisitorsLoading());
    final result = await repo.getProfileVisitors();
    result.fold(
      (failure) => emit(ProfileVisitorsFailure(failure.message)),
      (data) => emit(
        ProfileVisitorsSuccess(
          visitors: data.visitors,
          isSubscribed: data.isSubscribed,
        ),
      ),
    );
  }
}
