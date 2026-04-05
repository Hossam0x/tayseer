import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/utils/subscription_event_bus.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/profile_visitors_repo.dart';
import 'profile_visitors_state.dart';

class ProfileVisitorsCubit extends Cubit<ProfileVisitorsState> {
  final ProfileVisitorsRepo repo;
  late final StreamSubscription<SubscriptionChangedEvent> _subSubscription;

  ProfileVisitorsCubit(this.repo) : super(ProfileVisitorsInitial()) {
    _subSubscription = SubscriptionEventBus.instance.onSubscriptionChanged
        .listen((_) {
          if (isClosed) return;
          fetchVisitors();
        });
  }

  Future<void> fetchVisitors() async {
    emit(ProfileVisitorsLoading());
    final result = await repo.getProfileVisitors();
    result.fold(
      (failure) => emit(ProfileVisitorsFailure(failure.message)),
      (data) => emit(
        ProfileVisitorsSuccess(
          visitors: data.visitors,
          isSubscribed: data.isSubscribed,
          subscriptionType: data.subscriptionType,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _subSubscription.cancel();
    return super.close();
  }
}
