import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/shared/packages/data/models/new_advisor_sub_model.dart';
import 'package:tayseer/features/shared/packages/domain/entities/package_type.dart';
import '../../../../advisor/settings/data/repositories/advisor_packages_repository.dart';

enum SelectedPackage { basic, pro, elite }

class PackagesState {
  final SelectedPackage selectedPackage;
  final List<NewAdvisorSubModel> subscriptions;
  final bool isLoading;
  final String? errorMessage;

  PackagesState({
    required this.selectedPackage,
    this.subscriptions = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  PackagesState copyWith({
    SelectedPackage? selectedPackage,
    List<NewAdvisorSubModel>? subscriptions,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PackagesState(
      selectedPackage: selectedPackage ?? this.selectedPackage,
      subscriptions: subscriptions ?? this.subscriptions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class PackagesCubit extends Cubit<PackagesState> {
  final AdvisorPackagesRepository _repository;

  PackagesCubit(this._repository)
    : super(PackagesState(selectedPackage: SelectedPackage.basic));

  Future<void> getPackages() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _repository.getPackages();
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (subs) => emit(state.copyWith(isLoading: false, subscriptions: subs)),
    );
  }

  /// يرجع الـ PackageType اللي المستخدم مشترك فيها حالياً (null لو مفيش)
  PackageType? get currentSubscribedPackage {
    if (state.subscriptions.isEmpty) return null;
    final current = state.subscriptions
        .where((s) => s.isCurrentSub)
        .firstOrNull;
    if (current == null) return null;
    if (current.subscriptionType == 'gold') return PackageType.pro;
    if (current.subscriptionType == 'ultra') return PackageType.elite;
    return null;
  }
}
