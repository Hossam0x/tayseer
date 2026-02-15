import 'package:flutter_bloc/flutter_bloc.dart';

class PackageTypeCubit extends Cubit<String> {
  PackageTypeCubit() : super('comprehensive');

  void selectType(String type) => emit(type);
}
