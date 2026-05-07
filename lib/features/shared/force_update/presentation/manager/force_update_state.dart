part of 'force_update_cubit.dart';

abstract class ForceUpdateState extends Equatable {
  const ForceUpdateState();

  @override
  List<Object?> get props => [];
}

class ForceUpdateInitial extends ForceUpdateState {
  const ForceUpdateInitial();
}

class ForceUpdateChecking extends ForceUpdateState {
  const ForceUpdateChecking();
}

class ForceUpdateRequired extends ForceUpdateState {
  final String storeUrl;
  const ForceUpdateRequired({required this.storeUrl});

  @override
  List<Object?> get props => [storeUrl];
}

class ForceUpdateNotRequired extends ForceUpdateState {
  const ForceUpdateNotRequired();
}
