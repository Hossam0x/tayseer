import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/functions/country_helper.dart';
import 'packages_cubit.dart';

class AdvisorSubscriptionState {
  final int selectedDurationIndex;
  final bool useWallet;
  final SelectedPackage packageType;

  AdvisorSubscriptionState({
    this.selectedDurationIndex = 1,
    this.useWallet = false,
    required this.packageType,
  });

  AdvisorSubscriptionState copyWith({
    int? selectedDurationIndex,
    bool? useWallet,
    SelectedPackage? packageType,
  }) {
    return AdvisorSubscriptionState(
      selectedDurationIndex:
          selectedDurationIndex ?? this.selectedDurationIndex,
      useWallet: useWallet ?? this.useWallet,
      packageType: packageType ?? this.packageType,
    );
  }
}

class AdvisorSubscriptionCubit extends Cubit<AdvisorSubscriptionState> {
  AdvisorSubscriptionCubit(SelectedPackage packageType)
    : super(AdvisorSubscriptionState(packageType: packageType));

  void selectDuration(int index) {
    emit(state.copyWith(selectedDurationIndex: index));
  }

  void toggleWallet(bool value) {
    emit(state.copyWith(useWallet: value));
  }

  List<SubscriptionPriceData> getPricing() {
    final bool gulf = isGulfGroup();
    final bool isElite = state.packageType == SelectedPackage.elite;

    if (gulf) {
      if (isElite) {
        return [
          SubscriptionPriceData(months: 1, price: 399, discount: 0),
          SubscriptionPriceData(months: 3, price: 1077, discount: 10),
          SubscriptionPriceData(months: 6, price: 1914, discount: 20),
        ];
      } else {
        return [
          SubscriptionPriceData(months: 1, price: 200, discount: 0),
          SubscriptionPriceData(months: 3, price: 540, discount: 10),
          SubscriptionPriceData(months: 6, price: 960, discount: 20),
        ];
      }
    } else {
      // Egypt
      if (isElite) {
        return [
          SubscriptionPriceData(months: 1, price: 80, discount: 0),
          SubscriptionPriceData(months: 3, price: 216, discount: 10),
          SubscriptionPriceData(months: 6, price: 384, discount: 20),
        ];
      } else {
        return [
          SubscriptionPriceData(months: 1, price: 40, discount: 0),
          SubscriptionPriceData(months: 3, price: 108, discount: 10),
          SubscriptionPriceData(months: 6, price: 192, discount: 20),
        ];
      }
    }
  }
}

class SubscriptionPriceData {
  final int months;
  final num price;
  final int discount;

  SubscriptionPriceData({
    required this.months,
    required this.price,
    required this.discount,
  });
}
